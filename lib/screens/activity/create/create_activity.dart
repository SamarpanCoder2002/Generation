import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';

import '../../../config/text_style_collection.dart';

class CreateActivity extends StatefulWidget {
  const CreateActivity({Key? key}) : super(key: key);

  @override
  State<CreateActivity> createState() => _CreateActivityState();
}

class _CreateActivityState extends State<CreateActivity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _headerSection(),
      backgroundColor: AppColors.backgroundDarkMode,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,

      ),
    );
  }
  _headerSection() => AppBar(
    elevation: 0,
    backgroundColor: AppColors.chatDarkBackgroundColor,
    automaticallyImplyLeading: false,
    title: Row(
      children: [
        IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_outlined)),
        Text(
          "Wallpaper Management",
          style:
          TextStyleCollection.terminalTextStyle.copyWith(fontSize: 16),
        ),
      ],
    ),
  );
}
