import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:generation/config/types.dart';
import 'package:provider/provider.dart';

import '../../config/text_style_collection.dart';
import '../../providers/theme_provider.dart';

class SoundManagementScreen extends StatefulWidget {
  const SoundManagementScreen({Key? key}) : super(key: key);

  @override
  State<SoundManagementScreen> createState() => _SoundManagementScreenState();
}

class _SoundManagementScreenState extends State<SoundManagementScreen> {
  final LocalStorage _localStorage = LocalStorage();
  final DBOperations _dbOperations = DBOperations();
  bool _isNotificationActive = false;

  _initialize()async{
    final _currAccData = await _localStorage.getDataForCurrAccount();

    print('Global Notification: ${_currAccData["notification"]}');

    if(mounted){
      setState(() {
        _isNotificationActive = _currAccData["notification"] == NotificationType.unMuted.toString();
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
            _heading(),
            const SizedBox(height: 20),
            _commonSection(
                title: "Notification",
                subTitle: "Receive Notification When App is Open and Closed"),
            const SizedBox(height: 5),
            //_commonSection(title: "Online Notification", subTitle: "Receive Notification When You Using this App"),
          ],
        ),
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
              "Sound Management",
              style: TextStyleCollection.headingTextStyle.copyWith(
                  fontSize: 20,
                  color: _isDarkMode
                      ? AppColors.pureWhiteColor
                      : AppColors.lightChatConnectionTextColor),
            ),
          ],
        ));
  }

  _commonSection({required String title, required String subTitle}) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return ListTile(
      tileColor: AppColors.getBgColor(_isDarkMode),
      onTap: () {},
      title: Text(
        title,
        style: TextStyleCollection.terminalTextStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: _isDarkMode
                ? AppColors.pureWhiteColor
                : AppColors.lightChatConnectionTextColor),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(
          subTitle,
          style: TextStyleCollection.terminalTextStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: _isDarkMode
                  ? AppColors.pureWhiteColor.withOpacity(0.6)
                  : AppColors.lightChatConnectionTextColor.withOpacity(0.6)),
        ),
      ),
      trailing: Switch.adaptive(
        value: _isNotificationActive,
        onChanged: _onChanged,
        activeTrackColor: _isDarkMode
            ? AppColors.darkBorderGreenColor.withOpacity(0.8)
            : AppColors.lightBorderGreenColor.withOpacity(0.8),
        activeColor: AppColors.locationIconBgColor,
        inactiveTrackColor: _isDarkMode
            ? AppColors.oppositeMsgDarkModeColor
            : AppColors.pureBlackColor.withOpacity(0.2),
      ),
    );
  }

  void _onChanged(bool value) async {
    if (!mounted) return;
    setState(() {
      _isNotificationActive = value;
    });

    final _currAccData = await _localStorage.getDataForCurrAccount();
    _localStorage.insertUpdateDataCurrAccData(
        currUserId: _currAccData["id"],
        currUserName: _currAccData["name"],
        currUserProfilePic: _currAccData["profilePic"],
        currUserAbout: _currAccData["about"],
        currUserEmail: _currAccData["email"],
        dbOperation: DBOperation.update,
        notificationType:
            value ? NotificationType.unMuted : NotificationType.muted);

    _dbOperations.updateNotificationStatus(value);
  }
}
