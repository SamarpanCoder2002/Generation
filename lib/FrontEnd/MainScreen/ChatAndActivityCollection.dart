import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:animations/animations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:generation/FrontEnd/Preview/images_preview_screen.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation/FrontEnd/Activity/activity_maker.dart';
import 'package:generation/FrontEnd/Activity/activity_view.dart';
import 'package:generation/FrontEnd/Services/ChatManagement/ChatScreen.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/connection_important_data.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/this_account_important_data.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/encrytion_maker.dart';
import 'package:generation/BackendAndDatabaseManager/native_internal_call/native_call.dart';
import 'package:generation/FrontEnd/Services/search_screen_connections_management.dart';

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
  final Map<String, bool> _allConnectionChatNotificationStatus =
  Map<String, bool>();

  final List<String> _allUserConnectionActivity = [];
  final Map<String, int> _everyUserActivityTotalCountTake = Map<String, int>();

  /// For FireStore Management Purpose
  final Management _management = Management();

  /// For Local Database Management Purpose
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();

  /// For Encryption make object
  final EncryptionMaker _encryptionMaker = EncryptionMaker();

  /// For Downloading Purpose
  final Dio _dio = Dio();

  /// Native Call Make Object
  final NativeCallback _nativeCallback = NativeCallback();

  /// Regular Expression for Media Detection
  final RegExp _mediaRegex =
  RegExp(r"(http(s?):)|([/|.|\w|\s])*\.(?:jpg|gif|png)");
  final RegExp _messageRegex = RegExp(r'[a-zA-Z0-9]');

  Future<void> _fetchRealTimeData() async {
    await ProfileImageManagement.userProfileNameAndImageExtractor();

    print(
        'Now it: ${ProfileImageManagement.allConnectionsProfilePicLocalPath}');

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    /// Storage Request
    final PermissionStatus storagePermissionStatus =
    await Permission.storage.request();

    await Permission.microphone.request();

    if (storagePermissionStatus.isDenied)
      _showDiaLog(
          titleText: 'Storage Permission Denied',
          contentText:
          "If any connection send you a media file, You can't receive that.\n\nPlease Go the Phone Settings and\nGo to Apps -> Generation ->\nPermission -> Allow Access for Storage");

    final Directory? directory = await getExternalStorageDirectory();

    /// Listen to the realTime Data Fetch
    _management.getDatabaseData().listen((event) async {
      final Map<String, dynamic> _allUserConnectionActivityTake =
      event.data()!['activity'] as Map<String, dynamic>;

      /// Current Account User Name Take
      final String _thisAccountUserName =
      await _localStorageHelper.extractImportantDataFromThatAccount(
          userMail: FirebaseAuth.instance.currentUser!.email.toString());

      /// Checking Already This Account Name Present in Local Container or not
      if (!_allUserConnectionActivity.contains(_thisAccountUserName) &&
          !_allUserConnectionActivity
              .contains('$_thisAccountUserName[[[new_activity]]]')) {
        if (mounted) {
          setState(() {
            _allUserConnectionActivity.insert(0, _thisAccountUserName);
          });
        }
      }

      /// For [Activity Data] Store in Local Storage
      _allUserConnectionActivityTake
          .forEach((connectionMail, connectionActivity) async {
        /// If There no new Activity in FireStore Record
        if (connectionActivity
            .toList()
            .isEmpty) {
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
              .contains(_connectionUserNameFromLocalDatabase) &&
              !_allUserConnectionActivity.contains(
                  '$_connectionUserNameFromLocalDatabase[[[new_activity]]]')) {
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
                  'generation_users/${FirebaseAuth.instance.currentUser!.email
                      .toString()}')
                  .update({
                'activity': _allUserConnectionActivityTake,
              });
            });
          }

          particularConnectionActivity
              .toSet()
              .toList(); // For Avoid Duplicate Inclusion of Activity

          particularConnectionActivity.forEach((everyActivity) async {
            if (mounted) {
              setState(() {
                everyActivity = {
                  _encryptionMaker
                      .decryptionMaker(everyActivity.keys.first.toString()):
                  _encryptionMaker.decryptionMaker(
                      everyActivity.values.first.toString()),
                };
              });
            }

            if (_mediaRegex.hasMatch(everyActivity.keys.first.toString())) {
              final String currTime = DateTime.now().toString();

              try {
                if (everyActivity.values.first.toString().split('++++++')[1] ==
                    'video') {
                  if (storagePermissionStatus.isGranted) {
                    final activityVideoPath =
                    await Directory(directory!.path + '/.ActivityVideos/')
                        .create();

                    print('Add Video Activity to Sqlite');

                    /// Insert Video  Activity Data to the local database for future use
                    final bool _videoPathStorageResponse =
                    await _localStorageHelper.insertDataInUserActivityTable(
                      tableName: _connectionUserNameFromLocalDatabase,
                      statusLinkOrString:
                      '${activityVideoPath.path}$currTime.mp4',
                      mediaTypes: MediaTypes.Video,
                      activityTime: everyActivity.values.first
                          .toString()
                          .split('++++++')[2],
                      extraText: everyActivity.values.first
                          .toString()
                          .split('++++++')[0],
                    );

                    /// If path insertion in sqLite having no error, download the video and store it in local storage
                    if (_videoPathStorageResponse) {
                      try {
                        await _dio.download(everyActivity.keys.first.toString(),
                            '${activityVideoPath.path}$currTime.mp4');

                        await _newActivityUpdate(
                            _connectionUserNameFromLocalDatabase);

                        print('Video Download Complete');
                        print(
                            'Activity Video Time: ${everyActivity.values.first
                                .toString().split('++++++')[2]}');
                      } catch (e) {
                        print('Activity Video Download Error: ${e.toString()}');
                      }
                    }
                  } else {
                    print('Storage Permission Denied');
                  }
                } else {
                  if (storagePermissionStatus.isGranted) {
                    /// Create new Hidden Folder once in desired location
                    final activityImagePath =
                    await Directory('${directory!.path}/.ActivityImages/')
                        .create();

                    print('Add Files to Sqlite');

                    /// Add Activity Image Data to Local Storage for Future use and take response about insertion data
                    final bool _imageActivityInsertionResponse =
                    await _localStorageHelper.insertDataInUserActivityTable(
                      tableName: _connectionUserNameFromLocalDatabase,
                      statusLinkOrString:
                      '${activityImagePath.path}$currTime.jpg',
                      mediaTypes: MediaTypes.Image,
                      activityTime: everyActivity.values.first
                          .toString()
                          .split('++++++')[2],
                      extraText: everyActivity.values.first
                          .toString()
                          .split('++++++')[0],
                    );

                    /// If path insertion in sqLite having no error, download the image and store it in local storage
                    if (_imageActivityInsertionResponse) {
                      try {
                        /// Download Image Activity from Firebase Storage and store in local database
                        await _dio.downloadUri(
                            Uri.parse(everyActivity.keys.first.toString()),
                            '${activityImagePath.path}$currTime.jpg');

                        await _newActivityUpdate(
                            _connectionUserNameFromLocalDatabase);

                        print('Image Download Complete');

                        print(
                            'Activity Image Time: ${everyActivity.values.first
                                .toString().split('++++++')[2]}');
                      } catch (e) {
                        print('Activity Image Download Error: ${e.toString()}');
                      }
                    }
                  } else {
                    print('Permission Denied');
                  }
                }
              } catch (e) {
                print('Error: Media Activity Saving Error: ${e.toString()}');
              }
            } else {
              try {
                /// Add Text Activity Data to Local Storage for future use
                await _localStorageHelper.insertDataInUserActivityTable(
                  tableName: _connectionUserNameFromLocalDatabase,
                  statusLinkOrString: everyActivity.keys.first
                      .toString()
                      .split('+')[1] ==
                      ActivitySpecialOptions.Polling.toString()
                      ? '${everyActivity.keys.first.toString().split(
                      '+')[2]}${everyActivity.keys.first.toString().split(
                      '+')[0]}[[[question]]]${everyActivity.values.first
                      .toString()}'
                      : everyActivity.keys.first.toString().split('+')[0],
                  mediaTypes:
                  everyActivity.keys.first.toString().split('+')[1] ==
                      MediaTypes.Text.toString()
                      ? MediaTypes.Text
                      : null,
                  activitySpecialOptions:
                  everyActivity.keys.first.toString().split('+')[1] ==
                      ActivitySpecialOptions.Polling.toString()
                      ? ActivitySpecialOptions.Polling
                      : null,
                  activityTime:
                  everyActivity.keys.first.toString().split('+')[1] ==
                      MediaTypes.Text.toString()
                      ? everyActivity.values.first.toString().split('+')[5]
                      : everyActivity.keys.first.toString().split('+')[3],
                  bgInformation: everyActivity.values.first.toString(),
                );

                await _newActivityUpdate(_connectionUserNameFromLocalDatabase);
              } catch (e) {
                print(
                    'Error: Text And Poll Activity Saving Error: ${e
                        .toString()}');
              }
            }
          });
        }
      });

      /// Connection Request Processing
      if (event.data()!['connection_request'].length > 0) {
        if (mounted) {
          final Map<String, dynamic> allConnectionRequest = event
              .data()!['connection_request']; // Take All Connection Request

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
              if (!_allConnectionsUserName.contains(_encryptionMaker
                  .decryptionMaker(documentSnapshot['user_name']))) {
                /// Make SqLite Table With User UserName
                final bool response = await _localStorageHelper
                    .createTableForUserName(_encryptionMaker
                    .decryptionMaker(documentSnapshot['user_name']));

                try {
                  if (response) {
                    print(
                        'Profile Picture Url: ${documentSnapshot['profile_pic']}');

                    /// Create new Hidden Folder once in desired location
                    final Directory profilePicDir =
                    await Directory('${directory!.path}/.ProfilePictures/')
                        .create(recursive: true);

                    String profilePicPath =
                        '${profilePicDir.path}${DateTime.now()}';

                    if (documentSnapshot['profile_pic'] != null &&
                        documentSnapshot['profile_pic'] != '') {
                      await _dio
                          .download(
                          _encryptionMaker.decryptionMaker(
                              documentSnapshot['profile_pic'].toString()),
                          profilePicPath)
                          .whenComplete(
                              () => print('Profile Picture Download Complete'));
                    } else
                      profilePicPath = '';

                    final String? _globalChatWallpaper =
                    await _localStorageHelper.extractImportantTableData(
                        extraImportant: ExtraImportant.ChatWallpaper,
                        userMail: FirebaseAuth.instance.currentUser!.email
                            .toString());

                    /// Data Store for General Reference
                    await _localStorageHelper.insertOrUpdateDataForThisAccount(
                      userMail: connectionName,
                      userName: _encryptionMaker
                          .decryptionMaker(documentSnapshot['user_name']),
                      userToken: _encryptionMaker
                          .decryptionMaker(documentSnapshot['token']),
                      userAbout: _encryptionMaker
                          .decryptionMaker(documentSnapshot['about']),
                      profileImagePath: profilePicPath,
                      profileImageUrl: (documentSnapshot['profile_pic'] == null)
                          ? ''
                          : documentSnapshot['profile_pic'] == ''
                          ? ''
                          : _encryptionMaker.decryptionMaker(
                          documentSnapshot['profile_pic'].toString()),
                      userAccCreationDate: _encryptionMaker
                          .decryptionMaker(documentSnapshot['creation_date']),
                      userAccCreationTime: _encryptionMaker
                          .decryptionMaker(documentSnapshot['creation_time']),
                      chatWallpaper: _globalChatWallpaper == null
                          ? ''
                          : _globalChatWallpaper,
                    );

                    /// Make a new table to this new connected user Activity
                    await _localStorageHelper.createTableForUserActivity(
                        _encryptionMaker
                            .decryptionMaker(documentSnapshot['user_name']));

                    /// For Call Logs Store of new Connection
                    await _localStorageHelper.createTableForConnectionCallLogs(
                        _encryptionMaker
                            .decryptionMaker(documentSnapshot['user_name']));

                    await ProfileImageManagement
                        .userProfileNameAndImageExtractor();

                    if (ProfileImageManagement
                        .allConnectionsProfilePicLocalPath[
                    _encryptionMaker.decryptionMaker(
                        documentSnapshot['user_name'])] !=
                        profilePicPath) {
                      print('New Connection Profile Pic Not Matched');
                      if (mounted) {
                        setState(() {
                          ProfileImageManagement
                              .allConnectionsProfilePicLocalPath[
                          _encryptionMaker.decryptionMaker(
                              documentSnapshot['user_name'])] =
                              profilePicPath;
                        });
                      }
                    }
                  }
                } catch (e) {
                  print(
                      'Error New Connected Connection Data Entry Error: ${e
                          .toString()}');
                }

                /// Insert New Connected user name at the front of local container
                if (mounted) {
                  setState(() {
                    _allConnectionsUserName.insert(
                        0,
                        _encryptionMaker
                            .decryptionMaker(documentSnapshot['user_name']));

                    this._allConnectionChatNotificationStatus[_encryptionMaker
                        .decryptionMaker(documentSnapshot['user_name'])] = true;

                    _chatNotificationStatusCheckAndUpdate(_encryptionMaker
                        .decryptionMaker(documentSnapshot['user_name']));
                  });
                }
              } else {
                print("Already Connection Added");
              }

              /// User Latest Data Fetch
              final Map<String, dynamic> _allActiveConnections =
              event.data()!['connections'];

              /// For Every Connection, Latest Data to Show
              _allConnectionsUserName.forEach((everyUserName) async {
                final String _connectionMail = await _localStorageHelper
                    .extractImportantDataFromThatAccount(
                    userName: everyUserName);

                final List<dynamic>? _allRemainingMessages =
                _allActiveConnections[_connectionMail];

                final List<Map<String, String>>? _lastMessage = [];

                if (_allRemainingMessages == null ||
                    _allRemainingMessages.length == 0) {
                  final Map<String, String>? takeLocalData =
                  await _localStorageHelper
                      .fetchLatestMessage(everyUserName);

                  if (takeLocalData != null && takeLocalData.isNotEmpty)
                    _lastMessage!.add(takeLocalData);
                } else {
                  _allRemainingMessages.forEach((everyMessage) {
                    _lastMessage!.add({
                      everyMessage.keys.first.toString():
                      everyMessage.values.first.toString(),
                    });
                  });
                }

                if (mounted) {
                  setState(() {
                    if (_lastMessage != null && _lastMessage.isNotEmpty) {
                      _allConnectionsLatestMessage[everyUserName] =
                          _lastMessage;
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

  void _realTimeDataFetchDependsOnNetConnectivity() async {
    final bool isNetworkExist =
    await _nativeCallback.callToCheckNetworkConnectivity();
    if (isNetworkExist) {
      await _fetchRealTimeData();
    } else {
      print('Net Connection Not Found');
      await _offlineConnectionDataManagement();
    }
  }

  /// ChatCollection, Notification Management when you are offline
  Future<void> _offlineConnectionDataManagement() async {
    _showDiaLog(
        titleText: 'You Are Offline',
        contentText: 'Please Connect to the Internet to send Messages');

    final List<Map<String, Object?>> _allConnectionTempList =
    await _localStorageHelper.extractAllUsersName();
    _allConnectionTempList.forEach((userNameMap) {
      if (mounted) {
        setState(() {
          this
              ._allConnectionsUserName
              .add(userNameMap.values.first.toString().toString());
          this._allConnectionChatNotificationStatus[
          userNameMap.values.first.toString().toString()] = true;
        });
      }
    });

    if (mounted) {
      setState(() {
        this._allConnectionsUserName.toSet().toList();
        this._allUserConnectionActivity.toSet().toList();
      });
    }
  }

  /// Existing connection having some activity stored in local database, user name add
  void _searchAboutExistingConnectionActivity() async {
    print('Connection Activity Check');
    final List<Map<String, Object?>> _alreadyStoredUserNameList =
    await _localStorageHelper.extractAllUsersName(
        thisAccountAllowed:
        await _nativeCallback.callToCheckNetworkConnectivity()
            ? false
            : true);

    _alreadyStoredUserNameList.forEach((userNameMap) async {
      final int _countTotalActivity =
      await _localStorageHelper.countTotalActivitiesForParticularUserName(
          userNameMap.values.first.toString());

      if (mounted) {
        setState(() {
          if (_countTotalActivity > 0 ||
              ImportantThings.thisAccountUserName ==
                  userNameMap.values.first.toString().toString()) {
            if (!_allUserConnectionActivity
                .contains(userNameMap.values.first.toString()) &&
                !_allUserConnectionActivity.contains(
                    '${userNameMap.values.first
                        .toString()}[[[new_activity]]]')) {
              if (mounted) {
                setState(() {
                  if (userNameMap.values.first.toString() ==
                      ImportantThings.thisAccountUserName)
                    _allUserConnectionActivity.insert(
                        0, userNameMap.values.first.toString());
                  else
                    _allUserConnectionActivity
                        .add(userNameMap.values.first.toString());

                  this._everyUserActivityTotalCountTake[
                  userNameMap.values.first.toString()] = 0;
                });
              }
            }
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    print("Initialization");
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: SystemUiOverlay.values); // Android StatusBar and Navigation Bar Show

    ImportantThings.findImageUrlAndUserName();

    try {
      _realTimeDataFetchDependsOnNetConnectivity();
      _searchAboutExistingConnectionActivity();

      /// For Unique User Name[Because SomeTimes Duplicate UserName showing after opening the app]
      _allConnectionsUserName.toSet().toList();
      _allUserConnectionActivity.toSet().toList();
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) =>
              AlertDialog(
                title: Text('Chat Collection Load Error'),
                content: Text(e.toString()),
              ));
    }
  }

  @override
  void dispose() {
    print("Chat Collection Dispose");
    super.dispose();
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
          onClosed: (val) {
            if (mounted) {
              setState(() {
                this._allConnectionsUserName.toSet().toList();
                this._allUserConnectionActivity.toSet().toList();
              });
            }
          },
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
                Icons.add,
                color: Colors.white,
                size: 37.0,
              ),
            );
          },
        ),
        body: LoadingOverlay(
          isLoading: _isLoading,
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
        top: 20.0,
        left: 10.0,
      ),
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: MediaQuery
          .of(context)
          .orientation == Orientation.portrait
          ? MediaQuery
          .of(context)
          .size
          .height * (1.5 / 8)
          : MediaQuery
          .of(context)
          .size
          .height * (3 / 8),
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
      margin: EdgeInsets.only(right: MediaQuery
          .of(context)
          .size
          .width / 18),
      padding: EdgeInsets.only(top: 3.0),
      height: MediaQuery
          .of(context)
          .size
          .height * (1.5 / 8),
      child: Column(
        children: [
          Stack(
            children: [
              if (_allUserConnectionActivity[index]
                  .contains('[[[new_activity]]]'))
                Container(
                  height:
                  MediaQuery
                      .of(context)
                      .orientation == Orientation.portrait
                      ? (MediaQuery
                      .of(context)
                      .size
                      .height *
                      (1.2 / 7.95) /
                      2.5) *
                      2
                      : (MediaQuery
                      .of(context)
                      .size
                      .height *
                      (2.5 / 7.95) /
                      2.5) *
                      2,
                  width:
                  MediaQuery
                      .of(context)
                      .orientation == Orientation.portrait
                      ? (MediaQuery
                      .of(context)
                      .size
                      .height *
                      (1.2 / 7.95) /
                      2.5) *
                      2
                      : (MediaQuery
                      .of(context)
                      .size
                      .height *
                      (2.5 / 7.95) /
                      2.5) *
                      2,
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                    value: 1.0,
                  ),
                ),
              OpenContainer(
                closedColor: const Color.fromRGBO(34, 48, 60, 1),
                openColor: const Color.fromRGBO(34, 48, 60, 1),
                middleColor: const Color.fromRGBO(34, 48, 60, 1),
                closedElevation: 0.0,
                closedShape: CircleBorder(),
                transitionDuration: Duration(
                  milliseconds: 500,
                ),
                transitionType: ContainerTransitionType.fadeThrough,
                onClosed: (val) {
                  if (mounted) {
                    setState(() {
                      if (this
                          ._allUserConnectionActivity[index]
                          .contains('[[[new_activity]]]')) {
                        this._allUserConnectionActivity[index] = this
                            ._allUserConnectionActivity[index]
                            .split('[[[new_activity]]]')[0];

                        this._everyUserActivityTotalCountTake[
                        this._allUserConnectionActivity[index]] = 0;
                      }

                      if (index > 0) {
                        final String _connectionUserNameExtracted =
                        this._allUserConnectionActivity.removeAt(index);
                        this
                            ._allUserConnectionActivity
                            .add(_connectionUserNameExtracted);
                      }
                    });
                  }
                },
                openBuilder: (context, openWidget) {
                  final String getOpenActivityConnectionUserName =
                  _allUserConnectionActivity[index]
                      .contains('[[[new_activity]]]')
                      ? _allUserConnectionActivity[index]
                      .split('[[[new_activity]]]')[0]
                      : _allUserConnectionActivity[index];

                  return ActivityView(
                    takeParticularConnectionUserName:
                    getOpenActivityConnectionUserName,
                    activityStartIndex: _allUserConnectionActivity[index]
                        .contains('[[[new_activity]]]')
                        ? this._everyUserActivityTotalCountTake[
                    getOpenActivityConnectionUserName]! -
                        1
                        : 0,
                  );
                },
                closedBuilder: (context, closeWidget) {
                  return CircleAvatar(
                    backgroundImage:
                    getProperImageProviderForConnectionActivity(index),
                    radius: MediaQuery
                        .of(context)
                        .orientation ==
                        Orientation.portrait
                        ? MediaQuery
                        .of(context)
                        .size
                        .height * (1.2 / 8) / 2.5
                        : MediaQuery
                        .of(context)
                        .size
                        .height * (2.5 / 8) / 2.5,
                  );
                },
              ),
              index == 0 // This is for current user Account
                  ? Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery
                      .of(context)
                      .orientation ==
                      Orientation.portrait
                      ? MediaQuery
                      .of(context)
                      .size
                      .height * (0.7 / 8) -
                      10
                      : MediaQuery
                      .of(context)
                      .size
                      .height * (1.5 / 8) -
                      10,
                  left: MediaQuery
                      .of(context)
                      .orientation ==
                      Orientation.portrait
                      ? MediaQuery
                      .of(context)
                      .size
                      .width / 3 - 65
                      : MediaQuery
                      .of(context)
                      .size
                      .width / 8 - 15,
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
                        size: MediaQuery
                            .of(context)
                            .orientation ==
                            Orientation.portrait
                            ? MediaQuery
                            .of(context)
                            .size
                            .height *
                            (1.3 / 8) /
                            2.5 *
                            (3.5 / 6)
                            : MediaQuery
                            .of(context)
                            .size
                            .height *
                            (1.3 / 8) /
                            2,
                      ),
                      onTap: () =>
                          activityList(
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
              _userNameExtractForActivity(index),
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
              top: MediaQuery
                  .of(context)
                  .orientation == Orientation.portrait
                  ? 5.0
                  : 0.0),
          padding: const EdgeInsets.only(top: 18.0, bottom: 10.0),
          height: MediaQuery
              .of(context)
              .size
              .height * (5.15 / 8),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(31, 51, 71, 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10.0,
                spreadRadius: 0.0,
                offset: const Offset(
                    0.0, -5.0), // shadow direction: bottom right
              )
            ],
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0)),
            border: Border.all(
              color: Colors.black26,
              width: 1.0,
            ),
          ),
          child: ReorderableListView.builder(
            onReorder: (first, last) {
              if (mounted) {
                setState(() {
                  final String _draggableConnection =
                  this._allConnectionsUserName.removeAt(first);

                  this._allConnectionsUserName.insert(
                      last >= this._allConnectionsUserName.length
                          ? this._allConnectionsUserName.length
                          : last > first
                          ? --last
                          : last,
                      _draggableConnection);
                });
              }
            },
            itemCount: _allConnectionsUserName.length,
            itemBuilder: (context, position) {
              return chatTile(
                  context, position, _allConnectionsUserName[position]);
            },
          ),
        ));
  }

  Widget chatTile(BuildContext context, int index, String _userName) {
    return Card(
        key: Key('$index'),
        elevation: 0.0,
        color: const Color.fromRGBO(31, 51, 71, 1),
        child: Container(
          //padding: EdgeInsets.only(left: 1.0, right: 1.0),
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
                Padding(
                  padding: EdgeInsets.only(
                    top: 5.0,
                    bottom: 5.0,
                  ),
                  child: OpenContainer(
                    closedColor: const Color.fromRGBO(31, 51, 71, 1),
                    openColor: const Color.fromRGBO(31, 51, 71, 1),
                    middleColor: const Color.fromRGBO(31, 51, 71, 1),
                    closedShape: CircleBorder(),
                    closedElevation: 0.0,
                    transitionDuration: Duration(milliseconds: 500),
                    transitionType: ContainerTransitionType.fadeThrough,
                    openBuilder: (_, __) {
                      return ProfileImageManagement
                          .allConnectionsProfilePicLocalPath[
                      _userName] !=
                          ''
                          ? PreviewImageScreen(
                          imageFile: File(ProfileImageManagement
                              .allConnectionsProfilePicLocalPath[
                          _userName]))
                          : Center(
                        child: Text(
                          'No Profile Image',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20.0,
                          ),
                        ),
                      );
                    },
                    closedBuilder: (_, __) {
                      return CircleAvatar(
                        radius: 30.0,
                        backgroundImage:
                        getProperImageProviderForConnectionsCollection(
                            _userName),
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
                  onClosed: (value) async {
                    /// Irrespectively make changes when a chat just Close
                    _localStorageHelper
                        .fetchLatestMessage(_userName)
                        .then((Map<String, String>? takeLocalData) {
                      if (takeLocalData != null &&
                          takeLocalData.isNotEmpty &&
                          takeLocalData.values.toString().split('+')[0] != '') {
                        if (_allConnectionsLatestMessage[_userName] != null &&
                            _allConnectionsLatestMessage[_userName].isNotEmpty)
                          _allConnectionsLatestMessage[_userName].clear();
                        else {
                          final List<Map<String, String>> tempList = [];
                          _allConnectionsLatestMessage[_userName] = tempList;
                        }
                        if (mounted) {
                          setState(() {
                            print(
                                'Before Add Data On Closed: ${_allConnectionsLatestMessage[_userName]}');

                            _allConnectionsLatestMessage[_userName]
                                .add(takeLocalData);
                          });
                        }
                      }
                    });

                    _localStorageHelper
                        .extractProfileImageLocalPath(userName: _userName)
                        .then((String profileImageLocalPath) {
                      print(
                          'All Closed: ${ProfileImageManagement
                              .allConnectionsProfilePicLocalPath[_userName]}');

                      if (ProfileImageManagement
                          .allConnectionsProfilePicLocalPath[_userName] !=
                          profileImageLocalPath) {
                        if (mounted) {
                          setState(() {
                            ProfileImageManagement
                                .allConnectionsProfilePicLocalPath[
                            _userName] = profileImageLocalPath;
                          });
                        }
                      }
                    });

                    await _chatNotificationStatusCheckAndUpdate(_userName);
                  },
                  openBuilder: (context, openWidget) {
                    return ChatScreenSetUp(
                        _userName,
                        ProfileImageManagement
                            .allConnectionsProfilePicLocalPath[
                        _userName] ==
                            null
                            ? ''
                            : ProfileImageManagement
                            .allConnectionsProfilePicLocalPath[_userName]);
                  },
                  closedBuilder: (context, closeWidget) {
                    return Container(
                      alignment: Alignment.center,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width / 2 + 30,
                      padding: EdgeInsets.only(
                        top: 5.0,
                        bottom: 5.0,
                        left: 5.0,
                      ),
                      child: Column(
                        children: [
                          Text(
                            _userName.length <= 18
                                ? _userName
                                : '${_userName.replaceRange(
                                18, _userName.length, '...')}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 12.0,
                          ),

                          /// For Extract latest Conversation Message
                          _latestDataForConnectionExtractPerfectly(_userName)
                        ],
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(
                      top: 2.0,
                      bottom: 2.0,
                    ),
                    child: Column(
                      children: [

                        /// For Extract latest Conversation Time
                        _latestDataForConnectionExtractPerfectly(_userName,
                            purpose: 'lastConnectionTime'),

                        SizedBox(
                          height: 10.0,
                        ),
                        this._allConnectionChatNotificationStatus[_userName]!
                            ? const Icon(
                          Icons.notification_important_outlined,
                          color: Colors.green,
                        )
                            : const Icon(
                          Icons.notifications_off_outlined,
                          color: Colors.red,
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
    if (_allConnectionsLatestMessage[_userName] != null &&
        _allConnectionsLatestMessage[_userName].isNotEmpty) {
      final List<Map<String, String>>? _allLatestMessages =
      _allConnectionsLatestMessage[_userName] as List<Map<String, String>>;

      /// Extract UserName Specific Messages from temp storage
      if (_allLatestMessages != null && _allLatestMessages.length > 0) {
        Map<String, String>? _lastMessage = _allLatestMessages.last;

        String take = '';
        if (_lastMessage.values.first.toString().contains('+MediaTypes'))
          take = this._encryptionMaker.decryptionMaker(
              _lastMessage.values.first.toString().split('+MediaTypes')[0]);

        _lastMessage = {
          this
              ._encryptionMaker
              .decryptionMaker(_lastMessage.keys.first.toString()):
          _lastMessage.values.first.toString().contains('+MediaTypes')
              ? _lastMessage.values.first.toString().replaceRange(
              0,
              _lastMessage.values.first
                  .toString()
                  .split('+MediaTypes')[0]
                  .length,
              take)
              : this
              ._encryptionMaker
              .decryptionMaker(_lastMessage.values.first.toString()),
        };

        /// For Extract Last Conversation Time
        if (purpose == 'lastConnectionTime') {
          return _latestConversationTime(_lastMessage);
        }

        /// For Extract Last Conversation Message

          String _mediaType = _lastMessage.values.last.toString().split('+')[1];
          String _remainingMessagesLength = '';

          /// If Last Message Not From Local Database
          if (_lastMessage.values.last
              .toString()
              .split('+')
              .length != 4 ||
              _lastMessage.values.last.toString().split('+')[2] != 'localDb')
            _remainingMessagesLength = _allLatestMessages.length.toString();

          /// After Filtering Extract Latest Message and Return Message Widget
          return _latestMessageTypeExtract(_lastMessage.keys.last.toString(),
              _mediaType, _remainingMessagesLength, _userName);


        // /// If there is no last message
        // return Text(
        //   'No Messages',
        //   style: TextStyle(color: Colors.red),
        // );
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
    } else {
      /// For Empty Data
      /// For Extract Last Conversation Time
      if (purpose == 'lastConnectionTime') return Text('');
      return Text('No Messages', style: TextStyle(color: Colors.red));
    }
  }

  /// Message Type Extract
  Widget _latestMessageTypeExtract(String _message, String _mediaTypesToString,
      String _remainingMessagesLength, String _userName) {
    switch (_mediaTypesToString) {
      case 'MediaTypes.Text':
        bool _blankMsgIndicator = false;

        final List<String>? splitMsg = _message.split('\n');

        while (splitMsg!.contains('')) {
          splitMsg.remove('');
        }

        if (splitMsg.length == 0) {
          _message = 'Blank Message';
          _blankMsgIndicator = true;
        } else
          _message = splitMsg[0];

        if (_message.contains('[[[@]]]'))
          _message = _message.split('[[[@]]]')[1];

        if (_messageRegex.hasMatch(_message)) {
          if (_message.length > 16) {
            List<String> take = _message.split('').sublist(0, 16);

            _message = '${take.join('')}...';
          }
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                _message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: _blankMsgIndicator
                      ? Colors.redAccent
                      : const Color.fromRGBO(150, 150, 150, 1),
                  fontFamily: 'Arial',
                ),
              ),
            ),
            if (_remainingMessagesLength != '')
              _totalRemainingMessagesTake(_remainingMessagesLength, _userName),
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
              _totalRemainingMessagesTake(_remainingMessagesLength, _userName),
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
              _totalRemainingMessagesTake(_remainingMessagesLength, _userName),
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
              _totalRemainingMessagesTake(_remainingMessagesLength, _userName),
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
              _totalRemainingMessagesTake(_remainingMessagesLength, _userName),
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
              _totalRemainingMessagesTake(_remainingMessagesLength, _userName),
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
  Widget _totalRemainingMessagesTake(String _remainingMessagesLength,
      String _userName) {
    print('Remaining Messages: $_remainingMessagesLength');

    /// Latest Chat Message show on at first
    if (int.parse(_remainingMessagesLength) > 0 &&
        this._allConnectionsUserName.indexOf(_userName) > 0) {
      this._allConnectionsUserName.remove(_userName);
      this._allConnectionsUserName.insert(0, _userName);
    }

    /// Return Remaining Messages Widget
    return Container(
      margin: EdgeInsets.only(left: 20.0),
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
  Widget _latestConversationTime(Map<String, String>? _lastMessage) {
    if (_lastMessage!.isNotEmpty) {
      String _willReturnTime = '';
      if (_lastMessage.values.last.toString().split('+')[0].toString() != '') {
        /// Extract Incoming Message Date
        final String _incomingMessageDate = _lastMessage.values.first
            .toString()
            .split('+')
            .last
            .toString()
            .split(' ')[0];

        final String compareString =
        _incomingMessageDate
            .split('-')
            .last
            .length <= 2
            ? _incomingMessageDate
            .split('-')
            .last
            : _incomingMessageDate
            .split('-')
            .first;

        /// Checking if the incoming message date day is less than Today's date
        if (int.parse(compareString) < DateTime
            .now()
            .day) {
          _willReturnTime = _incomingMessageDate
              .split('-')
              .last
              .length <= 2
              ? _incomingMessageDate
              .split('-')
              .reversed
              .toList()
              .join('-')
              : _incomingMessageDate;
        } else {
          _willReturnTime =
              _lastMessage.values.last.toString().split('+')[0].toString();

          if (int.parse(_willReturnTime.split(':')[0]) < 10)
            _willReturnTime = _willReturnTime.replaceRange(
                0,
                _willReturnTime.indexOf(':'),
                '0${_willReturnTime.split(':')[0]}');
          if (int.parse(_willReturnTime.split(':')[1]) < 10)
            _willReturnTime = _willReturnTime.replaceRange(
                _willReturnTime.indexOf(':') + 1,
                _willReturnTime.length,
                '0${_willReturnTime.split(':')[1]}');
        }
      }

      return Center(
          child: Text(
            _willReturnTime,
            style: TextStyle(fontSize: 12.0, color: Colors.lightBlue),
          ));
    } else
      return Text(
        '',
        style: TextStyle(
          color: Colors.red,
        ),
      );
  }

  ImageProvider<Object>?  getProperImageProviderForConnectionActivity(int index) {

    print('Probleming Here');

    if ((index == 0 && ImportantThings.thisAccountProfileImagePath == '') ||
        (index > 0 &&
            ProfileImageManagement.allConnectionsProfilePicLocalPath[
            _getUserNameForActivity(index)] ==
                ''))
      return const ExactAssetImage('assets/logo/logo.png');
    else {
      if (index == 0)
        return FileImage(
          File(ImportantThings.thisAccountProfileImagePath),
          scale: 0.5,
        );
      return FileImage(File(ProfileImageManagement
          .allConnectionsProfilePicLocalPath[_getUserNameForActivity(index)]));
    }
  }

  ImageProvider<Object>?  getProperImageProviderForConnectionsCollection(
      String userName) {
    if (ProfileImageManagement.allConnectionsProfilePicLocalPath[userName] ==
        null ||
        ProfileImageManagement
            .allConnectionsProfilePicLocalPath[userName] ==
            '')
      return const ExactAssetImage('assets/logo/logo.png');
    return FileImage(
      File(ProfileImageManagement
          .allConnectionsProfilePicLocalPath[userName]),
      scale: 0.5,
    );
  }

  void _showDiaLog({required String titleText, String contentText = ''}) {
    showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(
              elevation: 5.0,
              backgroundColor: Color.fromRGBO(34, 48, 60, 0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              title: Center(
                  child: Text(
                    titleText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18.0,
                    ),
                  )),
              content: contentText == ''
                  ? null
                  : Container(
                height: 150,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                alignment: Alignment.center,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Center(
                      child: Text(
                        contentText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  Future<void> _chatNotificationStatusCheckAndUpdate(String userName) async {
    bool _previousStatus = this._allConnectionChatNotificationStatus[userName]!;

    final bool _bgNGlobalStatus =
    await _localStorageHelper.extractDataForNotificationConfigTable(
        nConfigTypes: NConfigTypes.BgNotification);
    final bool _fgNGlobalStatus =
    await _localStorageHelper.extractDataForNotificationConfigTable(
        nConfigTypes: NConfigTypes.FGNotification);

    print(_bgNGlobalStatus);
    print(_fgNGlobalStatus);

    if (!_bgNGlobalStatus && !_fgNGlobalStatus) {
      _previousStatus = false;
    } else {
      final bool _bgConnectionSpecificNStatus =
      await _localStorageHelper.extractImportantTableData(
          extraImportant: ExtraImportant.BGNStatus, userName: userName);
      final bool _fgConnectionSpecificNStatus =
      await _localStorageHelper.extractImportantTableData(
          extraImportant: ExtraImportant.FGNStatus, userName: userName);

      print(_bgConnectionSpecificNStatus);
      print(_fgConnectionSpecificNStatus);

      if (!_bgConnectionSpecificNStatus && !_fgConnectionSpecificNStatus) {
        _previousStatus = false;
      } else {
        _previousStatus = true;
      }
    }

    if (mounted) {
      setState(() {
        this._allConnectionChatNotificationStatus[userName] = _previousStatus;
      });
    }
  }

  String _userNameExtractForActivity(int index) {
    String _modifiedUserName = _getUserNameForActivity(index);

    return _modifiedUserName.length <= 10
        ? _modifiedUserName
        : '${_modifiedUserName.replaceRange(
        10, _modifiedUserName.length, '...')}';
  }

  String _getUserNameForActivity(int index) =>
      this
          ._allUserConnectionActivity[index]
          .contains('[[[new_activity]]]')
          ? this._allUserConnectionActivity[index].split(
          '[[[new_activity]]]')[0]
          : this._allUserConnectionActivity[index];

  /// For New Activity Remainder
  Future<void> _newActivityUpdate(String realUserName) async {
    int _countTotalActivity = 0;

    if (this._allUserConnectionActivity.contains(realUserName))
      _countTotalActivity = await _localStorageHelper
          .countTotalActivitiesForParticularUserName(realUserName);

    if (mounted) {
      setState(() {
        if (this._allUserConnectionActivity.contains(realUserName)) {
          /// Remove New Activity Containing user at the second
          this._allUserConnectionActivity.remove(realUserName);
          this
              ._allUserConnectionActivity
              .insert(1, '$realUserName[[[new_activity]]]');

          /// Based upon Activity Condition, Activity Starting index set[For Text Activity Store At last but otherCase Activity Store at first in Local Database]
          this._everyUserActivityTotalCountTake.containsKey(realUserName)
              ? this._everyUserActivityTotalCountTake[realUserName] =
              _countTotalActivity
              : this._everyUserActivityTotalCountTake[realUserName] = 1;
        }
      });
    }
  }
}
