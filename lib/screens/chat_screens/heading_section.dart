import 'dart:io';

import 'package:flutter/material.dart';
import 'package:generation/config/images_path_collection.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/screens/chat_screens/connection_profile_screen.dart';
import 'package:generation/screens/common/common_selection_screen.dart';
import 'package:generation/services/encryption_operations.dart';
import 'package:generation/services/input_system_services.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:generation/services/navigation_management.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/colors_collection.dart';
import '../../config/text_style_collection.dart';
import '../../model/chat_message_model.dart';
import '../../providers/chat/chat_creation_section_provider.dart';
import '../../providers/chat/messaging_provider.dart';
import '../../providers/status_collection_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/device_specific_operations.dart';
import '../../services/local_data_management.dart';
import '../../services/toast_message_show.dart';
import '../../config/types.dart';
import '../common/button.dart';
import '../common/image_showing_screen.dart';

class ChatBoxHeaderSection extends StatelessWidget {
  final Map<String, dynamic> connectionData;
  final BuildContext context;

  const ChatBoxHeaderSection(
      {Key? key, required this.connectionData, required this.context})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _headingSection();
  }

  _headingSection() {
    final _selectedMessages =
        Provider.of<ChatBoxMessagingProvider>(context).getSelectedMessage();

    return Container(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            _backButton(),
            _headerProfilePicSection(),
            if (_selectedMessages.isEmpty) _profileShortInformationSection(),
            //if (_selectedMessages.isEmpty) _terminalSection(),
            //if(_selectedMessages.isNotEmpty) const SizedBox(width: 100,),
            if (_selectedMessages.isNotEmpty)
              _selectedMessagesOperationSection(),
          ],
        ));
  }

  _headerProfilePicSection() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return InkWell(
      onTap: () => _onImageClicked(connectionData["profilePic"]),
      child: Container(
        width: 45,
        height: 45,
        margin: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
            color: _isDarkMode
                ? AppColors.searchBarBgDarkMode.withOpacity(0.5)
                : AppColors.searchBarBgLightMode.withOpacity(0.5),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.darkBorderGreenColor, width: 2),
            image: Secure.decode(connectionData["profilePic"]) == ''
                ? null
                : DecorationImage(
                    image: NetworkImage(
                        Secure.decode(connectionData["profilePic"])),
                    fit: BoxFit.cover)),
      ),
    );
  }

  _profileShortInformationSection() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
    final _connCurrStatus =
        Provider.of<ChatBoxMessagingProvider>(context).getCurrStatus();

    return InkWell(
      onTap: () => Navigation.intent(
          context, ConnectionProfileScreen(connData: connectionData)),
      child: Container(
        width: (MediaQuery.of(context).size.width - 40) / 1.6,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Secure.decode(connectionData["name"]),
                overflow: TextOverflow.ellipsis,
                style: TextStyleCollection.headingTextStyle.copyWith(
                    fontSize: 16,
                    color: AppColors.chatInfoTextColor(_isDarkMode),
                    fontWeight: FontWeight.w600),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _connCurrStatus,
                  style: TextStyleCollection.terminalTextStyle.copyWith(
                      color: AppColors.chatInfoTextColor(_isDarkMode)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _backButton() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return InkWell(
      child: Icon(
        Icons.arrow_back_outlined,
        size: 20,
        color: _isDarkMode
            ? AppColors.pureWhiteColor
            : AppColors.lightChatConnectionTextColor,
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  _selectedMessagesOperationSection() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
    final _selectedMessages =
        Provider.of<ChatBoxMessagingProvider>(context).getSelectedMessage();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(
          width: 10,
        ),
        Text(
          _selectedMessages.length.toString(),
          style: TextStyleCollection.terminalTextStyle.copyWith(
            fontSize: 18,
            color: AppColors.getIconColor(_isDarkMode),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_selectedMessages.length == 1)
              IconButton(
                onPressed: _onReply,
                icon: const Icon(Icons.reply_outlined),
                color: AppColors.getIconColor(_isDarkMode),
              ),
            // const SizedBox(
            //   width: 10,
            // ),
            IconButton(
              icon: Image.asset(
                IconImages.forwardImagePath,
                width: 20,
                color: AppColors.getIconColor(_isDarkMode),
              ),
              onPressed: () => Navigation.intent(
                  context,
                  const CommonSelectionScreen(
                      commonRequirement: CommonRequirement.forwardMsg)),
            ),
            // const SizedBox(
            //   width: 10,
            // ),
            IconButton(
              onPressed: _deleteMsg,
              icon: const Icon(Icons.delete_outline_outlined),
              color: AppColors.getIconColor(_isDarkMode),
            ),
            if (Provider.of<ChatBoxMessagingProvider>(context)
                .eligibleForCopyTextSelMsg())
              IconButton(
                onPressed: _copySelectedMsgData,
                icon: const Icon(Icons.copy_outlined),
                color: AppColors.getIconColor(_isDarkMode),
              ),
            const SizedBox(width: 5),
            _popUpBtnCollection(),
          ],
        ),
      ],
    );
  }

  _onImageClicked(String? photo) {
    if (photo == null) {
      showToast(title: "Image Not Found", toastIconType: ToastIconType.info);
      return;
    }

    final _isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();

    Navigation.intent(
        context,
        ImageShowingScreen(
            imgPath: photo,
            imageType: _getPerfectImageType(photo)), afterWork: () {
      showStatusAndNavigationBar();
      changeOnlyNavigationBarColor(
          navigationBarColor: AppColors.getBgColor(_isDarkMode));
    });
  }

  _getPerfectImageType(String imagePath) {
    if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
      return ImageType.network;
    }
    return ImageType.file;
  }

  void _copySelectedMsgData() {
    final _selectedMessages =
        Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .getSelectedMessage();
    final _selectedMsgData = _selectedMessages.values.toList()[0].message;

    copyText(_selectedMsgData).then((value) =>
        showToast(title: 'Text Copied', toastIconType: ToastIconType.success));
  }

  void _onReply() async {
    final _selectedMessages =
        Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .getSelectedMessage();
    final ChatMessageModel messageData = _selectedMessages.values.toList()[0];
    final String msgKey = _selectedMessages.keys.toList()[0];

    final _msgHolderId =
        messageData.holder == MessageHolderType.other.toString()
            ? Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                .getPartnerUserId()
            : Provider.of<StatusCollectionProvider>(context, listen: false)
                .getCurrentAccData()['id'];

    Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .setReplyHolderMsg(msgKey, messageData, _msgHolderId);
    Provider.of<ChatCreationSectionProvider>(context, listen: false)
        .setSectionHeightForReply();

    Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .clearSelectedMsgCollection();
  }

  void _deleteMsg() {
    final _isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();

    final _eligibleForDeleteForEveryOne =
        Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .eligibleForDeleteForEveryOne();

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 10),
              backgroundColor: AppColors.popUpBgColor(_isDarkMode),
              elevation: 10,
              title: Center(
                child: Text(
                  'Delete this message',
                  textAlign: TextAlign.center,
                  style: TextStyleCollection.headingTextStyle
                      .copyWith(fontSize: 20, color: AppColors.popUpTextColor(_isDarkMode)),
                ),
              ),
              actionsAlignment: _eligibleForDeleteForEveryOne
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              actions: [
                commonTextButton(
                    btnText: "Delete For Me",
                    onPressed: _deleteMyMsgOnly,
                    borderColor: _isDarkMode
                        ? AppColors.darkBorderGreenColor
                        : AppColors.lightBorderGreenColor),
                if (_eligibleForDeleteForEveryOne)
                  commonTextButton(
                      btnText: "Delete For Everyone",
                      onPressed: _deleteForEveryOne,
                      borderColor: _isDarkMode
                          ? AppColors.darkBorderGreenColor
                          : AppColors.lightBorderGreenColor),
              ],
            ));
  }

  void _deleteForEveryOne() async {
    final _selectedMessages =
        Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .getSelectedMessage();
    final msgIdCollection = _selectedMessages.keys.toList();

    final DBOperations _dbOperations = DBOperations();

    bool _sendToRemotely = false;

    for (final msgId in msgIdCollection) {
      _sendToRemotely = await _dbOperations.deleteForEveryoneMsg(
          msgId,
          Provider.of<ChatBoxMessagingProvider>(context, listen: false)
              .getPartnerUserId());
    }

    if (_sendToRemotely) {
      _deleteMyMsgOnly();
      return;
    }

    showToast(
        title: 'Messages Deletion Failed', toastIconType: ToastIconType.error);
  }

  void _deleteMyMsgOnly() async {
    final LocalStorage _localStorage = LocalStorage();
    final tableName = DataManagement.generateTableNameForNewConnectionChat(
        Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .getPartnerUserId());

    final _selectedMessages =
        Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .getSelectedMessage();
    final msgIdCollection = _selectedMessages.keys.toList();

    bool _operationDone = false;

    for (final msgId in msgIdCollection) {
      _operationDone =
          await _localStorage.deleteDataFromParticularChatConnTable(
              tableName: tableName, msgId: msgId);
      if (_operationDone) {
        Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .deleteParticularMessage(msgId);
      }
    }

    if (_operationDone) {
      Provider.of<ChatBoxMessagingProvider>(context, listen: false)
          .clearSelectedMsgCollection();
      showToast(
          title: 'Messages Deleted Successfully',
          toastIconType: ToastIconType.success);
    } else {
      showToast(
          title: 'Failed to Delete Messages',
          toastIconType: ToastIconType.error);
    }

    Navigator.pop(context);
  }

  _popUpBtnCollection() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
    final _selectedMessages =
        Provider.of<ChatBoxMessagingProvider>(context).getSelectedMessage();
    final _selectedMessage =
        (_selectedMessages.values.toList()[0]) as ChatMessageModel;

    return PopupMenuButton(
      color: AppColors.getChatBgColor(_isDarkMode),
      itemBuilder: (BuildContext context) => [
        if (_selectedMessages.length == 1 &&
            _selectedMessage.type != ChatMessageType.contact.toString() &&
            _selectedMessage.type != ChatMessageType.location.toString())
          _shareOption(),
        _selectionClear(),
      ],
      child: Icon(
        Icons.more_vert_outlined,
        color: AppColors.getIconColor(_isDarkMode),
        size: 25,
      ),
    );
  }

  PopupMenuEntry<dynamic> _shareOption() {
    final _isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();
    final _selectedMessages =
        Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .getSelectedMessage();
    final _selectedMessage =
        (_selectedMessages.values.toList()[0]) as ChatMessageModel;
    final InputOption _inputOption = InputOption(context);

    _onShare() {
      if (_selectedMessage.type == ChatMessageType.text.toString()) {
        Share.share(_selectedMessage.message);
        _inputOption.shareTextContent(_selectedMessage.message);
      } else {
        _inputOption.shareFile(File(_selectedMessage.message));
      }
    }

    return PopupMenuItem(
      onTap: _onShare,
      child: Row(
        children: [
          Icon(Icons.share_outlined,
              color: AppColors.getIconColor(_isDarkMode)),
          const SizedBox(
            width: 10,
          ),
          Text(
            'Share',
            style: TextStyleCollection.searchTextStyle
                .copyWith(color: AppColors.getIconColor(_isDarkMode)),
          )
        ],
      ),
    );
  }

  PopupMenuEntry<dynamic> _selectionClear() {
    final _isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();

    return PopupMenuItem(
      onTap: () => Provider.of<ChatBoxMessagingProvider>(context, listen: false)
          .clearSelectedMsgCollection(),
      child: Row(
        children: [
          Icon(Icons.cancel_outlined,
              color: AppColors.getIconColor(_isDarkMode)),
          const SizedBox(
            width: 10,
          ),
          Text(
            'Clear',
            style: TextStyleCollection.searchTextStyle
                .copyWith(color: AppColors.getIconColor(_isDarkMode)),
          )
        ],
      ),
    );
  }
}
