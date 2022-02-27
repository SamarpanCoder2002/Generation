import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/images_path_collection.dart';
import 'package:generation/providers/main_screen_provider.dart';
import 'package:generation/screens/common/scroll_to_hide_widget.dart';
import 'package:generation/screens/main_screens/home_screen.dart';
import 'package:generation/screens/main_screens/settings_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/messages_screen_controller.dart';
import '../../services/device_specific_operations.dart';
import 'add_connection_screen.dart';
import 'groups_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  var activeSlideIndex = 0;

  @override
  void initState() {
    showStatusAndNavigationBar();
    makeStatusBarTransparent();
    changeOnlyNavigationBarColor(
        navigationBarColor: AppColors.backgroundDarkMode);

    print("Platform Brightness: ${SchedulerBinding.instance!.window.platformBrightness}");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundDarkMode,
        bottomSheet: _bottomSheet(),
        body: _currentScreenDetector());
  }

  _bottomSheet() {
    final ScrollController _messageScreenScrollController =
        Provider.of<MessageScreenScrollingProvider>(context)
            .getScrollController();

    final int _currentBottomIconIndex =
        Provider.of<MainScreenNavigationProvider>(context).getUpdatedIndex();

    return ScrollToHideWidget(
      scrollController: _messageScreenScrollController,
      child: Container(
        height: 60,
        color: AppColors.backgroundDarkMode,
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              color: _currentBottomIconIndex == 0
                  ? AppColors.darkBorderGreenColor
                  : AppColors.darkInactiveIconColor,
              icon: Image.asset(IconImages.messageImagePath,
                  height: 30,
                  width: 30,
                  color: _currentBottomIconIndex == 0
                      ? AppColors.darkBorderGreenColor
                      : AppColors.darkInactiveIconColor),
              onPressed: ()  => Provider.of<MainScreenNavigationProvider>(
                  context,
                  listen: false)
                  .setUpdatedIndex(0),
            ),
            IconButton(
              color: _currentBottomIconIndex == 1
                  ? AppColors.darkBorderGreenColor
                  : AppColors.darkInactiveIconColor,
              icon: Image.asset(IconImages.groupImagePath,
                  height: 30,
                  width: 30,
                  color: _currentBottomIconIndex == 1
                      ? AppColors.darkBorderGreenColor
                      : AppColors.darkInactiveIconColor),
              onPressed: ()  => Provider.of<MainScreenNavigationProvider>(
                  context,
                  listen: false)
                  .setUpdatedIndex(1),
            ),
            IconButton(
              color: _currentBottomIconIndex == 2
                  ? AppColors.darkBorderGreenColor
                  : AppColors.darkInactiveIconColor,
              icon: Image.asset(IconImages.connectImagePath,
                  height: 30,
                  width: 30,
                  color: _currentBottomIconIndex == 2
                      ? AppColors.darkBorderGreenColor
                      : AppColors.darkInactiveIconColor),
              onPressed: ()  => Provider.of<MainScreenNavigationProvider>(
                  context,
                  listen: false)
                  .setUpdatedIndex(2),
            ),
            IconButton(
              color: _currentBottomIconIndex == 3
                  ? AppColors.darkBorderGreenColor
                  : AppColors.darkInactiveIconColor,
              icon: Image.asset(IconImages.settingsImagePath,
                  height: 30,
                  width: 30,
                  color: _currentBottomIconIndex == 3
                      ? AppColors.darkBorderGreenColor
                      : AppColors.darkInactiveIconColor),
              onPressed: () => Provider.of<MainScreenNavigationProvider>(
                      context,
                      listen: false)
                  .setUpdatedIndex(3),
            ),
          ],
        ),
      ),
    );
  }

  _currentScreenDetector() {
    final _currentIndex = Provider.of<MainScreenNavigationProvider>(context).getUpdatedIndex();

    switch(_currentIndex){
      case 0:
        return const HomeScreen();
      case 1:
        return const GroupsScreen();
      case 2:
        return const AddConnectionScreen();
      case 3:
        return const SettingsScreen();
    }
  }
}
