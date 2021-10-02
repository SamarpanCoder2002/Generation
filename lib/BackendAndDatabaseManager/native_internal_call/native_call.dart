import 'package:flutter/services.dart';

class NativeCallback {
  static const MethodChannel _platform =
      const MethodChannel('com.official.generation/nativeCallBack');

  Future<void> callForCancelNotifications() async {
    print('Here in Notification Clear Native Calling');

    final result = await _platform.invokeMethod('cancelAllNotification', '');
    print('Call For Notification Result: $result');
  }

  Future<bool> callToCheckNetworkConnectivity() async {
    print('Here in Internet Connectivity Native Calling');

    final bool result =
        await _platform.invokeMethod('checkNetworkConnectivity', '');
    print('Network Connectivity: $result');

    return result;
  }

  Future<String> getTheVideoThumbnail({required String videoPath}) async {
    print('Thumbnail Take');

    final String thumbnailPath = await _platform
        .invokeMethod('makeVideoThumbnail', {'videoPath': videoPath});

    print("Thumbnail Path is: $thumbnailPath");

    return thumbnailPath;
  }
}
