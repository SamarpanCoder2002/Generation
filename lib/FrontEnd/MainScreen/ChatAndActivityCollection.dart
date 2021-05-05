import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
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
  /// For Modal Progress HUD Control
  bool _isLoading = false;

  /// Initialize Some Containers to Store data in Future
  final List<String> _allConnectionsUserName = [];
  final Map<String, dynamic> _allConnectionsLatestMessage =
      Map<String, dynamic>();

  final List<String> _allUserConnectionActivity = [];

  //final FToast _fToast = FToast();

  /// For FireStore Management Purpose
  final Management _management = Management();

  /// For Local Database Management Purpose
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();

  /// For Downloading Purpose
  final Dio _dio = Dio();

  /// Regular Expression for Media Detection
  final RegExp _mediaRegex =
      RegExp(r"(http(s?):)|([/|.|\w|\s])*\.(?:jpg|gif|png)");

  void _fetchRealTimeData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    /// Storage Request
    final PermissionStatus storagePermissionStatus =
        await Permission.storage.request();

    /// Listen to the realTime Data Fetch
    _management.getDatabaseData().listen((event) async {
      final Map<String, dynamic> _allUserConnectionActivityTake =
          event.data()['activity'] as Map;

      /// Current Account User Name Take
      final String _thisAccountUserName =
          await _localStorageHelper.extractImportantDataFromThatAccount(
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
        /// If There no new Activity in FireStore Record
        if (connectionActivity.toList().isEmpty) {
          print("Empty Container");
        } else {
          final List<dynamic> particularConnectionActivity =
              _allUserConnectionActivityTake[connectionMail] as List;

          final String _connectionUserNameFromLocalDatabase =
              await _localStorageHelper.extractImportantDataFromThatAccount(
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

              FirebaseFirestore.instance
                  .doc(
                      'generation_users/${FirebaseAuth.instance.currentUser.email}')
                  .update({
                'activity': _allUserConnectionActivityTake,
              });
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

                  await _dio
                      .download(everyActivity.keys.first.toString(),
                          '${activityVideoPath.path}$currTime.mp4')
                      .whenComplete(() async {
                    print('Video Download Complete');
                  });

                  /// Insert Video  Activity Data to the local database for future use
                  await _localStorageHelper.insertDataInUserActivityTable(
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
                  print('Storage Permission Denied');
                }
              } else {
                if (storagePermissionStatus.isGranted) {
                  /// Create new Hidden Folder once in desired location
                  final activityImagePath =
                      await Directory('${directory.path}/.ActivityImages/')
                          .create();

                  /// Download Image Activity from Firebase Storage and store in local database
                  await _dio
                      .download(everyActivity.keys.first.toString(),
                          '${activityImagePath.path}$currTime.jpg')
                      .whenComplete(() async {
                    print('Image Download Complete');
                    // await _management.deleteFilesFromFirebaseStorage(
                    //     everyActivity.keys.first.toString());
                  });

                  /// Add Activity Image Data to Local Storage for Future use
                  await _localStorageHelper.insertDataInUserActivityTable(
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
              await _localStorageHelper.insertDataInUserActivityTable(
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

      /// Connection Request Processing
      if (event.data()['connection_request'].length > 0) {
        if (mounted) {
          final Map<String, Object> allConnectionRequest =
              event.data()['connection_request']; // Take All Connection Request

          /// Take all Connection Request Data to Update Connectivity
          allConnectionRequest
              .forEach((connectionName, connectionStatus) async {
            if (connectionStatus.toString() == 'Request Accepted' ||
                connectionStatus.toString() == 'Invitation Accepted') {
              /// User All Information Take
              final DocumentSnapshot documentSnapshot = await FirebaseFirestore
                  .instance
                  .doc('generation_users/$connectionName')
                  .get();

              /// Checking If Same User Name Present in the list or not
              if (!_allConnectionsUserName
                  .contains(documentSnapshot['user_name'])) {
                /// Make SqLite Table With User UserName
                final bool response = await _localStorageHelper
                    .createTableForUserName(documentSnapshot['user_name']);

                if (response) {
                  /// Data Store for General Reference
                  await _localStorageHelper.insertDataForThisAccount(
                      userMail: connectionName,
                      userName: documentSnapshot['user_name']);

                  /// Insert Additional Data to user Specific SqLite Database Table
                  await _localStorageHelper.insertAdditionalData(
                    documentSnapshot['user_name'],
                    documentSnapshot['about'],
                    documentSnapshot.id,
                  );

                  /// Make a new table to this new connected user Activity
                  await _localStorageHelper.createTableForUserActivity(
                      documentSnapshot['user_name']);
                }

                /// Insert New Connected user name at the front of local container
                if (mounted) {
                  setState(() {
                    _allConnectionsUserName.insert(
                        0, documentSnapshot['user_name']);
                  });
                }
              } else {
                print("Already Connection Added");
              }

              /// User Latest Data Fetch
              final Map<String, dynamic> _allActiveConnections =
                  event.data()['connections'];

              /// For Every Connection, Latest Data to Show
              _allConnectionsUserName.forEach((everyUserName) async {
                final String _connectionMail = await _localStorageHelper
                    .extractImportantDataFromThatAccount(
                        userName: everyUserName);

                final List<dynamic> _allRemainingMessages =
                    _allActiveConnections[_connectionMail];

                final List<Map<String, String>> _lastMessage = [];

                if (_allRemainingMessages == null ||
                    _allRemainingMessages.length == 0) {
                  final Map<String, String> takeLocalData =
                      await _localStorageHelper
                          .fetchLatestMessage(everyUserName);

                  _lastMessage.add(takeLocalData);
                } else {
                  _allRemainingMessages.forEach((everyMessage) {
                    _lastMessage.add({
                      everyMessage.keys.first.toString():
                          everyMessage.values.first.toString(),
                    });
                  });
                }

                if (mounted) {
                  setState(() {
                    try {
                      _allConnectionsLatestMessage[everyUserName] =
                          _lastMessage;
                    } catch (e) {
                      print('Last Message Insert Error: ${e.toString()}');
                      _allConnectionsLatestMessage.addAll({
                        everyUserName: _lastMessage,
                      });
                    }
                  });
                }
              });
            }
          });
        }
      }
    });

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Existing connection having some activity store in local database, user name add
  void _searchAboutExistingConnectionActivity() async {
    final List<Map<String, Object>> _alreadyStoredUserNameList =
        await _localStorageHelper.extractAllUsersNameExceptThis();
    _alreadyStoredUserNameList.forEach((userNameMap) async {
      final int _countTotalActivity = await _localStorageHelper
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

    //_fToast.init(context); // Flutter Toast Initialized

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
          inAsyncCall: _isLoading,
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
                                allConnectionsUserName:
                                    _allConnectionsUserName),
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
        itemCount: _allConnectionsUserName.length,
        itemBuilder: (context, position) {
          return chatTile(context, position, _allConnectionsUserName[position]);
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
                          imageFile: File('assets/logo/logo.jpg'));
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
                  transitionDuration: Duration(milliseconds: 50),
                  transitionType: ContainerTransitionType.fadeThrough,
                  onClosed: (value) {
                    // For Set the Latest Close chat index at beginning
                    if (_allConnectionsUserName.length > 1) {
                      if (mounted) {
                        setState(() {
                          String _latestUserName =
                              _allConnectionsUserName.removeAt(
                                  _allConnectionsUserName.indexOf(_userName));
                          _allConnectionsUserName.insert(0, _latestUserName);
                        });
                      }
                    }

                    // Irrespectively make changes when a chat just Close
                    _localStorageHelper
                        .fetchLatestMessage(_userName)
                        .then((Map<String, String> takeLocalData) {
                      if (takeLocalData.values.toString().split('+')[0] != '') {
                        _allConnectionsLatestMessage[_userName].clear();
                        if (mounted) {
                          setState(() {
                            _allConnectionsLatestMessage[_userName]
                                .add(takeLocalData);
                          });
                        }
                      }
                    });
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
                          // For Extract latest Conversation Message
                          _latestDataForConnectionExtractPerfectly(_userName)
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
                        // For Extract latest Conversation Time
                        _latestDataForConnectionExtractPerfectly(_userName,
                            purpose: 'lastConnectionTime'),
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

  /// Latest Message Extract
  Widget _latestDataForConnectionExtractPerfectly(String _userName,
      {String purpose = 'lastMessage'}) {
    final List<Map<String, String>> _allLatestMessages =
        _allConnectionsLatestMessage[_userName] as List<Map<String, String>>;

    /// Extract UserName Specific Messages from temp storage

    if (_allLatestMessages != null && _allLatestMessages.length > 0) {
      final Map<String, String> _lastMessage = _allLatestMessages.last;

      /// For Extract Last Conversation Time
      if (purpose == 'lastConnectionTime') {
        return _latestConversationTime(_lastMessage);
      }

      /// For Extract Last Conversation Message
      if (_lastMessage != null) {
        String _mediaType = _lastMessage.values.last.toString().split('+')[1];
        String _remainingMessagesLength = '';

        /// If Last Message Not From Local Database
        if (_lastMessage.values.last.toString().split('+').length != 3 ||
            _lastMessage.values.last.toString().split('+')[2] != 'localDb')
          _remainingMessagesLength = _allLatestMessages.length.toString();

        /// After Filtering Extract Latest Message and Return Message Widget
        return _latestMessageTypeExtract(_lastMessage.keys.last.toString(),
            _mediaType, _remainingMessagesLength);
      }

      /// If there is no last message
      return Text(
        'No Messages',
        style: TextStyle(color: Colors.red),
      );
    }

    /// For Extract Last Connection Time
    if (purpose == 'lastConnectionTime')
      return Container(
          child: Text(
        '',
        style: TextStyle(fontSize: 13.0, color: Colors.lightBlue),
      ));

    /// For Null Control
    return Text('No Messages', style: TextStyle(color: Colors.red));
  }

  /// Message Type Extract
  Widget _latestMessageTypeExtract(String _message, String _mediaTypesToString,
      String _remainingMessagesLength) {
    switch (_mediaTypesToString) {
      case 'MediaTypes.Text':
        bool _blankMsgIndicator = false;

        final List<String> splitMsg = _message.split('\n');

        while (splitMsg.contains('')) {
          splitMsg.remove('');
        }

        if (splitMsg == null || splitMsg.length == 0) {
          _message = 'Blank Message';
          _blankMsgIndicator = true;
        } else
          _message = splitMsg[0];

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Text(
                _message.length <= 15
                    ? _message
                    : '${_message.replaceRange(15, _message.length, '...')}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: _blankMsgIndicator
                      ? Colors.redAccent
                      : const Color.fromRGBO(150, 150, 150, 1),
                ),
              ),
            ),
            if (_remainingMessagesLength != '')
              _totalRemainingMessagesTake(_remainingMessagesLength),
          ],
        );

      case 'MediaTypes.Voice':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.audiotrack_rounded,
              color: Colors.lightBlueAccent,
            ),
            Text(
              "  Voice",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                color: const Color.fromRGBO(150, 150, 150, 1),
              ),
            ),
            if (_remainingMessagesLength != '')
              _totalRemainingMessagesTake(_remainingMessagesLength),
          ],
        );

      case 'MediaTypes.Image':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              color: Colors.lightBlueAccent,
            ),
            Text(
              "  Image",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                color: const Color.fromRGBO(150, 150, 150, 1),
              ),
            ),
            if (_remainingMessagesLength != '')
              _totalRemainingMessagesTake(_remainingMessagesLength),
          ],
        );

      case 'MediaTypes.Video':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_collection_rounded,
              color: Colors.lightBlueAccent,
            ),
            Text(
              "  Video",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                color: const Color.fromRGBO(150, 150, 150, 1),
              ),
            ),
            if (_remainingMessagesLength != '')
              _totalRemainingMessagesTake(_remainingMessagesLength),
          ],
        );

      case 'MediaTypes.Document':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Entypo.documents,
              color: Colors.lightBlueAccent,
            ),
            Text(
              "  Document",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                color: const Color.fromRGBO(150, 150, 150, 1),
              ),
            ),
            if (_remainingMessagesLength != '')
              _totalRemainingMessagesTake(_remainingMessagesLength),
          ],
        );

      case 'MediaTypes.Location':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              color: Colors.lightBlueAccent,
            ),
            Text(
              "  Location",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                color: const Color.fromRGBO(150, 150, 150, 1),
              ),
            ),
            if (_remainingMessagesLength != '')
              _totalRemainingMessagesTake(_remainingMessagesLength),
          ],
        );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "No Messages",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.0,
            color: const Color.fromRGBO(150, 150, 150, 1),
          ),
        ),
      ],
    );
  }

  /// Count Total Remaining Messages
  Widget _totalRemainingMessagesTake(String _remainingMessagesLength) {
    return Container(
      margin: EdgeInsets.only(left: 25.0),
      child: Text(
        '$_remainingMessagesLength',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.lightGreenAccent,
        ),
      ),
    );
  }

  /// Extract last Conversation Message
  Widget _latestConversationTime(Map<String, String> _lastMessage) {
    String _willReturnTime = '';
    if (_lastMessage != null &&
        _lastMessage.values.last.toString().split('+')[0].toString() != '') {
      _willReturnTime =
          _lastMessage.values.last.toString().split('+')[0].toString();

      if (int.parse(_willReturnTime.split(':')[0]) < 10)
        _willReturnTime = _willReturnTime.replaceRange(0,
            _willReturnTime.indexOf(':'), '0${_willReturnTime.split(':')[0]}');
      if (int.parse(_willReturnTime.split(':')[1]) < 10)
        _willReturnTime = _willReturnTime.replaceRange(
            _willReturnTime.indexOf(':') + 1,
            _willReturnTime.length,
            '0${_willReturnTime.split(':')[1]}');
    }
    return Container(
        child: Text(
      _willReturnTime,
      style: TextStyle(fontSize: 13.0, color: Colors.lightBlue),
    ));
  }
}
