import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/screens/settings/support/donate_screen.dart';
import 'package:generation/screens/settings/support/send_email_to_support.dart';
import 'package:generation/services/navigation_management.dart';

import '../../../config/text_style_collection.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _headerSection(context),
      backgroundColor: AppColors.backgroundDarkMode,
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
              _donateMoney(context)
            ],
          ),
        ),
      ),
    );
  }

  _headerSection(BuildContext context) => AppBar(
        elevation: 0,
        backgroundColor: AppColors.chatDarkBackgroundColor,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_outlined)),
            Text(
              "Support",
              style:
                  TextStyleCollection.terminalTextStyle.copyWith(fontSize: 16),
            ),
          ],
        ),
      );

  _submitProblem(BuildContext context) => ListTile(
        onTap: () => Navigation.intent(context, SendEmailToSupport()),
        title: Text(
          "Submit a Problem",
          style: TextStyleCollection.terminalTextStyle.copyWith(fontSize: 16),
        ),
        leading: const Icon(
          Icons.info,
          color: AppColors.normalBlueColor,
          size: 30,
        ),
      );

  _donateMoney(BuildContext context) => ListTile(
        onTap: () => Navigation.intent(context, const DonateScreen()),
        title: Text(
          "Donate",
          style: TextStyleCollection.terminalTextStyle.copyWith(fontSize: 16),
        ),
        leading: Image.asset(
          "assets/images/donate.png",
          width: 40,
        ),
        subtitle: Text(
          "Help Us to Add More Features and Improve Performances",
          style: TextStyleCollection.terminalTextStyle
              .copyWith(color: AppColors.pureWhiteColor.withOpacity(0.8)),
        ),
      );
}
