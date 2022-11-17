import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/stored_string_collection.dart';
import 'package:generation/config/text_collection.dart';
import 'package:generation/providers/providers_collection.dart';
import 'package:generation/screens/entry_screens/splash_screen.dart';
import 'package:generation/services/debugging.dart';
import 'package:generation/services/device_specific_operations.dart';
import 'package:generation/services/local_data_management.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataManagement.loadEnvData();
  _initializeFirebase();

  runApp(const GenerationEntry());
}

class GenerationEntry extends StatelessWidget {
  const GenerationEntry({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providersCollection,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppText.appName,
        theme: ThemeData(
            fontFamily: AppText.fontFamily,
            bottomSheetTheme: const BottomSheetThemeData(
                backgroundColor: AppColors.transparentColor)),
        builder: (context, child) => MediaQuery(
          child: child!,
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp();
  await notificationInitialize();

  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  /// For Background Message Handling
  FirebaseMessaging.onBackgroundMessage(backgroundMsgAction);

  /// For Foreground Message Handling
  FirebaseMessaging.onMessage.listen(foregroundMessageAction);
}

Future<void> notificationInitialize() async {
  /// Important to subscribe a topic to send and receive message using FCM via http
  ///
  debugShow('Topic to subscribe: ${ DataManagement.getEnvData(EnvFileKey.firebaseMessagingTopic)}');
  await FirebaseMessaging.instance.subscribeToTopic(
      DataManagement.getEnvData(EnvFileKey.firebaseMessagingTopic) ?? '');

  /// Foreground Notification Options Enabled
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

Future<void> backgroundMsgAction(RemoteMessage message) async {
  debugShow("Background MEssage is: ${message.data}");
}

void foregroundMessageAction(RemoteMessage msgEvent) async {
  final _currChatPartnerId =
      await DataManagement.getStringData(StoredString.currChatPartnerId);

  if (_currChatPartnerId != null &&
      _currChatPartnerId == msgEvent.data['connId']) return;

  final NotificationManagement _notificationManagement =
      NotificationManagement();
  _notificationManagement.showNotification(
      title: msgEvent.notification!.title ?? '',
      body: msgEvent.notification!.body ?? '',
      image: msgEvent.data['image']);
}
