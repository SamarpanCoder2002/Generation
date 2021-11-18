import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:generation/BackendAndDatabaseManager/native_internal_call/native_call.dart';

import 'package:generation/FrontEnd/Introduction_Screen/intro_screen.dart';
import 'package:generation/FrontEnd/MainScreen/main_window.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:generation/BackendAndDatabaseManager/firebase_services/google_auth.dart';
import 'package:generation/BackendAndDatabaseManager/general_services/notification_configuration.dart';

final GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();

  /// Initialize Notification Settings
  await notificationInitialize();

  /// For Background Message Handling
  FirebaseMessaging.onBackgroundMessage(backgroundMsgAction);

  /// For Foreground Message Handling
  FirebaseMessaging.onMessage.listen((messageEvent) async {
    print(
        'Message Data is: ${messageEvent.notification!.title}      ${messageEvent.notification!.body}');

    final bool _fgNotifyStatus =
        await _localStorageHelper.extractDataForNotificationConfigTable(
            nConfigTypes: NConfigTypes.FGNotification);

    print('Foreground Notification Status: $_fgNotifyStatus');

    if (_fgNotifyStatus) {
      if (messageEvent.notification!.title!.toString().contains('Connection Request') ||
          messageEvent.notification!.title!.toString().contains('New Connection')) {
        _receiveAndShowNotificationInitialization(
          title: messageEvent.notification!.title.toString(),
          body: messageEvent.notification!.body.toString(),
        );
      } else {
        final String _userName = messageEvent.notification!.title!.toString().split(' ')[0];

        print('Foreground Notification Comer User Name: $_userName');

        final bool _fgStatus =
            await _localStorageHelper.extractImportantTableData(
                extraImportant: ExtraImportant.FGNStatus, userName: _userName);

        if (_fgStatus)
          _receiveAndShowNotificationInitialization(
            title: messageEvent.notification!.title.toString(),
            body: messageEvent.notification!.body.toString(),
          );
        else
          print('$_userName Foreground notification off');
      }
    } else
      print('Global Notification Permission Denied');
  }, onDone: () => print('Done'), onError: (e) => print('Error: $e'));

  // /// Change Navigation Bar Color
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //   systemNavigationBarColor: Colors.black54,
  // ));

  runApp(MaterialApp(
    title: 'Generation',
    debugShowCheckedModeBanner: false,
    themeMode: ThemeMode.dark,
    home: await differentContext(),
  ));
}

/// Receive And Show Notification Customization
void _receiveAndShowNotificationInitialization(
    {required String title, required String body}) async {
  final ForeGroundNotificationReceiveAndShow
      _foregroundNotificationReceiveAndShow =
      ForeGroundNotificationReceiveAndShow();

  /// Show Notification When App is On
  print('Here');

  await _foregroundNotificationReceiveAndShow.showNotification(
    title: title,
    body: body,
  );
}

Future<void> notificationInitialize() async {
  /// Important to subscribe a topic to send and receive message using FCM via http
  await FirebaseMessaging.instance.subscribeToTopic('Generation');

  /// Foreground Notification Options Enabled
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

/// Background Message Show for Debugging
Future<void> backgroundMsgAction(RemoteMessage message) async {
  await Firebase.initializeApp();
  final NativeCallback nativeCallback = NativeCallback();

  print(
      'Background Message Data: ${message.notification!.body}   ${message.notification!.title}');

  final bool _bgNotifyStatus = await LocalStorageHelper()
      .extractDataForNotificationConfigTable(
          nConfigTypes: NConfigTypes.BgNotification);

  print('Background Notification Status: $_bgNotifyStatus');

  await nativeCallback.callForCancelNotifications();

  if (_bgNotifyStatus) {
    if (message.notification!.title!.contains('Connection Request') ||
        message.notification!.title!.contains('New Connection')) {
      _receiveAndShowNotificationInitialization(
        title: message.notification!.title.toString(),
        body: message.notification!.body.toString(),
      );
    } else {
      final String _userName = message.notification!.title!.split(' ')[0];

      print('Background Notification Comer User Name: $_userName');

      final bool _bgStatus = await LocalStorageHelper()
          .extractImportantTableData(
              extraImportant: ExtraImportant.BGNStatus, userName: _userName);

      if (_bgStatus)
        _receiveAndShowNotificationInitialization(
          title: message.notification!.title.toString(),
          body: message.notification!.body.toString(),
        );
      else
        print('$_userName Background notification off');
    }
  } else
    print('Background Global Notification Permission Denied');
}

/// Decide to Switch to widget based of current Scenario
Future<Widget> differentContext() async {
  if (FirebaseAuth.instance.currentUser == null) return IntroductionScreen();

  try {
    final DocumentSnapshot responseData = await FirebaseFirestore.instance
        .doc("generation_users/${FirebaseAuth.instance.currentUser!.email}")
        .get();

    print(responseData.exists);

    if (!responseData.exists) {
      print("Log-Out Event");
      final bool response = await GoogleAuth().logOut();

      if (!response) FirebaseAuth.instance.signOut();
      return IntroductionScreen();
    }
    return MainScreen();
  } catch (e) {
    print("Starting Error is: $e");
    return IntroductionScreen();
  }
}