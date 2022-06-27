import 'package:flutter/material.dart';
import 'package:generation/config/text_collection.dart';
import 'package:generation/screens/settings/chat_wallpaper/chat_wallpaper_category_screen.dart';
import 'package:generation/screens/settings/inner_settings.dart';
import 'package:generation/screens/settings/support/support_management.dart';
import 'package:generation/services/input_system_services.dart';
import 'package:generation/services/navigation_management.dart';
import 'package:provider/provider.dart';

import '../../config/colors_collection.dart';
import '../../config/text_style_collection.dart';
import '../../providers/main_scrolling_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/device_specific_operations.dart';
import '../../config/types.dart';
import '../settings/about.dart';
import '../common/common_selection_screen.dart';
import '../settings/profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    Provider.of<MainScrollingProvider>(context, listen: false).startListening();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Scaffold(
      backgroundColor: AppColors.getBgColor(_isDarkMode),
      body: Container(
          margin: const EdgeInsets.only(top: 30, left: 20, right: 20),
          height: MediaQuery.of(context).size.height * 0.9,
          width: MediaQuery.of(context).size.width,
          child: _settingsBody()),
    );
  }

  _headingSection() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(left: 23),
        child: Text(
          "Settings",
          style: TextStyleCollection.headingTextStyle.copyWith(
              fontSize: 20,
              color: _isDarkMode
                  ? AppColors.pureWhiteColor
                  : AppColors.lightChatConnectionTextColor),
        ));
  }

  _themeManager() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Theme(
      data: Theme.of(context).copyWith(
          backgroundColor: AppColors.getBgColor(_isDarkMode),
          dividerColor: AppColors.transparentColor),
      child: ExpansionTile(
        backgroundColor: AppColors.getBgColor(_isDarkMode),
        leading: Icon(
          Icons.invert_colors_on_outlined,
          color: AppColors.getIconColor(_isDarkMode),
        ),
        title: Text(
          "App theme",
          style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
            fontSize: 16,
            color: _isDarkMode
                ? AppColors.pureWhiteColor
                : AppColors.lightChatConnectionTextColor,
            fontWeight: FontWeight.normal,
          ),
        ),
        trailing: Icon(
          Icons.arrow_drop_down_outlined,
          size: 22,
          color: AppColors.getIconColor(_isDarkMode),
        ),
        children: [
          _themeModeOption(
              tileText: "System Theme",
              correspondingTheme: ThemeModeTypes.systemMode),
          _themeModeOption(
              tileText: "Dark Theme",
              correspondingTheme: ThemeModeTypes.darkMode),
          _themeModeOption(
              tileText: "Light Theme",
              correspondingTheme: ThemeModeTypes.lightMode),
        ],
      ),
    );
  }

  _themeModeOption(
      {required String tileText, required ThemeModeTypes correspondingTheme}) {
    final themeProviderRef = Provider.of<ThemeProvider>(context);
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return TextButton(
        onPressed: () async {
          final _isDarkMode =
              await Provider.of<ThemeProvider>(context, listen: false)
                  .setThemeData(correspondingTheme);
          changeContextTheme(_isDarkMode);
        },
        child: ListTile(
          visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
          dense: true,
          leading: Icon(
            themeProviderRef.isThatCurrentTheme(correspondingTheme)
                ? Icons.circle_rounded
                : Icons.circle_outlined,
            color: AppColors.getIconColor(_isDarkMode),
            size: 18,
          ),
          contentPadding: const EdgeInsets.only(left: 20),
          title: Text(
            tileText,
            style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
                color: _isDarkMode
                    ? AppColors.pureWhiteColor
                    : AppColors.lightChatConnectionTextColor),
          ),
        ));
  }

  _commonOption(
      {required IconData leadingIconData,
      required String title,
      required IconData? terminalIconData,
      required VoidCallback onPressed}) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

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
                  color: AppColors.getIconColor(_isDarkMode),
                ),
                const SizedBox(
                  width: 30,
                ),
                Text(
                  title,
                  style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: _isDarkMode
                          ? AppColors.pureWhiteColor
                          : AppColors.lightChatConnectionTextColor),
                )
              ],
            ),
            if (terminalIconData != null)
              Icon(
                terminalIconData,
                color: AppColors.getIconColor(_isDarkMode),
                size: 15,
              ),
          ],
        ),
      ),
    );
  }

  _settingsBody() {
    final ScrollController _settingsScrollController =
        Provider.of<MainScrollingProvider>(context).getScrollController();

    final InputOption _inputOption = InputOption(context);
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

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
            onPressed: () => Navigation.intent(context, const ProfileScreen())),
        _commonOption(
            leadingIconData: Icons.settings,
            title: "Settings",
            terminalIconData: Icons.arrow_forward_ios_outlined,
            onPressed: () =>
                Navigation.intent(context, const InnerSettingsScreen())),
        _commonOption(
            leadingIconData: Icons.wallpaper_outlined,
            title: "Chat WallPaper",
            terminalIconData: Icons.arrow_forward_ios_outlined,
            onPressed: () =>
                Navigation.intent(context, const ChatWallpaperScreen())),
        _commonOption(
            leadingIconData: Icons.history_edu_outlined,
            title: "Chat History",
            terminalIconData: Icons.arrow_forward_ios_outlined,
            onPressed: () => Navigation.intent(
                context,
                const CommonSelectionScreen(
                  commonRequirement: CommonRequirement.chatHistory,
                ))),
        // _commonOption(
        //     leadingIconData: Icons.backup_outlined,
        //     title: "Chat Backup",
        //     terminalIconData: Icons.arrow_forward_ios_outlined,
        //     onPressed: () =>
        //         Navigation.intent(context, const ChatBackupSettingsScreen())),
        _commonOption(
            leadingIconData: Icons.storage,
            title: "Storage",
            terminalIconData: Icons.arrow_forward_ios_outlined,
            onPressed: () => Navigation.intent(
                context,
                const CommonSelectionScreen(
                    commonRequirement: CommonRequirement.localDataStorage))),
        _commonOption(
            leadingIconData: Icons.support_agent_outlined,
            title: "Support",
            terminalIconData: Icons.arrow_forward_ios_outlined,
            onPressed: () => Navigation.intent(context, const SupportScreen())),
        _commonOption(
            leadingIconData: Icons.info_outlined,
            title: "About",
            terminalIconData: Icons.arrow_forward_ios_outlined,
            onPressed: () => Navigation.intent(context, const AboutScreen())),
        _commonOption(
            leadingIconData: Icons.people_outline_outlined,
            title: "Invite a Friend",
            terminalIconData: null,
            onPressed: () =>
                _inputOption.shareTextContent(TextCollection.appShareData)),
        const SizedBox(
          height: 40,
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Created By ",
                  style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
                      color: _isDarkMode
                          ? AppColors.pureWhiteColor
                          : AppColors.lightChatConnectionTextColor)),
              InkWell(
                onTap: _onClickMyName,
                child: Text(
                  TextCollection.appCreator,
                  style: TextStyleCollection.secondaryHeadingTextStyle
                      .copyWith(color: AppColors.normalBlueColor),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  void _onClickMyName() {
    final InputOption _inputOption = InputOption(context);
    _inputOption.openUrl(TextCollection.myWebsite);
  }
}
