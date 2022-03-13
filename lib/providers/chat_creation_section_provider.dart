import 'package:flutter/material.dart';
import 'package:generation/services/device_specific_operations.dart';

class ChatCreationSectionProvider extends ChangeNotifier{
  double _sectionHeight = 60;
  bool _isEmojiActivated = false;

  getEmojiActivationState() => _isEmojiActivated;

  updateEmojiActivationState(bool newState){
    _isEmojiActivated = newState;
    notifyListeners();
  }

  getSectionHeight() => _sectionHeight;

  setSectionHeight(){
    if(_sectionHeight > 60) return;
    _sectionHeight += 260;
    _isEmojiActivated = true;
    hideKeyboard();
    notifyListeners();
  }

  backToNormalHeight(){
    if(_sectionHeight == 60) return;
    _sectionHeight -= 260;
    _isEmojiActivated = false;
    showKeyboard();
    notifyListeners();
  }
}