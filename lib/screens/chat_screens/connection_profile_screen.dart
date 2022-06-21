import 'dart:io';

import 'package:flutter/material.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/screens/settings/chat_wallpaper/chat_wallpaper_category_screen.dart';
import 'package:generation/services/encryption_operations.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:provider/provider.dart';

import '../../config/colors_collection.dart';
import '../../config/text_style_collection.dart';
import '../../providers/chat/messaging_provider.dart';
import '../../providers/storage/storage_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/debugging.dart';
import '../../services/device_specific_operations.dart';
import '../../services/navigation_management.dart';
import '../../config/types.dart';
import '../common/image_showing_screen.dart';
import '../settings/storage/storage_screen.dart';

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
  final DBOperations _dbOperations = DBOperations();
  final bool _isLoading = false;

  bool _isNotificationActive = false;

  _initialize() async {
    print('Here');
    String _oldNotificationStatus =
        (await _localStorage.getConnectionPrimaryData(
                id: widget.connData["id"]))["notificationManually"];

    print('Local Notification Status: $_oldNotificationStatus');

    if (mounted) {
      setState(() {
        _isNotificationActive =
            _oldNotificationStatus == NotificationType.unMuted.toString();
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
                nameValue: Secure.decode(widget.connData["name"])),
            const SizedBox(height: 30),
            _commonSection(
                iconData: Icons.info_outlined,
                heading: "About",
                nameValue: Secure.decode(widget.connData["about"])),
            const SizedBox(height: 30),
            _commonSection(
                iconData: Icons.email_outlined,
                heading: "Email",
                nameValue: Secure.decode(widget.connData["email"])),
            const SizedBox(height: 30),
            // _commonSection(
            //     iconData: _notificationStatus == "Muted"
            //         ? Icons.notifications_off_outlined
            //         : Icons.notifications_none,
            //     heading: "Notification",
            //     nameValue: _notificationStatus,
            //     onPressed: _dialogNotification),
            _commonToggleSection(),
            const SizedBox(height: 30),
            _commonInputSection(
                iconData: Icons.wallpaper_outlined,
                text: 'Chat Wallpaper',
                onPressed: () => Navigation.intent(
                    context,
                    const ChatWallpaperScreen(
                      contentFor: ContentFor.particularConnection,
                    ))),
            const SizedBox(height: 30),
            _commonInputSection(
                iconData: Icons.perm_media_outlined,
                text: 'Media',
                onPressed: _navigateToLocalStorageScreen),
            const SizedBox(height: 30),
            // _commonInputSection(
            //     iconData: Icons.person_add_disabled,
            //     text: 'Remove Connection',
            //     startIconColor: AppColors.lightRedColor,
            //     terminalIconData: Icons.delete_outline_outlined,
            //     textColor: AppColors.lightRedColor,
            //     onPressed: () {},
            //     terminalIconColor: AppColors.lightRedColor),
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

    final _decodedProfilePic = Secure.decode(widget.connData["profilePic"]);

    return InkWell(
      onTap: () async {
        Navigation.intent(
            context,
            ImageShowingScreen(
                imgPath: _decodedProfilePic,
                imageType: _decodedProfilePic.startsWith("https")
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
            image: _decodedProfilePic.startsWith("https")
                ? DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(_decodedProfilePic),
                  )
                : DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(File(_decodedProfilePic)),
                  )),
      ),
    );
  }

  _commonSection(
      {required IconData iconData,
      required String heading,
      required String nameValue,
      VoidCallback? onPressed,
      IconData? terminalIconData,
      Color? terminalIconColor}) {
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
                if (onPressed != null)
                  InkWell(
                      onTap: onPressed,
                      child: Icon(
                        terminalIconData ?? Icons.edit_rounded,
                        color: terminalIconColor ??
                            AppColors.getIconColor(_isDarkMode),
                      ))
              ],
            ));
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

  _commonToggleSection() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _nameLeftSection(
                iconData: !_isNotificationActive
                    ? Icons.notifications_off
                    : Icons.notifications,
                heading: "Notification",
                nameValue: !_isNotificationActive ? "Inactive" : "Active"),
            Switch.adaptive(
              value: _isNotificationActive,
              onChanged: _onNotificationChanged,
              activeTrackColor: _isDarkMode
                  ? AppColors.darkBorderGreenColor.withOpacity(0.8)
                  : AppColors.lightBorderGreenColor.withOpacity(0.8),
              activeColor: AppColors.locationIconBgColor,
              inactiveTrackColor: _isDarkMode
                  ? AppColors.oppositeMsgDarkModeColor
                  : AppColors.pureBlackColor.withOpacity(0.2),
            )
          ],
        ));
  }

  void _onNotificationChanged(bool value) {
    if (mounted) {
      setState(() {
        _isNotificationActive = value;
      });
    }

    _localStorage.insertUpdateConnectionPrimaryData(
        id: widget.connData["id"],
        name: widget.connData["name"],
        profilePic: widget.connData["profilePic"],
        about: widget.connData["about"],
        dbOperation: DBOperation.update,
        notificationTypeManually: value
            ? NotificationType.unMuted.toString()
            : NotificationType.muted.toString());

    _dbOperations.updateParticularConnectionNotificationStatus(
        widget.connData["id"], !value);
  }

  void _navigateToLocalStorageScreen() async {
    final _chatHistoryData =
        await Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .getChatHistory(widget.connData["id"], widget.connData["name"]);

    debugShow("Connection Data:   $_chatHistoryData");

    Provider.of<StorageProvider>(context, listen: false)
        .setImagesCollection(_chatHistoryData[ChatMessageType.image]);
    Provider.of<StorageProvider>(context, listen: false)
        .setVideosCollection(_chatHistoryData[ChatMessageType.video]);
    Provider.of<StorageProvider>(context, listen: false)
        .setDocumentCollection(_chatHistoryData[ChatMessageType.document]);
    Provider.of<StorageProvider>(context, listen: false)
        .setAudioCollection(_chatHistoryData[ChatMessageType.audio]);

    Navigation.intent(context, const LocalStorageScreen());
  }
}
