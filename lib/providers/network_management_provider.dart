import 'package:flutter/material.dart';
import 'package:generation/config/types.dart';
import 'package:generation/services/native_operations.dart';
import 'package:generation/services/toast_message_show.dart';

class NetworkManagementProvider extends ChangeNotifier {
  final NativeCallback _nativeCallback = NativeCallback();

  Future<bool> get isNetworkActive async =>
      await _nativeCallback.checkInternet();

  noNetworkMsg(BuildContext context, {bool showFromTop = true, bool? showCenterToast}) => showToast(
      title: 'Network not available',
      toastIconType: ToastIconType.info,
      toastDuration: 10,showFromTop: showFromTop, showCenterToast: showCenterToast);
}
