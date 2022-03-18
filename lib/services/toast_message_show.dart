import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/types/types.dart';

void showToast(BuildContext context,
    {required String title,
    int? toastDuration,
    double? height,
    required ToastIconType toastIconType}) async {
  Fluttertoast.showToast(
    msg: title,
    toastLength: toastDuration == null
        ? Toast.LENGTH_SHORT
        : toastDuration < 5
            ? Toast.LENGTH_SHORT
            : Toast.LENGTH_LONG,
    gravity: ToastGravity.TOP,
    backgroundColor: _getColor(toastIconType),
    textColor: AppColors.pureWhiteColor,
    fontSize: 16.0,
  );

  // showDialog(
  //     context: context,
  //     builder: (_) => MotionToast(
  //           title: Text(title),
  //           description: Text(description ?? ""),
  //           width: MediaQuery.of(context).size.width - 80,
  //           height: height ?? 150,
  //           position: MOTION_TOAST_POSITION.top,
  //           animationType: ANIMATION.fromTop,
  //           toastDuration: Duration(seconds: toastDuration ?? 3),
  //           icon: _getCorrespondingIcon(toastIconType),
  //           primaryColor: _getColor(toastIconType),
  //           secondaryColor: _getColor(toastIconType).withOpacity(0.8),
  //         ));
}

// IconData _getCorrespondingIcon(ToastIconType toastIconType) {
//   switch (toastIconType) {
//     case ToastIconType.info:
//       return Icons.info_outlined;
//     case ToastIconType.success:
//       return Icons.done_outlined;
//     case ToastIconType.error:
//       return Icons.clear_outlined;
//     case ToastIconType.warning:
//       return Icons.warning_amber_outlined;
//   }
// }

Color _getColor(ToastIconType toastIconType) {
  switch (toastIconType) {
    case ToastIconType.info:
      return AppColors.toastBlueColor;
    case ToastIconType.success:
      return AppColors.darkBorderGreenColor;
    case ToastIconType.error:
      return AppColors.lightRedColor;
    case ToastIconType.warning:
      return AppColors.audioIconBgColor;
  }
}
