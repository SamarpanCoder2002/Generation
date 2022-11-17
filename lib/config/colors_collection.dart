import 'package:flutter/material.dart';

class AppColors {
  static const Color splashScreenColor = Color(0xff0152cd);

  static const Color backgroundDarkMode = Color(0xff15162d);
  static const Color backgroundLightMode = Color(0xfffefeff);
  static const Color backgroundLightSecondaryMode = Color(0xffF3F7FC);

  static const Color searchBarBgDarkMode = Color(0xff2e2d42);
  static const Color searchBarBgLightMode = Color(0xffebebeb);

  static const Color pureWhiteColor = Colors.white;
  static const Color pureBlackColor = Colors.black;

  static const Color imageDarkBgColor = Color(0xffB2B2BC);
  static const Color imageLightBgColor = Color(0xffF5F5F5);

  static const Color darkBorderGreenColor = Color(0xff02ba4b);
  static const Color lightBorderGreenColor = Color(0xff01bd47);

  static const Color darkInactiveIconColor = Colors.white60;
  static const Color lightInactiveIconColor = Color(0xff9fa0a1);

  static const Color normalBlueColor = Colors.blue;
  static const Color transparentColor = Colors.transparent;

  static const Color lightRedColor = Colors.redAccent;

  static const Color chatDarkBackgroundColor = Color(0xff14172D);
  static const Color chatLightBackgroundColor = Color(0xffdde5e6);

  static const Color messageWritingSectionColor = Color(0xff484850);

  static const Color myMsgDarkModeColor = Color(0xff6145D2);
  static const Color myMsgLightModeColor = Color(0xff01bd47);

  static const Color oppositeMsgDarkModeColor = Color(0xff303250);
  static const Color oppositeMsgLightModeColor = Color(0xffffffff);

  static const Color lightBlueColor = Colors.lightBlue;

  static const Color toastBlueColor = Color(0xff3b80f7);

  static const Color cameraIconBgColor = Color(0xffB45BE7);
  static const Color galleryIconBgColor = Color(0xff3160F5);
  static const Color videoIconBgColor = Color(0xff35C2EE);
  static const Color documentIconBgColor = Color(0xffEF458D);
  static const Color audioIconBgColor = Color(0xffEFBF40);
  static const Color locationIconBgColor = Color(0xff3FBC6C);
  static const Color personIconBgColor = Color(0xffF26109);
  static const Color lightMsgCreationColor = Color(0xffFFFEFE);

  static const Color orangeTextColor = Color(0xffffbf00);
  static const Color lightTextColor = Color(0xff6d6e75);
  static const Color lightSecondaryTextColor = Color(0xffb5b4b7);
  static const Color lightActivityTextColor = Color(0xff71747a);
  static const Color lightChatConnectionTextColor = Color(0xff696b71);
  static const Color lightLatestMsgTextColor = Color(0xff9fa0a1);

  static const Color lightModeBlueColor = Color(0xff0186fe);
  static const Color darkSelectionBlueColor = Color(0xff749cf2);

  /// Toast Message Color
  static const Color successMsgColor = Color(0xff4BB543);
  static const Color errorMsgColor = Color(0xffFF3333);
  static const Color infoMsgColor = Color(0xff766EEF);
  static const Color warningMsgColor = Color(0xffEBD114);

  static getBgColor(bool _isDarkMode) =>
      _isDarkMode ? backgroundDarkMode : backgroundLightMode;

  static Color getChatBgColor(bool _isDarkMode) =>
      _isDarkMode ? chatDarkBackgroundColor : chatLightBackgroundColor;

  static getBgSecondaryColor(bool _isDarkMode) =>
      _isDarkMode ? backgroundDarkMode : backgroundLightSecondaryMode;

  static Color getMsgColor(bool _isDarkMode, bool _isOppositeMsg) {
    if (_isDarkMode) {
      return _isOppositeMsg ? oppositeMsgDarkModeColor : myMsgDarkModeColor;
    } else {
      return _isOppositeMsg ? oppositeMsgLightModeColor : myMsgLightModeColor;
    }
  }

  static getMsgTextColor(bool _isOppositeSideMsg, bool _isDarkMode) =>
      !_isDarkMode && _isOppositeSideMsg
          ? AppColors.pureBlackColor
          : AppColors.pureWhiteColor;

  static getIconColor(bool _isDarkMode, {bool? isOpposite}) {
    if (_isDarkMode) return AppColors.pureWhiteColor;
    if (isOpposite == null) return AppColors.lightBorderGreenColor;
    return isOpposite
        ? AppColors.lightBorderGreenColor
        : AppColors.pureWhiteColor;
  }

  static getLoadingColor(bool _isDarkMode, bool isOppositeMsg) => _isDarkMode
      ? lightBlueColor
      : isOppositeMsg
          ? lightBorderGreenColor
          : pureWhiteColor;

  static chatInfoTextColor(bool _isDarkMode) =>
      _isDarkMode ? pureWhiteColor : lightChatConnectionTextColor;

  static getModalColor(bool _isDarkMode) =>
      _isDarkMode ? oppositeMsgDarkModeColor : chatLightBackgroundColor;

  static getModalColorSecondary(bool _isDarkMode) =>
      _isDarkMode ? backgroundDarkMode : chatLightBackgroundColor;

  static Color getModalTextColor(bool _isDarkMode) =>
      _isDarkMode ? pureWhiteColor : lightChatConnectionTextColor;

  static getTextButtonColor(bool _isDarkMode, bool isOpposite) {
    if (_isDarkMode) return null;
    return isOpposite ? lightBorderGreenColor : pureWhiteColor;
  }

  static getElevatedBtnColor(bool isDarkMode) =>
      isDarkMode ? oppositeMsgDarkModeColor : normalBlueColor;

  static getImageBgColor(bool _isDarkMode) => _isDarkMode
      ? oppositeMsgDarkModeColor.withOpacity(0.2)
      : pureBlackColor.withOpacity(0.1);

  static getSelectedMsgColor(bool _isDarkMode, bool isMsgSelected) {
    if (!isMsgSelected) return transparentColor;

    return _isDarkMode?darkSelectionBlueColor.withOpacity(0.3):lightModeBlueColor.withOpacity(0.3);
  }

  static popUpBgColor(bool _isDarkMode) => _isDarkMode
      ? AppColors.oppositeMsgDarkModeColor
      : AppColors.pureWhiteColor;

  static popUpTextColor(bool _isDarkMode) => _isDarkMode
      ? AppColors.pureWhiteColor
      : AppColors.lightChatConnectionTextColor;
}

class WaveForm {
  static List<Color> colors = [
    Colors.red[900]!,
    Colors.green[900]!,
    Colors.blue[900]!,
    Colors.brown[900]!
  ];
}
