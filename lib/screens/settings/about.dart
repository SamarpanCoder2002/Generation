import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/services/debugging.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/main_screen_provider.dart';
import '../../providers/theme_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Scaffold(
      backgroundColor: AppColors.getBgColor(_isDarkMode),
      //bottomSheet: _bottomSheet(context),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 50),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _heading(context),
              const SizedBox(
                height: 20,
              ),
              _appDescription(context),
              const SizedBox(
                height: 20,
              ),
              _specialization(context),
              const SizedBox(
                height: 20,
              ),
              _moreInfoAboutApp(context),
              const SizedBox(height: 20),
              _versionSection(context),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  _moreInfoAboutApp(context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Column(
      children: [
        Center(
          child: Text("Get to know more about this app from",
              textAlign: TextAlign.center,
              style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: _isDarkMode
                      ? AppColors.pureWhiteColor
                      : AppColors.lightChatConnectionTextColor)),
        ),
        const SizedBox(height: 5),
        InkWell(
          onTap: () {
            try {
              launch(TextCollection.appWebsiteLink);
            } catch (e) {
              debugShow('Website Opening Error: $e');
            }
          },
          child: Center(
            child: Text(TextCollection.appWebsiteLink,
                style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
                    fontSize: 14,
                    color: _isDarkMode
                        ? AppColors.darkBorderGreenColor
                        : AppColors.lightBorderGreenColor,
                    decoration: TextDecoration.underline)),
          ),
        ),
      ],
    );
  }

  _heading(context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
    return Center(
      child: Text(
        'About Generation',
        style: TextStyleCollection.headingTextStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _isDarkMode
                ? AppColors.darkBorderGreenColor
                : AppColors.lightBorderGreenColor),
      ),
    );
  }

  _appDescription(context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Center(
      child: Text(
        "A Private, Secure, End-to-End Encrypted Messaging app that helps you to connect with your connections without any Ads, promotion. No other third party person, organization, or even Generation Team can't read your messages.",
        textAlign: TextAlign.justify,
        style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: _isDarkMode
                ? AppColors.pureWhiteColor
                : AppColors.lightChatConnectionTextColor),
      ),
    );
  }

  _specialization(context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Center(
      child: Text(
        'Messages and Activities are End-to-End-Encrypted',
        textAlign: TextAlign.center,
        style: TextStyleCollection.terminalTextStyle.copyWith(
            color: _isDarkMode
                ? AppColors.darkBorderGreenColor
                : AppColors.lightBorderGreenColor,
            fontSize: 14),
      ),
    );
  }

  _versionSection(context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Center(
      child: Text(
          'v ${Provider.of<MainScreenNavigationProvider>(context).getLocalVersion}',
          style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
              letterSpacing: 1.0,
              color: _isDarkMode
                  ? AppColors.pureWhiteColor
                  : AppColors.lightChatConnectionTextColor)),
    );
  }

// _bottomSheet(BuildContext context) {
//   final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
//   _querySide() => InkWell(
//         onTap: () => Navigation.intent(
//             context,
//             SendEmailToSupport(
//               headingTerminal: "Query",
//             )),
//         child: Container(
//           alignment: Alignment.center,
//           width: MediaQuery.of(context).size.width / 2,
//           child: Text(
//             "Have Any Query ?",
//             style: TextStyleCollection.terminalTextStyle.copyWith(
//                 fontSize: 14,
//                 color: AppColors.pureWhiteColor,
//                 decoration: TextDecoration.underline),
//           ),
//         ),
//       );
//
//   // _donateSide() => InkWell(
//   //       onTap: () => Navigation.intent(
//   //           context, const DonateScreen(showMsgFromTop: true)),
//   //       child: Container(
//   //         color: _isDarkMode
//   //             ? AppColors.darkBorderGreenColor
//   //             : AppColors.lightBorderGreenColor,
//   //         alignment: Alignment.center,
//   //         width: MediaQuery.of(context).size.width / 2,
//   //         child: Text(
//   //           "Donate Now",
//   //           style:
//   //               TextStyleCollection.terminalTextStyle.copyWith(fontSize: 14),
//   //         ),
//   //       ),
//   //     );
//
//   return BottomSheet(
//       elevation: 0,
//       enableDrag: false,
//       onClosing: () {},
//       builder: (_) => SizedBox(
//             width: MediaQuery.of(context).size.width,
//             height: 60,
//             child: _querySide(),
//           ));
// }
}
