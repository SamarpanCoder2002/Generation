import 'package:flutter/material.dart';

import '../../config/colors_collection.dart';
import '../../config/text_style_collection.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundDarkMode,
      body: Align(
        alignment: Alignment.center,
        child: Text(
          "Settings Screen",
          style: TextStyleCollection.secondaryHeadingTextStyle,
        ),
      ),
    );
  }
}
