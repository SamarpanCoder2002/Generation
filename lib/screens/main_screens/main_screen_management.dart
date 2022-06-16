import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/images_path_collection.dart';
import 'package:generation/config/size_collection.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/providers/chat/messaging_provider.dart';
import 'package:generation/providers/main_screen_provider.dart';
import 'package:generation/screens/common/scroll_to_hide_widget.dart';
import 'package:generation/screens/main_screens/home_screen.dart';
import 'package:generation/screens/main_screens/settings_screen.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:generation/services/system_file_management.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import '../../config/data_collection.dart';
import '../../config/text_collection.dart';
import '../../config/types.dart';
import '../../providers/connection_collection_provider.dart';
import '../../providers/main_scrolling_provider.dart';
import '../../providers/status_collection_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/debugging.dart';
import '../../services/device_specific_operations.dart';
import '../../services/local_data_management.dart';
import 'connection_management/connection_management.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  var activeSlideIndex = 0;
  final DBOperations _dbOperations = DBOperations();
  final LocalStorage _localStorage = LocalStorage();

  @override
  void initState() {
    final _onlineStatus =
        Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .getOnlineStatus();
    _dbOperations.updateActiveStatus(_onlineStatus);
    _localStorage.storeDbInstance(context);

    WidgetsBinding.instance.addObserver(this);
    _dbOperations.getAvailableUsersData(context);
    Provider.of<ConnectionCollectionProvider>(context, listen: false)
        .fetchLocalConnectedUsers(context);
    Provider.of<StatusCollectionProvider>(context, listen: false).initialize();

    final _isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();

    showStatusAndNavigationBar();
    makeStatusBarTransparent();
    changeContextTheme(_isDarkMode);

    // BackgroundService().initialize();
    // BackgroundService().deleteOwnActivityTask();
    //BackgroundService.deleteConnectionsActivityTask();

    //_localStorage.deleteOwnExpiredActivity();

    Workmanager().initialize(
        bgTaskTopLevel, // The top level function, aka callbackDispatcher
        isInDebugMode: true);

    Workmanager().registerPeriodicTask(
      BgTask.deleteOwnActivityData['taskId'] ?? "1",
      BgTask.deleteOwnActivityData['task'] ?? BgTask.deleteOwnActivity,
      initialDelay: Duration(
          seconds: int.parse(
              BgTask.deleteOwnActivityData['initialDelayInSec'] ?? '30')),
      frequency: Duration(
          minutes: int.parse(
              BgTask.deleteOwnActivityData['frequencyInMin'] ?? '15')),
    );

    Workmanager().registerPeriodicTask(
      BgTask.deleteConnectionActivities['taskId'] ?? "2",
      BgTask.deleteConnectionActivities['task'] ??
          BgTask.deleteConnectionsActivity,
      initialDelay: Duration(
          seconds: int.parse(
              BgTask.deleteConnectionActivities['initialDelayInSec'] ?? '30')),
      frequency: Duration(
          minutes: int.parse(
              BgTask.deleteConnectionActivities['frequencyInMin'] ?? '15')),
    );

    deleteOwnExpiredActivity(stop: false);

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final _onlineStatus =
          Provider.of<ChatBoxMessagingProvider>(context, listen: false)
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

bgTaskTopLevel() {
  Workmanager().executeTask((taskName, inputData) async {
    switch (taskName) {
      case BgTask.deleteOwnActivity:
        debug('Delete Own Activity');
        await deleteOwnExpiredActivity(tableName: DbData.myActivityTable);
        break;
      case BgTask.deleteConnectionsActivity:
        await manageDeleteConnectionsExpiredActivity();
        break;
    }

    return true;
  });
}

deleteOwnExpiredActivity(
    {String tableName = DbData.myActivityTable, bool stop = false}) async {
  //try {
  debug('Entry 1');
  final LocalStorage _localStorage = LocalStorage();

  debug('Entry 2');
  final _activities = await _localStorage.getAllActivity(
      tableName: tableName, withStoragePermission: false);
  debug('Entry 3');
  final _currDateTime = DateTime.now();

  debug('All Activities Collection: $_activities');

  if (stop) return;

  for (final activity in _activities) {
    await _deleteEligibleActivities(
        activity: activity,
        currDateTime: _currDateTime,
        tableName: tableName,
        ownActivity: true);
  }
  // } catch (e) {
  //   debug('deleteMyExpiredActivity error :$e');
  //   return [];
  // }
}

manageDeleteConnectionsExpiredActivity() async {
  final LocalStorage _localStorage = LocalStorage();
  final _connectionsData = await _localStorage.getConnectionPrimaryData(
      withStoragePermission: false);

  debug('Connections Data: $_connectionsData');

  if (_connectionsData.isEmpty) return;

  Map<String, List<dynamic>> _connData = {};

  for (final conn in _connectionsData) {
    try {
      final _activities = await _localStorage.getAllActivity(
          tableName: DataManagement.generateTableNameForNewConnectionActivity(
              conn["id"]),
          withStoragePermission: false);
      _connData[conn["id"]] = _activities;

      debug('Connection Data Map: $_connData');
    } catch (e) {
      debug('Error in Get Ids: $e');
    }
  }

  final _currDateTime = DateTime.now();

  for (final connId in _connData.keys.toList()) {
    for (final activity in (_connData[connId] ?? [])) {
      await _deleteEligibleActivities(
          activity: activity,
          currDateTime: _currDateTime,
          tableName:
              DataManagement.generateTableNameForNewConnectionActivity(connId),
          ownActivity: false);
    }
  }
}

_deleteEligibleActivities(
    {required activity,
    required currDateTime,
    required String tableName,
    required bool ownActivity}) async {
  //try {
  final _date = activity["date"];
  final _time = activity["time"];
  final LocalStorage _localStorage = LocalStorage();

  debug('Activity date and time: $_date  $_time');

  DateFormat format = DateFormat("dd MMMM, yyyy hh:mm a");
  var formattedDateTime = format.parse('$_date $_time');
  final Duration _diffDateTime = currDateTime.difference(formattedDateTime);

  debug('Diff Time Date Time: $_diffDateTime');

  if (_diffDateTime.inHours >= SizeCollection.activitySustainTimeInHour) {
    debug('Activity Deleting Msg: $activity');

    if (ownActivity) {
      await _ownActivityRemoteDataDeletion(activity: activity);
    }

    debug('Under time Activity: $activity');

    if (activity["type"] != ActivityContentType.text.toString()) {
      debug('Non Text File');
      await SystemFileManagement.deleteFile(activity['message'] ?? '');
      if (activity['type'] == ActivityContentType.video.toString()) {
        final _additionalDataString = activity["additionalThings"] ?? "";
        debug('Additional Things in eligible: $_additionalDataString');
        final _additionalData =
            DataManagement.fromJsonString(_additionalDataString.toString());
        await SystemFileManagement.deleteFile(
            _additionalData["thumbnail"] ?? '');
      }
    }

    await _localStorage.deleteActivity(
        tableName: tableName,
        activityId: activity["id"],
        withStoragePermission: false);
    debug('Activity Deleted');
  }

  debug('Activity Deletion Completed Background $activity');
  // } catch (e) {
  //   debug('Error in _deleteEligibleActivities: $e');
  // }
}

_ownActivityRemoteDataDeletion({required activity}) async {
  final DBOperations _dbOperations = DBOperations();

  final _additionalThings = activity["additionalThings"] ?? "";
  debug('Additional Things: $_additionalThings');
  final _remoteData = DataManagement.fromJsonString(
      (DataManagement.fromJsonString(
              _additionalThings.toString())["remoteData"]) ??
          "");

  await _dbOperations.initializeFirebase();

  if (activity["type"] != ActivityContentType.text.toString()) {
    await _dbOperations.deleteMediaFromFirebaseStorage(_remoteData['message']);
  }

  await _dbOperations.deleteParticularActivity(_remoteData);
}
