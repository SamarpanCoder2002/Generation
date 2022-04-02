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
  static const Color chatLightBackgroundColor = Color(0xffF3F7FC);

  static const Color messageWritingSectionColor = Color(0xff484850);

  static const Color myMsgDarkModeColor = Color(0xff6145D2);

  //static const Color myMsgDarkModeColor = Color.fromRGBO(37, 137, 224, 1);
  static const Color oppositeMsgDarkModeColor = Color(0xff303250);

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

  static getBgColor(bool _isDarkMode) =>
      _isDarkMode ? backgroundDarkMode : backgroundLightMode;

  static getChatBgColor(bool _isDarkMode) => _isDarkMode?chatDarkBackgroundColor:chatLightBackgroundColor;

  static getBgSecondaryColor(bool _isDarkMode) => _isDarkMode ? backgroundDarkMode : backgroundLightSecondaryMode;
}

class WaveForm {
  static List<Color> colors = [
    Colors.red[900]!,
    Colors.green[900]!,
    Colors.blue[900]!,
    Colors.brown[900]!
  ];
}
