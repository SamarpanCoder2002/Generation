import 'package:flutter/material.dart';

import '../model/chat_message_model.dart';

class MainScreenNavigationProvider extends ChangeNotifier{
  int _currentScreenIndex = 0;
  List<ChatMessageModel> _incomingData = [];
  String _localVersion = '';

  setLocalVersion(String localVersion){
    _localVersion = localVersion;
    notifyListeners();
  }

  get getLocalVersion => _localVersion;

  setUpdatedIndex(updatedIndex){
    _currentScreenIndex = updatedIndex;
    notifyListeners();
  }

  getUpdatedIndex() => _currentScreenIndex;

  setIncomingData(List<ChatMessageModel> incomingData){
    _incomingData = incomingData;
    notifyListeners();
  }

  List<ChatMessageModel> getIncomingData() => _incomingData;
}