import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generation_official/BackendAndDatabaseManager/Dataset/data_type.dart';

import 'package:generation_official/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation_official/FrontEnd/Activity/activity_maker.dart';
import 'package:generation_official/FrontEnd/Services/search_screen.dart';
import 'package:generation_official/FrontEnd/Activity/activity_view.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:animations/animations.dart';

import 'package:generation_official/FrontEnd/MainScreen/ChatScreen.dart';
import 'package:generation_official/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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

    // Listen to the realTime Data Detch
    management.getDatabaseData().listen((event) async {
      final Map<String, dynamic> _allUserConnectionActivityTake =
          event.data()['activity'] as Map;


      // Current Account User Name Take
      final String _thisAccountUserName =
          await localStorageHelper.extractImportantDataFromThatAccount(
              userMail: FirebaseAuth.instance.currentUser.email);

      if (!_allUserConnectionActivity.contains(_thisAccountUserName)) {
        if (mounted) {
          setState(() {
            _allUserConnectionActivity.add(_thisAccountUserName);
          });
        }
      }

      // For Activity Data Store in Local Storage
      _allUserConnectionActivityTake
          .forEach((connectionMail, connectionActivity) async {
        if (connectionActivity.toList().isEmpty) {
          print("Empty Container");
        } else {
          final List<dynamic> particularConnectionActivity =
              _allUserConnectionActivityTake[connectionMail] as List;

          final String _connectionUserNameFromLocalDatabase =
              await localStorageHelper.extractImportantDataFromThatAccount(
                  userMail: connectionMail);

          if (!_allUserConnectionActivity
              .contains(_connectionUserNameFromLocalDatabase)) {
            if (mounted) {
              setState(() {
                _allUserConnectionActivity
                    .add(_connectionUserNameFromLocalDatabase);
              });
            }
          }

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
                    await management.deleteFilesFromFirebaseStorage(
                        everyActivity.keys.first.toString());
                  });

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
                  storagePermissionStatus = await Permission.storage.request();
                }
              } else {
                if (storagePermissionStatus.isGranted) {
                  final activityImagePath =
                      await Directory('${directory.path}/.ActivityImages/')
                          .create();

                  print('Url path: ${activityImagePath.path}$currTime.jpg');
                  print(
                      'Url Something: ${everyActivity.keys.first.toString()}');

                  await dio
                      .download(everyActivity.keys.first.toString(),
                          '${activityImagePath.path}$currTime.jpg')
                      .whenComplete(() async {
                    await management.deleteFilesFromFirebaseStorage(
                        everyActivity.keys.first.toString());
                  });

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
                  storagePermissionStatus = await Permission.storage.request();
                }
              }
            } else {
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

      // Connection Request Take
      if (event.data()['connection_request'].length > 0) {
        if (mounted) {
          Map<String, Object> allConnectionRequest =
              event.data()['connection_request']; // Take All Connection Request

          allConnectionRequest
              .forEach((connectionName, connectionStatus) async {
            if (connectionStatus.toString() == 'Request Accepted' ||
                connectionStatus.toString() == 'Invitation Accepted') {
              // User All Information Take
              DocumentSnapshot documentSnapshot = await FirebaseFirestore
                  .instance
                  .doc('generation_users/$connectionName')
                  .get();

              // Checking If Same USer NAme PResent in the list or not
              if (!allConnectionsUserName
                  .contains(documentSnapshot['user_name'])) {
                // Make SqLite Table With User UserName
                bool response = await localStorageHelper
                    .createTableForUserName(documentSnapshot['user_name']);
                if (response) {
                  await localStorageHelper.insertDataForThisAccount(
                      userMail: connectionName,
                      userName: documentSnapshot['user_name']);

                  await localStorageHelper.insertAdditionalData(
                    documentSnapshot['user_name'],
                    documentSnapshot['about'],
                    documentSnapshot.id,
                  );

                  await localStorageHelper.createTableForUserActivity(
                      documentSnapshot['user_name']);
                }

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

  @override
  void initState() {
    super.initState();
    print("Initialization");
    SystemChrome.setEnabledSystemUIOverlays(
        SystemUiOverlay.values); // Android StatusBar Show

    fToast.init(context);

    try {
      _fetchRealTimeData();
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
    return chatScreen(context);
  }

  Widget chatScreen(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color.fromRGBO(20, 200, 50, 1),
          child: Icon(
            Icons.search_rounded,
            color: Colors.white,
            size: 30.0,
          ),
          onPressed: () async {
            print('Search based on Text');
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => Search()));
          }),
      backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        color: Color.fromRGBO(0, 0, 0, 0.5),
        progressIndicator: CircularProgressIndicator(
          backgroundColor: Colors.black87,
        ),
        child: ListView(
          children: [
            statusBarContainer(context),
            chatList(context),
          ],
        ),
      ),
    );
  }

  Widget statusBarContainer(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 23.0,
        left: 10.0,
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * (1 / 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _allUserConnectionActivity.length,
        itemBuilder: (context, position) {
          return statusList(context, position);
        },
      ),
    );
  }

  Widget statusList(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.only(right: MediaQuery.of(context).size.width / 18),
      child: GestureDetector(
        onTap: () {},
        child: Stack(
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
                  backgroundImage: ExactAssetImage(
                    "assets/images/sam.jpg",
                  ),
                  radius: 50.0,
                );
              },
            ),
            index == 0
                ? Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * (1 / 8) - 30,
                      left: 60.0,
                    ),
                    child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.lightBlue,
                        ),
                        child: GestureDetector(
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 30.0,
                          ),
                          onTap: () => activityList(
                              context: context,
                              allConnectionsUserName: allConnectionsUserName),
                        )),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget chatList(BuildContext context) {
    return SafeArea(
        child: Container(
      margin: EdgeInsets.only(top: 35.0),
      padding: EdgeInsets.only(top: 18.0, bottom: 10.0),
      height: MediaQuery.of(context).size.height * (5.15 / 8),
      decoration: BoxDecoration(
        color: Color.fromRGBO(31, 51, 71, 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            spreadRadius: 0.0,
            offset: Offset(0.0, -5.0), // shadow direction: bottom right
          )
        ],
        borderRadius: BorderRadius.only(
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
                  child: GestureDetector(
                    child: CircleAvatar(
                      radius: 30.0,
                      backgroundImage: ExactAssetImage('assets/images/sam.jpg'),
                    ),
                    onTap: () {
                      print("Pic Pressed");
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
                                color: Color.fromRGBO(150, 150, 150, 1),
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
                    padding: EdgeInsets.only(
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
                          child: Icon(
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
