import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/colors_collection.dart';
import '../../config/text_style_collection.dart';
import '../../providers/common_scroll_controller_provider.dart';
import '../../providers/theme_provider.dart';
import '../../types/types.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  void initState() {
    Provider.of<MessageScreenScrollingProvider>(context, listen: false)
        .startListening();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkMode,
      body: Container(
          margin: const EdgeInsets.only(top: 30, left: 20, right: 20),
          height: MediaQuery.of(context).size.height * 0.9,
          width: MediaQuery.of(context).size.width,
          child: _settingsBody()),
    );
  }

  _headingSection() {
    return Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(left: 23),
        child: Text(
          "Settings",
          style: TextStyleCollection.headingTextStyle.copyWith(fontSize: 20),
        ));
  }

  _themeManager() {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        backgroundColor: AppColors.backgroundDarkMode,
        leading: const Icon(
          Icons.invert_colors_on_outlined,
          color: AppColors.pureWhiteColor,
        ),
        title: Text(
          "App theme",
          style: TextStyleCollection.secondaryHeadingTextStyle
              .copyWith(fontSize: 16),
        ),
        trailing: const Icon(
          Icons.arrow_drop_down_outlined,
          size: 22,
          color: AppColors.pureWhiteColor,
        ),
        children: [
          _themeModeOption(
              tileText: "System Theme",
              correspondingTheme: ThemeModeTypes.systemMode),
          _themeModeOption(
              tileText: "Dark Theme",
              correspondingTheme: ThemeModeTypes.lightMode),
          _themeModeOption(
              tileText: "Light Theme",
              correspondingTheme: ThemeModeTypes.darkMode),
        ],
      ),
    );
  }

  _themeModeOption(
      {required String tileText, required ThemeModeTypes correspondingTheme}) {
    final themeProviderRef = Provider.of<ThemeProvider>(context);

    return TextButton(
        onPressed: () async {
          Provider.of<ThemeProvider>(context, listen: false)
              .setCurrentTheme(correspondingTheme);
        },
        child: ListTile(
          visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
          dense: true,
          leading: Icon(
            themeProviderRef.getThemeDataValidation(correspondingTheme)
                ? Icons.circle_rounded
                : Icons.circle_outlined,
            color: AppColors.pureWhiteColor,
            size: 18,
          ),
          contentPadding: const EdgeInsets.only(left: 20),
          title: Text(
            tileText,
            style: TextStyleCollection.secondaryHeadingTextStyle,
          ),
        ));
  }

  _commonOption(
      {required IconData leadingIconData,
      required String title,
      required IconData? terminalIconData,
      required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 60,
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  leadingIconData,
                  color: AppColors.pureWhiteColor,
                ),
                const SizedBox(
                  width: 30,
                ),
                Text(
                  title,
                  style: TextStyleCollection.secondaryHeadingTextStyle
                      .copyWith(fontSize: 16, fontWeight: FontWeight.normal),
                )
              ],
            ),
            if(terminalIconData != null)
            Icon(
              terminalIconData,
              color: AppColors.pureWhiteColor,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  _settingsBody() {
    final ScrollController _settingsScrollController =
    Provider.of<MessageScreenScrollingProvider>(context)
        .getScrollController();

    return ListView(
      shrinkWrap: true,
      controller: _settingsScrollController,
      children: [
        _headingSection(),
        const SizedBox(height: 15),
        _themeManager(),
        _commonOption(
            leadingIconData: Icons.perm_identity_outlined,
            title: "Profile",
            terminalIconData: Icons.arrow_forward_ios_outlined,
            onPressed: () {}),
        _commonOption(
            leadingIconData: Icons.notification_important_outlined,
            title: "Notification",
            terminalIconData: Icons.arrow_forward_ios_outlined,
            onPressed: () {}),
        _commonOption(
            leadingIconData: Icons.wallpaper_outlined,
            title: "Chat WallPaper",
            terminalIconData: Icons.arrow_forward_ios_outlined,
            onPressed: () {}),
        _commonOption(
            leadingIconData: Icons.history_edu_outlined,
            title: "Chat History",
            terminalIconData: Icons.arrow_forward_ios_outlined,
            onPressed: () {}),
        _commonOption(
            leadingIconData: Icons.backup_outlined,
            title: "Chat Backup",
            terminalIconData: Icons.arrow_forward_ios_outlined,
            onPressed: () {}),
        _commonOption(
            leadingIconData: Icons.storage,
            title: "Storage",
            terminalIconData: Icons.arrow_forward_ios_outlined,
            onPressed: () {}),
        _commonOption(
            leadingIconData: Icons.support_agent_outlined,
            title: "Support",
            terminalIconData: Icons.arrow_forward_ios_outlined,
            onPressed: () {}),
        _commonOption(
            leadingIconData: Icons.info_outlined,
            title: "About",
            terminalIconData: Icons.arrow_forward_ios_outlined,
            onPressed: () {}),
        _commonOption(
            leadingIconData: Icons.people_outline_outlined,
            title: "Invite a Friend",
            terminalIconData: null,
            onPressed: () {}),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.08,
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Created By ", style: TextStyleCollection.secondaryHeadingTextStyle),
              Text("Samarpan Dasgupta", style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(color: AppColors.normalBlueColor),)
            ],
          ),
        )
      ],
    );
  }
}
