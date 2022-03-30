import 'package:flutter/material.dart';
import 'package:generation/config/data_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/screens/main_screens/main_screen_management.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../config/colors_collection.dart';
import '../../config/images_path_collection.dart';
import '../../services/device_specific_operations.dart';

class IntroScreens extends StatefulWidget {
  const IntroScreens({Key? key}) : super(key: key);

  @override
  State<IntroScreens> createState() => _IntroScreensState();
}

class _IntroScreensState extends State<IntroScreens> {
  final PageController _controller = PageController();

  @override
  void initState() {
    makeScreenCleanView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashScreenColor,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            const SizedBox(
              height: 140,
            ),
            _logoSection(),
            const SizedBox(
              height: 30,
            ),
            _customSlider(),
            const SizedBox(
              height: 30,
            ),
            _indicatorSection(),
            const SizedBox(
              height: 30,
            ),
            const Expanded(child: Center()),
            _googleLogInButton(),
            const SizedBox(
              height: 30,
            ),
            _fbLogInButton(),
            const SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }

  _logoSection() {
    return Center(
      child: Image.asset(
        AppImages.splashScreenLogo,
        width: MediaQuery.of(context).size.width / 2.5,
      ),
    );
  }

  _customSlider() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 4,
      child: PageView.builder(
        controller: _controller,
        itemCount: SliderData.content.length,
        itemBuilder: (_, index) {
          final _currentData = SliderData.content[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentData["title"],
                  style: TextStyleCollection.headingTextStyle
                      .copyWith(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 1.0),
                ),
                const SizedBox(
                  height: 20,
                ),
                Flexible(
                    child: Text(
                  _currentData["subtitle"],
                  style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(letterSpacing: 1.0),
                  textAlign: TextAlign.center,
                ))
              ],
            ),
          );
        },
      ),
    );
  }

  _indicatorSection() => SmoothPageIndicator(
        controller: _controller,
        effect: const WormEffect(
            dotWidth: 10.0,
            dotHeight: 10.0,
            activeDotColor: AppColors.pureWhiteColor),
        count: SliderData.content.length,
      );

  _googleLogInButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextButton(
        style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.pureWhiteColor))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/google.png",
              width: 35,
            ),
            const SizedBox(
              width: 15,
            ),
            Text(
              "Continue With Google",
              style: TextStyleCollection.secondaryHeadingTextStyle
                  .copyWith(fontSize: 16),
            ),
          ],
        ),
        onPressed: () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MainScreen())),
      ),
    );
  }

  _fbLogInButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextButton(
        style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.pureWhiteColor))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/facebook.png",
              width: 35,
            ),
            const SizedBox(
              width: 15,
            ),
            Text(
              "Continue With Facebook",
              style: TextStyleCollection.secondaryHeadingTextStyle
                  .copyWith(fontSize: 16),
            ),
          ],
        ),
        onPressed: () {},
      ),
    );
  }
}
