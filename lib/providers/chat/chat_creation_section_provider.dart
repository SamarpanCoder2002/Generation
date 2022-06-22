import 'package:flutter/material.dart';
import 'package:generation/services/device_specific_operations.dart';

class ChatCreationSectionProvider extends ChangeNotifier {
  double _sectionHeight = 60;
  bool _isEmojiActivated = false;

  getEmojiActivationState() => _isEmojiActivated;

  updateEmojiActivationState(bool newState) {
    _isEmojiActivated = newState;
    notifyListeners();
  }

  getSectionHeight(context) => _sectionHeight;

  setSectionHeightForEmoji() {
    if (_sectionHeight > 60) return;
    _sectionHeight += 260;
    _isEmojiActivated = true;
    hideKeyboard();
    notifyListeners();
  }

  backToNormalHeightForEmoji() {
    if (_sectionHeight == 60 || _sectionHeight == 60 + 45) return;
    _sectionHeight -= 260;
    _isEmojiActivated = false;
    showKeyboard();
    notifyListeners();
  }

  setSectionHeightForReply() {
    if (_sectionHeight > 60) return;
    _sectionHeight += 70;
    notifyListeners();
  }

  backToNormalHeightForReply() {
    if (_sectionHeight == 60) return;
    _sectionHeight -= 70;
    notifyListeners();
  }
}
