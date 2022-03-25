import 'package:flutter/material.dart';

class TimeProvider extends ChangeNotifier {
  int _durationInSecActivity = 5;

  getDurationForActivity() => _durationInSecActivity;

  updateActivityDuration(int incoming) {
    if (_durationInSecActivity == incoming) return;
    _durationInSecActivity = incoming;
    notifyListeners();
  }
}
