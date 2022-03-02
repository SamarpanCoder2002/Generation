import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:generation/config/stored_string_collection.dart';

import '../services/local_data_management.dart';
import '../types/types.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeModeTypes _themeModeType = ThemeModeTypes.lightMode;

  ThemeProvider() {
    _initialization();
  }

  _initialization() {
    DataManagement.getStringData(StoredString.themeKey).then((getThemeMode) {
      _themeModeType = _getPerfectTheme(getThemeMode);
      notifyListeners();
    });
  }

  ThemeModeTypes getCurrentTheme() {
    if (_themeModeType == ThemeModeTypes.systemMode) return _forSystemMode();
    return _themeModeType;
  }

  setCurrentTheme(ThemeModeTypes themeModeTypes) {
    _themeModeType = themeModeTypes;
    notifyListeners();
    DataManagement.storeStringData(
        StoredString.themeKey, themeModeTypes.toString());
  }

  getThemeDataValidation(ThemeModeTypes incomingThemeModeType) =>
      incomingThemeModeType == _themeModeType;

  _getPerfectTheme(examineThemeData) {
    if (examineThemeData == ThemeModeTypes.darkMode.toString()) {
      return ThemeModeTypes.darkMode;
    } else if (examineThemeData == ThemeModeTypes.systemMode.toString()) {
      return ThemeModeTypes.systemMode;
    } else if (examineThemeData == ThemeModeTypes.lightMode.toString()) {
      return ThemeModeTypes.lightMode;
    } else {
      return _forSystemMode();
    }
  }

  _forSystemMode() {
    final Brightness brightness =
        SchedulerBinding.instance!.window.platformBrightness;
    return brightness == Brightness.dark
        ? ThemeModeTypes.darkMode
        : ThemeModeTypes.lightMode;
  }
}
