import 'package:flutter/material.dart';

class ConnectionManagementProvider extends ChangeNotifier{
  int _currentIndex = 0;

  setUpdatedIndex(incomingIndex){
    _currentIndex = incomingIndex;
    notifyListeners();
  }

  getCurrentIndex() => _currentIndex;
}