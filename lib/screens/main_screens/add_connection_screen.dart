import 'package:flutter/material.dart';

import '../../config/colors_collection.dart';
import '../../config/text_style_collection.dart';

class AddConnectionScreen extends StatefulWidget {
  const AddConnectionScreen({Key? key}) : super(key: key);

  @override
  _AddConnectionScreenState createState() => _AddConnectionScreenState();
}

class _AddConnectionScreenState extends State<AddConnectionScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundDarkMode,
      body: Align(
        alignment: Alignment.center,
        child: Text(
          "Available Connections Collection",
          style: TextStyleCollection.secondaryHeadingTextStyle,
        ),
      ),
    );
  }
}
