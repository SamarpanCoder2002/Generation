import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/screens/common/button.dart';
import 'package:generation/types/types.dart';

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

void showToast(BuildContext context,
    {required String title,
    int? toastDuration,
    double? height,
    required ToastIconType toastIconType,
    bool showFromTop = true, double? fontSize}) async {
  Fluttertoast.showToast(
    msg: title,
    toastLength: toastDuration == null
        ? Toast.LENGTH_SHORT
        : toastDuration < 5
            ? Toast.LENGTH_SHORT
            : Toast.LENGTH_LONG,
    gravity: showFromTop ? ToastGravity.TOP : ToastGravity.BOTTOM,
    backgroundColor: _getColor(toastIconType),
    textColor: AppColors.pureWhiteColor,
    fontSize: fontSize ?? 16.0,
  );
}

void showPopUpDialog(
    BuildContext context, String title, String content, VoidCallback onPressed,
    {String? rightBtnText,
    String? leftBtnText,
    bool barrierDismissible = true,
    bool showCancelBtn = true,
    VoidCallback? leftOnPressed,
    Color? bgColor,
    Color? leftBtnColor}) {

  showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            backgroundColor: bgColor ?? AppColors.splashScreenColor,
            elevation: 10,
            title: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style:
                    TextStyleCollection.headingTextStyle.copyWith(fontSize: 20),
              ),
            ),
            content: Text(
              content,
              style: TextStyleCollection.secondaryHeadingTextStyle,
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              if (showCancelBtn)
                commonTextButton(
                    btnText: leftBtnText ?? "Cancel",
                    onPressed: leftOnPressed ?? () => Navigator.pop(context),
                    borderColor: leftBtnColor ?? AppColors.lightRedColor,
                    textColor: leftBtnColor ?? AppColors.lightRedColor),
              commonElevatedButton(
                  btnText: rightBtnText ?? "Ok",
                  onPressed: onPressed,
                  bgColor: AppColors.darkBorderGreenColor),
            ],
          ));
}



void showPopUpDialogManually(
    BuildContext context, String title, Widget content, VoidCallback onPressed,
    {String? rightBtnText,
      String? leftBtnText,
      bool barrierDismissible = true,
      bool showCancelBtn = true,
      VoidCallback? leftOnPressed,
      Color? bgColor,
      Color? leftBtnColor}) {

  showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        backgroundColor: bgColor ?? AppColors.splashScreenColor,
        elevation: 10,
        title: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style:
            TextStyleCollection.headingTextStyle.copyWith(fontSize: 20),
          ),
        ),
        content: content,
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          if (showCancelBtn)
            commonTextButton(
                btnText: leftBtnText ?? "Cancel",
                onPressed: leftOnPressed ?? () => Navigator.pop(context),
                borderColor: leftBtnColor ?? AppColors.lightRedColor,
                textColor: leftBtnColor ?? AppColors.lightRedColor),
          commonElevatedButton(
              btnText: rightBtnText ?? "Ok",
              onPressed: onPressed,
              bgColor: AppColors.darkBorderGreenColor),
        ],
      ));
}
