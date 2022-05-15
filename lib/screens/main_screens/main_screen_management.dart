import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/images_path_collection.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/providers/chat/messaging_provider.dart';
import 'package:generation/providers/main_screen_provider.dart';
import 'package:generation/screens/common/scroll_to_hide_widget.dart';
import 'package:generation/screens/main_screens/home_screen.dart';
import 'package:generation/screens/main_screens/settings_screen.dart';
import 'package:generation/types/types.dart';
import 'package:provider/provider.dart';
import '../../providers/connection_collection_provider.dart';
import '../../providers/main_scrolling_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/device_specific_operations.dart';
import 'connection_management/connection_management.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  var activeSlideIndex = 0;
  final DBOperations _dbOperations = DBOperations();

  @override
  void initState() {
    final _onlineStatus = Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .getOnlineStatus();
    _dbOperations.updateActiveStatus(_onlineStatus);

    WidgetsBinding.instance.addObserver(this);
    _dbOperations.getAvailableUsersData(context);
    Provider.of<ConnectionCollectionProvider>(context, listen: false)
        .fetchLocalConnectedUsers(context);

    final _isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();

    showStatusAndNavigationBar();
    makeStatusBarTransparent();
    changeContextTheme(_isDarkMode);

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final _onlineStatus = Provider.of<ChatBoxMessagingProvider>(context, listen: false)
          .getOnlineStatus();
      _dbOperations.updateActiveStatus(_onlineStatus);
    } else {
      final _latestStatus =
          Provider.of<ChatBoxMessagingProvider>(context, listen: false)
              .getLastSeenDateTime();
      _dbOperations.updateActiveStatus(_latestStatus);
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1.0;
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          backgroundColor: AppColors.getBgColor(_isDarkMode),
          bottomSheet: _bottomSheet(),
          body: _currentScreenDetector()),
    );
  }

  _bottomSheet() {
    final ScrollController _messageScreenScrollController =
        Provider.of<MainScrollingProvider>(context).getScrollController();

    final int _currentBottomIconIndex =
        Provider.of<MainScreenNavigationProvider>(context).getUpdatedIndex();

    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return ScrollToHideWidget(
      scrollController: _messageScreenScrollController,
      child: Container(
        height: 60,
        color: AppColors.getBgColor(_isDarkMode),
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              color: _currentBottomIconIndex == 0
                  ? _isDarkMode
                      ? AppColors.darkBorderGreenColor
                      : AppColors.lightBorderGreenColor
                  : _isDarkMode
                      ? AppColors.darkInactiveIconColor
                      : AppColors.lightInactiveIconColor,
              icon: Image.asset(IconImages.messageImagePath,
                  height: 30,
                  width: 30,
                  color: _currentBottomIconIndex == 0
                      ? _isDarkMode
                          ? AppColors.darkBorderGreenColor
                          : AppColors.lightBorderGreenColor
                      : _isDarkMode
                          ? AppColors.darkInactiveIconColor
                          : AppColors.lightInactiveIconColor),
              onPressed: () => Provider.of<MainScreenNavigationProvider>(
                      context,
                      listen: false)
                  .setUpdatedIndex(0),
            ),
            IconButton(
              color: _currentBottomIconIndex == 1
                  ? _isDarkMode
                      ? AppColors.darkBorderGreenColor
                      : AppColors.lightBorderGreenColor
                  : _isDarkMode
                      ? AppColors.darkInactiveIconColor
                      : AppColors.lightInactiveIconColor,
              icon: Image.asset(IconImages.connectImagePath,
                  height: 30,
                  width: 30,
                  color: _currentBottomIconIndex == 1
                      ? _isDarkMode
                          ? AppColors.darkBorderGreenColor
                          : AppColors.lightBorderGreenColor
                      : _isDarkMode
                          ? AppColors.darkInactiveIconColor
                          : AppColors.lightInactiveIconColor),
              onPressed: () => Provider.of<MainScreenNavigationProvider>(
                      context,
                      listen: false)
                  .setUpdatedIndex(1),
            ),
            IconButton(
              color: _currentBottomIconIndex == 2
                  ? _isDarkMode
                      ? AppColors.darkBorderGreenColor
                      : AppColors.lightBorderGreenColor
                  : _isDarkMode
                      ? AppColors.darkInactiveIconColor
                      : AppColors.lightInactiveIconColor,
              icon: Image.asset(IconImages.settingsImagePath,
                  height: 30,
                  width: 30,
                  color: _currentBottomIconIndex == 2
                      ? _isDarkMode
                          ? AppColors.darkBorderGreenColor
                          : AppColors.lightBorderGreenColor
                      : _isDarkMode
                          ? AppColors.darkInactiveIconColor
                          : AppColors.lightInactiveIconColor),
              onPressed: () => Provider.of<MainScreenNavigationProvider>(
                      context,
                      listen: false)
                  .setUpdatedIndex(2),
            ),
          ],
        ),
      ),
    );
  }

  _currentScreenDetector() {
    final _currentIndex =
        Provider.of<MainScreenNavigationProvider>(context).getUpdatedIndex();

    switch (_currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const ConnectionManagementScreen();
      case 2:
        return const SettingsScreen();
    }
  }

  Future<bool> _onWillPop() async {
    final int _currentBottomIconIndex =
        Provider.of<MainScreenNavigationProvider>(context, listen: false)
            .getUpdatedIndex();

    if (_currentBottomIconIndex > 0) {
      Provider.of<MainScreenNavigationProvider>(context, listen: false)
          .setUpdatedIndex(0);

      return false;
    }

    Provider.of<ConnectionCollectionProvider>(context, listen: false)
        .destroyConnectedDataStream();
    //Provider.of<RequestConnectionsProvider>(context, listen: false).destroyReceivedRequestStream();

    return true;
  }
}
