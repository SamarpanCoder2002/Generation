import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generation_official/FrontEnd/Preview/images_preview_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:animations/animations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:generation_official/BackendAndDatabaseManager/Dataset/data_type.dart';
import 'package:generation_official/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation_official/FrontEnd/Activity/activity_maker.dart';
import 'package:generation_official/FrontEnd/Services/search_screen.dart';
import 'package:generation_official/FrontEnd/Activity/activity_view.dart';

import 'package:generation_official/FrontEnd/MainScreen/ChatScreen.dart';
import 'package:generation_official/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';

class ChatsAndActivityCollection extends StatefulWidget {
  @override
  _ChatsAndActivityCollectionState createState() =>
      _ChatsAndActivityCollectionState();
}

class _ChatsAndActivityCollectionState
    extends State<ChatsAndActivityCollection> {
  bool isLoading = false;
  final List<String> allConnectionsUserName = [];

  final List<String> _allUserConnectionActivity = [];
  final FToast fToast = FToast();

  final Management management = Management();
  final LocalStorageHelper localStorageHelper = LocalStorageHelper();

  final Dio dio = Dio();

  // Regular Expression for Media Detection
  final RegExp _mediaRegex =
      RegExp(r"(http(s?):)|([/|.|\w|\s])*\.(?:jpg|gif|png)");

  int statusCurrIndex = 0;

  void _fetchRealTimeData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    // Storage Request
    PermissionStatus storagePermissionStatus =
        await Permission.storage.request();

    // Listen to the realTime Data Fetch
    management.getDatabaseData().listen((event) async {
      final Map<String, dynamic> _allUserConnectionActivityTake =
          event.data()['activity'] as Map;

      // Current Account User Name Take
      final String _thisAccountUserName =
          await localStorageHelper.extractImportantDataFromThatAccount(
              userMail: FirebaseAuth.instance.currentUser.email);

      /// Checking Already This Account Name Present in Local Container or not
      if (!_allUserConnectionActivity.contains(_thisAccountUserName)) {
        if (mounted) {
          setState(() {
            _allUserConnectionActivity.add(_thisAccountUserName);
          });
        }
      }

      /// For [Activity Data] Store in Local Storage
      _allUserConnectionActivityTake
          .forEach((connectionMail, connectionActivity) async {
        if (connectionActivity.toList().isEmpty) {
          // If There no new Activity in FireStore Record
          print("Empty Container");
        } else {
          final List<dynamic> particularConnectionActivity =
              _allUserConnectionActivityTake[connectionMail] as List;

          final String _connectionUserNameFromLocalDatabase =
              await localStorageHelper.extractImportantDataFromThatAccount(
                  userMail:
                      connectionMail); // FindOut User Name from local database

          /// Checking Already This Account Name Present in Local Container or not
          if (!_allUserConnectionActivity
              .contains(_connectionUserNameFromLocalDatabase)) {
            if (mounted) {
              setState(() {
                _allUserConnectionActivity
                    .add(_connectionUserNameFromLocalDatabase);
              });
            }
          }

          /// Updating FireStore by Removal of Current fetch all Activity of that particular user
          if (mounted) {
            setState(() {
              _allUserConnectionActivityTake[connectionMail] = [];
              print(
                  'Event Data: ${_allUserConnectionActivityTake[connectionMail]}');
              FirebaseFirestore.instance
                  .doc(
                      'generation_users/${FirebaseAuth.instance.currentUser.email}')
                  .update({
                'activity': _allUserConnectionActivityTake,
              });
              print('Data Activity Removed');
            });
          }

          particularConnectionActivity.forEach((everyActivity) async {
            if (_mediaRegex.hasMatch(everyActivity.keys.first.toString())) {
              final Directory directory = await getExternalStorageDirectory();
              final String currTime = DateTime.now().toString();

              if (everyActivity.values.first.toString().split('++++++')[1] ==
                  'video') {
                if (storagePermissionStatus.isGranted) {
                  final activityVideoPath =
                      await Directory(directory.path + '/.ActivityVideos/')
                          .create();

                  await dio
                      .download(everyActivity.keys.first.toString(),
                          '${activityVideoPath.path}$currTime.mp4')
                      .whenComplete(() async {
                    print('Video Download Complete');
                    // await management.deleteFilesFromFirebaseStorage(
                    //     everyActivity.keys.first.toString());
                  });

                  /// Insert Video  Activity Data to the local database for future use
                  await localStorageHelper.insertDataInUserActivityTable(
                    tableName: _connectionUserNameFromLocalDatabase,
                    statusLinkOrString:
                        '${activityVideoPath.path}$currTime.mp4',
                    mediaTypes: MediaTypes.Video,
                    activityTime: currTime,
                    extraText: everyActivity.values.first
                        .toString()
                        .split('++++++')[0],
                  );
                } else {
                  //storagePermissionStatus = await Permission.storage.request();
                  print('Storage Permission Denied');
                }
              } else {
                if (storagePermissionStatus.isGranted) {
                  // Create new Hidden Folder once in desired location
                  final activityImagePath =
                      await Directory('${directory.path}/.ActivityImages/')
                          .create();

                  /// Download Image Activity from Firebase Storage and store in local database
                  await dio
                      .download(everyActivity.keys.first.toString(),
                          '${activityImagePath.path}$currTime.jpg')
                      .whenComplete(() async {
                    print('Image Download Complete');
                    // await management.deleteFilesFromFirebaseStorage(
                    //     everyActivity.keys.first.toString());
                  });

                  /// Add Activity Image Data to Local Storage for Future use
                  await localStorageHelper.insertDataInUserActivityTable(
                    tableName: _connectionUserNameFromLocalDatabase,
                    statusLinkOrString:
                        '${activityImagePath.path}$currTime.jpg',
                    mediaTypes: MediaTypes.Image,
                    activityTime: currTime,
                    extraText: everyActivity.values.first
                        .toString()
                        .split('++++++')[0],
                  );
                } else {
                  print('Permission Denied');
                  //storagePermissionStatus = await Permission.storage.request();
                }
              }
            } else {
              /// Add Text Activity Data to Local Storage for future use
              await localStorageHelper.insertDataInUserActivityTable(
                tableName: _connectionUserNameFromLocalDatabase,
                statusLinkOrString: everyActivity.keys.first.toString(),
                mediaTypes: MediaTypes.Text,
                activityTime: DateTime.now().toString(),
                bgInformation: everyActivity.values.first.toString(),
              );
            }
          });
        }
      });

      print("All Connection Activity: $_allUserConnectionActivity");

      /// Connection Request Processing
      if (event.data()['connection_request'].length > 0) {
        if (mounted) {
          final Map<String, Object> allConnectionRequest =
              event.data()['connection_request']; // Take All Connection Request

          // Take all Connection Request Data to Update Connectivity
          allConnectionRequest
              .forEach((connectionName, connectionStatus) async {
            if (connectionStatus.toString() == 'Request Accepted' ||
                connectionStatus.toString() == 'Invitation Accepted') {
              // User All Information Take
              final DocumentSnapshot documentSnapshot = await FirebaseFirestore
                  .instance
                  .doc('generation_users/$connectionName')
                  .get();

              // Checking If Same User Name Present in the list or not
              if (!allConnectionsUserName
                  .contains(documentSnapshot['user_name'])) {
                // Make SqLite Table With User UserName
                bool response = await localStorageHelper
                    .createTableForUserName(documentSnapshot['user_name']);
                if (response) {
                  // Data Store for General Reference
                  await localStorageHelper.insertDataForThisAccount(
                      userMail: connectionName,
                      userName: documentSnapshot['user_name']);

                  // Insert Additional Data to user Specific SqLite Database Table
                  await localStorageHelper.insertAdditionalData(
                    documentSnapshot['user_name'],
                    documentSnapshot['about'],
                    documentSnapshot.id,
                  );

                  // Make a new table to this new connected user Activity
                  await localStorageHelper.createTableForUserActivity(
                      documentSnapshot['user_name']);
                }

                // Insert New Connected user name at the front of local container
                if (mounted) {
                  setState(() {
                    allConnectionsUserName.insert(
                        0, documentSnapshot['user_name']);
                  });
                }
              } else
                print("Already Connection Added");
            }
          });
        }
      }
    });

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Existing connection having some activity store in local database, user name add
  void _searchAboutExistingConnectionActivity() async {
    final List<Map<String, Object>> _alreadyStoredUserNameList =
        await localStorageHelper.extractAllUsersNameExceptThis();
    _alreadyStoredUserNameList.forEach((userNameMap) async {
      final int _countTotalActivity = await localStorageHelper
          .countTotalActivitiesForParticularUserName(userNameMap.values.first);
      if (_countTotalActivity > 0) {
        if (!_allUserConnectionActivity.contains(userNameMap.values.first)) {
          if (mounted) {
            setState(() {
              _allUserConnectionActivity.add(userNameMap.values.first);
            });
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    print("Initialization");
    SystemChrome.setEnabledSystemUIOverlays(
        SystemUiOverlay.values); // Android StatusBar Show

    fToast.init(context); // Flutter Toast Initialized

    try {
      _fetchRealTimeData();
      _searchAboutExistingConnectionActivity();
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('Chat Collection Load Error'),
                content: Text(e.toString()),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return connectionsCollection(context);
  }

  Widget connectionsCollection(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
        floatingActionButton: OpenContainer(
          closedColor: const Color.fromRGBO(20, 200, 50, 1),
          middleColor: const Color.fromRGBO(34, 48, 60, 1),
          openColor: const Color.fromRGBO(34, 48, 60, 1),
          closedShape: CircleBorder(),
          closedElevation: 15.0,
          transitionDuration: Duration(
            milliseconds: 500,
          ),
          transitionType: ContainerTransitionType.fadeThrough,
          openBuilder: (_, __) {
            return Search();
          },
          closedBuilder: (_, __) {
            return Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 37.0,
              ),
            );
          },
        ),
        body: ModalProgressHUD(
          inAsyncCall: isLoading,
          color: const Color.fromRGBO(0, 0, 0, 0.5),
          progressIndicator: const CircularProgressIndicator(
            backgroundColor: Colors.black87,
          ),
          child: ListView(
            children: [
              _activityList(context),
              _connectionList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activityList(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 23.0,
        left: 10.0,
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).orientation == Orientation.portrait
          ? MediaQuery.of(context).size.height * (1.5 / 8)
          : MediaQuery.of(context).size.height * (3 / 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Make ListView Horizontally
        itemCount: _allUserConnectionActivity.length,
        itemBuilder: (context, position) {
          return _activityCollectionList(context, position);
        },
      ),
    );
  }

  Widget _activityCollectionList(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.only(right: MediaQuery.of(context).size.width / 18),
      height: MediaQuery.of(context).size.height * (1.5 / 8),
      child: Column(
        children: [
          Stack(
            children: [
              OpenContainer(
                closedColor: const Color.fromRGBO(34, 48, 60, 1),
                openColor: const Color.fromRGBO(34, 48, 60, 1),
                middleColor: const Color.fromRGBO(34, 48, 60, 1),
                closedElevation: 0.0,
                transitionDuration: Duration(
                  milliseconds: 500,
                ),
                transitionType: ContainerTransitionType.fadeThrough,
                openBuilder: (context, openWidget) {
                  return ActivityView(
                      takeParticularConnectionUserName:
                          _allUserConnectionActivity[index]);
                },
                closedBuilder: (context, closeWidget) {
                  return CircleAvatar(
                    backgroundImage: const ExactAssetImage(
                      "assets/logo/logo.jpg",
                    ),
                    radius: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? MediaQuery.of(context).size.height * (1.2 / 8) / 2.5
                        : MediaQuery.of(context).size.height * (2.5 / 8) / 2.5,
                  );
                },
              ),
              index == 0 // This is for current user Account
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? MediaQuery.of(context).size.height * (0.7 / 8) -
                                10
                            : MediaQuery.of(context).size.height * (1.5 / 8) -
                                10,
                        left: MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? MediaQuery.of(context).size.width / 3 - 65
                            : MediaQuery.of(context).size.width / 8 - 15,
                      ),
                      child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.lightBlue,
                          ),
                          child: GestureDetector(
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: MediaQuery.of(context).orientation ==
                                      Orientation.portrait
                                  ? MediaQuery.of(context).size.height *
                                      (1.3 / 8) /
                                      2.5 *
                                      (3.5 / 6)
                                  : MediaQuery.of(context).size.height *
                                      (1.3 / 8) /
                                      2,
                            ),
                            onTap: () => activityList(
                                context: context,
                                allConnectionsUserName: allConnectionsUserName),
                          )),
                    )
                  : const SizedBox(),
            ],
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(
              top: 7.0,
            ),
            child: Text(
              _allUserConnectionActivity[index].length <= 10
                  ? _allUserConnectionActivity[index]
                  : '${_allUserConnectionActivity[index].replaceRange(10, _allUserConnectionActivity[index].length, '...')}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _connectionList(BuildContext context) {
    return SafeArea(
        child: Container(
      margin: EdgeInsets.only(
          top: MediaQuery.of(context).orientation == Orientation.portrait
              ? 5.0
              : 0.0),
      padding: const EdgeInsets.only(top: 18.0, bottom: 10.0),
      height: MediaQuery.of(context).size.height * (5.15 / 8),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(31, 51, 71, 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            spreadRadius: 0.0,
            offset: const Offset(0.0, -5.0), // shadow direction: bottom right
          )
        ],
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40.0), topRight: Radius.circular(40.0)),
        border: Border.all(
          color: Colors.black26,
          width: 1.0,
        ),
      ),
      child: ListView.builder(
        itemCount: allConnectionsUserName.length,
        itemBuilder: (context, position) {
          return chatTile(context, position, allConnectionsUserName[position]);
        },
      ),
    ));
  }

  Widget chatTile(BuildContext context, int index, String _userName) {
    return Card(
        elevation: 0.0,
        color: Color.fromRGBO(31, 51, 71, 1),
        child: Container(
          padding: EdgeInsets.only(left: 1.0, right: 1.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0.0,
              primary: Color.fromRGBO(31, 51, 71, 1),
              onPrimary: Colors.lightBlueAccent,
            ),
            onPressed: () {
              print("Chat List Pressed");
            },
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: 5.0,
                    bottom: 5.0,
                  ),
                  child: OpenContainer(
                    closedColor: const Color.fromRGBO(31, 51, 71, 1),
                    openColor: const Color.fromRGBO(31, 51, 71, 1),
                    middleColor: const Color.fromRGBO(31, 51, 71, 1),
                    closedElevation: 0.0,
                    openElevation: 0.0,
                    transitionDuration: Duration(milliseconds: 500),
                    transitionType: ContainerTransitionType.fadeThrough,
                    openBuilder: (_, __) {
                      return PreviewImageScreen(
                          imageFile: File('assets/images/sam.jpg'));
                    },
                    closedBuilder: (_, __) {
                      return CircleAvatar(
                        radius: 30.0,
                        backgroundImage:
                            ExactAssetImage('assets/logo/logo.jpg'),
                      );
                    },
                  ),
                ),
                OpenContainer(
                  closedColor: const Color.fromRGBO(31, 51, 71, 1),
                  openColor: const Color.fromRGBO(31, 51, 71, 1),
                  middleColor: const Color.fromRGBO(31, 51, 71, 1),
                  closedElevation: 0.0,
                  openElevation: 0.0,
                  transitionDuration: Duration(milliseconds: 500),
                  transitionType: ContainerTransitionType.fadeThrough,
                  onClosed: (value) {
                    if (allConnectionsUserName.length > 1) {
                      if (mounted) {
                        setState(() {
                          String _latestUserName =
                              allConnectionsUserName.removeAt(
                                  allConnectionsUserName.indexOf(_userName));
                          allConnectionsUserName.insert(0, _latestUserName);
                        });
                      }
                    }
                  },
                  openBuilder: (context, openWidget) {
                    return ChatScreenSetUp(_userName);
                  },
                  closedBuilder: (context, closeWidget) {
                    return Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width / 2 + 20,
                      padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                      child: Column(
                        children: [
                          Text(
                            _userName,
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 12.0,
                          ),
                          Container(
                            child: Text(
                              "Latest Message",
                              style: TextStyle(
                                fontSize: 15.0,
                                color: const Color.fromRGBO(150, 150, 150, 1),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(
                      right: 20.0,
                      top: 2.0,
                      bottom: 2.0,
                    ),
                    child: Column(
                      children: [
                        Container(
                            child: Text(
                          "12:00",
                          style: TextStyle(
                              fontSize: 13.0, color: Colors.lightBlue),
                        )),
                        SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          child: const Icon(
                            Icons.notification_important_outlined,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
