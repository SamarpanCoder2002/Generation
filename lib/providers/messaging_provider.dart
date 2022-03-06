import 'package:flutter/material.dart';

import '../types/types.dart';

class ChatBoxMessagingProvider extends ChangeNotifier{
  List<dynamic> _messageData = [];
  TextEditingController? _messageController;
  MessageHolderType _messageHolderType = MessageHolderType.me;

  getMessageHolderType(){
    if(_messageHolderType == MessageHolderType.me) {
      _messageHolderType = MessageHolderType.other;
    } else {
      _messageHolderType = MessageHolderType.me;
    }
    notifyListeners();
    return _messageHolderType;
  }

  getTextController() => _messageController;

  getMessagesData() => _messageData;

  getParticularMessage(index) => _messageData[index];

  getTotalMessages() => _messageData.length;

  setMessageData(incomingMessageData){
    _messageData = incomingMessageData;
    _messageController = TextEditingController();
  }

  setSingleNewMessage(incomingMessageSet){
    _messageData.add(incomingMessageSet);
    notifyListeners();
  }

  clearMessageData(){
    _messageData.clear();
    _messageController?.dispose();
  }
}