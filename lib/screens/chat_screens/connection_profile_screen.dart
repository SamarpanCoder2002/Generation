import 'dart:io';

import 'package:flutter/material.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:provider/provider.dart';

import '../../config/colors_collection.dart';
import '../../config/text_style_collection.dart';
import '../../providers/theme_provider.dart';
import '../../services/device_specific_operations.dart';
import '../../services/navigation_management.dart';
import '../../types/types.dart';
import '../common/image_showing_screen.dart';

class ConnectionProfileScreen extends StatefulWidget {
  final Map<String, dynamic> connData;

  const ConnectionProfileScreen({Key? key, required this.connData})
      : super(key: key);

  @override
  State<ConnectionProfileScreen> createState() =>
      _ConnectionProfileScreenState();
}

class _ConnectionProfileScreenState extends State<ConnectionProfileScreen> {
  final LocalStorage _localStorage = LocalStorage();
  final bool _isLoading = false;
  String _notificationStatus = "";

  _initialize() async {
    final _connData =
        await _localStorage.getConnectionPrimaryData(id: widget.connData["id"]);
    if (mounted) {
      setState(() {
        _notificationStatus =
            _connData["notification"] == NotificationType.muted.toString()
                ? "Mute"
                : "Unmute";
      });
    }
  }

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Scaffold(
      backgroundColor: AppColors.getBgColor(_isDarkMode),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.all(20),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          children: [
            if (_isLoading) _loadingIndicator(),
            if (_isLoading)
              const SizedBox(
                height: 20,
              ),
            _heading(),
            _profileImageSection(),
            const SizedBox(height: 30),
            _commonSection(
                iconData: Icons.account_circle_outlined,
                heading: "Name",
                nameValue: widget.connData["name"] ?? ""),
            const SizedBox(height: 30),
            _commonSection(
                iconData: Icons.info_outlined,
                heading: "About",
                nameValue: widget.connData["about"] ?? ""),
            const SizedBox(height: 30),
            _commonSection(
                iconData: Icons.email_outlined,
                heading: "Email",
                nameValue: widget.connData["email"] ?? ""),
            const SizedBox(height: 30),
            _commonSection(
                iconData: _notificationStatus == "Muted"
                    ? Icons.notifications_off_outlined
                    : Icons.notifications_none,
                heading: "Notification",
                nameValue: _notificationStatus, onPressed: (){}),
            const SizedBox(height: 30),
            _commonInputSection(
                iconData: Icons.wallpaper_outlined,
                text: 'Chat Wallpaper',
                onPressed: () {}),
            const SizedBox(height: 30),
            _commonInputSection(
                iconData: Icons.perm_media_outlined,
                text: 'Media',
                onPressed: () {}),
            const SizedBox(height: 30),
            _commonInputSection(
                iconData: Icons.person_add_disabled,
                text: 'Remove Connection',
                startIconColor: AppColors.lightRedColor,
                terminalIconData: Icons.delete_outline_outlined,
                textColor: AppColors.lightRedColor,
                onPressed: () {},
                terminalIconColor: AppColors.lightRedColor),
          ],
        ),
      ),
    );
  }

  _loadingIndicator() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 3,
      child: const LinearProgressIndicator(
        backgroundColor: AppColors.pureWhiteColor,
        color: AppColors.darkBorderGreenColor,
      ),
    );
  }

  _heading() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(left: 5),
        child: Row(
          children: [
            InkWell(
              child: Icon(
                Icons.arrow_back_outlined,
                color: _isDarkMode
                    ? AppColors.pureWhiteColor
                    : AppColors.lightChatConnectionTextColor,
              ),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              "Profile",
              style: TextStyleCollection.headingTextStyle.copyWith(
                  fontSize: 20,
                  color: _isDarkMode
                      ? AppColors.pureWhiteColor
                      : AppColors.lightChatConnectionTextColor),
            ),
          ],
        ));
  }

  _profileImageSection() {
    return widget.connData.isEmpty
        ? const Center()
        : Center(
            child: _imageSection(),
          );
  }

  _imageSection() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return InkWell(
      onTap: () async {
        Navigation.intent(
            context,
            ImageShowingScreen(
                imgPath: widget.connData["profilePic"],
                imageType: widget.connData["profilePic"].startsWith("https")
                    ? ImageType.network
                    : ImageType.file), afterWork: () {
          showStatusAndNavigationBar();

          changeOnlyNavigationBarColor(
              navigationBarColor: AppColors.getBgColor(_isDarkMode));
        });
      },
      child: Container(
        width: 125,
        height: 125,
        margin: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: AppColors.getImageBgColor(_isDarkMode),
            border: Border.all(color: AppColors.darkBorderGreenColor, width: 3),
            image: widget.connData["profilePic"]?.startsWith("https")
                ? DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(widget.connData["profilePic"]),
                  )
                : DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(File(widget.connData["profilePic"])),
                  )),
      ),
    );
  }

  _commonSection(
      {required IconData iconData,
      required String heading,
      required String nameValue, VoidCallback? onPressed, IconData? terminalIconData, Color? terminalIconColor}) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return widget.connData.isEmpty
        ? const Center()
        : SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _nameLeftSection(
                    iconData: iconData, heading: heading, nameValue: nameValue),
                if(onPressed != null)
                  InkWell(
                      onTap: onPressed,
                      child: Icon(
                        terminalIconData ?? Icons.edit_rounded,
                        color:
                        terminalIconColor ?? AppColors.getIconColor(_isDarkMode),
                      ))
              ],
            )


          );
  }

  _nameLeftSection(
      {required IconData iconData,
      required String heading,
      required String nameValue}) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Row(
      children: [
        Icon(
          iconData,
          color: AppColors.darkBorderGreenColor,
          size: 25,
        ),
        const SizedBox(
          width: 15,
        ),
        Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width - 40 - 100,
              child: Text(
                heading,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyleCollection.terminalTextStyle.copyWith(
                    color: _isDarkMode
                        ? AppColors.pureWhiteColor.withOpacity(0.6)
                        : AppColors.lightChatConnectionTextColor
                            .withOpacity(0.6)),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 40 - 100,
              child: Text(
                nameValue,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
                    fontSize: 14,
                    color: _isDarkMode
                        ? AppColors.pureWhiteColor
                        : AppColors.lightChatConnectionTextColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  _commonInputSection(
      {required IconData iconData,
      required String text,
      VoidCallback? onPressed,
      IconData? terminalIconData,
      Color? terminalIconColor,
      Color? textColor,
      Color? startIconColor}) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _commonInputLeftSection(
              iconData: iconData,
              text: text,
              textColor: textColor,
              startIconColor: startIconColor),
          if (onPressed != null)
            InkWell(
                onTap: onPressed,
                child: Icon(
                  terminalIconData ?? Icons.edit_rounded,
                  color:
                      terminalIconColor ?? AppColors.getIconColor(_isDarkMode),
                ))
        ],
      ),
    );
  }

  _commonInputLeftSection(
      {required IconData iconData,
      required String text,
      Color? textColor,
      Color? startIconColor}) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Row(
      children: [
        Icon(
          iconData,
          color: startIconColor ?? AppColors.darkBorderGreenColor,
          size: 25,
        ),
        const SizedBox(
          width: 15,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width - 40 - 100,
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
                fontSize: 14,
                color: textColor ??
                    (_isDarkMode
                        ? AppColors.pureWhiteColor
                        : AppColors.lightChatConnectionTextColor)),
          ),
        ),
      ],
    );
  }
}
