import 'dart:io';

import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/providers/chat/messaging_provider.dart';
import 'package:generation/providers/sound_provider.dart';
import 'package:generation/screens/chat_screens/heading_section.dart';
import 'package:generation/screens/chat_screens/message_creation_section.dart';
import 'package:generation/screens/chat_screens/messaging_section.dart';
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
    final _isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();

    Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .setContext(context);
    Provider.of<ChatScrollProvider>(context, listen: false).startListening();
    Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .setPartnerUserId(widget.connectionData["id"]);
    Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .disposeTextFieldOperation();
    Provider.of<ChatBoxMessagingProvider>(context, listen: false).initialize();
    Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .getChatWallpaperData(widget.connectionData["id"]);
    Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .getOldStoredChatMessages();
    Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .getConnectionDataRealTime(widget.connectionData["id"], context);
    Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .getSpecialOperationDataRealTime(widget.connectionData["id"]);

    changeOnlyContextChatColor(_isDarkMode);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return WillPopScope(
      onWillPop: () async {
        final bool _isEmojiSectionShowing =
            Provider.of<ChatCreationSectionProvider>(context, listen: false)
                .getEmojiActivationState();

        if (_isEmojiSectionShowing) {
          Provider.of<ChatCreationSectionProvider>(context, listen: false)
              .updateEmojiActivationState(false);
          Provider.of<ChatCreationSectionProvider>(context, listen: false)
              .backToNormalHeightForEmoji();
          return false;
        }

        final _selectedMessages =
            Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                .getSelectedMessage()
                .isNotEmpty;
        if (_selectedMessages) {
          Provider.of<ChatBoxMessagingProvider>(context, listen: false)
              .clearSelectedMsgCollection();
          return false;
        }

        final _isThereReplyMsg =
            Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                .isThereReplyMsg;
        if (_isThereReplyMsg) {
          Provider.of<ChatBoxMessagingProvider>(context, listen: false)
              .removeReplyMsg();
          Provider.of<ChatCreationSectionProvider>(context, listen: false)
              .backToNormalHeightForReply();
          return false;
        }

        Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .destroyRealTimeMessaging();
        Provider.of<ChatScrollProvider>(context, listen: false).stopListening();
        Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .clearMessageData();
        Provider.of<ChatScrollProvider>(context, listen: false)
            .changeScrollAtFirstValue(true);
        Provider.of<SongManagementProvider>(context,listen: false).stopSong();
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
    return BottomSheet(
        enableDrag: false,
        onClosing: () {},
        backgroundColor: AppColors.transparentColor,
        elevation: 0,
        builder: (_) => MessageCreationSection(
              context: context,
            ));

    // return ScrollToHideWidget(
    //   scrollController:
    //       Provider.of<ChatScrollProvider>(context).getController(),
    //   hideWhenScrollToBottom: false,
    //   height: Provider.of<ChatCreationSectionProvider>(context)
    //       .getSectionHeight(context),
    //   child: BottomSheet(
    //       enableDrag: false,
    //       onClosing: () {},
    //       backgroundColor: AppColors.transparentColor,
    //       elevation: 0,
    //       builder: (_) => MessageCreationSection(
    //             context: context,
    //           )),
    // );
  }

  _chatCollectionSection() {
    final _connWallpaper =
        Provider.of<ChatBoxMessagingProvider>(context).getConnectionWallpaper();

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.only(top: 2, left: 10, right: 10),
      decoration: _connWallpaper != null && _connWallpaper != ''
          ? BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover, image: FileImage(File(_connWallpaper))))
          : null,
      child: ListView(
        shrinkWrap: true,
        children: [
          const SizedBox(
            height: 10,
          ),
          MessagingSection(
            context: context,
            connData: widget.connectionData,
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
