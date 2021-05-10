import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:generation_official/BackendAndDatabaseManager/Dataset/data_type.dart';
import 'package:generation_official/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation_official/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';

import 'package:generation_official/FrontEnd/MainScreen/ChatAndActivityCollection.dart';
import 'package:generation_official/FrontEnd/MainScreen/applications_section.dart';
import 'package:generation_official/FrontEnd/MainScreen/LogsCollection.dart';
import 'package:generation_official/FrontEnd/MenuScreen/ProfileScreen.dart';
import 'package:generation_official/FrontEnd/MenuScreen/SettingsMenu.dart';
import 'package:generation_official/FrontEnd/Services/notification_configuration.dart';
import 'package:workmanager/workmanager.dart';

final List<String> _activityLinkDeleteFromStorage = [];

/// For WorkManager Callback Function
void deleteOldActivity() async {
  Workmanager().executeTask((taskName, inputData) async {
    switch (taskName) {
      case "deleteActivity":
        print('Delete Activity Executing');
        await _deleteActivitySeparately();
        await Future.delayed(
          Duration(seconds: 20),
        );
        await _deleteFromStorage();
        await Future.delayed(
          Duration(seconds: 10),
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

    _activityLinkDeleteFromStorage.forEach((storageElementToDelete) async {
      if (storageElementToDelete.contains('https')) {
        await _management.deleteFilesFromFirebaseStorage(storageElementToDelete,
            specialPurpose: true);
      }
    });

    _activityLinkDeleteFromStorage.clear();
  }
}

/// Delete Activity Path From Local Database
Future<void> _deleteActivitySeparately() async {
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

          /// Backup Plan
          // /// Delete Particular Activity
          // await _localStorageHelper.deleteParticularActivity(
          //     tableName: everyUser.values.first,
          //     activity: everyActivity['Status']);
          //
          // /// For This Current Account Status
          // if (everyActivity['Status'].contains('+') &&
          //     (everyActivity['Media'] == MediaTypes.Image.toString() ||
          //         everyActivity['Media'] ==
          //             MediaTypes.Video.toString())) {
          //   /// Store in Local Container about Media Store in Firebase Storage
          //   _activityLinkDeleteFromStorage
          //       .add(everyActivity['Status'].split('+')[1]);
          // }

          final String _activityDateTime = everyActivity['Status_Time'];

          print('Now 3: $_thisUserActivityCollection');

          final String currDate = DateTime.now().toString().split(' ')[0];
          final int currHour = DateTime.now().hour;
          final int currMinute = DateTime.now().minute;

          final List<String> _timeDistribution =
              _activityDateTime.split(' ')[1].split(':');

          /// Accurate Work
          if (_activityDateTime.split(' ')[0] != currDate &&
              int.parse(_timeDistribution[0]) <= currHour &&
              int.parse(_timeDistribution[1]) <= currMinute) {
            print('Delete that Status');

            /// Delete Particular Activity
            await _localStorageHelper.deleteParticularActivity(
                tableName: everyUser.values.first,
                activity: everyActivity['Status']);

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
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currIndex = 0;

  @override
  void initState() {
    // TODO: implement initState

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
          hours:
              1), // Minimum frequency is 15 min. For Debug that, Please change that to 1 Hour
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: WillPopScope(
          onWillPop: () async {
            if (_currIndex > 0) return false;
            return true;
          },
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Color.fromRGBO(34, 48, 60, 1),
            drawer: Drawer(
              elevation: 10.0,
              child: Container(
                color: Color.fromRGBO(34, 48, 60, 1),
                height: double.maxFinite,
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.account_box_outlined),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Profile()));
                        }),
                    IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettingsWindow()));
                        }),
                    IconButton(
                        icon: Icon(Icons.feedback),
                        onPressed: () {
                          print("Exit Clicked");
                        }),
                    IconButton(
                        icon: Icon(Icons.exit_to_app),
                        onPressed: () {
                          print("Exit Clicked");
                          SystemNavigator.pop();
                        }),
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
                      Icons.supervised_user_circle_outlined,
                      size: 25.0,
                    ),
                    onPressed: () async {
                      print("New User Add");
                      await ForeGroundNotificationReceiveAndShow()
                          .showNotification(
                              title: 'Title', body: 'Body', context: context);
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
}
