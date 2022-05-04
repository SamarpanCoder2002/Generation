import 'dart:io';

import 'package:flutter/material.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/db_operations/helper.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:intl/intl.dart';

import '../../config/text_collection.dart';
import '../../services/local_data_management.dart';
import '../../types/types.dart';

class ChatBoxMessagingProvider extends ChangeNotifier {
  List<dynamic> _messageData = [];
  TextEditingController? _messageController;
  FocusNode _focus = FocusNode();
  final LocalStorage _localStorage = LocalStorage();
  final DBOperations _dbOperations = DBOperations();
  MessageHolderType _messageHolderType = MessageHolderType.me;
  bool _showVoiceIcon = true;
  final Map<String, dynamic> _selectedMessage = {};
  String _partnerUserId = "";

  setPartnerUserId(String partnerUserId, {bool update = false}) {
    _partnerUserId = partnerUserId;
    if (update) notifyListeners();
  }

  getPartnerUserId() => _partnerUserId;

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
  }

  void _onFocusChange() {
    debugPrint("Focus: ${_focus.hasFocus.toString()}");
  }

  setSingleNewMessage(incomingMessageSet) {
    _messageData.add(incomingMessageSet);
    notifyListeners();
  }

  clearMessageData() {
    _messageData.clear();
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
  void _manageMessageForLocale(Map<dynamic, Map<String, dynamic>> _msgData) {
    setSingleNewMessage(_msgData);

    _localStorage.insertUpdateMsgUnderConnectionChatTable(
        chatConTableName: DataManagement.generateTableNameForNewConnectionChat(
            getPartnerUserId()),
        id: _msgData.keys.toList()[0],
        holder: _msgData.values.toList()[0][MessageData.holder],
        message: _msgData.values.toList()[0][MessageData.message],
        date: _msgData.values.toList()[0][MessageData.date],
        time: _msgData.values.toList()[0][MessageData.time],
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
}
