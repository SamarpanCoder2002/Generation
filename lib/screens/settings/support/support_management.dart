import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/screens/settings/support/donate_screen.dart';
import 'package:generation/screens/settings/support/send_email_to_support.dart';
import 'package:generation/services/navigation_management.dart';
import 'package:provider/provider.dart';

import '../../../config/text_style_collection.dart';
import '../../../providers/theme_provider.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Scaffold(
      appBar: _headerSection(context),
      backgroundColor: AppColors.getBgColor(_isDarkMode),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _submitProblem(context),
              const SizedBox(
                height: 10,
              ),
              //_donateMoney(context)
            ],
          ),
        ),
      ),
    );
  }

  _headerSection(BuildContext context){
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.getBgColor(_isDarkMode),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_outlined,color: _isDarkMode?AppColors.pureWhiteColor:AppColors.lightChatConnectionTextColor)),
          Text(
            "Support",
            style:
            TextStyleCollection.terminalTextStyle.copyWith(fontSize: 16,color: _isDarkMode?AppColors.pureWhiteColor:AppColors.lightChatConnectionTextColor),
          ),
        ],
      ),
    );
  }

  _submitProblem(BuildContext context){
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return ListTile(
      onTap: () => Navigation.intent(context, SendEmailToSupport()),
      title: Text(
        "Submit a Problem",
        style: TextStyleCollection.terminalTextStyle.copyWith(fontSize: 16,color: _isDarkMode?AppColors.pureWhiteColor:AppColors.lightChatConnectionTextColor),
      ),
      leading: const Icon(
        Icons.info,
        color: AppColors.normalBlueColor,
        size: 30,
      ),
      subtitle: Text('Let us know what problem you are facing in this app, so that we can resolve it',
        style: TextStyleCollection.terminalTextStyle.copyWith(
            color: _isDarkMode
                ? AppColors.pureWhiteColor.withOpacity(0.8)
                : AppColors.lightLatestMsgTextColor),
      ),
    );
  }

  // _donateMoney(BuildContext context) {
  //   final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
  //
  //   return ListTile(
  //     onTap: () => Navigation.intent(context, const DonateScreen()),
  //     title: Text(
  //       "Donate",
  //       style: TextStyleCollection.terminalTextStyle.copyWith(fontSize: 16,color: _isDarkMode?AppColors.pureWhiteColor:AppColors.lightChatConnectionTextColor),
  //     ),
  //     leading: Image.asset(
  //       "assets/images/donate.png",
  //       width: 40,
  //     ),
  //     subtitle: Text(
  //       "Help Us to Add More Features and Improve Performances",
  //       style: TextStyleCollection.terminalTextStyle
  //           .copyWith(color: _isDarkMode?AppColors.pureWhiteColor.withOpacity(0.8):AppColors.lightLatestMsgTextColor),
  //     ),
  //   );
  // }
}
