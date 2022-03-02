import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/colors_collection.dart';
import '../../config/text_collection.dart';
import '../../config/text_style_collection.dart';
import '../../providers/theme_provider.dart';
import '../../types/types.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkMode,
      body: Container(
          margin: const EdgeInsets.only(top: 2, left: 20, right: 20),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            shrinkWrap: true,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              _headingSection(),
              const SizedBox(height: 15),
              _settingsCollection(),
            ],
          )),
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

  _settingsCollection() {
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
}
