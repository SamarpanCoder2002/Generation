import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:http/http.dart';

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

changeOnlyContextChatColor(bool dark) =>
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: dark
            ? AppColors.chatDarkBackgroundColor
            : AppColors.chatLightBackgroundColor,
        systemNavigationBarColor: dark
            ? AppColors.chatDarkBackgroundColor
            : AppColors.chatLightBackgroundColor,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        systemNavigationBarIconBrightness:
            dark ? Brightness.light : Brightness.dark));

closeYourApp() => SystemNavigator.pop();

class NotificationManagement {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings _androidInitializationSettings =
      const AndroidInitializationSettings('app_icon');

  NotificationManagement() {
    final InitializationSettings _initializationSettings =
        InitializationSettings(android: _androidInitializationSettings);

    _initAll(_initializationSettings);
  }

  _initAll(InitializationSettings initializationSettings) async {
    final response = await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings, onSelectNotification: (payload) async {
      print("Payload is: $payload");
    });

    print('Local Notification Initialization Status: $response');
  }

  showNotification(
      {required String title, required String body, String? image}) async {
    try {
      BigPictureStyleInformation? bigPictureStyleInformation;

      if (image != null) {
        final ByteArrayAndroidBitmap bigPicture =
            ByteArrayAndroidBitmap(await _getByteArrayFromUrl(image));

        bigPictureStyleInformation = BigPictureStyleInformation(bigPicture,
            htmlFormatContentTitle: true, htmlFormatSummaryText: true);
      }

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
              "high_importance_channel", "FLUTTER_NOTIFICATION_CLICK",
              importance: Importance.max,
              priority: Priority.max,
              styleInformation: bigPictureStyleInformation);

      final NotificationDetails generalNotificationDetails =
          NotificationDetails(android: androidDetails);

      await _flutterLocalNotificationsPlugin
          .show(0, title, body, generalNotificationDetails, payload: title);
    } catch (e) {
      print("Notification Showing Error: $e");
    }
  }

  Future<Uint8List> _getByteArrayFromUrl(String url) async {
    final Response response = await get(Uri.parse(url));
    return response.bodyBytes;
  }
}
