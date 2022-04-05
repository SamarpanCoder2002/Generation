import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:provider/provider.dart';

import '../../config/text_style_collection.dart';
import '../../providers/theme_provider.dart';

class NotificationOptionsScreen extends StatefulWidget {
  const NotificationOptionsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationOptionsScreen> createState() =>
      _NotificationOptionsScreenState();
}

class _NotificationOptionsScreenState extends State<NotificationOptionsScreen> {

  bool _isActive = true;

  @override
  Widget build(BuildContext context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Scaffold(
      backgroundColor: AppColors.getBgColor(_isDarkMode),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.all(20),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          children: [
            _heading(),
            const SizedBox(height: 20),
            _commonSection(title: "Conversation Tone", subTitle: "Play Sounds for incoming and outgoing messages"),
            const SizedBox(height: 5),
            _commonSection(title: "Background Notification", subTitle: "Receive Notification When App is Closed"),
            const SizedBox(height: 5),
            _commonSection(title: "Online Notification", subTitle: "Receive Notification When You Using this App"),
          ],
        ),
      ),
    );
  }

  _heading() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(left: 5),
        child: Row(
          children: [
            InkWell(
              child: Icon(
                Icons.arrow_back_outlined,
                color: _isDarkMode
                    ? AppColors.pureWhiteColor
                    : AppColors.lightChatConnectionTextColor,
              ),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              "Notification",
              style:
                  TextStyleCollection.headingTextStyle.copyWith(fontSize: 20, color: _isDarkMode
                      ? AppColors.pureWhiteColor
                      : AppColors.lightChatConnectionTextColor),
            ),
          ],
        ));
  }

  _commonSection({required String title, required String subTitle}) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return ListTile(
      tileColor: AppColors.getBgColor(_isDarkMode),
      onTap: () {},
      title: Text(
        title,
        style: TextStyleCollection.terminalTextStyle
            .copyWith(fontSize: 16, fontWeight: FontWeight.normal,color: _isDarkMode?AppColors.pureWhiteColor:AppColors.lightChatConnectionTextColor),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(
          subTitle,
          style: TextStyleCollection.terminalTextStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: _isDarkMode?AppColors.pureWhiteColor.withOpacity(0.6):AppColors.lightChatConnectionTextColor.withOpacity(0.6)),
        ),
      ),
      trailing: Switch.adaptive(
        value: _isActive,
        onChanged: (value) {
          setState(() {
            _isActive = value;
          });
        },
        activeTrackColor: _isDarkMode?AppColors.darkBorderGreenColor.withOpacity(0.8):AppColors.lightBorderGreenColor.withOpacity(0.8),
        activeColor: AppColors.locationIconBgColor,
        inactiveTrackColor: _isDarkMode?AppColors.oppositeMsgDarkModeColor:AppColors.pureBlackColor.withOpacity(0.2),
      ),
    );
  }
}
