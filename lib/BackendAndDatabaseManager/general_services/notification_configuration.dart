import 'dart:convert';

import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/main.dart';
import 'package:http/http.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SendNotification {
  Future<void> messageNotificationClassifier(MediaTypes mediaTypes,
      {String textMsg = '',
      @required String connectionToken,
      @required String currAccountUserName}) async {
    print('Token is: $connectionToken');

    switch (mediaTypes) {
      case MediaTypes.Text:
        await sendNotification(
          token: connectionToken,
          title: "$currAccountUserName Send You a Message",
          body: textMsg,
        );
        break;

      case MediaTypes.Voice:
        await sendNotification(
          token: connectionToken,
          title: "$currAccountUserName Send You a Voice",
          body: '',
        );
        break;

      case MediaTypes.Image:
        await sendNotification(
          token: connectionToken,
          title: "$currAccountUserName Send You a Image",
          body: textMsg,
        );
        break;

      case MediaTypes.Video:
        await sendNotification(
          token: connectionToken,
          title: "$currAccountUserName Send You a Video",
          body: textMsg,
        );
        break;

      case MediaTypes.Sticker:
        await sendNotification(
          token: connectionToken,
          title: "$currAccountUserName Send You a Sticker",
          body: '',
        );
        break;

      case MediaTypes.Location:
        await sendNotification(
          token: connectionToken,
          title: "$currAccountUserName Send You Device Location",
          body: textMsg,
        );
        break;

      case MediaTypes.Document:
        await sendNotification(
          token: connectionToken,
          title: "$currAccountUserName Send You a Document",
          body: textMsg,
        );
        break;

      case MediaTypes.Indicator:
        break;
    }
  }

  Future<int> sendNotification(
      {@required String token,
      @required String title,
      @required String body}) async {
    try {
      print('Send');

      final String _serverKey =
          'AAAAq0K_fTE:APA91bGZYVVXCwF26L5cqkmh1F9_b4Z4mfs2GTx66-GHI8hXpEFY4IUluTCQyXxdk_ARYLjT9z540KvMxZ4itcBMax3COu2s5FxJuv95fWJQc2tfPspUp7oWY4annwhCH58_xAHrIElI';

      final Response response = await post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body': body,
            'title': title,
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            "collapse_key": "type_a",
          },
          'to': token,
        }),
      );

      print('Response is: ${response.statusCode}');

      return response.statusCode;
    } catch (e) {
      showDialog(
          context: navigatorKey.currentContext,
          builder: (_) => AlertDialog(
                title: Text('Send Notification Error'),
                content: Text(e.toString()),
              ));

      return 404;
    }
  }
}

class ForeGroundNotificationReceiveAndShow {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings _androidInitializationSettings =
      AndroidInitializationSettings('app_icon');

  ForeGroundNotificationReceiveAndShow() {
    final InitializationSettings _initializationSettings =
        InitializationSettings(android: _androidInitializationSettings);

    print('Noti Here');

    initAll(_initializationSettings);
  }

  initAll(InitializationSettings initializationSettings) async {
    var response = await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: notificationSelected);

    print('Local Notification Initialization Status: $response');
  }

  Future<void> showNotification(
      {@required String title, @required String body}) async {
    try {
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
              "Channel ID", "Generation Official", "This is Generation App",
              importance: Importance.max);

      final NotificationDetails generalNotificationDetails =
          NotificationDetails(android: androidDetails);

      await _flutterLocalNotificationsPlugin
          .show(0, title, body, generalNotificationDetails, payload: title);
    } catch (e) {
      showDialog(
        context: navigatorKey.currentContext,
        builder: (_) => AlertDialog(
          title: Text('Show Notification Error'),
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future notificationSelected(String payload) async {
    print('On Select Notification Payload: $payload');
  }
}
