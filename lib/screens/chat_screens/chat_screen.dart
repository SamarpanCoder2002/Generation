import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/screens/chat_screens/heading_section.dart';
import 'package:generation/screens/chat_screens/message_creation_section.dart';
import 'package:generation/screens/chat_screens/messaging_section.dart';

import '../../config/text_collection.dart';
import '../../config/text_style_collection.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> connectionData;

  const ChatScreen({Key? key, required this.connectionData}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.chatDarkBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.chatDarkBackgroundColor,
        automaticallyImplyLeading: false,
        title:  ChatBoxHeaderSection(
            connectionData: widget.connectionData, context: context),
      ),
      bottomSheet: BottomSheet(
          onClosing: () {},
          backgroundColor: AppColors.chatDarkBackgroundColor,
          elevation: 0,
          builder: (BuildContext _) => MessageCreationSection(
                context: context,
              )),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.only(top: 2, left: 20, right: 20),
        child: ListView(
          shrinkWrap: true,
          children: [

            //
            // const SizedBox(
            //   height: 10,
            // ),
            MessagingSection(context: context),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
