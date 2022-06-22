import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:generation/config/stored_string_collection.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/db_operations/config.dart';
import 'package:generation/db_operations/types.dart';
import 'package:generation/model/chat_message_model.dart';
import 'package:generation/providers/connection_collection_provider.dart';
import 'package:generation/providers/network_management_provider.dart';
import 'package:generation/services/directory_management.dart';
import 'package:generation/services/encryption_operations.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import '../../config/text_collection.dart';
import '../../services/debugging.dart';
import '../../services/local_data_management.dart';
import '../../config/types.dart';
import 'chat_scroll_provider.dart';

class ChatBoxMessagingProvider extends ChangeNotifier {
  List<dynamic> _messageData = [];
  TextEditingController? _messageController;
  MessageHolderType _messageHolderType = MessageHolderType.me;
  bool _showVoiceIcon = true;
  final Map<String, dynamic> _selectedMessage = {};
  String _partnerUserId = "";
  String _connToken = "";
  String _localWallpaperPath = '';
  StreamSubscription? _realTimeMessagingSubscription;
  StreamSubscription? _realTimeConnSubscription;
  StreamSubscription? _realTimeSpecialOperationSubscription;
  late BuildContext context;
  Map<String, dynamic> _currStatus = {};
  Map<String, dynamic> _replyHolderMsg = {};

//  Map<String, dynamic> _partnerData = {};

  FocusNode _focus = FocusNode();
  final LocalStorage _localStorage = LocalStorage();
  final DBOperations _dbOperations = DBOperations();
  final RealTimeOperations _realTimeOperations = RealTimeOperations();
  final Dio _dio = Dio();

  // setPartnerData(incoming, {bool update = false}) {
  //   _partnerData = incoming;
  //   if (update) notifyListeners();
  // }

  // Map<String, dynamic> getPartnerData() => _partnerData;
  //
  // _removePartnerData() {
  //   _partnerData.clear();
  //   notifyListeners();
  // }

  setContext(context) {
    this.context = context;
  }

  setReplyHolderMsg(String msgId, ChatMessageModel incoming) {
    _replyHolderMsg = {msgId: incoming};
    notifyListeners();
  }

  setReplyActivity(String activityId, String activityHolderId) {
    _replyHolderMsg = {
      "activityReply": true,
      "activityId": activityId,
      "activityHolderId": activityHolderId,
    };
    notifyListeners();
  }

  popUpScreen() {
    try {
      Navigator.pop(context);
    } catch (e) {
      debugShow("Error in Pop Up Screen:  $e");
    }
  }

  Map<String, dynamic> get getReplyHolderMsg => _replyHolderMsg;

  Map<String, dynamic> getReplyModifiedMsg() {
    if (_replyHolderMsg.isEmpty) return {};

    Map<String, dynamic> _msgData = {};

    final _msgId = _replyHolderMsg.keys.toList()[0];
    final _msgOldData = _replyHolderMsg.values.toList()[0];

    _msgData = {
      _msgId: {
        MessageData.holder: _msgOldData?.holder,
        MessageData.message: _msgOldData?.message,
        MessageData.type: _msgOldData?.type,
        MessageData.date: _msgOldData?.date,
        MessageData.time: _msgOldData?.time,
        MessageData.additionalData: _msgOldData?.additionalData
      }
    };

    return _msgData;
  }

  removeReplyMsg() {
    if (!isThereReplyMsg) return;
    _replyHolderMsg.clear();
    notifyListeners();
  }

  bool get isThereReplyMsg => _replyHolderMsg.isNotEmpty;

  getContext() => context;

  getConnectionWallpaper() => _localWallpaperPath;

  getMessagesRealtime(String partnerId) {
    _realTimeMessagingSubscription =
        _realTimeOperations.getChatMessages(partnerId).listen((docSnapShot) {
      final _docData = docSnapShot.data();

      if (_docData != null &&
          _docData.isNotEmpty &&
          _docData["data"].isNotEmpty) {
        _manageIncomingMessages(_docData["data"]);

        _dbOperations.resetRemoteOldChatMessages(partnerId);
      }
    });
  }

  getConnectionDataRealTime(String partnerId, BuildContext context) {
    _realTimeConnSubscription =
        _realTimeOperations.getConnectionData(partnerId).listen((docSnapShot) {
      final Map<String, dynamic>? _docData = docSnapShot.data();

      if (_docData != null) {
        setToken(_docData['token']);

        if (_docData.isNotEmpty) {
          debugShow('Sattus: ${Secure.decode(_docData[DBPath.status])}');
          setCurrStatus(DataManagement.fromJsonString(Secure.decode(_docData[DBPath.status])) ?? {});

          _localStorage.insertUpdateConnectionPrimaryData(
              id: _docData["id"],
              name: _docData["name"],
              profilePic: _docData["profilePic"],
              about: _docData["about"],
              dbOperation: DBOperation.update);
          Provider.of<ConnectionCollectionProvider>(context, listen: false)
              .updateParticularConnectionData(_docData["id"], _docData);
        }
      }
    });
  }

  getSpecialOperationDataRealTime(String partnerId) {
    _realTimeSpecialOperationSubscription = _realTimeOperations
        .getRealTimeSpecialOperationsData(partnerId)
        .listen((docSnapShot) {
      final Map<String, dynamic>? _docData = docSnapShot.data();

      debugShow('Doc Data is: $_docData');

      if (_docData == null) return;

      final _deletedMessages = _docData[SpecialOperationTypes.deleteMsg];
      _deleteSpecialOperationMessages(_deletedMessages, partnerId);
    });
  }

  _deleteSpecialOperationMessages(_deletedMessages, partnerId) async {
    if (_deletedMessages == null) return;

    for (final msgId in _deletedMessages) {
      await _localStorage.deleteDataFromParticularChatConnTable(
          tableName:
              DataManagement.generateTableNameForNewConnectionChat(partnerId),
          msgId: msgId);
      deleteParticularMessage(msgId);
    }

    _dbOperations.deleteSpecialOperationMsgIdSet(partnerId);
  }

  setToken(String token) {
    _connToken = Secure.decode(token);
    notifyListeners();
  }

  getToken() => _connToken;

  clearToken() {
    _connToken = '';
    notifyListeners();
  }

  setCurrStatus(Map<String, dynamic> updatedStatus) {
    _currStatus = updatedStatus;
    notifyListeners();
  }

  String getCurrStatus() {
    debugShow('curent Status: $_currStatus');

    if (_currStatus.isEmpty) return '';
    if (_currStatus["status"] == UserStatus.online.toString()) return 'Online';

    if (_currStatus["rawDate"] == null) {
      return 'Last Seen ${_currStatus["date"]} at ${_currStatus["time"]}';
    }

    var _dayShow = _currStatus["date"];
    final _incomingRawDate = DateTime.parse(_currStatus["rawDate"]);
    final _currDateTime = DateTime.now();

    if (_incomingRawDate.day == _currDateTime.day &&
        _incomingRawDate.month == _currDateTime.month &&
        _incomingRawDate.year == _currDateTime.year) {
      _dayShow = "today";
    } else if (_incomingRawDate.day ==
        _currDateTime.subtract(const Duration(days: 1)).day) {
      _dayShow = "yesterday";
    }

    return 'Last Seen $_dayShow at ${_currStatus["time"]}';
  }

  _manageIncomingMessages(messages) {
    for (var message in messages) {
      message = DataManagement.fromJsonString(Secure.decode(message));
      _manageMessageForLocale(message);
      final _msgType =
          Secure.decode(message.values.toList()[0][MessageData.type]);
      if (_msgType != ChatMessageType.text.toString() &&
          _msgType != ChatMessageType.location.toString() &&
          _msgType != ChatMessageType.contact.toString()) {
        _downloadMediaContent(message);
      }
    }
  }

  _downloadMediaContent(message) async {
    final _message = message.values.toList()[0];
    final _msgData = Secure.decode(_message[MessageData.message]);
    final _msgType = Secure.decode(_message[MessageData.type]);
    final _msgAdditionalData = _message[MessageData.additionalData] == null
        ? {}
        : DataManagement.fromJsonString(
            Secure.decode(_message[MessageData.additionalData]));

    String _mediaStorePath = "";

    if (_msgType == ChatMessageType.image.toString()) {
      final _dirPath = await createImageStoreDir();
      _mediaStorePath = createImageFile(
          dirPath: _dirPath, name: _msgData.toString().split('/').last);
    } else if (_msgType == ChatMessageType.video.toString()) {
      final _dirPath = await createVideoStoreDir();
      _mediaStorePath = createVideoFile(
          dirPath: _dirPath, name: _msgData.toString().split('/').last);
    } else if (_msgType == ChatMessageType.audio.toString()) {
      final _dirPath = await createVoiceStoreDir();
      _mediaStorePath = createAudioFile(
          dirPath: _dirPath, name: _msgData.toString().split('/').last);
    } else if (_msgType == ChatMessageType.document.toString()) {
      final _dirPath = await createDocStoreDir();
      _mediaStorePath = createDocFile(
          dirPath: _dirPath,
          extension: _msgAdditionalData["extension-for-document"],
          name: _msgData.toString().split('/').last);
    }

    debugShow("Media Message Data is:   $_mediaStorePath\n\n");

    _dio.download(_msgData, _mediaStorePath).whenComplete(() async {
      debugShow("Media Download Completed");
      message.values.toList()[0][MessageData.message] =
          Secure.encode(_mediaStorePath);
      _dbOperations.deleteMediaFromFirebaseStorage(_msgData);

      /// For Thumbnail Management
      if (_msgType == ChatMessageType.video.toString()) {
        _incomingMsgThumbnailManagement(_msgAdditionalData, message);
        return;
      }

      _updateInLocalStorage(message);
      _updateInTopLevel(message);
    });
  }

  _incomingMsgThumbnailManagement(_msgAdditionalData, message) async {
    final _dirPath = await createThumbnailStoreDir();
    final _thumbnailPath =
        createImageFile(dirPath: _dirPath, name: 'thumbnail');
    final _remoteThumbnailPath = _msgAdditionalData["thumbnail"];

    _dio
        .download(_msgAdditionalData["thumbnail"], _thumbnailPath)
        .whenComplete(() {
      debugShow("Thumbnail Download Completed");
      _msgAdditionalData["thumbnail"] = _thumbnailPath;
      message.values.toList()[0][MessageData.additionalData] =
          Secure.encode(DataManagement.toJsonString(_msgAdditionalData));

      _dbOperations
          .deleteMediaFromFirebaseStorage(_remoteThumbnailPath);

      _updateInLocalStorage(message);
      _updateInTopLevel(message);
    });
  }

  _updateInTopLevel(message) {
    for (var msg in _messageData) {
      if (msg.keys.toList()[0].toString() ==
          message.keys.toList()[0].toString()) {
        _messageData[_messageData.indexOf(msg)] = message;
        notifyListeners();
        break;
      }
    }
  }

  _updateInLocalStorage(_msgData) {
    _localStorage.insertUpdateMsgUnderConnectionChatTable(
        chatConTableName: DataManagement.generateTableNameForNewConnectionChat(
            getPartnerUserId()),
        id: _msgData.keys.toList()[0],
        holder: _msgData.values.toList()[0][MessageData.holder],
        message: _msgData.values.toList()[0][MessageData.message],
        date: _msgData.values.toList()[0][MessageData.date],
        time: _msgData.values.toList()[0][MessageData.time],
        type: _msgData.values.toList()[0][MessageData.type],
        additionalData: _msgData.values.toList()[0][MessageData.additionalData],
        dbOperation: DBOperation.update);
  }

  destroyRealTimeMessaging() {
    _realTimeMessagingSubscription?.cancel();
    _realTimeConnSubscription?.cancel();
    _realTimeSpecialOperationSubscription?.cancel();
    resetLocalWallpaper();
    clearToken();
    notifyListeners();
    _removePartnerId();
    //_removePartnerData();
    removeReplyMsg();
  }

  setPartnerUserId(String partnerUserId, {bool update = false}) {
    _partnerUserId = partnerUserId;
    if (update) notifyListeners();
    DataManagement.storeStringData(
        StoredString.currChatPartnerId, partnerUserId);
  }

  getPartnerUserId() => _partnerUserId;

  _removePartnerId() {
    _partnerUserId = "";
    DataManagement.storeStringData(StoredString.currChatPartnerId, '');
    notifyListeners();
  }

  showVoiceIcon() => _showVoiceIcon && _messageController!.text.isEmpty;

  getMessageHolderType() {
    if (_messageHolderType == MessageHolderType.me) {
      _messageHolderType = MessageHolderType.other;
    } else {
      _messageHolderType = MessageHolderType.me;
    }
    notifyListeners();
    return _messageHolderType;
  }

  getMessageHolderForSendMsg(SendMsgStorage sendMsgStorage) =>
      sendMsgStorage == SendMsgStorage.local
          ? MessageHolderType.me.toString()
          : MessageHolderType.other.toString();

  getTextController() => _messageController;

  getMessagesData() => _messageData;

  // getParticularMessage(index){
  //   final _particularData = _messageData[index];
  //   return ChatMessageModel.toJson(type: _particularData["type"], message: _particularData["message"], time: _particularData["time"], holder: _particularData["holder"], additionalData: _particularData["additionalData"]);
  // }

  getParticularMessage(index) => _messageData[index];

  getTotalMessages() => _messageData.length;

  getFocusNode() => _focus;

  hasTextFieldFocus(context) =>
      _focus.hasFocus && WidgetsBinding.instance.window.viewInsets.bottom > 0.0;

  unFocusNode() {
    _focus.unfocus();
    notifyListeners();
  }

  initialize() {
    _messageController = TextEditingController();
    _focus = FocusNode();
    _focus.addListener(_onFocusChange);
  }

  disposeMethod() {
    _messageController!.dispose();
  }

  setShowVoiceIcon(bool status) {
    _showVoiceIcon = status;
    notifyListeners();
  }

  setMessageData(incomingMessageData) {
    _messageData = incomingMessageData;
    notifyListeners();
  }

  void _onFocusChange() {
    debugShow("Focus: ${_focus.hasFocus.toString()}");
  }

  setSingleNewMessage(incomingMessageSet) {
    _messageData.add(incomingMessageSet);
    Provider.of<ChatScrollProvider>(context, listen: false).animateToBottom();
    notifyListeners();
  }

  deleteParticularMessage(msgId) {
    _messageData.removeWhere((element) => element.keys.toList()[0] == msgId);
    notifyListeners();
  }

  clearMessageData() {
    _messageData.clear();
    notifyListeners();
  }

  disposeTextFieldOperation() {
    _focus.removeListener(_onFocusChange);
    _messageController?.dispose();
    _focus.dispose();
  }

  clearTextFromMessageInputSection() {
    _messageController?.clear();
    notifyListeners();
  }

  getMsgUniqueId() =>
      '${_dbOperations.currUid}_${DateTime.now().toString().split(" ").join("_")}';

  getCurrentTime({DateTime? dateTime}) =>
      DateFormat('hh:mm a').format(dateTime ?? DateTime.now());

  getCurrentDate({DateTime? dateTime}) =>
      DateFormat('dd MMMM, yyyy').format(dateTime ?? DateTime.now());

  Map<String, dynamic> getLastSeenDateTime() {
    Map<String, dynamic> _dateTime = {};
    _dateTime["rawDate"] = DateTime.now().toString().split(" ").first;
    _dateTime["date"] = getCurrentDate();
    _dateTime["time"] = getCurrentTime();
    _dateTime["status"] = UserStatus.offline.toString();
    return _dateTime;
  }

  Map<String, dynamic> getOnlineStatus() {
    Map<String, dynamic> _dateTime = {};
    _dateTime["status"] = UserStatus.online.toString();
    return _dateTime;
  }

  getChatMessagingSectionHeight(bool isKeyboardShowing, BuildContext context) =>
      isKeyboardShowing
          ? MediaQuery.of(context).size.height / 2.1
          : MediaQuery.of(context).size.height / 1.22;

  insertEmoji(String incomingEmojiData) {
    _messageController!.text += incomingEmojiData;
    notifyListeners();
  }

  setSelectedMessage(messageId, messageData) {
    _selectedMessage[messageId] = messageData;
    notifyListeners();
  }

  Map<String, dynamic> getSelectedMessage() => _selectedMessage;

  removeSingleMessageSelection(messageId) {
    _selectedMessage.remove(messageId);
    notifyListeners();
  }

  bool eligibleForCopyTextSelMsg() {
    if (_selectedMessage.length > 1) return false;
    return _selectedMessage.values.toList()[0].type ==
        ChatMessageType.text.toString();
  }

  bool eligibleForDeleteForEveryOne() {
    for (ChatMessageModel msg in _selectedMessage.values.toList()) {
      debugShow('Message Type: ${msg.holder}');
      if (msg.holder == MessageHolderType.other.toString()) return false;
    }

    return true;
  }

  clearSelectedMsgCollection() {
    _selectedMessage.clear();
    notifyListeners();
  }

  sendMsgManagement(
      {required String msgType,
      required message,
      additionalData,
      bool forSendMultiple = false,
      bool storeOnMsgBox = true,
      String? incomingConnId}) async {
    try {
      if (!(await Provider.of<NetworkManagementProvider>(context, listen: false)
          .isNetworkActive)) {
        Provider.of<NetworkManagementProvider>(context, listen: false)
            .noNetworkMsg(context);
        return;
      }
    } catch (e) {
      debugShow('Error in network check: $e');
    }

    /// Collecting Message Corresponding Data
    final _uniqueMsgId = getMsgUniqueId();
    final _msgTime = getCurrentTime();
    final _msgDate = getCurrentDate();

    var _localMsgModify = message;
    if (msgType == ChatMessageType.contact.toString() ||
        msgType == ChatMessageType.location.toString()) {
      _localMsgModify = DataManagement.toJsonString(message);
    }

    /// Local Data Management
    final _msgLocalData = {
      _uniqueMsgId: {
        MessageData.type: Secure.encode(msgType),
        MessageData.message: Secure.encode(_localMsgModify),
        MessageData.time: Secure.encode(_msgTime),
        MessageData.date: Secure.encode(_msgDate),
        MessageData.holder:
            Secure.encode(getMessageHolderForSendMsg(SendMsgStorage.local)),
        MessageData.additionalData: additionalData != null
            ? Secure.encode(DataManagement.toJsonString(additionalData))
            : Secure.encode(additionalData)
      }
    };
    _manageMessageForLocale(_msgLocalData,
        forSendMultiple: forSendMultiple,
        incomingConnId: incomingConnId,
        storeOnMsgBox: storeOnMsgBox);

    /// ---------------------------------------------------------- ///

    /// Remote Data Management
    _manageMessageForRemote(
        message: message,
        msgType: msgType,
        additionalData: additionalData,
        uniqueMsgId: _uniqueMsgId,
        msgTime: _msgTime,
        msgDate: _msgDate,
        incomingConnId: incomingConnId);
  }

  /// Making Message Data Ready For Local
  void _manageMessageForLocale(_msgData,
      {bool forSendMultiple = false,
      String? incomingConnId,
      bool storeOnMsgBox = true}) {
    if (!forSendMultiple && storeOnMsgBox) setSingleNewMessage(_msgData);

    _localStorage.insertUpdateMsgUnderConnectionChatTable(
        chatConTableName: DataManagement.generateTableNameForNewConnectionChat(
            incomingConnId ?? getPartnerUserId()),
        id: _msgData.keys.toList()[0],
        holder: _msgData.values.toList()[0][MessageData.holder],
        message: _msgData.values.toList()[0][MessageData.message],
        date: _msgData.values.toList()[0][MessageData.date],
        time: _msgData.values.toList()[0][MessageData.time],
        type: _msgData.values.toList()[0][MessageData.type],
        additionalData: _msgData.values.toList()[0][MessageData.additionalData],
        dbOperation: DBOperation.insert);
  }

  /// Making Message Data Ready For Remote
  void _manageMessageForRemote(
      {required message,
      required msgType,
      required additionalData,
      required uniqueMsgId,
      required msgTime,
      required msgDate,
      String? incomingConnId}) async {
    bool _isNotificationPermitted = false;

    try {
      _isNotificationPermitted =
          Provider.of<ConnectionCollectionProvider>(context, listen: false)
              .notificationPermitted(incomingConnId ?? getPartnerUserId());

      debugShow("Is notification Permitted:  $_isNotificationPermitted");
    } catch (e) {
      debugShow('Error in manage message for remote: $e');
    }

    var _remoteMsg = message;
    if (msgType != ChatMessageType.text.toString() &&
        msgType != ChatMessageType.contact.toString() &&
        msgType != ChatMessageType.location.toString()) {
      _remoteMsg = await _dbOperations.uploadMediaToStorage(
          message.split("/").last, File(message),
          reference: _getStorageRef(msgType));
    }

    if (msgType == ChatMessageType.contact.toString() ||
        msgType == ChatMessageType.location.toString()) {
      _remoteMsg = DataManagement.toJsonString(message);
    }

    var _additionalDataModified = additionalData;
    if (msgType == ChatMessageType.video.toString()) {
      final _thumbnail = await _dbOperations.uploadMediaToStorage(
          _additionalDataModified["thumbnail"].split("/").last,
          File(_additionalDataModified["thumbnail"]),
          reference: _getStorageRef("thumbnail"));

      _additionalDataModified["thumbnail"] = _thumbnail;
    }

    final _msgRemoteData = {
      uniqueMsgId: {
        MessageData.type: Secure.encode(msgType),
        MessageData.message: Secure.encode(_remoteMsg),
        MessageData.time: Secure.encode(msgTime),
        MessageData.date: Secure.encode(msgDate),
        MessageData.holder:
            Secure.encode(getMessageHolderForSendMsg(SendMsgStorage.remote)),
        MessageData.additionalData: _additionalDataModified != null
            ? Secure.encode(
                DataManagement.toJsonString(_additionalDataModified))
            : Secure.encode(_additionalDataModified)
      }
    };

    Map<String, dynamic> _notificationData = {};

    try {
      _notificationData = _rendererForNotification(msgType, _remoteMsg);
    } catch (e) {
      debugShow('Error in Renderer For Notification: $e');
    }

    _dbOperations.sendMessage(
        partnerId: incomingConnId ?? getPartnerUserId(),
        msgData: _msgRemoteData,
        token: getToken(),
        title: _notificationData['title'] ?? '',
        body: _notificationData['body'] ?? '',
        image: _notificationData['image'],
        isNotificationPermitted: _isNotificationPermitted);
  }

  /// Get Chat Media Storage Reference
  String _getStorageRef(String msgType) {
    if (msgType == ChatMessageType.image.toString()) {
      return StorageHelper.chatImageRef(
          _dbOperations.currUid, getPartnerUserId());
    } else if (msgType == ChatMessageType.audio.toString()) {
      return StorageHelper.chatAudioRef(
          _dbOperations.currUid, getPartnerUserId());
    } else if (msgType == ChatMessageType.video.toString()) {
      return StorageHelper.chatVideoRef(
          _dbOperations.currUid, getPartnerUserId());
    } else if (msgType == ChatMessageType.document.toString()) {
      return StorageHelper.chatDocRef(
          _dbOperations.currUid, getPartnerUserId());
    } else if (msgType == "thumbnail") {
      return StorageHelper.chatVideoThumbnailRef(
          _dbOperations.currUid, getPartnerUserId());
    }

    return StorageHelper.otherRef;
  }

  getOldStoredChatMessages() {
    _localStorage
        .getOldChatMessages(
            tableName: DataManagement.generateTableNameForNewConnectionChat(
                getPartnerUserId()))
        .then((oldMessages) {
      if (oldMessages.isEmpty) {
        getMessagesRealtime(getPartnerUserId());
        return;
      }

      final _oldMessagesCollection = [];

      for (final message in oldMessages) {
        _oldMessagesCollection.add({message["id"]: message});
      }

      setMessageData(_oldMessagesCollection);

      getMessagesRealtime(getPartnerUserId());
    });
  }

  getChatWallpaperData(String partnerId, {String? newWallpaper}) async {
    if (newWallpaper != null) {
      _localWallpaperPath = newWallpaper;
      notifyListeners();
      return;
    }

    final _wallpaperData =
        await _localStorage.getParticularChatWallpaper(partnerId);
    if (_wallpaperData == null || _wallpaperData == null.toString()) return;
    _localWallpaperPath = _wallpaperData;
    notifyListeners();
  }

  void resetLocalWallpaper() {
    _localWallpaperPath = '';
    notifyListeners();
  }

  Future<Map<ChatMessageType, dynamic>> getChatHistory(
      String connId, String? connName) async {
    final _chatMessages = await _localStorage.getOldChatMessages(
        tableName:
            DataManagement.generateTableNameForNewConnectionChat(connId));
    final Map<ChatMessageType, dynamic> _chatHistoryData = {
      ChatMessageType.text: [],
      ChatMessageType.image: [],
      ChatMessageType.video: [],
      ChatMessageType.audio: [],
      ChatMessageType.document: [],
      ChatMessageType.location: [],
      ChatMessageType.contact: []
    };

    for (final message in _chatMessages) {
      if (Secure.decode(message['type'].toString()) ==
          ChatMessageType.image.toString()) {
        (_chatHistoryData[ChatMessageType.image] as List<dynamic>).add(message);
      } else if (Secure.decode(message['type'].toString()) ==
          ChatMessageType.video.toString()) {
        (_chatHistoryData[ChatMessageType.video] as List<dynamic>).add(message);
      } else if (Secure.decode(message['type'].toString()) ==
          ChatMessageType.audio.toString()) {
        (_chatHistoryData[ChatMessageType.audio] as List<dynamic>).add(message);
      } else if (Secure.decode(message['type'].toString()) ==
          ChatMessageType.document.toString()) {
        (_chatHistoryData[ChatMessageType.document] as List<dynamic>)
            .add(message);
      } else if (Secure.decode(message['type'].toString()) ==
          ChatMessageType.location.toString()) {
        (_chatHistoryData[ChatMessageType.location] as List<dynamic>)
            .add(message);
      } else if (Secure.decode(message['type'].toString()) ==
          ChatMessageType.contact.toString()) {
        (_chatHistoryData[ChatMessageType.contact] as List<dynamic>)
            .add(message);
      }

      (_chatHistoryData[ChatMessageType.text] as List<dynamic>).add(
          """${Secure.decode(message['holder'].toString()) == MessageHolderType.me.toString() ? 'You' : connName ?? ''}:  ${Secure.decode(message['type'].toString()) == ChatMessageType.text.toString() ? Secure.decode(message['message'].toString()) : '<Non-Text-File>'}\n\n""");
    }

    return _chatHistoryData;
  }

  Map<String, dynamic> _rendererForNotification(
      String _msgType, String msgData) {
    final _currUserName =
        Provider.of<ConnectionCollectionProvider>(context, listen: false)
            .getCurrAccData()['name'];
    Map<String, dynamic> _notificationData = {
      'title': """${Secure.decode(_currUserName)} send you a """,
      'body': '',
    };

    if (_msgType == ChatMessageType.text.toString()) {
      _notificationData['title'] += 'Message';
      _notificationData['body'] = msgData;
    } else if (_msgType == ChatMessageType.image.toString()) {
      _notificationData['title'] += 'Image';
      _notificationData['body'] = 'Expand to see the image';
      _notificationData['image'] = msgData;
    } else if (_msgType == ChatMessageType.video.toString()) {
      _notificationData['title'] += 'Video';
      _notificationData['body'] = "New Video File";
    } else if (_msgType == ChatMessageType.audio.toString()) {
      _notificationData['title'] += 'Audio';
      _notificationData['body'] = "New Audio File";
    } else if (_msgType == ChatMessageType.document.toString()) {
      _notificationData['title'] += 'Document';
      _notificationData['body'] = "New Document File";
    } else if (_msgType == ChatMessageType.location.toString()) {
      _notificationData['title'] += 'Location';
      _notificationData['body'] = '🗺️ Map';
    } else if (_msgType == ChatMessageType.contact.toString()) {
      _notificationData['title'] += 'Contact';
      _notificationData['body'] =
          DataManagement.fromJsonString(msgData)[PhoneNumberData.name];
    }

    return _notificationData;
  }

  Map<String, dynamic> getJson(msgId, ChatMessageModel msgData) => {
        msgId: {
          "id": msgId,
          "type": msgData.type,
          "holder": msgData.holder,
          "message": msgData.message,
          "date": msgData.date,
          "time": msgData.time,
          "additionalData": msgData.additionalData
        }
      };
}
