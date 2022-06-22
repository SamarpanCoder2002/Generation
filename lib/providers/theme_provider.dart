import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:generation/config/stored_string_collection.dart';

import '../services/debugging.dart';
import '../services/local_data_management.dart';
import '../config/types.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeModeTypes _themeModeType = ThemeModeTypes.systemMode;

  initialization() async {
    final extractedTheme =
        await DataManagement.getStringData(StoredString.themeKey);
    await setThemeData(_filtration(extractedTheme));
  }

  setThemeData(ThemeModeTypes themeModeType) async {
    debugShow("Theme Mode Type: $themeModeType");
    if (_themeModeType == themeModeType) return;

    _themeModeType = themeModeType;
    await DataManagement.storeStringData(
        StoredString.themeKey, themeModeType.toString());
    notifyListeners();
    return isDarkTheme();
  }

  _filtration(String? examineThemeData) {
    debugShow("Examine Theme Data: $examineThemeData");
    if (examineThemeData == null) return ThemeModeTypes.systemMode;

    if (examineThemeData == ThemeModeTypes.systemMode.toString()) {
      return ThemeModeTypes.systemMode;
    } else if (examineThemeData == ThemeModeTypes.lightMode.toString()) {
      return ThemeModeTypes.lightMode;
    } else if (examineThemeData == ThemeModeTypes.darkMode.toString()) {
      return ThemeModeTypes.darkMode;
    }
  }

  isThatCurrentTheme(ThemeModeTypes themeModeType) =>
      _themeModeType == themeModeType;

  bool isDarkTheme() {
    if (_themeModeType == ThemeModeTypes.darkMode) return true;
    if (_themeModeType == ThemeModeTypes.lightMode) return false;

    final Brightness brightness =
        SchedulerBinding.instance.window.platformBrightness;

    return brightness == Brightness.dark;
  }
}
