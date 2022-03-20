import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/screens/common/button.dart';

import '../../config/text_style_collection.dart';

class ChatBackupSettingsScreen extends StatefulWidget {
  const ChatBackupSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ChatBackupSettingsScreen> createState() =>
      _ChatBackupSettingsScreenState();
}

class _ChatBackupSettingsScreenState extends State<ChatBackupSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _headerSection(),
      backgroundColor: AppColors.backgroundDarkMode,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                title: Text(
                  "Backup",
                  style: TextStyleCollection.terminalTextStyle
                      .copyWith(fontSize: 16),
                ),
                subtitle: Text(
                  "Stored Data Will Be End-To-End-Encypted",
                  style: TextStyleCollection.terminalTextStyle.copyWith(
                      color: AppColors.pureWhiteColor.withOpacity(0.8)),
                ),
                trailing:
                    commonElevatedButton(btnText: "Start", onPressed: () {}),
              ),
            ],
          ),
        ),
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
              "Backup Settings",
              style:
                  TextStyleCollection.terminalTextStyle.copyWith(fontSize: 16),
            ),
          ],
        ),
      );
}
