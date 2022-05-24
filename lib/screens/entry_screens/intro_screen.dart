import 'package:flutter/material.dart';
import 'package:generation/config/data_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/operation/google_auth.dart';
import 'package:generation/screens/entry_screens/sign_in_screen.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:generation/services/toast_message_show.dart';
import 'package:generation/config/types.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../config/colors_collection.dart';
import '../../config/images_path_collection.dart';
import '../../providers/incoming_data_provider.dart';
import '../../services/device_specific_operations.dart';
import '../../services/navigation_management.dart';
import '../common/common_operations.dart';
import '../common/common_selection_screen.dart';
import 'information_taking.dart';

class IntroScreens extends StatefulWidget {
  const IntroScreens({Key? key}) : super(key: key);

  @override
  State<IntroScreens> createState() => _IntroScreensState();
}

class _IntroScreensState extends State<IntroScreens> {
  final PageController _controller = PageController();
  final GoogleAuth _googleAuth = GoogleAuth();
  final DBOperations _dbOperations = DBOperations();
  final LocalStorage _localStorage = LocalStorage();

  bool _isLoading = false;

  @override
  void initState() {
    makeScreenCleanView();
    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  //   final _incomingData = Provider.of<IncomingDataProvider>(context).getIncomingData();
  //
  //   print("Incoming DAta: $_incomingData");
  //
  //   if(_incomingData.isNotEmpty){
  //
  //
  //     Navigation.intent(
  //         context,
  //         const CommonSelectionScreen(
  //           commonRequirement: CommonRequirement.forwardMsg,
  //         ));
  //   }
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    final _incomingData =
        Provider.of<IncomingDataProvider>(context, listen: false)
            .getIncomingData();

    print("Incoming DAta: $_incomingData");

    if (_incomingData.isNotEmpty) {
      return const CommonSelectionScreen(
        commonRequirement: CommonRequirement.forwardMsg,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.splashScreenColor,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            if (_isLoading)
              const SizedBox(
                height: 40,
              ),
            if (_isLoading) _loadingIndicator(),
            SizedBox(
              height: _isLoading ? 95 : 140,
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
            _emailLogInButton(),
            const SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }

  _loadingIndicator() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 3,
      child: const LinearProgressIndicator(
        backgroundColor: AppColors.pureWhiteColor,
        color: AppColors.darkBorderGreenColor,
      ),
    );
  }

  _logoSection() {
    return Center(
      child: Image.asset(
        AppImages.mainSplashScreenLogo,
        width: MediaQuery.of(context).size.width / 2.7,
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
                  style: TextStyleCollection.headingTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0),
                ),
                const SizedBox(
                  height: 20,
                ),
                Flexible(
                    child: Text(
                  _currentData["subtitle"],
                  style: TextStyleCollection.secondaryHeadingTextStyle
                      .copyWith(letterSpacing: 1.0),
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
              AppImages.googleLogo,
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
        onPressed: _googleSignIn,
      ),
    );
  }

  _emailLogInButton() {
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
            const Icon(
              Icons.email_outlined,
              size: 30,
              color: AppColors.pureWhiteColor,
            ),
            const SizedBox(
              width: 15,
            ),
            Text(
              "Continue With Email",
              style: TextStyleCollection.secondaryHeadingTextStyle
                  .copyWith(fontSize: 16),
            ),
          ],
        ),
        onPressed: () => Navigation.intent(context, const SignInScreen()),
      ),
    );
  }

  void _googleSignIn() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final _userData = await _googleAuth.logIn();

    if (_userData == null) {
      showToast(context,
          title: "Sign In Failed",
          toastIconType: ToastIconType.error,
          showFromTop: false);
      return;
    }

    showToast(context,
        title: "Sign In Successful",
        toastIconType: ToastIconType.success,
        showFromTop: false);

    print("User Data: $_userData");

    final _createdBefore = await _dbOperations.isAccountCreatedBefore();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    if (!_createdBefore["success"]) {
      Navigation.intent(
          context,
          InformationTakingScreen(
            name: _userData["name"],
            email: _userData["email"],
            profilePic: _userData["profilePic"],
          ));
    } else {
      dataFetchingOperations(context, _createdBefore, _dbOperations.currUid);
    }
  }
}
