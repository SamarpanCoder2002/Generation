import 'package:flutter/services.dart';

import 'debugging.dart';

class NativeCallback {
  static const MethodChannel _platform =
      MethodChannel("com.samarpandasgupta.generation/nativeCallBack");

  Future<void> callForCancelNotifications() async {
    debug('Here in Notification Clear Native Calling');

    final result = await _platform.invokeMethod('cancelAllNotification', '');
    debug('Call For Notification Result: $result');
  }

  Future<bool> checkInternet() async {
    debug('Here in Internet Connectivity Native Calling');

    final bool result =
        await _platform.invokeMethod('checkNetworkConnectivity', '');
    debug('Network Connectivity: $result');

    return result;
  }

  Future<String> getTheVideoThumbnail({required String videoPath}) async {
    debug('Thumbnail Take');

    final String thumbnailPath = await _platform
        .invokeMethod('makeVideoThumbnail', {'videoPath': videoPath});

    debug("Thumbnail Path is: $thumbnailPath");

    return thumbnailPath;
  }
}
