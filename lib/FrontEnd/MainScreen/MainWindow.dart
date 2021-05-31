import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:generation/BackendAndDatabaseManager/native_internal_call/native_call.dart';
import 'package:generation/FrontEnd/MenuScreen/Support/support_menu.dart';
import 'package:workmanager/workmanager.dart';

import 'package:generation/BackendAndDatabaseManager/global_controller/this_account_important_data.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:generation/FrontEnd/MainScreen/ChatAndActivityCollection.dart';
import 'package:generation/FrontEnd/MainScreen/general_applications_section.dart';
import 'package:generation/FrontEnd/MainScreen/LogsCollection.dart';
import 'package:generation/FrontEnd/MenuScreen/profile_screen.dart';
import 'package:generation/FrontEnd/MenuScreen/Settings/settings_menu.dart';

final List<String> _activityLinkDeleteFromStorage = [];

/// For WorkManager Callback Function
void deleteOldActivity() async {
  Workmanager().executeTask((taskName, inputData) async {
    switch (taskName) {
      case "deleteActivity":
        print('Delete Activity Executing');
        await _deleteOldTask();
        await Future.delayed(
          Duration(seconds: 15),
        );
        await _deleteFromStorage();
        await Future.delayed(
          Duration(seconds: 15),
        );
        print('All After Delete Activity');
        break;
    }

    return true;
  });
}

/// Delete From Firebase Storage
Future<void> _deleteFromStorage() async {
  if (_activityLinkDeleteFromStorage.isNotEmpty) {
    final Management _management = Management(takeTotalUserName: false);

    print('Activity Links to delete: $_activityLinkDeleteFromStorage');

    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('Error: Firebase initialization Exception');
    }

    _activityLinkDeleteFromStorage.forEach((storageElementToDelete) async {
      if (storageElementToDelete.contains('https')) {
        _management
            .deleteFilesFromFirebaseStorage(storageElementToDelete)
            .then((value) {
          print('$storageElementToDelete Deleted From Firebase Storage');

          final bool response =
              _activityLinkDeleteFromStorage.remove(storageElementToDelete);
          print('$storageElementToDelete Delete Status: $response');
        });
      }
    });
  }
}

/// Delete Activity Path From Local Database
Future<void> _deleteOldTask() async {
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();

  print('Here Delete Activity');

  final List<Map<String, dynamic>> _connectionUserName =
      await _localStorageHelper.extractAllUsersName(thisAccountAllowed: true);

  print('Delete Activity Executing 2: $_connectionUserName');

  _connectionUserName.forEach((everyUser) async {
    final List<Map<String, dynamic>> _thisUserActivityCollection =
        await _localStorageHelper
            .extractActivityForParticularUserName(everyUser.values.first);

    print('Now 1: $_thisUserActivityCollection');

    if (_thisUserActivityCollection != null) {
      if (_thisUserActivityCollection.length == 0) {
        print('User Has No Activity');
      } else {
        print('Now 2: $_thisUserActivityCollection');

        _thisUserActivityCollection
            .forEach((Map<String, dynamic> everyActivity) async {
          print('Activity: ${everyActivity['Status']}');

          // /// Backup Plan
          // print('Delete that Status');
          //
          // /// Delete Particular Activity
          // await _localStorageHelper.deleteParticularActivity(
          //     tableName: everyUser.values.first,
          //     activity: everyActivity['Status']);
          //
          // await File(everyActivity['Status'].split('+')[0])
          //     .delete(recursive: true);
          //
          // /// For This Current Account Status For Media
          // if (everyActivity['Status'].contains('+') &&
          //     (everyActivity['Media'] == MediaTypes.Image.toString() ||
          //         everyActivity['Media'] == MediaTypes.Video.toString())) {
          //   /// Store in Local Container about Media Store in Firebase Storage
          //   _activityLinkDeleteFromStorage
          //       .add(everyActivity['Status'].split('+')[1]);
          // }

          String _activityDateTime = everyActivity['Status_Time'];

          if (_activityDateTime.contains('+'))
            _activityDateTime = _activityDateTime.split('+')[0];

          print('Now 3: $_thisUserActivityCollection');

          final String currDate = DateTime.now().toString().split(' ')[0];
          final int currHour = DateTime.now().hour;
          final int currMinute = DateTime.now().minute;

          final List<String> _timeDistribution =
              _activityDateTime.split(' ')[1].split(':');

          /// Accurate Work
          if (_activityDateTime.split(' ')[0] != currDate &&
              ((int.parse(_timeDistribution[0]) == currHour &&
                      int.parse(_timeDistribution[1]) <= currMinute) ||
                  int.parse(_timeDistribution[0]) < currHour)) {
            print('Delete that Status');

            /// Delete Particular Activity
            await _localStorageHelper.deleteParticularActivity(
                tableName: everyUser.values.first,
                activity: everyActivity['Status']);

            /// Delete File From Local Storage[Exception Handling Because File Can be Deleted by user Manually]
            try {
              await File(everyActivity['Status'].split('+')[0])
                  .delete(recursive: true);
            } catch (e) {
              print('File Deleted Already Exception: ${e.toString()}');
            }

            /// For This Current Account Status For Media
            if (everyActivity['Status'].contains('+') &&
                (everyActivity['Media'] == MediaTypes.Image.toString() ||
                    everyActivity['Media'] == MediaTypes.Video.toString())) {
              /// Store in Local Container about Media Store in Firebase Storage
              _activityLinkDeleteFromStorage
                  .add(everyActivity['Status'].split('+')[1]);
            }
          }
        });
      }
    }
  });

  final Map<String, String> _linksMap =
      await _localStorageHelper.extractRemainingLinks();

  final String currDate = DateTime.now().toString().split(' ')[0];
  final int currHour = DateTime.now().hour;
  final int currMinute = DateTime.now().minute;

  if (_linksMap != null && _linksMap.length > 0) {
    _linksMap.forEach((_link, _time) async {
      // /// Activate this section For Debugging purpose
      // print('Delete Multiple Connection Media Added');
      // await _localStorageHelper.deleteRemainingLinksFromLocalStore(link: _link);
      // _activityLinkDeleteFromStorage.add(_link);

      final List<String> _timeDistribution = _time.split(' ')[1].split(':');

      if (_time.split(' ')[0] != currDate &&
          ((int.parse(_timeDistribution[0]) == currHour &&
                  int.parse(_timeDistribution[1]) <= currMinute) ||
              int.parse(_timeDistribution[0]) < currHour)) {
        print('Delete Multiple Connection Media Added');

        await _localStorageHelper.deleteRemainingLinksFromLocalStore(
            link: _link);

        _activityLinkDeleteFromStorage.add(_link);
      }
    });
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();
  final NativeCallback _nativeCallback = NativeCallback();

  int _currIndex = 0;

  void _removeBirthNotificationChecking() async {
    final bool _removeBNStatus =
        await _localStorageHelper.extractDataForNotificationConfigTable(
            nConfigTypes: NConfigTypes.RemoveBirthNotification);

    print('Remove Birth Notification Status: $_removeBNStatus');

    /// Notification Remove from Notification Tray if Permission Granted
    if (_removeBNStatus) await _nativeCallback.callForCancelNotifications();
  }

  @override
  void initState() {
    Workmanager().initialize(
        deleteOldActivity, // The top level function, aka callbackDispatcher
        isInDebugMode:
            true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
        );

    /// Periodic task registration
    Workmanager().registerPeriodicTask(
      "1",
      "deleteActivity",
      initialDelay: Duration(seconds: 30),
      frequency: Duration(
          minutes:
              15), // Minimum frequency is 15 min. For Debug that, Please change that to 15 min
    );

    ImportantThings.findImageUrlAndUserName();
    _removeBirthNotificationChecking();

    super.initState();
  }

  @override
  void dispose() {
    print('Dispose in MainWindow');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: WillPopScope(
          onWillPop: () async {
            if (_currIndex > 0)
              return false;
            else {
              print('Tata');
              return true;
            }
          },
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Color.fromRGBO(34, 48, 60, 1),
            drawer: Drawer(
              elevation: 10.0,
              child: Container(
                color: const Color.fromRGBO(34, 48, 60, 1),
                height: double.maxFinite,
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    SizedBox(
                      height: 10.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => Profile()));
                      },
                      child: Center(
                        child: CircleAvatar(
                          backgroundImage:
                              ImportantThings.thisAccountProfileImagePath == ''
                                  ? const ExactAssetImage(
                                      "assets/logo/logo.jpg",
                                    )
                                  : FileImage(
                                      File(ImportantThings
                                          .thisAccountProfileImagePath),
                                    ),
                          radius: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? MediaQuery.of(context).size.height *
                                  (1.2 / 8) /
                                  2.5
                              : MediaQuery.of(context).size.height *
                                  (2.5 / 8) /
                                  2.5,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    _menuOptions(Icons.person_outline_rounded, 'Profile'),
                    SizedBox(
                      height: 10.0,
                    ),
                    _menuOptions(Icons.settings, 'Setting'),
                    SizedBox(
                      height: 10.0,
                    ),
                    _menuOptions(Icons.support_outlined, 'Support'),
                    SizedBox(
                      height: 30.0,
                    ),
                    exitButtonCall(),
                  ],
                ),
              ),
            ),
            appBar: AppBar(
              brightness: Brightness.dark,
              backgroundColor: Color.fromRGBO(25, 39, 52, 1),
              elevation: 10.0,
              shadowColor: Colors.white70,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40.0),
                  bottomRight: Radius.circular(40.0),
                ),
                side: BorderSide(width: 0.7),
              ),
              title: Text(
                "Generation",
                style: TextStyle(
                    fontSize: 25.0, fontFamily: 'Lora', letterSpacing: 1.0),
              ),
              actions: [
                Container(
                  padding: EdgeInsets.only(
                    right: 20.0,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.refresh_outlined,
                      size: 25.0,
                    ),
                    onPressed: () async {
                      print('Clicked Refresh in MainWindow');

                      await _localStorageHelper.showAll();

                      if (mounted) {
                        setState(() {
                          ImportantThings.findImageUrlAndUserName();
                        });
                      }

                      _removeAnonymousNotificationChecking();
                    },
                  ),
                )
              ],
              bottom: TabBar(
                indicatorPadding: EdgeInsets.only(left: 20.0, right: 20.0),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(width: 2.0, color: Colors.lightBlue),
                    insets: EdgeInsets.symmetric(horizontal: 15.0)),
                automaticIndicatorColorAdjustment: true,
                labelStyle: TextStyle(
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                ),
                onTap: (index) {
                  print("\nIndex is: $index");
                  if (mounted) {
                    setState(() {
                      _currIndex = index;
                    });
                  }
                },
                tabs: [
                  Tab(
                    child: Text(
                      "Chats",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Logs",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.store,
                      size: 25.0,
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                ChatsAndActivityCollection(),
                ScreenLogs(),
                ApplicationList(),
              ],
            ),
          )),
    );
  }

  Widget _menuOptions(IconData icon, String menuOptionIs) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: Duration(
        milliseconds: 500,
      ),
      closedElevation: 0.0,
      openElevation: 3.0,
      closedColor: const Color.fromRGBO(34, 48, 60, 1),
      openColor: const Color.fromRGBO(34, 48, 60, 1),
      middleColor: const Color.fromRGBO(34, 48, 60, 1),
      onClosed: (value) {
        print('Profile Page Closed');
        if (mounted) {
          setState(() {
            ImportantThings.findImageUrlAndUserName();
          });
        }
      },
      openBuilder: (context, openWidget) {
        if (menuOptionIs == 'Profile')
          return Profile();
        else if (menuOptionIs == 'Setting')
          return SettingsWindow();
        else if (menuOptionIs == 'Support') return SupportMenuMaker();
        return Center();
      },
      closedBuilder: (context, closeWidget) {
        return Container(
          height: 60.0,
          //color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.lightBlue,
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(
                menuOptionIs,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget exitButtonCall() {
    return GestureDetector(
      onTap: () async {
        await SystemNavigator.pop(animated: true);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.exit_to_app_rounded,
            color: Colors.lightBlue,
          ),
          SizedBox(
            width: 10.0,
          ),
          Text(
            'Exit',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _removeAnonymousNotificationChecking() async {
    final bool _removeAStatus =
        await _localStorageHelper.extractDataForNotificationConfigTable(
            nConfigTypes: NConfigTypes.RemoveAnonymousNotification);

    print('Remove Birth Notification Status: $_removeAStatus');

    /// Notification Remove from Notification Tray if Permission Granted
    if (_removeAStatus) await _nativeCallback.callForCancelNotifications();
  }
}
