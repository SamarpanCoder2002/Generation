import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/providers/messaging_provider.dart';
import 'package:generation/providers/sound_record_provider.dart';
import 'package:generation/screens/chat_screens/heading_section.dart';
import 'package:generation/screens/chat_screens/message_creation_section.dart';
import 'package:generation/screens/chat_screens/messaging_section.dart';
import 'package:generation/screens/common/scroll_to_hide_widget.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_scroll_provider.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> connectionData;

  const ChatScreen({Key? key, required this.connectionData}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    Provider.of<ChatScrollProvider>(context, listen: false).startListening();
    Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .disposeTextFieldOperation();
    Provider.of<ChatBoxMessagingProvider>(context, listen: false).initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.chatDarkBackgroundColor,
      appBar: _headerSection(),
      bottomSheet: _messageCreationSection(),
      body: _chatCollectionSection(),
    );
  }

  _headerSection() => AppBar(
        elevation: 0,
        backgroundColor: AppColors.chatDarkBackgroundColor,
        automaticallyImplyLeading: false,
        title: ChatBoxHeaderSection(
            connectionData: widget.connectionData, context: context),
      );

  _messageCreationSection() => ScrollToHideWidget(
        scrollController:
            Provider.of<ChatScrollProvider>(context).getController(),
        hideWhenScrollToBottom: false,
        child: BottomSheet(
            enableDrag: false,
            onClosing: () {},
            backgroundColor: AppColors.chatDarkBackgroundColor,
            elevation: 0,
            builder: (_) => MessageCreationSection(
                  context: context,
                )),
      );

  _chatCollectionSection() => Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.only(top: 2, left: 10, right: 10),
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(
              height: 10,
            ),
            MessagingSection(context: context),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      );
}
