import 'package:flutter/services.dart';

class NativeCallback {
  static const MethodChannel _platform =
      const MethodChannel('com.official.generation/nativeCallBack');

  Future<void> callForCancelNotifications() async {
    print('Here in Notification Clear Native Calling');

    final result = await _platform.invokeMethod('cancelAllNotification', '');
    print('Call For Notification Result: $result');
  }

}
