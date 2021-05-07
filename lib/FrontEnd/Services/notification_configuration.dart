import 'dart:convert';

import 'package:http/http.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<int> sendNotification(
    {@required String token,
    @required String title,
    @required String body}) async {
  print('Send');

  final String _serverKey =
      'AAAAhYAupkM:APA91bENB9fuZLd3VKNaDLMordtXDJAggph3pp4SJRnJBQs8ZOodjS05url3ef0AILjoI2FE6qf3xImVGrfjymZX2jIBXN1QqBXLRt_VVG7wnduCtw8ntbHBTHT133_gy7weQ5eNMhk0';

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

  initAll(InitializationSettings initializationSettings) async{
    var response = await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: notificationSelected);

    print('Local Notification Initialization Status: $response');
  }

  Future<void> showNotification(
      {@required String title, @required String body}) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
            "Channel ID", "Generation Official", "This is Generation App",
            importance: Importance.max);

    final NotificationDetails generalNotificationDetails =
        NotificationDetails(android: androidDetails);


    await _flutterLocalNotificationsPlugin
        .show(0, title, body, generalNotificationDetails, payload: title);
  }

  Future notificationSelected(String payload) async {
    print('On Select Notification Payload: $payload');
  }
}
