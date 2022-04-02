import 'dart:async';

import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/images_path_collection.dart';
import 'package:generation/config/text_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/providers/theme_provider.dart';
import 'package:generation/screens/entry_screens/intro_screen.dart';
import 'package:generation/services/device_specific_operations.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  _initialize() async{
    await Provider.of<ThemeProvider>(context, listen: false).initialization();
  }

  @override
  void initState() {
    _initialize();
    makeScreenCleanView();
    makeScreenStrictPortrait();
    changeOnlyIconBrightness(true);
    _switchToNextScreen();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 2.0;

    return Scaffold(
      backgroundColor: AppColors.splashScreenColor,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                AppImages.splashScreenLogo,
                width: MediaQuery.of(context).size.width / 2,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Center(
              child: Text(
                AppText.appName,
                style: TextStyleCollection.headingTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _switchToNextScreen() {

    Timer(const Duration(seconds: 3), (){
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const IntroScreens()),
              (route) => false);
    });
  }
}
