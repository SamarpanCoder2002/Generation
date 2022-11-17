import 'package:flutter/services.dart';

import 'debugging.dart';

class NativeCallback {
  static const MethodChannel _platform =
      MethodChannel("com.generation.messaging/nativeCallBack");

  Future<void> callForCancelNotifications() async {
    debugShow('Here in Notification Clear Native Calling');

    final result = await _platform.invokeMethod('cancelAllNotification', '');
    debugShow('Call For Notification Result: $result');
  }

  Future<bool> checkInternet() async {
    debugShow('Here in Internet Connectivity Native Calling');

    final bool result =
        await _platform.invokeMethod('checkNetworkConnectivity', '');
    debugShow('Network Connectivity: $result');

    return result;
  }

  Future<String> getTheVideoThumbnail({required String videoPath}) async {
    debugShow('Thumbnail Take');

    final String thumbnailPath = await _platform
        .invokeMethod('makeVideoThumbnail', {'videoPath': videoPath});

    debugShow("Thumbnail Path is: $thumbnailPath");

    return thumbnailPath;
  }
}
