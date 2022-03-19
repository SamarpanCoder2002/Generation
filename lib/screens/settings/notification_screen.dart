import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';

import '../../config/text_style_collection.dart';

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
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkMode,
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
    return Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(left: 5),
        child: Row(
          children: [
            InkWell(
              child: const Icon(
                Icons.arrow_back_outlined,
                color: AppColors.pureWhiteColor,
              ),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              "Notification",
              style:
                  TextStyleCollection.headingTextStyle.copyWith(fontSize: 20),
            ),
          ],
        ));
  }

  _commonSection({required String title, required String subTitle}) {
    return ListTile(
      tileColor: AppColors.backgroundDarkMode,
      onTap: () {},
      title: Text(
        title,
        style: TextStyleCollection.terminalTextStyle
            .copyWith(fontSize: 16, fontWeight: FontWeight.normal),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(
          subTitle,
          style: TextStyleCollection.terminalTextStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: AppColors.pureWhiteColor.withOpacity(0.6)),
        ),
      ),
      trailing: Switch.adaptive(
        value: _isActive,
        onChanged: (value) {
          setState(() {
            _isActive = value;
          });
        },
        activeTrackColor: AppColors.darkBorderGreenColor.withOpacity(0.8),
        activeColor: AppColors.locationIconBgColor,
        inactiveTrackColor: AppColors.oppositeMsgDarkModeColor,
      ),
    );
  }
}
