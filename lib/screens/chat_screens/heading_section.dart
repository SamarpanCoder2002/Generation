import 'package:flutter/material.dart';
import 'package:generation/config/images_path_collection.dart';
import 'package:generation/screens/chat_screens/connection_profile_screen.dart';
import 'package:generation/screens/common/common_selection_screen.dart';
import 'package:generation/services/navigation_management.dart';
import 'package:provider/provider.dart';

import '../../config/colors_collection.dart';
import '../../config/text_style_collection.dart';
import '../../providers/chat/messaging_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/device_specific_operations.dart';
import '../../services/toast_message_show.dart';
import '../../types/types.dart';
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
      onTap: () =>  _onImageClicked(connectionData["profilePic"]),
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
            image: connectionData["profilePic"] == null
                ? null
                : DecorationImage(
                    image: NetworkImage(connectionData["profilePic"]),
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
                connectionData["name"],
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
          width: 18,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_selectedMessages.length == 1)
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.reply_outlined),
                color: AppColors.getIconColor(_isDarkMode),
              ),
            const SizedBox(
              width: 10,
            ),
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
            const SizedBox(
              width: 10,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.delete_outline_outlined),
              color: AppColors.getIconColor(_isDarkMode),
            ),
            if (Provider.of<ChatBoxMessagingProvider>(context)
                .eligibleForCopyTextSelMsg())
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.copy_outlined),
                color: AppColors.getIconColor(_isDarkMode),
              ),
            IconButton(
              onPressed: () =>
                  Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                      .clearSelectedMsgCollection(),
              icon: const Icon(Icons.cancel_outlined),
              color: AppColors.getIconColor(_isDarkMode),
            ),
          ],
        ),
      ],
    );
  }

  _onImageClicked(String? photo) {
    if (photo == null) {
      showToast(context,
          title: "Image Not Found", toastIconType: ToastIconType.info);
      return;
    }

    final _isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();

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
}
