import 'package:flutter/material.dart';

class MainScreenNavigationProvider extends ChangeNotifier{
  int _currentScreenIndex = 0;

  setUpdatedIndex(updatedIndex){
    _currentScreenIndex = updatedIndex;
    notifyListeners();
  }

  getUpdatedIndex() => _currentScreenIndex;
}