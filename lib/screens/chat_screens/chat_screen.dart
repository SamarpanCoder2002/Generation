import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/providers/chat/messaging_provider.dart';
import 'package:generation/screens/chat_screens/heading_section.dart';
import 'package:generation/screens/chat_screens/message_creation_section.dart';
import 'package:generation/screens/chat_screens/messaging_section.dart';
import 'package:generation/screens/common/scroll_to_hide_widget.dart';
import 'package:generation/services/device_specific_operations.dart';
import 'package:provider/provider.dart';

import '../../providers/chat/chat_creation_section_provider.dart';
import '../../providers/chat/chat_scroll_provider.dart';
import '../../providers/theme_provider.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> connectionData;

  const ChatScreen({Key? key, required this.connectionData}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    final _isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();

    Provider.of<ChatScrollProvider>(context, listen: false).startListening();
    Provider.of<ChatBoxMessagingProvider>(context, listen: false).setPartnerUserId(widget.connectionData["id"]);
    Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .disposeTextFieldOperation();
    Provider.of<ChatBoxMessagingProvider>(context, listen: false).initialize();
    Provider.of<ChatBoxMessagingProvider>(context, listen: false).getMessagesRealtime(widget.connectionData["id"]);

    changeOnlyContextChatColor(_isDarkMode);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return WillPopScope(
      onWillPop: () async{
        final bool _isEmojiSectionShowing =
        Provider.of<ChatCreationSectionProvider>(context, listen: false)
            .getEmojiActivationState();

        if(_isEmojiSectionShowing){
          Provider.of<ChatCreationSectionProvider>(context, listen: false).updateEmojiActivationState(false);
          Provider.of<ChatCreationSectionProvider>(context, listen: false)
              .backToNormalHeight();
          return false;
        }

        Provider.of<ChatScrollProvider>(context, listen: false).stopListening();
        Provider.of<ChatBoxMessagingProvider>(context, listen: false).destroyRealTimeMessaging();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.getChatBgColor(_isDarkMode),
        appBar: _headerSection(),
        bottomSheet: _messageCreationSection(),
        body: _chatCollectionSection(),
      ),
    );
  }

  _headerSection() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme(); 
    
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.getChatBgColor(_isDarkMode),
      automaticallyImplyLeading: false,
      title: ChatBoxHeaderSection(
          connectionData: widget.connectionData, context: context),
    );
  }

  _messageCreationSection() {
    return ScrollToHideWidget(
      scrollController:
          Provider.of<ChatScrollProvider>(context).getController(),
      hideWhenScrollToBottom: false,
      height: Provider.of<ChatCreationSectionProvider>(context)
          .getSectionHeight(context),
      child: BottomSheet(
          enableDrag: false,
          onClosing: () {},
          backgroundColor: AppColors.transparentColor,
          elevation: 0,
          builder: (_) => MessageCreationSection(
                context: context,
              )),
    );
  }

  _chatCollectionSection() => Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.only(top: 2, left: 10, right: 10),
        // // Don't Remove that following code
        // decoration: BoxDecoration(
        //     image: DecorationImage(
        //         fit: BoxFit.cover,
        //         image: NetworkImage(
        //             "https://images.pexels.com/photos/1612461/pexels-photo-1612461.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940"))),
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
