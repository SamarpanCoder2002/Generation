import 'package:flutter/material.dart';

class SizeManagementProvider extends ChangeNotifier {
  static double kBottomNavigationBarHeight = 60.0;

  getBottomNavigationBarHeight() => kBottomNavigationBarHeight;

  increaseBottomNavigationBarHeight() {
    if (kBottomNavigationBarHeight < 105) {
      kBottomNavigationBarHeight += 45;
      //notifyListeners();
    }
  }

  decreaseBottomNavigationBarHeight() {
    if (kBottomNavigationBarHeight > 60) {
      kBottomNavigationBarHeight -= 45;
      notifyListeners();
    }
  }
}
