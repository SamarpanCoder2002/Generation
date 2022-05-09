import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/db_operations/helper.dart';
import 'package:generation/db_operations/types.dart';
import 'package:generation/providers/connection_collection_provider.dart';
import 'package:generation/services/directory_management.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import '../../config/text_collection.dart';
import '../../services/local_data_management.dart';
import '../../types/types.dart';
import 'chat_scroll_provider.dart';

class ChatBoxMessagingProvider extends ChangeNotifier {
  List<dynamic> _messageData = [];
  TextEditingController? _messageController;
  MessageHolderType _messageHolderType = MessageHolderType.me;
  bool _showVoiceIcon = true;
  final Map<String, dynamic> _selectedMessage = {};
  String _partnerUserId = "";
  StreamSubscription? _realTimeMessagingSubscription;
  StreamSubscription? _realTimeConnSubscription;
  late BuildContext context;
  Map<String, dynamic> _currStatus = {};

  FocusNode _focus = FocusNode();
  final LocalStorage _localStorage = LocalStorage();
  final DBOperations _dbOperations = DBOperations();
  final RealTimeOperations _realTimeOperations = RealTimeOperations();
  final Dio _dio = Dio();

  setContext(context) {
    this.context = context;
  }

  getContext() => context;

  getMessagesRealtime(String partnerId) {
    _realTimeMessagingSubscription =
        _realTimeOperations.getChatMessages(partnerId).listen((docSnapShot) {
      final _docData = docSnapShot.data();

      if (_docData != null &&
          _docData.isNotEmpty &&
          _docData["data"].isNotEmpty) {
        print("Document Data is: ${_docData["data"]}\n\n");

        _manageIncomingMessages(_docData["data"]);

        _dbOperations.resetRemoteOldChatMessages(partnerId);
      }
    });
  }

  getConnectionDataRealTime(String partnerId, BuildContext context) {
    _realTimeConnSubscription =
        _realTimeOperations.getConnectionData(partnerId).listen((docSnapShot) {
      final _docData = docSnapShot.data();

      if (_docData != null && _docData.isNotEmpty) {
        setCurrStatus(_docData[DBPath.status] ?? {});

        _localStorage.insertUpdateConnectionPrimaryData(
            id: _docData["id"],
            name: _docData["name"],
            profilePic: _docData["profilePic"],
            about: _docData["about"],
            notificationType: _docData["notification"],
            dbOperation: DBOperation.update);
        Provider.of<ConnectionCollectionProvider>(context, listen: false)
            .updateParticularConnectionData(_docData["id"], _docData);
      }
    });
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
      _mediaStorePath = createImageFile(dirPath: _dirPath);
    } else if (_msgType == ChatMessageType.video.toString()) {
      final _dirPath = await createVideoStoreDir();
      _mediaStorePath = createVideoFile(dirPath: _dirPath);
    } else if (_msgType == ChatMessageType.audio.toString()) {
      final _dirPath = await createVoiceStoreDir();
      _mediaStorePath = createAudioFile(dirPath: _dirPath);
    } else if (_msgType == ChatMessageType.document.toString()) {
      final _dirPath = await createDocStoreDir();
      _mediaStorePath = createDocFile(
          dirPath: _dirPath,
          extension: _msgAdditionalData["extension-for-document"]);
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
    final _thumbnailPath = createImageFile(dirPath: _dirPath);

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
    notifyListeners();
    _removePartnerId();
  }

  setPartnerUserId(String partnerUserId, {bool update = false}) {
    _partnerUserId = partnerUserId;
    if (update) notifyListeners();
  }

  getPartnerUserId() => _partnerUserId;

  _removePartnerId() {
    _partnerUserId = "";
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
      _focus.hasFocus &&
      WidgetsBinding.instance!.window.viewInsets.bottom > 0.0;

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
      {required String msgType, required message, additionalData}) async {
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
    _manageMessageForLocale(_msgLocalData);

    /// ---------------------------------------------------------- ///

    /// Remote Data Management
    _manageMessageForRemote(
        message: message,
        msgType: msgType,
        additionalData: additionalData,
        uniqueMsgId: _uniqueMsgId,
        msgTime: _msgTime,
        msgDate: _msgDate);
  }

  /// Making Message Data Ready For Local
  void _manageMessageForLocale(_msgData) {
    print("Message Data to Stoer: $_msgData");

    setSingleNewMessage(_msgData);

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
        dbOperation: DBOperation.insert);
  }

  /// Making Message Data Ready For Remote
  void _manageMessageForRemote(
      {required message,
      required msgType,
      required additionalData,
      required uniqueMsgId,
      required msgTime,
      required msgDate}) async {
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

    _dbOperations.sendMessage(
        partnerId: getPartnerUserId(), msgData: _msgRemoteData);
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
}
