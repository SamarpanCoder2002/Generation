import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:generation_official/FrontEnd/MainScreen/MainWindow.dart';
import 'package:generation_official/FrontEnd/Auth_UI/sign_up_UI.dart';
import 'package:generation_official/BackendAndDatabaseManager/firebase_services/google_auth.dart';
import 'package:generation_official/FrontEnd/Services/notification_configuration.dart';


final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  /// Initialize Notification Settings
  await notificationInitialize();

  /// For Background Message Handling
  FirebaseMessaging.onBackgroundMessage(backgroundMsgAction);

  /// For Foreground Message Handling
  FirebaseMessaging.onMessage.listen((messageEvent) {
    print(
        'Message Data is: ${messageEvent.notification.title}      ${messageEvent.notification.body}');

    _receiveAndShowNotificationInitialization(
      title: messageEvent.notification.title,
      body: messageEvent.notification.body,
    );
  }, onDone: () => print('Done'), onError: (e) => print('Error: $e'));

  runApp(MaterialApp(
    title: 'Generation',
    debugShowCheckedModeBanner: false,
    home: await differentContext(),
  ));
}

/// Receive And Show Notification Customization
void _receiveAndShowNotificationInitialization(
    {@required String title, @required String body}) async {
  final ForeGroundNotificationReceiveAndShow
      _foregroundNotificationReceiveAndShow =
      ForeGroundNotificationReceiveAndShow();

  /// Show Notification When App is On
  print('Here');

  await _foregroundNotificationReceiveAndShow.showNotification(
      title: title, body: body,);
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
  print(
      'Background Message Data: ${message.notification.body}   ${message.notification.title}');
}

/// Decide to Switch to widget based of current Scenario
Future<Widget> differentContext() async {
  if (FirebaseAuth.instance.currentUser == null) return SignUpAuthentication();

  try {
    final DocumentSnapshot responseData = await FirebaseFirestore.instance
        .doc("generation_users/${FirebaseAuth.instance.currentUser.email}")
        .get();

    print(responseData.exists);

    if (!responseData.exists) {
      print("Log-Out Event");
      final bool response = await GoogleAuth().logOut();

      if (!response) FirebaseAuth.instance.signOut();
      return SignUpAuthentication();
    }
    return MainScreen();
  } catch (e) {
    print("Starting Error is: $e");
    return SignUpAuthentication();
  }
}
