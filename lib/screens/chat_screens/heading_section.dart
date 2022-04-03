import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:generation/config/images_path_collection.dart';
import 'package:provider/provider.dart';

import '../../config/colors_collection.dart';
import '../../config/text_style_collection.dart';
import '../../providers/theme_provider.dart';
import '../../services/toast_message_show.dart';
import '../../types/types.dart';

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
    return Container(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            _backButton(),
            _headerProfilePicSection(),
            _profileShortInformationSection(),
            _terminalSection(),
          ],
        ));
  }

  _headerProfilePicSection() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
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
    );
  }

  _profileShortInformationSection() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
      width: (MediaQuery.of(context).size.width - 40) / 1.7,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              connectionData["connectionName"],
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
                "Online",
                style: TextStyleCollection.terminalTextStyle
                    .copyWith(color: AppColors.chatInfoTextColor(_isDarkMode)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _terminalSection() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return InkWell(
      child: Image.asset(
        IconImages.videoImagePath,
        width: 30,
        color: AppColors.getIconColor(_isDarkMode),
      ),
      onTap: () {
        print("Video clickjed");

        showToast(context,
            title: "Map will show within few seconds",
            toastIconType: ToastIconType.info,
            toastDuration: 12);
      },
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
}
