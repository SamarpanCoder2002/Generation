import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../types/types.dart';

class ChatBoxMessagingProvider extends ChangeNotifier {
  List<dynamic> _messageData = [];
  TextEditingController? _messageController;
  FocusNode _focus = FocusNode();
  MessageHolderType _messageHolderType = MessageHolderType.me;
  bool _showVoiceIcon = true;

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

  getCurrentTime() => DateFormat('hh:mm a').format(DateTime.now());

  getChatMessagingSectionHeight(bool isKeyboardShowing, BuildContext context) =>
      isKeyboardShowing
          ? MediaQuery.of(context).size.height / 2.1
          : MediaQuery.of(context).size.height / 1.22;

  insertEmoji(String incomingEmojiData){
    _messageController!.text += incomingEmojiData;
    notifyListeners();
  }
}
