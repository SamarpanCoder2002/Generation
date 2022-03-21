import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/screens/settings/support/donate_screen.dart';
import 'package:generation/screens/settings/support/send_email_to_support.dart';
import 'package:generation/services/navigation_management.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkMode,
      bottomSheet: _bottomSheet(context),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 50),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _heading(),
              const SizedBox(
                height: 20,
              ),
              _appDescription(),
              const SizedBox(
                height: 20,
              ),
              _specialization(),
            ],
          ),
        ),
      ),
    );
  }

  _heading() {
    return Center(
      child: Text(
        'About Generation',
        style: TextStyleCollection.headingTextStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBorderGreenColor),
      ),
    );
  }

  _appDescription() => Center(
        child: Text(
          "A Private, Secure, End-to-End Encrypted Messaging app that helps you to connect with your connections without any Ads, promotion. No other third party person, organization, or even Generation Team can't read your messages.",
          textAlign: TextAlign.justify,
          style: TextStyleCollection.secondaryHeadingTextStyle
              .copyWith(fontSize: 14, fontWeight: FontWeight.normal),
        ),
      );

  _specialization() => Center(
        child: Text(
          'Messages and Activity With Video Calling are\nEnd-to-End-Encrypted',
          textAlign: TextAlign.center,
          style: TextStyleCollection.terminalTextStyle
              .copyWith(color: AppColors.darkBorderGreenColor, fontSize: 14),
        ),
      );

  _bottomSheet(BuildContext context) {
    _querySide() => InkWell(
          onTap: () => Navigation.intent(
              context,
              SendEmailToSupport(
                headingTerminal: "Query",
              )),
          child: Container(
            color: AppColors.oppositeMsgDarkModeColor,
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width / 2,
            child: Text(
              "Have Any Query ?",
              style:
                  TextStyleCollection.terminalTextStyle.copyWith(fontSize: 14),
            ),
          ),
        );

    _donateSide() => InkWell(
          onTap: () => Navigation.intent(context, const DonateScreen(showMsgFromTop: true)),
          child: Container(
            color: AppColors.darkBorderGreenColor,
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width / 2,
            child: Text(
              "Donate Now",
              style:
                  TextStyleCollection.terminalTextStyle.copyWith(fontSize: 14),
            ),
          ),
        );

    return BottomSheet(
        elevation: 0,
        enableDrag: false,
        onClosing: () {},
        builder: (_) => SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 60,
              child: Row(
                children: [
                  _querySide(),
                  _donateSide(),
                ],
              ),
            ));
  }
}
