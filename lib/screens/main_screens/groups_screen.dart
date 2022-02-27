import 'package:flutter/material.dart';

import '../../config/colors_collection.dart';
import '../../config/text_collection.dart';
import '../../config/text_style_collection.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  _GroupsScreenState createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundDarkMode,
      body: Align(
        alignment: Alignment.center,
        child: Text(
          "Groups Screen",
          style: TextStyleCollection.secondaryHeadingTextStyle,
        ),
      ),
    );
  }
}
