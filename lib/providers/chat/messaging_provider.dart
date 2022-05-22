import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:generation/config/stored_string_collection.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/db_operations/helper.dart';
import 'package:generation/db_operations/types.dart';
import 'package:generation/model/chat_message_model.dart';
import 'package:generation/providers/connection_collection_provider.dart';
import 'package:generation/services/directory_management.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import '../../config/text_collection.dart';
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
  late BuildContext context;
  Map<String, dynamic> _currStatus = {};
  Map<String, ChatMessageModel?> _replyHolderMsg = {};
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

  popUpScreen(){
    try{
      Navigator.pop(context);
    }catch(e){
      print("Error in Pop Up Screen:  $e");
    }
  }

  Map<String, ChatMessageModel?> getReplyHolderMsg() => _replyHolderMsg;

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
          setCurrStatus(_docData[DBPath.status] ?? {});

          _localStorage.insertUpdateConnectionPrimaryData(
              id: _docData["id"],
              name: _docData["name"],
              profilePic: _docData["profilePic"],
              about: _docData["about"],
              notificationTypeManually: _docData["notificationManually"],
              dbOperation: DBOperation.update);
          Provider.of<ConnectionCollectionProvider>(context, listen: false)
              .updateParticularConnectionData(_docData["id"], _docData);
        }
      }
    });
  }

  setToken(String token) {
    _connToken = token;
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
    for (final message in messages) {
      _manageMessageForLocale(message);
      final _msgType = message.values.toList()[0][MessageData.type];
      if (_msgType != ChatMessageType.text.toString() &&
          _msgType != ChatMessageType.location.toString() &&
          _msgType != ChatMessageType.contact.toString()) {
        _downloadMediaContent(message);
      }
    }
  }

  _downloadMediaContent(message) async {
    final _message = message.values.toList()[0];
    final _msgData = _message[MessageData.message];
    final _msgType = _message[MessageData.type];
    final _msgAdditionalData = _message[MessageData.additionalData] == null
        ? {}
        : DataManagement.fromJsonString(_message[MessageData.additionalData]);

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

    print("Media Message Data is:   $_mediaStorePath\n\n");

    _dio.download(_msgData, _mediaStorePath).whenComplete(() async {
      print("Media Download Completed");
      message.values.toList()[0][MessageData.message] = _mediaStorePath;
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

    _dio
        .download(_msgAdditionalData["thumbnail"], _thumbnailPath)
        .whenComplete(() {
      print("Thumbnail Download Completed");
      _msgAdditionalData["thumbnail"] = _thumbnailPath;
      message.values.toList()[0][MessageData.additionalData] =
          DataManagement.toJsonString(_msgAdditionalData);

      _dbOperations
          .deleteMediaFromFirebaseStorage(_msgAdditionalData["thumbnail"]);

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
    debugPrint("Focus: ${_focus.hasFocus.toString()}");
  }

  setSingleNewMessage(incomingMessageSet) {
    _messageData.add(incomingMessageSet);
    Provider.of<ChatScrollProvider>(context, listen: false).animateToBottom();
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

  clearSelectedMsgCollection() {
    _selectedMessage.clear();
    notifyListeners();
  }

  sendMsgManagement(
      {required String msgType,
      required message,
      additionalData,
      bool forSendMultiple = false,
      String? incomingConnId}) async {
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
        MessageData.type: msgType,
        MessageData.message: _localMsgModify,
        MessageData.time: _msgTime,
        MessageData.date: _msgDate,
        MessageData.holder: getMessageHolderForSendMsg(SendMsgStorage.local),
        MessageData.additionalData: additionalData != null
            ? DataManagement.toJsonString(additionalData)
            : additionalData
      }
    };
    _manageMessageForLocale(_msgLocalData,
        forSendMultiple: forSendMultiple, incomingConnId: incomingConnId);

    /// ---------------------------------------------------------- ///

    /// Remote Data Management
    _manageMessageForRemote(
        message: message,
        msgType: msgType,
        additionalData: additionalData,
        uniqueMsgId: _uniqueMsgId,
        msgTime: _msgTime,
        msgDate: _msgDate,
        forSendMultiple: forSendMultiple,
        incomingConnId: incomingConnId);
  }

  /// Making Message Data Ready For Local
  void _manageMessageForLocale(_msgData,
      {bool forSendMultiple = false, String? incomingConnId}) {
    if (!forSendMultiple) setSingleNewMessage(_msgData);

    _localStorage.insertUpdateMsgUnderConnectionChatTable(
        chatConTableName: DataManagement.generateTableNameForNewConnectionChat(
            !forSendMultiple ? getPartnerUserId() : incomingConnId),
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
      bool forSendMultiple = false,
      String? incomingConnId}) async {
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
        MessageData.type: msgType,
        MessageData.message: _remoteMsg,
        MessageData.time: msgTime,
        MessageData.date: msgDate,
        MessageData.holder: getMessageHolderForSendMsg(SendMsgStorage.remote),
        MessageData.additionalData: _additionalDataModified != null
            ? DataManagement.toJsonString(_additionalDataModified)
            : _additionalDataModified
      }
    };

    final _notificationData = _rendererForNotification(msgType, _remoteMsg);

    _dbOperations.sendMessage(
        partnerId: !forSendMultiple ? getPartnerUserId() : incomingConnId,
        msgData: _msgRemoteData,
        token: getToken(),
        title: _notificationData['title'],
        body: _notificationData['body'],
        image: _notificationData['image']);
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
      if (message['type'] == ChatMessageType.image.toString()) {
        (_chatHistoryData[ChatMessageType.image] as List<dynamic>).add(message);
      } else if (message['type'] == ChatMessageType.video.toString()) {
        (_chatHistoryData[ChatMessageType.video] as List<dynamic>).add(message);
      } else if (message['type'] == ChatMessageType.audio.toString()) {
        (_chatHistoryData[ChatMessageType.audio] as List<dynamic>).add(message);
      } else if (message['type'] == ChatMessageType.document.toString()) {
        (_chatHistoryData[ChatMessageType.document] as List<dynamic>)
            .add(message);
      } else if (message['type'] == ChatMessageType.location.toString()) {
        (_chatHistoryData[ChatMessageType.location] as List<dynamic>)
            .add(message);
      } else if (message['type'] == ChatMessageType.contact.toString()) {
        (_chatHistoryData[ChatMessageType.contact] as List<dynamic>)
            .add(message);
      }

      (_chatHistoryData[ChatMessageType.text] as List<dynamic>).add(
          """${message['holder'] == MessageHolderType.me.toString() ? 'You' : connName ?? ''}:  ${message['type'] == ChatMessageType.text.toString() ? message['message'] : '<Non-Text-File>'}\n\n""");
    }

    return _chatHistoryData;
  }

  Map<String, dynamic> _rendererForNotification(
      String _msgType, String msgData) {
    final _currUserName =
        Provider.of<ConnectionCollectionProvider>(context, listen: false)
            .getCurrAccData()['name'];
    Map<String, dynamic> _notificationData = {
      'title': """$_currUserName send you a """,
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
}
