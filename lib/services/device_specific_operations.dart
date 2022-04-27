import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:generation/config/colors_collection.dart';

void showStatusAndNavigationBar() =>
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);

void changeSystemNavigationAndStatusBarColor(
        {Color navigationBarColor = Colors.white,
        Color statusBarColor = Colors.white,
        Brightness? statusIconBrightness = Brightness.light,
        Brightness? navigationIconBrightness = Brightness.light}) =>
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: navigationBarColor, // navigation bar color
      statusBarColor: statusBarColor, // status bar color
      statusBarIconBrightness: statusIconBrightness,
      systemNavigationBarIconBrightness: navigationIconBrightness,
    ));

void onlyShowStatusBar() =>
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);

void hideStatusAndNavigationBar() =>
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

void changeOnlyStatusBarColor(
        {Color statusBarColor = AppColors.splashScreenColor}) =>
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: statusBarColor, // status bar color
    ));

void changeOnlyNavigationBarColor(
        {Color navigationBarColor = AppColors.splashScreenColor}) =>
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: navigationBarColor, // navigation bar color
    ));

void makeStatusBarTransparent() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // status bar color
  ));
}

void makeScreenCleanView(
    {Color navigationBarColor = AppColors.splashScreenColor}) {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: navigationBarColor,
    statusBarColor: Colors.transparent, // status bar color
  ));
}

void hideKeyboard() => SystemChannels.textInput.invokeMethod('TextInput.hide');

void showKeyboard() => SystemChannels.textInput.invokeMethod('TextInput.show');

makeNavigationBarTransparent() =>
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light));

makeScreenStrictPortrait() => SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp,
      ],
    );

makeFullScreen() =>
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

closeFullScreen() =>
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

changeContextTheme(bool dark) =>
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor:
            dark ? AppColors.backgroundDarkMode : AppColors.backgroundLightMode,
        systemNavigationBarColor:
            dark ? AppColors.backgroundDarkMode : AppColors.backgroundLightMode,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        systemNavigationBarIconBrightness:
            dark ? Brightness.light : Brightness.dark));

changeOnlyIconBrightness(bool dark) =>
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        systemNavigationBarIconBrightness:
            dark ? Brightness.light : Brightness.dark));

changeOnlyContextChatColor(bool dark) =>  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor:
    dark ? AppColors.chatDarkBackgroundColor : AppColors.chatLightBackgroundColor,
    systemNavigationBarColor:
    dark ? AppColors.chatDarkBackgroundColor : AppColors.chatLightBackgroundColor,
    statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
    systemNavigationBarIconBrightness:
    dark ? Brightness.light : Brightness.dark));

closeYourApp() => SystemNavigator.pop();
