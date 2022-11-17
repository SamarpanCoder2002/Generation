import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/material.dart';

import '../config/colors_collection.dart';
import '../config/types.dart';
import 'debugging.dart';

class ToastMsg {
  static void showSuccessToast(text,
          {required dynamic context,
          bool shortToast = true,
          bool fromBottom = true}) =>
      _commonToastShow(
          context, text, shortToast, fromBottom, AppColors.successMsgColor);

  static void showErrorToast(text,
          {required dynamic context,
          bool shortToast = true,
          bool fromBottom = true}) =>
      _commonToastShow(
          context, text, shortToast, fromBottom, AppColors.errorMsgColor);

  static void showInfoToast(text,
          {required dynamic context,
          bool shortToast = true,
          bool fromBottom = true}) =>
      _commonToastShow(
          context, text, shortToast, fromBottom, AppColors.infoMsgColor);

  static void showWarningToast(text,
          {required dynamic context,
          bool shortToast = true,
          bool fromBottom = true}) =>
      _commonToastShow(
          context, text, shortToast, fromBottom, AppColors.warningMsgColor);

  static _commonToastShow(dynamic context, String text, bool shortToast,
      bool fromBottom, Color color) {
    try {
      final snackBar = SnackBar(
        content: Text(text),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: shortToast ? 3 : 6),
        margin: const EdgeInsets.all(10),
        action: SnackBarAction(
          textColor: AppColors.pureWhiteColor,
          label: 'Close',
          onPressed: () {},
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      debugShow('Error while showing context: $e');
      _alternativeToastShow(text, shortToast, fromBottom, color);
    }
  }

  static _alternativeToastShow(
      String text, bool shortToast, bool fromBottom, Color color) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: shortToast ? Toast.LENGTH_SHORT : Toast.LENGTH_SHORT,
        gravity: fromBottom ? ToastGravity.BOTTOM : ToastGravity.TOP,
        backgroundColor: color,
        textColor: AppColors.pureWhiteColor,
        fontSize: 16.0);
  }
}

class DialogMsg {
  static void showDialog(context, String title, String description,
      {required AwesomeDialogType awesomeDialogType, VoidCallback? onSuccess, String? rightBtnText, VoidCallback? onFailure}) {
    AwesomeDialog(
      context: context,
      dialogType: _getDialogType(awesomeDialogType),
      animType: AnimType.bottomSlide,
      title: title,
      desc: description,
      btnCancelOnPress: () {
        if(onFailure == null) return;
        onFailure();
      },
      btnOkText: rightBtnText,
      btnOkOnPress: () {
        if (onSuccess == null) return;
        onSuccess();
      },
    ).show();
  }

  static _getDialogType(AwesomeDialogType awesomeDialogType) {
    switch (awesomeDialogType) {
      case AwesomeDialogType.success:
        return DialogType.success;
      case AwesomeDialogType.error:
        return DialogType.error;
      case AwesomeDialogType.warning:
        return DialogType.warning;
      case AwesomeDialogType.info:
        return DialogType.info;
    }
  }
}
