import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:circle_list/circle_list.dart';
import 'package:circle_list/radial_drag_gesture_detector.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter_autolink_text/flutter_autolink_text.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/encrytion_maker.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/this_account_important_data.dart';
import 'package:generation/BackendAndDatabaseManager/native_internal_call/native_call.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share/share.dart';
import 'package:thumbnails/thumbnails.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:swipe_to/swipe_to.dart';

import 'package:generation/FrontEnd/Preview/images_preview_screen.dart';
import 'package:generation/BackendAndDatabaseManager/general_services/notification_configuration.dart';
import 'package:generation/BackendAndDatabaseManager/general_services/toast_message_manage.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:generation/FrontEnd/Services/multiple_message_send_connection_selection.dart';

import 'connection_profile_view.dart';

// ignore: must_be_immutable
class ChatScreenSetUp extends StatefulWidget {
  final String _userName;
  String _connectionProfileImageLocalPath;

  ChatScreenSetUp(this._userName, this._connectionProfileImageLocalPath);

  @override
  _ChatScreenSetUpState createState() => _ChatScreenSetUpState();
}

class _ChatScreenSetUpState extends State<ChatScreenSetUp>
    with TickerProviderStateMixin {
  /// Some Boolean Value Initialization
  bool _iconChanger = true;
  bool _isMicrophonePermissionGranted = false;
  bool _isLoading = false;
  bool _showEmojiPicker = false, _isChatOpenFirstTime = true;
  bool _autoFocus = false;
  bool _deleteMediaFromInternalStorage = false;

  /// Some Integer Value Initialized
  double _audioDownloadProgress = 0;
  double _currAudioPlayingTime;
  int _lastAudioPlayingIndex;
  double _bottomRowDownPadding = 7.0;
  double _audioPlayingSpeed = 1.0;

  /// For Control the Scrolling
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
  );

  /// All Container List
  final List<Map<String, String>> _chatContainer = [];
  final List<bool> _response = [];
  final List<MediaTypes> _mediaTypes = [];

  /// For Controller Text in Field
  final TextEditingController _inputTextController = TextEditingController();
  final TextEditingController _mediaTextController = TextEditingController();

  /// Object Initialization For FireStore and Local Database Management Respectly
  final Management _management = Management();
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();
  final SendNotification _sendNotification = SendNotification();
  final NativeCallback _nativeCallback = NativeCallback();
  final EncryptionMaker _encryptionMaker = EncryptionMaker();

  /// Audio Player and Dio Downloader Initialized
  final AudioPlayer _justAudioPlayer = AudioPlayer();
  final Dio _dio = Dio();

  /// Image Picker and Flutter Toast Initialized
  final ImagePicker _picker = ImagePicker();
  final FToast fToast = FToast();

  /// Regular Expression
  final RegExp _messageRegex = RegExp(r'[a-zA-Z0-9]');

  /// Chat List View Parent Height
  double _chatBoxHeight;
  double _bottomRowHeight = 80.0;

  /// Sound Recorder and Audio Obj Initialization
  FlutterSoundRecorder _flutterSoundRecorder;
  Directory _audioDirectory;

  /// Current User Some Details Containers Variables
  String _senderMail;
  String _connectionToken;
  String _currAccountUserName;

  /// For This Chat Specific Feature
  String _thisChatWallPaper = '';

  /// Audio Playing Time Related
  String _totalDuration = '0:00';
  String _loadingTime = '0:00';

  /// For Reply a Text
  String _replyText = '';

  /// Text Writing Place Hint Text
  String _hintText;

  /// For Audio Player
  IconData _iconData = Icons.play_arrow_rounded;

  /// Chat Screen Use Frequently Changeable Send and Voice Icon
  final Icon _senderIcon = Icon(
    Icons.send_rounded,
    size: 30.0,
    color: const Color.fromRGBO(20, 255, 50, 1),
  );

  final Icon _voiceIcon = Icon(
    Icons.keyboard_voice_rounded,
    size: 30.0,
    color: const Color.fromRGBO(20, 255, 50, 1),
  );

  void _essentialExtract() async {
    _senderMail = await _localStorageHelper.extractImportantDataFromThatAccount(
        userName: widget._userName);

    _connectionToken =
        await _localStorageHelper.extractToken(userMail: this._senderMail);

    _currAccountUserName =
        await _localStorageHelper.extractImportantDataFromThatAccount(
            userMail: FirebaseAuth.instance.currentUser.email);
  }

  _extractHistoryDataFromSqLite() async {
    try {
      double _positionToScroll = 0;

      List<Map<String, dynamic>> messagesGet = [];
      messagesGet =
          await _localStorageHelper.extractMessageData(widget._userName);

      /// If messagesList not Empty
      if (messagesGet.isNotEmpty) {
        for (Map<String, dynamic> message in messagesGet) {
          /// Change Every Message Value to List
          List<dynamic> messageContainer = message.values.toList();

          print('Message Container: $messageContainer');

          /// If there is no opponent's person messages
          if (messageContainer.isEmpty) {
            print("No messages in ChatContainer");
          } else {
            if (mounted) {
              setState(() {
                _chatContainer.add({
                  _encryptionMaker
                          .decryptionMaker(messageContainer[0].toString()):
                      _encryptionMaker
                          .decryptionMaker(messageContainer[1].toString()),
                });
                if (messageContainer[2] == 1)
                  _response.add(true);
                else
                  _response.add(false);

                /// Rectify MediaType
                if (messageContainer[3] == MediaTypes.Text.toString()) {
                  _positionToScroll += 100;
                  _mediaTypes.add(MediaTypes.Text);
                } else if (messageContainer[3] == MediaTypes.Voice.toString()) {
                  _positionToScroll += 150;
                  _mediaTypes.add(MediaTypes.Voice);
                } else if (messageContainer[3] == MediaTypes.Image.toString()) {
                  _positionToScroll += MediaQuery.of(context).size.height * 0.6;
                  _mediaTypes.add(MediaTypes.Image);
                } else if (messageContainer[3] == MediaTypes.Video.toString()) {
                  _positionToScroll += MediaQuery.of(context).size.height * 0.6;
                  _mediaTypes.add(MediaTypes.Video);
                } else if (messageContainer[3] ==
                    MediaTypes.Document.toString()) {
                  _positionToScroll += MediaQuery.of(context).size.height * 0.6;
                  _mediaTypes.add(MediaTypes.Document);
                } else if (messageContainer[3] ==
                    MediaTypes.Location.toString()) {
                  _positionToScroll += MediaQuery.of(context).size.height * 0.6;
                  _mediaTypes.add(MediaTypes.Location);
                }
              });
            }
          }
        }

        /// Auto Scroll Control to the latest Message
        if (mounted) {
          setState(() {
            _scrollController.jumpTo(
                _scrollController.position.maxScrollExtent + _positionToScroll);
          });
        }
      } else {
        print('No Old Messages in Local Database');
      }

      /// After Get the old Conversation messages from SqLite, Take New Messages Data from FireStore
      _extractDataFromFireStore();
    } catch (e) {
      // For AutoScroll to the end position

      print('Error in Extract Data From Local Storage: ${e.toString()}');

      _scrollController.jumpTo(_scrollController.position.maxScrollExtent *
          _chatContainer.length *
          (MediaQuery.of(context).size.height) *
          0.2);

      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text("Local Database Error"),
                content: Text(e.toString()),
              ));
    }
  }

  _extractDataFromFireStore() {
    try {
      double _positionToScroll = 100;

      /// Fetch Updated Real Time Data from FireStore
      _management.getDatabaseData().listen((event) async {
        if (event.data()['connections'].length < 0) {
          print("No Connections Present");
        } else {
          /// Checking If Sender Mail Present or Not
          if (event.data()['connections'].containsKey(this._senderMail)) {
            try {
              /// For Profile Pic Updation Purpose
              final String _profilePicUrl = await _localStorageHelper
                  .extractProfilePicUrl(userName: widget._userName);
              final String _connectionMail =
                  await _localStorageHelper.extractImportantDataFromThatAccount(
                      userName: widget._userName);

              final DocumentSnapshot connectionSnapShot =
                  await FirebaseFirestore.instance
                      .doc('generation_users/$_connectionMail')
                      .get();

              /// Profile Picture Updation Check
              if (connectionSnapShot.data()['profile_pic'] != _profilePicUrl) {
                final Directory directory = await getExternalStorageDirectory();

                /// Create new Hidden Folder once in desired location
                final Directory profilePicDir =
                    await Directory('${directory.path}/.ProfilePictures/')
                        .create(recursive: true);

                String profilePicPath =
                    '${profilePicDir.path}${DateTime.now()}';

                /// If Updated ProfilePic not null and Empty String
                if (connectionSnapShot.data()['profile_pic'].toString() !=
                        null &&
                    connectionSnapShot.data()['profile_pic'].toString() != '') {
                  print('Path: ${widget._connectionProfileImageLocalPath}');

                  if (widget._connectionProfileImageLocalPath != '')
                    await File(widget._connectionProfileImageLocalPath)
                        .delete(recursive: true)
                        .whenComplete(() => print(
                            'Old Profile Image of Connection Deletion Complete'));

                  print(
                      'Cute: ${connectionSnapShot['profile_pic'].toString()}');

                  showToast(
                    'Profile Picture Updating...\nPlease Wait',
                    fToast,
                    fontSize: 18.0,
                    toastColor: Colors.amber,
                  );

                  if (mounted) {
                    setState(() {
                      _isLoading = true;
                    });
                  }

                  try {
                    await _dio
                        .download(connectionSnapShot['profile_pic'].toString(),
                            profilePicPath)
                        .whenComplete(() {
                      print('Profile Picture Download Complete');
                    });
                  } catch (e) {
                    print('Profile Pic Download Error: ${e.toString()}');
                  }
                } else {
                  if (connectionSnapShot.data()['profile_pic'].toString() ==
                          '' &&
                      widget._connectionProfileImageLocalPath != '')
                    await File(widget._connectionProfileImageLocalPath)
                        .delete(recursive: true)
                        .whenComplete(() => print(
                            'Old Profile Image of Connection Deletion Complete'));

                  profilePicPath = '';
                }

                if (mounted) {
                  setState(() {
                    widget._connectionProfileImageLocalPath = profilePicPath;
                    if (_isLoading) _isLoading = false;
                  });
                }

                /// Update Local And Remote Profile Image Path
                await _localStorageHelper.insertProfilePictureInImportant(
                    imagePath: profilePicPath,
                    imageUrl: connectionSnapShot
                                .data()['profile_pic']
                                .toString() !=
                            null
                        ? connectionSnapShot.data()['profile_pic'].toString()
                        : '',
                    mail: _connectionMail);
              }
            } catch (e) {
              print(
                  'Exception Error : In Chat Screen Profile Pic Updation Error: ${e.toString()}');

              if (_isLoading) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
                showToast(
                  'Profile Picture Update Error...',
                  fToast,
                  fontSize: 16.0,
                );
              }
            }

            /// Take Corresponding messages of that Contact
            List<dynamic> messages = [];
            messages = event.data()['connections'][this._senderMail];

            /// If messageContainer not Empty
            if (messages.isNotEmpty) {
              if (mounted) {
                setState(() {
                  /// Take Map of Connections
                  Map<String, dynamic> allConnections =
                      event.data()['connections'] as Map;

                  /// Particular connection messages set to Empty
                  allConnections[this._senderMail] = [];

                  if (_isChatOpenFirstTime) {
                    _mediaTypes.add(MediaTypes.Indicator);
                    _chatContainer.add({
                      'New Messages': '',
                    });
                    _response.add(null);
                  }

                  /// Update Data in FireStore
                  FirebaseFirestore.instance
                      .doc(
                          'generation_users/${FirebaseAuth.instance.currentUser.email}')
                      .update({
                    'connections': allConnections,
                  });

                  List<String> _incomingInformationContainer = [];

                  print('Messages: $messages');

                  /// Taking all the remaining messages to store in local container
                  messages.forEach((everyMessage) async {
                    everyMessage = {
                      _encryptionMaker.decryptionMaker(
                              everyMessage.keys.first.toString()):
                          _encryptionMaker.decryptionMaker(
                              everyMessage.values.first.toString()),
                    };

                    _incomingInformationContainer =
                        everyMessage.values.first.toString().split('+');

                    /// MediaTypes Rectify
                    switch (_incomingInformationContainer[1]) {
                      case 'MediaTypes.Text': // If Message Type is Text

                        if (everyMessage.keys.first
                            .toString()
                            .contains('[[[@]]]')) {
                          _positionToScroll = 110;
                        }

                        await _manageText(
                            _incomingInformationContainer, everyMessage);
                        break;

                      case 'MediaTypes.Voice': // If Message type is voice

                        await _manageVoice(
                            _incomingInformationContainer, everyMessage);
                        break;

                      case 'MediaTypes.Image':
                        _positionToScroll =
                            MediaQuery.of(context).size.height * 0.6;
                        await _manageMedia(
                            _incomingInformationContainer, everyMessage);
                        break;

                      case 'MediaTypes.Video':
                        _positionToScroll =
                            MediaQuery.of(context).size.height * 0.6;
                        await _manageMedia(
                          _incomingInformationContainer,
                          everyMessage,
                        );
                        break;

                      case 'MediaTypes.Document':
                        _positionToScroll =
                            MediaQuery.of(context).size.height * 0.6;
                        await _manageDocument(
                            _incomingInformationContainer, everyMessage);
                        break;

                      case 'MediaTypes.Location':
                        _positionToScroll =
                            MediaQuery.of(context).size.height * 0.6;
                        await _manageLocation(
                            _incomingInformationContainer, everyMessage);
                        break;
                    }

                    if (_isChatOpenFirstTime) {
                      print('Chat Opened First Time');
                    } else {
                      print('Reach Here');

                      if (_scrollController.hasClients) {
                        print(_positionToScroll);

                        _scrollController.jumpTo(
                            _scrollController.position.maxScrollExtent +
                                _positionToScroll);

                        _positionToScroll = 100;
                      }
                    }
                  });
                });
              }
            } else {
              print("No message Here");
            }

            /// Make Control in isChatOpenFirstTime
            if (mounted) {
              setState(() {
                if (_isChatOpenFirstTime) {
                  _isChatOpenFirstTime = false;
                }
              });
            }
          } else {
            print("Contacts Not Present");
          }
        }
      });
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text("FireStore Problem"),
                content: Text(e.toString()),
              ));
    }
  }

  Future<void> _manageText(
      List<String> _incomingInformationContainer, everyMessage) async {
    /// Store Data in local Storage
    await _localStorageHelper.insertNewMessages(
        widget._userName,
        _encryptionMaker.encryptionMaker(everyMessage.keys.first.toString()),
        MediaTypes.Text,
        1,
        _encryptionMaker.encryptionMaker(_incomingInformationContainer[0]));

    print('Encrypted Every Message: $everyMessage');

    if (mounted) {
      setState(() {
        _mediaTypes.add(MediaTypes.Text);

        _chatContainer.add({
          /// Current Running information Store
          '${everyMessage.keys.first}': '${_incomingInformationContainer[0]}',
        });

        _response.add(true); // Chat Position Status Added
      });
    }
  }

  Future<void> _manageVoice(
      List<String> _incomingInformationContainer, everyMessage) async {
    try {
      final PermissionStatus storagePermissionStatus =
          await Permission.storage.request();

      /// Take User Permission To Take Voice
      if (storagePermissionStatus.isGranted) {
        if (mounted) {
          setState(() {
            _isLoading = true;
          });
        }

        final Directory directory = await getExternalStorageDirectory();
        print('Directory Path: ${directory.path}');

        final recordingStorage =
            await Directory(directory.path + '/Recordings/')
                .create(); // Create New Folder about the desire location

        final String currTime = DateTime.now().toString(); // Current Time Take

        if (mounted) {
          setState(() {
            _mediaTypes.add(MediaTypes.Voice); // add New Media Type

            _chatContainer.add({
              // Take Messages in Local Container
              '${recordingStorage.path}$currTime${_incomingInformationContainer[2]}':
                  '${_incomingInformationContainer[0]}',
            });

            _response.add(true); // Chat Position Status Added
          });
        }

        try {
          /// Download the voice from the Firebase Storage and delete from storage permanently
          await _dio
              .download(everyMessage.keys.first.toString(),
                  '${recordingStorage.path}$currTime${_incomingInformationContainer[2]}',
                  onReceiveProgress: _downLoadOnReceiveProgress)
              .whenComplete(() async {
            print('After Download: $_incomingInformationContainer');
            if (_incomingInformationContainer.length < 4)
              await _management.deleteFilesFromFirebaseStorage(
                  everyMessage.keys.first.toString());
          });
        } catch (e) {
          print('Dio Audio Download Error: ${e.toString()}');
        }

        print(
            'Recorded Path: ${recordingStorage.path}$currTime${_incomingInformationContainer[2]}');

        /// Store Data in local Storage
        _localStorageHelper.insertNewMessages(
            widget._userName,
            _encryptionMaker.encryptionMaker(
                '${recordingStorage.path}$currTime${_incomingInformationContainer[2]}'),
            MediaTypes.Voice,
            1,
            _encryptionMaker.encryptionMaker(_incomingInformationContainer[0]));
      }
    } catch (e) {
      print('Voice Download Error: ${e.toString()}');
    }

    if (_isLoading) if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _manageLocation(
      List<String> _incomingInformationContainer, everyMessage) async {
    final PermissionStatus storagePermissionStatus = await Permission.storage
        .request(); // Take User Permission To Take Voice

    if (storagePermissionStatus.isGranted) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      /// Store in Local Database
      await _localStorageHelper.insertNewMessages(
          widget._userName,
          _encryptionMaker.encryptionMaker(everyMessage.keys.first),
          MediaTypes.Location,
          1,
          _encryptionMaker.encryptionMaker(everyMessage.values.first));

      /// Important Local Container Updated
      if (mounted) {
        setState(() {
          _mediaTypes.add(MediaTypes.Location);

          _chatContainer.add({
            everyMessage.keys.first: everyMessage.values.first,
          });

          _response.add(true);
        });
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      try {
        /// Toast Message
        showToast('Click Red Pointer in Map to Open in Google Map', fToast,
            seconds: 5, fontSize: 16.0);
      } catch (e) {
        print('Toast Error in Chat Screen: ${e.toString()}');
      }
    }
  }

  Future<void> _manageDocument(
      List<String> _incomingInformationContainer, everyMessage) async {
    final PermissionStatus storagePermissionStatus = await Permission.storage
        .request(); // Take User Permission To Take Voice

    try {
      if (storagePermissionStatus.isGranted) {
        if (mounted) {
          setState(() {
            _isLoading = true;
          });
        }

        final Directory directory = await getExternalStorageDirectory();
        print('Directory Path: ${directory.path}');

        final Directory _newDirectory =
            await Directory('${directory.path}/Documents/')
                .create(); // Create New Folder about the desire location;

        final String currTime =
            DateTime.now().toString().split(' ').join('_'); // Current Time Take

        try {
          await _dio
              .download(everyMessage.keys.first.toString(),
                  '${_newDirectory.path}$currTime${everyMessage.values.first.split('+')[3]}')
              .whenComplete(() async {
            print(
                'In When Complete: ${everyMessage.keys.first.toString()}   $_incomingInformationContainer');
            if (_incomingInformationContainer.length < 5)
              await _management.deleteFilesFromFirebaseStorage(
                  everyMessage.keys.first.toString());
          });
        } catch (e) {
          print('Dio Document Download Error: ${e.toString()}');
        }

        await _localStorageHelper.insertNewMessages(
            widget._userName,
            _encryptionMaker.encryptionMaker('${_newDirectory.path}$currTime${everyMessage.values.first.split('+')[3]}'),
            MediaTypes.Document,
            1,
            _encryptionMaker.encryptionMaker('${_incomingInformationContainer[0]}+${_incomingInformationContainer[2]}+${_incomingInformationContainer[3]}'));

        if (mounted) {
          setState(() {
            _mediaTypes.add(MediaTypes.Document); // add New Media Type

            _chatContainer.add({
              // Take Messages in Local Container
              '${_newDirectory.path}$currTime${everyMessage.values.first.split('+')[3]}':
                  '${_incomingInformationContainer[0]}+${_incomingInformationContainer[2]}+${_incomingInformationContainer[3]}',
            });

            _response.add(true); // Chat Position Status Added
          });
        }
      }
    } catch (e) {
      print('Document Download Error: ${e.toString()}');
    }

    if (_isLoading) if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _manageMedia(
    List<String> _incomingInformationContainer,
    dynamic everyMessage,
  ) async {
    print('Samarpan: $_incomingInformationContainer, $everyMessage');

    final PermissionStatus storagePermissionStatus = await Permission.storage
        .request(); // Take User Permission To Take Voice

    try {
      if (storagePermissionStatus.isGranted) {
        if (mounted) {
          setState(() {
            _isLoading = true;
          });
        }

        final Directory directory = await getExternalStorageDirectory();
        print('Directory Path: ${directory.path}');

        Directory _newDirectory;

        if (_incomingInformationContainer[1] == MediaTypes.Image.toString())
          _newDirectory = await Directory('${directory.path}/Images/').create(
              recursive: true); // Create New Folder about the desire location
        else
          _newDirectory = await Directory('${directory.path}/Videos/').create(
              recursive: true); // Create New Folder about the desire location

        print('New Directory: ${_newDirectory.path}    $everyMessage');

        final String currTime =
            DateTime.now().toString().split(' ').join('_'); // Current Time Take

        final Directory _thumbNailDir =
            await Directory('${directory.path}/.ThumbNails/').create(
                recursive:
                    true); // Create New Folder about the desire location;

        String thumbNailPicturePath;

        String _filePathStore =
            _incomingInformationContainer[1] == MediaTypes.Image.toString()
                ? '${_newDirectory.path}$currTime.jpg'
                : '${_newDirectory.path}$currTime.mp4';

        print('Previous File Path: $_filePathStore');

        try {
          /// Download the voice from the Firebase Storage and delete from storage permanently
          await _dio
              .download(
            _incomingInformationContainer[1] == MediaTypes.Video.toString()
                ? everyMessage.keys.first.toString().split('+')[0]
                : everyMessage.keys.first.toString(),
            _incomingInformationContainer[1] == MediaTypes.Image.toString()
                ? '${_newDirectory.path}$currTime.jpg'
                : '${_newDirectory.path}$currTime.mp4',
          )
              .whenComplete(() async {
            print(
                'In When Complete: ${everyMessage.keys.first.toString()}:   ${_incomingInformationContainer.length}');

            /// For Save Image or Video In Gallery
            final gallerySaverResult = await ImageGallerySaver.saveFile(
                _incomingInformationContainer[1] == MediaTypes.Image.toString()
                    ? '${_newDirectory.path}$currTime.jpg'
                    : '${_newDirectory.path}$currTime.mp4');
            print(
                'Gallery Image Path: ${gallerySaverResult['filePath']}   ${gallerySaverResult['isSuccess']}');

            print(gallerySaverResult['isSuccess']);

            if (gallerySaverResult['isSuccess'].toString() == 'true') {
              _filePathStore = gallerySaverResult['filePath']
                  .toString()
                  .split('file:///')[1];

              await File(_incomingInformationContainer[1] ==
                          MediaTypes.Image.toString()
                      ? '${_newDirectory.path}$currTime.jpg'
                      : '${_newDirectory.path}$currTime.mp4')
                  .delete(recursive: true)
                  .whenComplete(() => print('Store in Gallery'))
                  .catchError((e) {
                print('File Delete Error in ChatScreen: ${e.toString()}');
              });

              print('In Gallery Save');
            }

            if (_incomingInformationContainer.length < 4)
              await _management.deleteFilesFromFirebaseStorage(
                  _incomingInformationContainer[1] !=
                          MediaTypes.Video.toString()
                      ? everyMessage.keys.first.toString()
                      : everyMessage.keys.first.toString().split('+')[0]);

            if (_incomingInformationContainer[1] ==
                MediaTypes.Video.toString()) {
              print("Video Path: ${_newDirectory.path}$currTime.mp4'");

              try {
                print(
                    'Thumbnail Url is: ${everyMessage.keys.first.toString().split('+')[1]}');

                await _dio
                    .download(
                  everyMessage.keys.first.toString().split('+')[1],
                  '${_thumbNailDir.path}$currTime.jpg',
                )
                    .whenComplete(() async {
                  if (_incomingInformationContainer.length < 4)
                    await _management.deleteFilesFromFirebaseStorage(
                        everyMessage.keys.first.toString().split('+')[1]);
                });
              } catch (e) {
                print(
                    'Dio Video Thumbnail DownloadException: ${e.toString()} ');
              }

              print('ThumbNail Path: $thumbNailPicturePath');
            }
          });
        } catch (e) {
          print('Dio Video Download Error: ${e.toString}');
        }

        print('Recorded Path: $_filePathStore');

        /// Store Data in local Storage
        _localStorageHelper.insertNewMessages(
            widget._userName,
            _encryptionMaker.encryptionMaker(_filePathStore),
            _incomingInformationContainer[1] == MediaTypes.Image.toString()
                ? MediaTypes.Image
                : MediaTypes.Video,
            1,
            _incomingInformationContainer[1] == MediaTypes.Image.toString()
                ? _encryptionMaker.encryptionMaker('${_incomingInformationContainer[0]}+${_incomingInformationContainer[2]}')
                : _encryptionMaker.encryptionMaker('${_incomingInformationContainer[0]}+${_incomingInformationContainer[2]}+${_thumbNailDir.path}$currTime.jpg'));

        if (mounted) {
          setState(() {
            _incomingInformationContainer[1] == MediaTypes.Image.toString()
                ? _mediaTypes.add(MediaTypes.Image)
                : _mediaTypes.add(MediaTypes.Video); // add New Media Type

            _chatContainer.add({
              /// Take Messages in Local Container
              _filePathStore: _incomingInformationContainer[1] ==
                      MediaTypes.Image.toString()
                  ? '${_incomingInformationContainer[0]}+${_incomingInformationContainer[2]}'
                  : '${_incomingInformationContainer[0]}+${_incomingInformationContainer[2]}+${_thumbNailDir.path}$currTime.jpg',
            });
            _response.add(true); // Chat Position Status Added
          });
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Media Download Error: ${e.toString()}');
    }
    if (_isLoading) if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _permissionSetForRecording() async {
    try {
      final PermissionStatus recordingPermissionStatus =
          await Permission.microphone.request();

      if (recordingPermissionStatus.isGranted) {
        _isMicrophonePermissionGranted = true;
        _flutterSoundRecorder = FlutterSoundRecorder(); // Initialize
        await _flutterSoundRecorder.openAudioSession(); // Active Audio Session

        /// Make Directory One Time
        await _makeDirectoryOnce();
      } else
        _showDiaLog(
            titleText: 'Sorry, Microphone Permission Already Denied',
            contentText:
                'Please go to the phone settings and\nGo to the Apps -> Generation ->\nPermission -> Allow Microphone to access this app');
    } catch (e) {
      print("Record Permission Status Error: ${e.toString()}");
      _permissionSetForRecording();
    }
  }

  Future<void> _makeDirectoryOnce() async {
    final Directory directory = await getExternalStorageDirectory();

    _audioDirectory = await Directory(directory.path + '/Recordings/')
        .create(); // This directory will create Once in whole Application
  }

  Future<void> _chatWallPaperManager() async {
    final String _takeWallPaperPath =
        await _localStorageHelper.extractImportantTableData(
            extraImportant: ExtraImportant.ChatWallpaper,
            userName: widget._userName);

    if (await File(_takeWallPaperPath).exists()) {
      if (mounted) {
        setState(() {
          this._thisChatWallPaper =
              _takeWallPaperPath == null ? '' : _takeWallPaperPath;
        });
      }
    }

    print('Image Path is: ${this._thisChatWallPaper}');
  }

  @override
  void initState() {
    super.initState();

    print('UserName: ${widget._userName}');
    print('Profile Image: ${widget._connectionProfileImageLocalPath}');

    _essentialExtract();

    _hintText = 'Type Here...';
    _mediaTextController.text = '';

    _currAudioPlayingTime = 100;

    _totalDuration = '';
    _loadingTime = '0:00';

    fToast.init(context);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    if (_isChatOpenFirstTime) {
      _extractHistoryDataFromSqLite();
      _chatWallPaperManager();
    }

    if (mounted) {
      setState(() {
        // For AutoScroll to the end position
        if (_scrollController.hasClients)
          _scrollController.animateTo(10.0,
              duration: Duration(
                milliseconds: 10,
              ),
              curve: Curves.easeInOut);
      });
    }

    _permissionSetForRecording();
  }

  void disposeMicrophoneController() async {
    if (await Permission.microphone.isGranted)
      _flutterSoundRecorder.closeAudioSession();
  }

  @override
  void dispose() {
    _justAudioPlayer.dispose();
    disposeMicrophoneController();
    _inputTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_showEmojiPicker) {
          if (mounted) {
            setState(() {
              _showEmojiPicker = false;
            });
          }
          return false;
        }
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: const Color.fromRGBO(25, 39, 52, 1),
          elevation: 10.0,
          shadowColor: Colors.white70,
          leading: Row(
            children: <Widget>[
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: OpenContainer(
                  closedColor: const Color.fromRGBO(25, 39, 52, 1),
                  middleColor: const Color.fromRGBO(25, 39, 52, 1),
                  openColor: const Color.fromRGBO(25, 39, 52, 1),
                  closedShape: CircleBorder(),
                  closedElevation: 0.0,
                  transitionType: ContainerTransitionType.fadeThrough,
                  transitionDuration: Duration(milliseconds: 500),
                  openBuilder: (_, __) {
                    return widget._connectionProfileImageLocalPath == ''
                        ? Center(
                            child: Text(
                              'No Profile Picture',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 20.0,
                              ),
                            ),
                          )
                        : PreviewImageScreen(
                            imageFile:
                                File(widget._connectionProfileImageLocalPath));
                  },
                  closedBuilder: (_, __) {
                    return CircleAvatar(
                      radius: 23.0,
                      backgroundImage: widget
                                  ._connectionProfileImageLocalPath ==
                              ''
                          ? ExactAssetImage(
                              "assets/logo/logo.jpg",
                            )
                          : FileImage(
                              File(widget._connectionProfileImageLocalPath)),
                    );
                  },
                ),
              ),
            ],
          ),
          title: OpenContainer(
            closedColor: const Color.fromRGBO(25, 39, 52, 1),
            middleColor: const Color.fromRGBO(25, 39, 52, 1),
            openColor: const Color.fromRGBO(25, 39, 52, 1),
            closedElevation: 0.0,
            transitionType: ContainerTransitionType.fadeThrough,
            transitionDuration: Duration(milliseconds: 700),
            openBuilder: (_, __) {
              return ConnectionProfileView(
                profileImagePath: widget._connectionProfileImageLocalPath,
                userName: widget._userName,
              );
            },
            closedBuilder: (_, __) => SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Text(
                widget._userName.length <= 20
                    ? widget._userName
                    : '${widget._userName.replaceRange(20, widget._userName.length, '...')}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontFamily: 'Lora',
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.call,
                color: Colors.green,
              ),
              highlightColor: const Color.fromRGBO(0, 200, 200, 0.3),
              onPressed: _makeGenerationPhoneCall,
            ),
          ],
        ),
        body: ModalProgressHUD(
          inAsyncCall: _isLoading,
          color: Color.fromRGBO(0, 0, 0, 0.5),
          progressIndicator: CircularProgressIndicator(
            backgroundColor: Colors.black87,
          ),
          child: mainBody(context),
        ),
      ),
    );
  }

  Widget mainBody(BuildContext context) {
    _chatBoxHeight = MediaQuery.of(context).size.height - 150;
    return WillPopScope(
      onWillPop: () async {
        if (_showEmojiPicker) {
          if (mounted) {
            setState(() {
              _showEmojiPicker = false;
              _chatBoxHeight = MediaQuery.of(context).size.height - 150;
            });
          }
          return false;
        } else {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          return true;
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        // padding: EdgeInsets.only(
        //   top: 10.0,
        // ),
        decoration: BoxDecoration(
          image: this._thisChatWallPaper != ''
              ? DecorationImage(
                  image: FileImage(File(this._thisChatWallPaper)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Container(
              height: _chatBoxHeight,
              padding: EdgeInsets.only(bottom: 10.0, top: 5.0),
              child: Scrollbar(
                showTrackOnHover: false,
                thickness: 4.0,
                child: ListView.builder(
                  shrinkWrap: true,
                  controller: _scrollController,
                  itemCount: _chatContainer.length,
                  itemBuilder: (context, position) {
                    if (_mediaTypes[position] == MediaTypes.Indicator) {
                      return newMessageIndicator(context);
                    } else if (_mediaTypes[position] == MediaTypes.Text)
                      return textConversationList(
                          context, position, _response[position]);
                    else if (_mediaTypes[position] == MediaTypes.Image ||
                        _mediaTypes[position] == MediaTypes.Video)
                      return _mediaConversationList(
                          context, position, _response[position]);
                    else if (_mediaTypes[position] == MediaTypes.Document) {
                      return _documentConversationList(
                          context, position, _response[position]);
                    } else if (_mediaTypes[position] == MediaTypes.Location) {
                      return _locationConversationList(
                          position, _response[position]);
                    }
                    return voiceConversationList(
                        context, position, _response[position]);
                  },
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                bottom: 3.0,
                top: 3.0,
              ),
              height: _bottomRowHeight,
              decoration: BoxDecoration(
                color: _thisChatWallPaper != ''
                    ? Color.fromRGBO(0, 0, 0, 0.2)
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft:
                      Radius.circular(_thisChatWallPaper != '' ? 40.0 : 0.0),
                  topRight:
                      Radius.circular(_thisChatWallPaper != '' ? 40.0 : 0.0),
                ),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 10.0, right: 10.0),
                        child: GestureDetector(
                          child: const Icon(
                            Icons.emoji_emotions_rounded,
                            color: Colors.orangeAccent,
                          ),
                          onTap: () {
                            /// Close the keyboard
                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');

                            if (mounted) {
                              setState(() {
                                _chatBoxHeight -= 50;
                                _showEmojiPicker = true;
                              });
                            }
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 5.0, right: 10.0),
                        child: GestureDetector(
                          child: const Icon(
                            Entypo.link,
                            color: Colors.lightBlue,
                          ),
                          onTap: () async {
                            _showChoices();
                          },
                        ),
                      ),
                      Column(
                        children: [
                          if (this._replyText != '')
                            Container(
                              width: MediaQuery.of(context).size.width * 0.65,
                              padding: EdgeInsets.only(
                                bottom: 5.0,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _replyText,
                                      style: TextStyle(
                                        color: this._thisChatWallPaper != ''
                                            ? Colors.yellow
                                            : Colors.lightBlue,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 18.0,
                                      color: Colors.red,
                                    ),
                                    onTap: () {
                                      if (mounted) {
                                        setState(() {
                                          _replyText = '';
                                          this._bottomRowHeight = 80.0;
                                        });
                                      }
                                      // SystemChannels.textInput.invokeMethod('TextInput.hide');
                                      // SystemChannels.textInput.invokeMethod('TextInput.hide');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.65,
                              constraints: BoxConstraints.loose(Size(
                                  MediaQuery.of(context).size.width * 0.65,
                                  74.0)),
                              padding: EdgeInsets.only(
                                top: _bottomRowDownPadding,
                              ),
                              child: Scrollbar(
                                showTrackOnHover: true,
                                thickness: 10.0,
                                radius: Radius.circular(30.0),
                                child: TextField(
                                  autofocus: _autoFocus,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  onTap: () {
                                    if (mounted) {
                                      setState(() {
                                        _showEmojiPicker = false;
                                        _chatBoxHeight =
                                            MediaQuery.of(context).size.height -
                                                150;
                                      });
                                    }

                                    _scrollController.jumpTo(_scrollController
                                        .position.maxScrollExtent);
                                  },
                                  onChanged: (inputValue) {
                                    if (mounted) {
                                      setState(() {
                                        if (inputValue == '') {
                                          _iconChanger = true;
                                        } else
                                          _iconChanger = false;
                                      });
                                    }
                                  },
                                  controller: _inputTextController,
                                  maxLines: null,
                                  // For Line Break
                                  decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      // borderRadius:
                                      //     BorderRadius.all(Radius.circular(20.0)),
                                      borderSide: BorderSide(
                                        color: Colors.lightGreen,
                                        width: 2.0,
                                      ),
                                    ),
                                    hintText: _hintText,
                                    hintStyle: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Lora',
                                      letterSpacing: 2.0,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.lightBlue)),
                                  ),
                                ),
                              )),
                        ],
                      ),
                      Expanded(
                        child: IconButton(
                          icon: _iconChanger ? _voiceIcon : _senderIcon,
                          onPressed:
                              _iconChanger ? _voiceController : _textSend,
                        ),
                      ),
                      SizedBox(
                        height: 2.0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _showEmojiPicker
                ? EmojiPicker(
                    rows: 3,
                    columns: 7,
                    buttonMode: ButtonMode.MATERIAL,
                    bgColor: Color.fromRGBO(34, 48, 60, 1),
                    indicatorColor: Color.fromRGBO(34, 48, 60, 1),
                    onEmojiSelected: (item, category) {
                      if (mounted) {
                        setState(() {
                          _inputTextController.text += item.emoji;
                          if (_iconChanger) _iconChanger = false;
                        });
                      }
                    },
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget newMessageIndicator(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width / 4,
        right: MediaQuery.of(context).size.width / 4,
        top: 10.0,
        bottom: 20.0,
      ),
      //width: MediaQuery.of(context).size.width / 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.redAccent,
      ),
      child: Text(
        'New Messages',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          //fontFamily: 'Lora',
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  /// All Conversation List

  Widget textConversationList(
      BuildContext context, int index, bool _responseValue) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (_chatContainer[index].keys.first.contains('[[[@]]]'))
          SizedBox(
            height: 20.0,
          ),
        SwipeTo(
          iconColor: Colors.lightBlue,
          iconOnLeftSwipe: Entypo.forward,
          onRightSwipe: () {
            if (mounted) {
              setState(() {
                if (_chatContainer[index].keys.first.contains('[[[@]]]'))
                  _replyText =
                      _chatContainer[index].keys.first.split('[[[@]]]')[1];
                else
                  _replyText = _chatContainer[index].keys.first;

                if (_replyText.contains('\n'))
                  _replyText = '${_replyText.split('\n')[0]}';

                if (_messageRegex.hasMatch(_replyText)) {
                  print('Under Regex Match');
                  if (_replyText.length > 30) {
                    List<String> take = _replyText.split('').sublist(0, 30);

                    _replyText = '${take.join('')}...';
                  }
                }

                _bottomRowHeight = 90;
                _autoFocus = true;
              });
            }
            print(_replyText);
          },
          child: Container(
            margin: _responseValue
                ? EdgeInsets.only(
                    right: MediaQuery.of(context).size.width / 3,
                    left: 5.0,
                  )
                : EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 3,
                    right: 5.0,
                  ),
            alignment:
                _responseValue ? Alignment.centerLeft : Alignment.centerRight,
            child: Column(
              children: [
                if (_chatContainer[index].keys.first.contains('[[[@]]]'))
                  Container(
                    margin: EdgeInsets.only(
                      bottom: 5.0,
                    ),
                    child: Text(
                      _chatContainer[index].keys.first.split('[[[@]]]')[0],
                      style: TextStyle(
                        color: this._thisChatWallPaper != ''
                            ? Colors.yellow
                            : Colors.lightBlue,
                      ),
                    ),
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: _responseValue
                        ? Color.fromRGBO(60, 80, 100, 1)
                        : Color.fromRGBO(102, 102, 255, 1),
                    elevation: 0.0,
                    padding: EdgeInsets.all(10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: _responseValue
                            ? Radius.circular(0.0)
                            : Radius.circular(20.0),
                        topRight: _responseValue
                            ? Radius.circular(20.0)
                            : Radius.circular(0.0),
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                    ),
                  ),
                  child: AutolinkText(
                    text: _chatContainer[index].keys.first.contains('[[[@]]]')
                        ? _chatContainer[index].keys.first.split('[[[@]]]')[1]
                        : _chatContainer[index].keys.first,
                    humanize: false,
                    textStyle: TextStyle(
                      color: Colors.white,
                    ),
                    linkStyle: TextStyle(
                      color: Colors.amber,
                    ),
                    onEmailTap: (matchText) async {
                      try {
                        final Uri params = Uri(
                          scheme: 'mailto',
                          path: '$matchText',
                        );

                        await launch(params.toString());
                      } catch (e) {
                        _showDiaLog(titleText: "Sorry, Can't Send Email");
                      }
                    },
                    onPhoneTap: (matchText) async {
                      try {
                        final Uri params = Uri(
                          scheme: 'tel',
                          path: '$matchText',
                        );

                        await launch(params.toString());
                      } catch (e) {
                        _showDiaLog(titleText: "Sorry, Access this number");
                      }
                    },
                    onWebLinkTap: (matchText) async {
                      try {
                        final String _recognize =
                            matchText.contains('https') ? 'https' : 'http';
                        final Uri params = Uri(
                          scheme:
                              matchText.contains('https') ? 'https' : 'http',
                          path: '${matchText.split(_recognize)[1]}',
                        );

                        await launch(params.toString());
                        showToast(
                          'Wait For launch',
                          fToast,
                          fontSize: 16,
                        );
                      } catch (e) {
                        print(e.toString);
                        _showDiaLog(titleText: "Sorry, Can't Open This Url");
                      }
                    },
                  ),
                  onPressed: () {},
                  onLongPress: () {
                    print('Delete that message');
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40.0),
                              ),
                              elevation: 0.3,
                              backgroundColor: Color.fromRGBO(34, 48, 60, 0.5),
                              title: _multipleOptions(index,
                                  bgColor: Color.fromRGBO(34, 48, 60, 0.0),
                                  mediaTypes: _mediaTypes[index]),
                            ));
                  },
                ),
              ],
            ),
          ),
        ),
        _conversationShowingTime(index, _responseValue),
        if (_chatContainer[index].keys.first.contains('[[[@]]]'))
          SizedBox(
            height: 5.0,
          ),
      ],
    );
  }

  Widget voiceConversationList(
      BuildContext context, int index, bool _responseValue) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onLongPress: () async {
            print('Voice Long Press');
            if (await File(_chatContainer[index].keys.first).exists())
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        elevation: 0.3,
                        backgroundColor: Color.fromRGBO(34, 48, 60, 0.5),
                        title: _multipleOptions(index,
                            bgColor: Color.fromRGBO(34, 48, 60, 0.0),
                            mediaTypes: _mediaTypes[index]),
                      ));
          },
          child: Container(
            margin: _responseValue
                ? EdgeInsets.only(
                    right: MediaQuery.of(context).size.width / 3,
                    left: 5.0,
                    top: 5.0,
                  )
                : EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 3,
                    right: 5.0,
                    top: 5.0,
                  ),
            alignment:
                _responseValue ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              height: 70.0,
              width: 250.0,
              decoration: BoxDecoration(
                color: _responseValue
                    ? Color.fromRGBO(60, 80, 100, 1)
                    : Color.fromRGBO(102, 102, 255, 1),
                borderRadius: _responseValue
                    ? BorderRadius.only(
                        topRight: Radius.circular(40.0),
                        bottomLeft: Radius.circular(40.0),
                        bottomRight: Radius.circular(40.0),
                      )
                    : BorderRadius.only(
                        topLeft: Radius.circular(40.0),
                        bottomLeft: Radius.circular(40.0),
                        bottomRight: Radius.circular(40.0),
                      ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 20.0,
                  ),
                  Stack(
                    children: [
                      if (_responseValue &&
                          index == _response.length - 1 &&
                          _audioDownloadProgress > 0.0 &&
                          _audioDownloadProgress < 1.0)
                        Container(
                          margin: EdgeInsets.only(
                            left: 1.5,
                            top: 2.0,
                          ),
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.black12,
                            value: _audioDownloadProgress,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.orange),
                          ),
                        ),
                      GestureDetector(
                        onLongPress: () => _chatMicrophoneOnLongPressAction(),
                        onTap: () => chatMicrophoneOnTapAction(index),
                        child: Icon(
                          index == _lastAudioPlayingIndex
                              ? _iconData
                              : Icons.play_arrow_rounded,
                          color: Color.fromRGBO(10, 255, 30, 1),
                          size: 35.0,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              top: 26.0,
                            ),
                            child: LinearPercentIndicator(
                              percent: _justAudioPlayer.duration == null
                                  ? 0.0
                                  : _lastAudioPlayingIndex == index
                                      ? _currAudioPlayingTime /
                                          _justAudioPlayer
                                              .duration.inMicroseconds
                                              .ceilToDouble()
                                      : 0,
                              backgroundColor: Colors.black26,
                              progressColor: _responseValue
                                  ? Colors.lightBlue
                                  : Colors.amber,
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0, right: 7.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _lastAudioPlayingIndex == index
                                          ? _loadingTime
                                          : '0:00',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _lastAudioPlayingIndex == index
                                          ? _totalDuration
                                          : '',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: GestureDetector(
                      child: _lastAudioPlayingIndex != index
                          ? CircleAvatar(
                              radius: 23.0,
                              backgroundImage: (_responseValue
                                          ? widget
                                              ._connectionProfileImageLocalPath
                                          : ImportantThings
                                              .thisAccountProfileImagePath) ==
                                      ''
                                  ? ExactAssetImage(
                                      "assets/logo/logo.jpg",
                                    )
                                  : FileImage(File(_responseValue
                                      ? widget._connectionProfileImageLocalPath
                                      : ImportantThings
                                          .thisAccountProfileImagePath)),
                            )
                          : Text(
                              '${this._audioPlayingSpeed.toString().contains('.0') ? this._audioPlayingSpeed.toString().split('.')[0] : this._audioPlayingSpeed}x',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18.0),
                            ),
                      onTap: () {
                        print('Audio Play Speed Tapped');
                        if (mounted) {
                          setState(() {
                            if (this._audioPlayingSpeed != 3.0)
                              this._audioPlayingSpeed += 0.5;
                            else
                              this._audioPlayingSpeed = 1.0;

                            _justAudioPlayer.setSpeed(this._audioPlayingSpeed);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _conversationShowingTime(index, _responseValue),
      ],
    );
  }

  Widget _mediaConversationList(
      BuildContext context, int index, bool _responseValue) {
    print(
        'Media Extension: ${_chatContainer[index].keys.first.split('.')[_chatContainer[index].keys.first.split('.').length - 1]}');

    return Column(
      children: [
        Container(
            height: MediaQuery.of(context).size.height * 0.3,
            margin: _responseValue
                ? EdgeInsets.only(
                    right: MediaQuery.of(context).size.width / 3,
                    left: 5.0,
                    top: 30.0,
                  )
                : EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 3,
                    right: 5.0,
                    top: 15.0,
                  ),
            alignment:
                _responseValue ? Alignment.centerLeft : Alignment.centerRight,
            child: OpenContainer(
              openColor: Color.fromRGBO(60, 80, 100, 1),
              closedColor: _responseValue
                  ? Color.fromRGBO(60, 80, 100, 1)
                  : Color.fromRGBO(102, 102, 255, 1),
              middleColor: Color.fromRGBO(60, 80, 100, 1),
              closedElevation: 0.0,
              closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20.0),
                  topLeft: Radius.circular(20.0),
                  bottomRight:
                      _chatContainer[index].values.first.split('+')[1] == ''
                          ? Radius.circular(20.0)
                          : Radius.circular(0.0),
                  bottomLeft:
                      _chatContainer[index].values.first.split('+')[1] == ''
                          ? Radius.circular(20.0)
                          : Radius.circular(0.0),
                ),
              ),
              transitionDuration: Duration(
                milliseconds: 400,
              ),
              transitionType: ContainerTransitionType.fadeThrough,
              openBuilder: (context, openWidget) {
                print('MediaTypes: ${_mediaTypes[index]}');
                return PreviewImageScreen(
                  imageFile: _mediaTypes[index] == MediaTypes.Image
                      ? File(_chatContainer[index].keys.first)
                      : File(_chatContainer[index].values.first.split('+')[2]),
                );
              },
              closedBuilder: (context, closeWidget) => Stack(
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: PhotoView(
                      imageProvider: _mediaTypes[index] == MediaTypes.Image
                          ? FileImage(File(_chatContainer[index].keys.first))
                          : FileImage(File(_chatContainer[index]
                              .values
                              .first
                              .split('+')[2])),
                      loadingBuilder: (context, event) => Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorBuilder: (context, obj, stackTrace) => Center(
                          child: Text(
                        'Image not Found',
                        style: TextStyle(
                          fontSize: 23.0,
                          color: Colors.red,
                          fontFamily: 'Lora',
                          letterSpacing: 1.0,
                        ),
                      )),
                      enableRotation: true,
                      minScale: PhotoViewComputedScale.covered,
                    ),
                  ),
                  if (File(_chatContainer[index].keys.first).existsSync())
                    _multipleOptions(index, mediaTypes: _mediaTypes[index]),
                  if (_mediaTypes[index] == MediaTypes.Video)
                    Center(
                      child: IconButton(
                        iconSize: 100.0,
                        icon: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          final OpenResult openResult = await OpenFile.open(
                              _chatContainer[index].keys.first);

                          openFileResultStatus(openResult: openResult);
                        },
                      ),
                    ),
                ],
              ),
            )),
        if (_chatContainer[index].values.first.split('+')[1] != '')
          _documentsAndMediaCommonConversationList(index, _responseValue),
        _conversationShowingTime(index, _responseValue),
      ],
    );
  }

  Widget _documentConversationList(
      BuildContext context, int index, bool _responseValue) {
    print(_chatContainer[index].values.first);

    return Column(
      children: [
        Container(
            height: _chatContainer[index]
                    .values
                    .first
                    .split('+')[2]
                    .contains('.pdf')
                ? MediaQuery.of(context).size.height * 0.3
                : 70.0,
            margin: _responseValue
                ? EdgeInsets.only(
                    right: MediaQuery.of(context).size.width / 3,
                    left: 5.0,
                    top: 30.0,
                  )
                : EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 3,
                    right: 5.0,
                    top: 15.0,
                  ),
            alignment:
                _responseValue ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: _chatContainer[index]
                        .values
                        .first
                        .split('+')[2]
                        .contains('.pdf')
                    ? Colors.white
                    : _responseValue
                        ? Color.fromRGBO(60, 80, 100, 1)
                        : Color.fromRGBO(102, 102, 255, 1),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20.0),
                  topLeft: Radius.circular(20.0),
                  bottomRight:
                      _chatContainer[index].values.first.split('+')[1] == ''
                          ? Radius.circular(20.0)
                          : Radius.circular(0.0),
                  bottomLeft:
                      _chatContainer[index].values.first.split('+')[1] == ''
                          ? Radius.circular(20.0)
                          : Radius.circular(0.0),
                ),
              ),
              child: _chatContainer[index]
                      .values
                      .first
                      .split('+')[2]
                      .contains('.pdf')
                  ? Stack(
                      children: [
                        Center(
                            child: Text(
                          'Loading Error',
                          style: TextStyle(
                            fontFamily: 'Lora',
                            color: Colors.red,
                            fontSize: 20.0,
                            letterSpacing: 1.0,
                          ),
                        )),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: PdfView(
                            path: _chatContainer[index].keys.first,
                          ),
                        ),
                        Center(
                          child: GestureDetector(
                            child: Icon(
                              Icons.open_in_new_rounded,
                              size: 40.0,
                              color: Colors.blue,
                            ),
                            onTap: () async {
                              final OpenResult openResult = await OpenFile.open(
                                  _chatContainer[index].keys.first);

                              openFileResultStatus(openResult: openResult);
                            },
                          ),
                        ),
                        if (File(_chatContainer[index].keys.first).existsSync())
                          _multipleOptions(index,
                              mediaTypes: _mediaTypes[index]),
                      ],
                    )
                  : GestureDetector(
                      onTap: () async {
                        final OpenResult openResult = await OpenFile.open(
                            _chatContainer[index].keys.first);

                        openFileResultStatus(openResult: openResult);
                      },
                      onLongPress: () async {
                        print('Delete that message');
                        if (await File(_chatContainer[index].keys.first)
                            .exists())
                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40.0),
                                    ),
                                    elevation: 0.3,
                                    backgroundColor:
                                        Color.fromRGBO(34, 48, 60, 0.5),
                                    title: _multipleOptions(index,
                                        bgColor:
                                            Color.fromRGBO(34, 48, 60, 0.0),
                                        mediaTypes: _mediaTypes[index]),
                                  ));
                      },
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 20.0,
                            ),
                            Icon(
                              Entypo.documents,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                            Expanded(
                              child: Text(
                                _chatContainer[index]
                                            .values
                                            .first
                                            .split('+')[2]
                                            .length >=
                                        17
                                    ? _chatContainer[index]
                                        .values
                                        .first
                                        .split('+')[2]
                                        .replaceRange(
                                            17,
                                            _chatContainer[index]
                                                .values
                                                .first
                                                .split('+')[2]
                                                .length,
                                            '...')
                                    : _chatContainer[index]
                                        .values
                                        .first
                                        .split('+')[2],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Lora',
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            )),
        if (_chatContainer[index].values.first.split('+')[1] != '')
          _documentsAndMediaCommonConversationList(index, _responseValue),
        _conversationShowingTime(index, _responseValue),
      ],
    );
  }

  Widget _locationConversationList(int index, bool _responseValue) {
    return Column(children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
        ),
        height: MediaQuery.of(context).size.height * 0.3,
        margin: _responseValue
            ? EdgeInsets.only(
                right: MediaQuery.of(context).size.width / 3,
                left: 5.0,
                top: 30.0,
              )
            : EdgeInsets.only(
                left: MediaQuery.of(context).size.width / 3,
                right: 5.0,
                top: 15.0,
              ),
        alignment:
            _responseValue ? Alignment.centerLeft : Alignment.centerRight,
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.hybrid,
              markers: Set.of([
                Marker(
                    markerId: MarkerId('locate'),
                    zIndex: 1.0,
                    draggable: true,
                    position: LatLng(
                        double.parse(
                            _chatContainer[index].keys.first.split('+')[0]),
                        double.parse(
                            _chatContainer[index].keys.first.split('+')[1])))
              ]),
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    double.parse(
                        _chatContainer[index].keys.first.split('+')[0]),
                    double.parse(
                        _chatContainer[index].keys.first.split('+')[1])),
                zoom: 17.4746,
              ),
            ),
            _multipleOptions(index, mediaTypes: _mediaTypes[index]),
          ],
        ),
      ),
      _conversationShowingTime(index, _responseValue),
    ]);
  }

  Widget _documentsAndMediaCommonConversationList(
      int index, bool _responseValue) {
    return Scrollbar(
      showTrackOnHover: true,
      thickness: 10.0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(
          10.0,
          5.0,
          10.0,
          5.0,
        ),
        margin: _responseValue
            ? EdgeInsets.only(
                right: MediaQuery.of(context).size.width / 3,
                left: 5.0,
                //top: 5.0,
              )
            : EdgeInsets.only(
                left: MediaQuery.of(context).size.width / 3,
                right: 5.0,
                //top: 5.0,
              ),
        alignment:
            _responseValue ? Alignment.centerLeft : Alignment.centerRight,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: const Radius.circular(20.0),
            bottomRight: const Radius.circular(20.0),
          ),
          color: _responseValue
              ? const Color.fromRGBO(60, 80, 100, 1)
              : const Color.fromRGBO(102, 102, 255, 1),
        ),
        child: Center(
          child: Text(
            _chatContainer[index].values.first.split('+')[1],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontFamily: 'Lora',
              fontWeight: FontWeight.w400,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _conversationShowingTime(int index, bool _responseValue) {
    return Container(
      alignment: _responseValue ? Alignment.centerLeft : Alignment.centerRight,
      margin: _responseValue
          ? const EdgeInsets.only(
              left: 5.0,
              bottom: 5.0,
              top: 5.0,
            )
          : const EdgeInsets.only(
              right: 5.0,
              bottom: 5.0,
              top: 5.0,
            ),
      child: _timeReFormat(_chatContainer[index].values.first.split('+')[0]),
    );
  }

  Widget _timeReFormat(String _willReturnTime) {
    if (int.parse(_willReturnTime.split(':')[0]) < 10)
      _willReturnTime = _willReturnTime.replaceRange(
          0, _willReturnTime.indexOf(':'), '0${_willReturnTime.split(':')[0]}');

    if (int.parse(_willReturnTime.split(':')[1]) < 10)
      _willReturnTime = _willReturnTime.replaceRange(
          _willReturnTime.indexOf(':') + 1,
          _willReturnTime.length,
          '0${_willReturnTime.split(':')[1]}');

    return Text(
      _willReturnTime,
      style: const TextStyle(color: Colors.lightBlue),
    );
  }

  /// All Sending Operations

  void _textSend() async {
    try {
      print("Send Pressed");

      if (!await _nativeCallback.callToCheckNetworkConnectivity())
        _showDiaLog(titleText: 'No Internet Connection');
      else {
        if (_inputTextController.text.isNotEmpty) {
          /// Take Document Data related to old messages
          final DocumentSnapshot documentSnapShot = await FirebaseFirestore
              .instance
              .doc("generation_users/$_senderMail")
              .get();

          /// Initialize Temporary List
          List<dynamic> sendingMessages = [];

          /// Store Updated sending messages list
          sendingMessages = documentSnapShot.data()['connections']
              [FirebaseAuth.instance.currentUser.email.toString()];

          if (mounted) {
            if (sendingMessages == null) sendingMessages = [];

            setState(() {
              /// Add data to temporary Storage of Sending
              sendingMessages.add({
                _replyText != ''
                        ? "${_encryptionMaker.encryptionMaker('$_replyText[[[@]]]${_inputTextController.text}')}"
                        : '${_encryptionMaker.encryptionMaker(_inputTextController.text)}':
                    "${_encryptionMaker.encryptionMaker('${DateTime.now().hour}:${DateTime.now().minute}+${MediaTypes.Text}')}",
              });

              /// Add Data to the UI related all chat Container
              _chatContainer.add({
                _replyText != ''
                        ? '$_replyText[[[@]]]${_inputTextController.text}'
                        : '${_inputTextController.text}':
                    "${DateTime.now().hour}:${DateTime.now().minute}",
              });

              _response.add(
                  false); // Add the data _response to chat related container

              _mediaTypes.add(MediaTypes.Text); // Add MediaType

              _iconChanger = true; // IconChanger Should Change

              if (_replyText != '') {
                _replyText = '';

                this._bottomRowHeight = 80.0;
              }
            });
          }

          if (_chatContainer.last.keys.first.contains('[[[@]]]'))
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent + 130);
          else
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent + 100);

          /// Data Store in Local Storage
          await _localStorageHelper.insertNewMessages(
              widget._userName,
              _encryptionMaker
                  .encryptionMaker(_chatContainer.last.keys.first.toString()),
              MediaTypes.Text,
              0,
              _encryptionMaker.encryptionMaker(
                  _chatContainer.last.values.first.toString()));

          /// Data Store in Firestore
          await _management.addConversationMessages(this._senderMail,
              sendingMessages, documentSnapShot.data()['connections']);

          final String _textToSend = _inputTextController.text;

          _inputTextController.clear();

          await _sendNotification.messageNotificationClassifier(MediaTypes.Text,
              textMsg: _textToSend,
              connectionToken: _connectionToken,
              currAccountUserName: _currAccountUserName);
        }
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text("Text Send Problem"),
              content: Text(e.toString()),
            );
          });
    }
  }

  void _voiceController() async {
    if (!_isMicrophonePermissionGranted || _flutterSoundRecorder == null) {
      _permissionSetForRecording();
    } else {
      /// For Recording Action
      if (_flutterSoundRecorder.isStopped) {
        if (mounted) {
          setState(() {
            _hintText = 'Recording....';
          });
        }

        final PermissionStatus recordingPermissionStatus =
            await Permission.microphone.request();

        if (recordingPermissionStatus.isGranted) {
          _flutterSoundRecorder
              .startRecorder(
                toFile: '${_audioDirectory.path}${DateTime.now()}.mp3',
              )
              .then((value) => print("Recording"));
        }
      } else {
        // For recording stop after action
        if (mounted) {
          setState(() {
            _hintText = 'Type Here...';
          });
        }
        final String recordedFilePath =
            await _flutterSoundRecorder.stopRecorder();

        _voiceSend(recordedFilePath);
      }
    }
  }

  void _voiceSend(String recordedFilePath,
      {String audioExtension = '.mp3'}) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    if (!await _nativeCallback.callToCheckNetworkConnectivity())
      _showDiaLog(titleText: 'No Internet Connection');
    else {
      if (_justAudioPlayer.duration != null) {
        if (mounted) {
          setState(() {
            _justAudioPlayer.stop();
            _iconData = Icons.play_arrow_rounded;
          });
        }
      }

      await _justAudioPlayer.setFilePath(recordedFilePath);

      if (_justAudioPlayer.duration.inMinutes > 20)
        _showDiaLog(
            titleText: "Longer Audio File",
            contentText:
                "Audio File Duration Can't be greater than 20 minutes\n\nCurrent Audio Duration: ${_justAudioPlayer.duration.inMinutes > 59 ? _justAudioPlayer.duration.inMinutes % 60 : _justAudioPlayer.duration.inMinutes} minutes");
      else {
        if (mounted) {
          setState(() {
            _isLoading = true;
          });
          print("Start");
        }

        final String downloadUrl = await _management.uploadMediaToStorage(
            File(recordedFilePath), context,
            reference: 'chatVoices/');

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          print("End");
        }

        final DocumentSnapshot documentSnapShot = await FirebaseFirestore
            .instance
            .doc("generation_users/$_senderMail")
            .get();

        // Initialize Temporary List
        List<dynamic> sendingMessages = [];

        // Store Updated sending messages list
        sendingMessages = documentSnapShot.data()['connections']
            [FirebaseAuth.instance.currentUser.email.toString()];

        if (mounted) {
          if (sendingMessages == null) sendingMessages = [];

          setState(() {
            /// Add data to temporary Storage of Sending
            sendingMessages.add({
              _encryptionMaker
                  .encryptionMaker(
                      downloadUrl): _encryptionMaker.encryptionMaker(
                  '${DateTime.now().hour}:${DateTime.now().minute}+${MediaTypes.Voice}+$audioExtension'),
            });

            /// Add Data to the UI related all chat Container
            _chatContainer.add({
              recordedFilePath:
                  '${DateTime.now().hour}:${DateTime.now().minute}',
            });

            _response
                .add(false); // Add the data _response to chat related container

            _mediaTypes.add(MediaTypes.Voice); // Add MediaType

            _inputTextController.clear(); // Get Clear the InputBox
          });

          /// Data Store in Local Storage
          await _localStorageHelper.insertNewMessages(
              widget._userName,
              _encryptionMaker.encryptionMaker(recordedFilePath),
              MediaTypes.Voice,
              0,
              _encryptionMaker.encryptionMaker(
                  _chatContainer.last.values.first.toString()));

          /// Data Store in FireStore
          await _management.addConversationMessages(this._senderMail,
              sendingMessages, documentSnapShot.data()['connections']);

          if (mounted) {
            setState(() {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent + 300);
            });
          }

          await _sendNotification.messageNotificationClassifier(
              MediaTypes.Voice,
              currAccountUserName: _currAccountUserName,
              connectionToken: _connectionToken);
        }
      }
    }
  }

  Future<void> _mediaSend(File _takeImageFile,
      {MediaTypes mediaTypesForSend = MediaTypes.Image,
      String extraText = '',
      String extension = '.pdf'}) async {
    if (!await _nativeCallback.callToCheckNetworkConnectivity())
      _showDiaLog(titleText: 'No Internet Connection');
    else {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final String _imageDownLoadUrl = await _management.uploadMediaToStorage(
          _takeImageFile, context,
          reference: 'chatMedia/');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      final DocumentSnapshot documentSnapShot = await FirebaseFirestore.instance
          .doc("generation_users/$_senderMail")
          .get();

      // Initialize Temporary List
      List<dynamic> _sendingMessages = [];

      // Store Updated Sending Messages List
      _sendingMessages = documentSnapShot.data()['connections']
          [FirebaseAuth.instance.currentUser.email.toString()];

      String thumbNailPicturePath, thumbNailPicturePathUrl;

      if (mediaTypesForSend == MediaTypes.Video) {
        final Directory directory = await getExternalStorageDirectory();

        final Directory _newDirectory =
            await Directory('${directory.path}/.ThumbNails/')
                .create(); // Create New Folder about the desire location;

        thumbNailPicturePath = await Thumbnails.getThumbnail(
            thumbnailFolder: _newDirectory.path,
            videoFile: _takeImageFile.path,
            imageType: ThumbFormat.JPEG,
            quality: 20);

        thumbNailPicturePathUrl = await _management.uploadMediaToStorage(
            File(thumbNailPicturePath), context,
            reference: 'videoThumbNail/');
      }

      if (mounted) {
        if (_sendingMessages == null) _sendingMessages = [];

        setState(() {
          if (mediaTypesForSend == MediaTypes.Video) {
            // Add data to temporary Storage of Sending
            _sendingMessages.add({
              _encryptionMaker.encryptionMaker('$_imageDownLoadUrl+$thumbNailPicturePathUrl'):
                 _encryptionMaker.encryptionMaker('${DateTime.now().hour}:${DateTime.now().minute}+$mediaTypesForSend+$extraText'),
            });

            // Add Data to the UI related all Chat Container
            _chatContainer.add({
              _takeImageFile.path:
                  '${DateTime.now().hour}:${DateTime.now().minute}+$extraText+$thumbNailPicturePath',
            });
          } else if (mediaTypesForSend == MediaTypes.Image) {
            // Add data to temporary Storage of Sending
            _sendingMessages.add({
              _encryptionMaker.encryptionMaker(_imageDownLoadUrl):
                  _encryptionMaker.encryptionMaker('${DateTime.now().hour}:${DateTime.now().minute}+$mediaTypesForSend+$extraText'),
            });

            // Add Data to the UI related all Chat Container
            _chatContainer.add({
              _takeImageFile.path:
                  '${DateTime.now().hour}:${DateTime.now().minute}+$extraText',
            });
          } else if (mediaTypesForSend == MediaTypes.Document) {
            // Add data to temporary Storage of Sending
            _sendingMessages.add({
              _encryptionMaker.encryptionMaker(_imageDownLoadUrl):
                  _encryptionMaker.encryptionMaker('${DateTime.now().hour}:${DateTime.now().minute}+$mediaTypesForSend+$extraText+${_takeImageFile.path.split('/').last}'),
            });

            // Add Data to the UI related all Chat Container
            _chatContainer.add({
              _takeImageFile.path:
                  '${DateTime.now().hour}:${DateTime.now().minute}+$extraText+${_takeImageFile.path.split('/').last}',
            });
          }

          _response
              .add(false); // Add the data _response to chat related container

          _mediaTypes.add(mediaTypesForSend); // Add MediaType

          _inputTextController.clear(); // Get Clear the InputBox
        });

        // Data Store in Local Storage
        await _localStorageHelper.insertNewMessages(
            widget._userName,
            _encryptionMaker.encryptionMaker(_takeImageFile.path),
            mediaTypesForSend,
            0,
            _encryptionMaker.encryptionMaker(_chatContainer.last.values.first.toString()));

        // Data Store in Firestore
        await _management.addConversationMessages(this._senderMail,
            _sendingMessages, documentSnapShot.data()['connections']);

        if (mounted) {
          setState(() {
            _scrollController.jumpTo(
                _scrollController.position.maxScrollExtent +
                    (MediaQuery.of(context).size.height * 0.8));
          });
        }

        if (mediaTypesForSend == MediaTypes.Video) {
          await _sendNotification.messageNotificationClassifier(
              MediaTypes.Video,
              textMsg: extraText,
              currAccountUserName: _currAccountUserName,
              connectionToken: _connectionToken);
        } else if (mediaTypesForSend == MediaTypes.Image) {
          await _sendNotification.messageNotificationClassifier(
              MediaTypes.Image,
              textMsg: extraText,
              currAccountUserName: _currAccountUserName,
              connectionToken: _connectionToken);
        } else if (mediaTypesForSend == MediaTypes.Document) {
          await _sendNotification.messageNotificationClassifier(
              MediaTypes.Document,
              textMsg: extraText,
              currAccountUserName: _currAccountUserName,
              connectionToken: _connectionToken);
        }
      }
    }
  }

  void _locationSend({double latitude, double longitude}) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    if (!await _nativeCallback.callToCheckNetworkConnectivity())
      _showDiaLog(titleText: 'No Internet Connection');
    else {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });

        final DocumentSnapshot documentSnapShot = await FirebaseFirestore
            .instance
            .doc("generation_users/$_senderMail")
            .get();

        /// Initialize Temporary List
        List<dynamic> _sendingMessages = [];

        /// Store Updated Sending Messages List
        _sendingMessages = documentSnapShot.data()['connections']
            [FirebaseAuth.instance.currentUser.email.toString()];

        setState(() {
          // Add data to temporary Storage of Sending
          _sendingMessages.add({
            _encryptionMaker.encryptionMaker('$latitude+$longitude'):
                _encryptionMaker.encryptionMaker('${DateTime.now().hour}:${DateTime.now().minute}+${MediaTypes.Location}'),
          });

          _chatContainer.add({
            '$latitude+$longitude':
                '${DateTime.now().hour}:${DateTime.now().minute}+${MediaTypes.Location}',
          });

          _response.add(false);

          _mediaTypes.add(MediaTypes.Location);
        });

        // Data Store in Local Storage
        await _localStorageHelper.insertNewMessages(
            widget._userName,
            _encryptionMaker.encryptionMaker('$latitude+$longitude'),
            MediaTypes.Location,
            0,
            _encryptionMaker.encryptionMaker(_chatContainer.last.values.first.toString()));

        // Data Store in Firestore
        await _management.addConversationMessages(this._senderMail,
            _sendingMessages, documentSnapShot.data()['connections']);

        setState(() {
          _isLoading = false;
        });
      }
      if (mounted) {
        setState(() {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent +
              (MediaQuery.of(context).size.height * 0.8));
        });
      }

      await _sendNotification.messageNotificationClassifier(MediaTypes.Location,
          textMsg: 'Click Red Pointer in Map to Open in Google Map',
          currAccountUserName: _currAccountUserName,
          connectionToken: _connectionToken);
    }
  }

  void chatMicrophoneOnTapAction(int index) async {
    try {
      _justAudioPlayer.positionStream.listen((event) {
        if (mounted) {
          setState(() {
            _currAudioPlayingTime = event.inMicroseconds.ceilToDouble();
            _loadingTime =
                '${event.inMinutes} : ${event.inSeconds > 59 ? event.inSeconds % 60 : event.inSeconds}';
          });
        }
      });

      _justAudioPlayer.playerStateStream.listen((event) {
        if (event.processingState == ProcessingState.completed) {
          _justAudioPlayer.stop();
          if (mounted) {
            setState(() {
              this._loadingTime = '0:00';
              this._iconData = Icons.play_arrow_rounded;
            });
          }
        }
      });

      if (_lastAudioPlayingIndex != index) {
        await _justAudioPlayer.setFilePath(_chatContainer[index].keys.first);

        if (mounted) {
          setState(() {
            _lastAudioPlayingIndex = index;
            _totalDuration =
                '${_justAudioPlayer.duration.inMinutes} : ${_justAudioPlayer.duration.inSeconds > 59 ? _justAudioPlayer.duration.inSeconds % 60 : _justAudioPlayer.duration.inSeconds}';
            _iconData = Icons.pause;
            this._audioPlayingSpeed = 1.0;
            _justAudioPlayer.setSpeed(this._audioPlayingSpeed);
          });
        }

        await _justAudioPlayer.play();
      } else {
        print(_justAudioPlayer.processingState);
        if (_justAudioPlayer.processingState == ProcessingState.idle) {
          await _justAudioPlayer.setFilePath(_chatContainer[index].keys.first);

          if (mounted) {
            setState(() {
              _lastAudioPlayingIndex = index;
              _totalDuration =
                  '${_justAudioPlayer.duration.inMinutes} : ${_justAudioPlayer.duration.inSeconds}';
              _iconData = Icons.pause;
            });
          }

          await _justAudioPlayer.play();
        } else if (_justAudioPlayer.playing) {
          if (mounted) {
            setState(() {
              _iconData = Icons.play_arrow_rounded;
            });
          }

          await _justAudioPlayer.pause();
        } else if (_justAudioPlayer.processingState == ProcessingState.ready) {
          if (mounted) {
            setState(() {
              _iconData = Icons.pause;
            });
          }

          await _justAudioPlayer.play();
        } else if (_justAudioPlayer.processingState ==
            ProcessingState.completed) {}
      }
    } catch (e) {
      print('Audio Playing Error');
      _showDiaLog(
          titleText: 'Audio Playing Error',
          contentText: 'May be Audio File Not Found');
    }
  }

  void _downLoadOnReceiveProgress(int countReceive, int totalReceive) {
    if (mounted) {
      setState(() {
        _audioDownloadProgress = countReceive / totalReceive;
      });
    }
  }

  void _chatMicrophoneOnLongPressAction() async {
    if (_justAudioPlayer.playing) {
      await _justAudioPlayer.stop();
      if (mounted) {
        setState(() {
          print('Audio Play Completed');
          _justAudioPlayer.stop();
          if (mounted) {
            setState(() {
              _loadingTime = '0:00';
              _iconData = Icons.play_arrow_rounded;
            });
          }
        });
      }
    }
  }

  void _showChoices() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              elevation: 0.3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
              backgroundColor: Color.fromRGBO(34, 48, 60, 1),
              title: Center(
                child: Text(
                  'Choice',
                  style: TextStyle(
                    color: Colors.lightBlue,
                    fontSize: 20.0,
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              content: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.7,
                child: ListView(
                  children: [
                    CircleList(
                      initialAngle: 55,
                      outerRadius: MediaQuery.of(context).size.width / 3.2,
                      innerRadius: MediaQuery.of(context).size.width / 10,
                      showInitialAnimation: true,
                      innerCircleColor: Color.fromRGBO(34, 48, 60, 1),
                      outerCircleColor: Color.fromRGBO(0, 0, 0, 0.1),
                      origin: Offset(0, 0),
                      rotateMode: RotateMode.allRotate,
                      centerWidget: Center(
                        child: Text(
                          "G",
                          style: TextStyle(
                            color: Colors.lightBlue,
                            fontSize: 40.0,
                            fontFamily: 'Lora',
                          ),
                        ),
                      ),
                      children: <Widget>[
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: Colors.blue,
                                width: 3,
                              )),
                          child: GestureDetector(
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.lightGreen,
                            ),
                            onTap: () async {
                              await _connectionExtraTextManagement(
                                  imageSource: ImageSource.camera,
                                  mediaTypesForExtraText: MediaTypes.Image);
                            },
                            onLongPress: () async {
                              await _connectionExtraTextManagement(
                                  imageSource: ImageSource.gallery,
                                  mediaTypesForExtraText: MediaTypes.Image);
                            },
                          ),
                        ),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: Colors.blue,
                                width: 3,
                              )),
                          child: GestureDetector(
                            onTap: () async {
                              await _connectionExtraTextManagement(
                                  imageSource: ImageSource.camera,
                                  mediaTypesForExtraText: MediaTypes.Video);
                            },
                            onLongPress: () async {
                              await _connectionExtraTextManagement(
                                  imageSource: ImageSource.gallery,
                                  mediaTypesForExtraText: MediaTypes.Video);
                            },
                            child: Icon(
                              Icons.video_collection,
                              color: Colors.lightGreen,
                            ),
                          ),
                        ),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: Colors.blue,
                                width: 3,
                              )),
                          child: GestureDetector(
                            onTap: () async {
                              List<String> _allowedExtensions = [
                                'pdf',
                                'doc',
                                'docx',
                                'ppt',
                                'pptx',
                                'c',
                                'cpp',
                                'py',
                                'text'
                              ];

                              try {
                                final FilePickerResult filePickerResult =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: _allowedExtensions,
                                );

                                if (filePickerResult != null &&
                                    filePickerResult.files.length > 0) {
                                  Navigator.pop(context);
                                  filePickerResult.files.forEach((file) async {
                                    print(file.path);
                                    if (_allowedExtensions
                                        .contains(file.extension))
                                      _connectionExtraTextManagement(
                                          mediaTypesForExtraText:
                                              MediaTypes.Document,
                                          file: File(file.path),
                                          extension: '.${file.extension}');
                                    else {
                                      _showDiaLog(
                                        titleText:
                                            'Not Supporting Document Format',
                                      );
                                    }
                                  });
                                }
                              } catch (e) {
                                _showDiaLog(
                                    titleText: 'Some Error Occurred',
                                    contentText:
                                        'Please close and reopen this chat');
                              }
                            },
                            child: Icon(
                              Entypo.documents,
                              color: Colors.lightGreen,
                            ),
                          ),
                        ),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: Colors.blue,
                                width: 3,
                              )),
                          child: GestureDetector(
                            onTap: () async {
                              try {
                                showToast(
                                  'Waiting for Map',
                                  fToast,
                                  fontSize: 16.0,
                                );
                                _showMap();
                              } catch (e) {
                                print(
                                    'Error: Location Show Toast Error to open Map: ${e.toString()}');
                              }
                            },
                            child: Icon(
                              Icons.location_on_rounded,
                              color: Colors.lightGreen,
                            ),
                          ),
                        ),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: Colors.blue,
                                width: 3,
                              )),
                          child: GestureDetector(
                            child: Icon(
                              Icons.music_note_rounded,
                              color: Colors.lightGreen,
                            ),
                            onTap: () async {
                              final List<String> _allowedExtensions = const [
                                'mp3',
                                'm4a',
                                'wav',
                                'ogg',
                              ];

                              final FilePickerResult _audioFilePickerResult =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.audio,
                              );

                              Navigator.pop(context);

                              if (_audioFilePickerResult != null) {
                                _audioFilePickerResult.files.forEach((element) {
                                  print('Name: ${element.path}');
                                  print('Extension: ${element.extension}');
                                  if (_allowedExtensions
                                      .contains(element.extension)) {
                                    _voiceSend(element.path,
                                        audioExtension:
                                            '.${element.extension}');
                                  } else {
                                    _voiceSend(element.path);
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ));
  }

  void openFileResultStatus({@required OpenResult openResult}) {
    if (openResult.type == ResultType.permissionDenied)
      _showDiaLog(titleText: 'Permission Denied to Open File');
    else if (openResult.type == ResultType.noAppToOpen)
      _showDiaLog(titleText: 'No App Found to Open');
    else if (openResult.type == ResultType.error)
      _showDiaLog(titleText: 'Error in Opening File');
    else if (openResult.type == ResultType.fileNotFound)
      _showDiaLog(titleText: 'Sorry, File Not Found');
  }

  Future<void> _connectionExtraTextManagement(
      {ImageSource imageSource = ImageSource.camera,
      @required MediaTypes mediaTypesForExtraText,
      String extension = '',
      File file}) async {
    PickedFile _pickedFile;

    if (mediaTypesForExtraText == MediaTypes.Image) {
      _pickedFile = await _picker.getImage(
        source: imageSource,
        imageQuality: 50,
      );
      if (_pickedFile != null) {
        Navigator.pop(context);

        _extraTextInputTakeInDialogForm(
            fileLocation: _pickedFile.path, mediaTypesIS: MediaTypes.Image);
      }
    } else if (mediaTypesForExtraText == MediaTypes.Video) {
      _pickedFile = await _picker.getVideo(
        source: imageSource,
        maxDuration: Duration(seconds: 15),
      );
      if (_pickedFile != null) {
        Navigator.pop(context);

        _extraTextInputTakeInDialogForm(
            fileLocation: _pickedFile.path, mediaTypesIS: MediaTypes.Video);
      }
    } else if (mediaTypesForExtraText == MediaTypes.Document) {
      _extraTextInputTakeInDialogForm(
          mediaTypesIS: MediaTypes.Document, file: file, extension: extension);
    }
  }

  void _extraTextInputTakeInDialogForm(
      {String fileLocation,
      @required MediaTypes mediaTypesIS,
      String extension = '',
      File file}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        elevation: 5.0,
        backgroundColor: Color.fromRGBO(34, 48, 60, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(
            40.0,
          )),
        ),
        title: Center(
          child: Text(
            'Something About That',
            style: TextStyle(
              color: Colors.lightBlue,
              fontSize: 14.0,
              fontFamily: 'Lora',
              fontStyle: FontStyle.italic,
              letterSpacing: 1.0,
            ),
          ),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: TextField(
                controller: _mediaTextController,
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                    labelText: 'Type Here...',
                    labelStyle: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Lora',
                      letterSpacing: 1.0,
                      fontStyle: FontStyle.italic,
                    ),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.lightBlue))),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: IconButton(
                icon: Icon(
                  Icons.send_rounded,
                  color: Colors.green,
                  size: 30.0,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                  if (mediaTypesIS == MediaTypes.Image)
                    await _mediaSend(File(fileLocation),
                        extraText: _mediaTextController.text);
                  else if (mediaTypesIS == MediaTypes.Video) {
                    await _mediaSend(File(fileLocation),
                        extraText: _mediaTextController.text,
                        mediaTypesForSend: MediaTypes.Video);
                  } else if (mediaTypesIS == MediaTypes.Document) {
                    _mediaSend(
                      file,
                      mediaTypesForSend: mediaTypesIS,
                      extension: extension,
                      extraText: _mediaTextController.text,
                    );
                  }
                  if (mounted) {
                    //Navigator.pop(context);
                    _mediaTextController.clear();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDiaLog({@required String titleText, String contentText = ''}) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
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
                      height: 100,
                      width: MediaQuery.of(context).size.width,
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

  _showMap() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);

      final Marker marker = Marker(
          markerId: MarkerId('locate'),
          zIndex: 1.0,
          draggable: true,
          position: LatLng(position.latitude, position.longitude));

      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                backgroundColor: Colors.black26,
                actions: [
                  FloatingActionButton(
                    child: Icon(Icons.send),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      _locationSend(
                          latitude: position.latitude,
                          longitude: position.longitude);
                    },
                  ),
                ],
                content: FittedBox(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                    ),
                    child: GoogleMap(
                      mapType: MapType.hybrid,
                      markers: Set.of([marker]),
                      initialCameraPosition: CameraPosition(
                        target: LatLng(position.latitude, position.longitude),
                        zoom: 18.4746,
                      ),
                    ),
                  ),
                ),
              ));
    } catch (e) {
      print('Map Show Error: ${e.toString()}');
      _showDiaLog(titleText: 'Map Show Error', contentText: e.toString());
    }
  }

  Widget _multipleOptions(int index,
      {@required MediaTypes mediaTypes, Color bgColor = Colors.black38}) {
    return Container(
      alignment: mediaTypes != MediaTypes.Location
          ? Alignment.bottomCenter
          : Alignment.topCenter,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: 50.0,
        alignment: mediaTypes != MediaTypes.Location
            ? Alignment.bottomCenter
            : Alignment.topCenter,
        color: bgColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              iconSize: 30,
              icon: Icon(
                Entypo.forward,
                color: Colors.lightGreenAccent,
              ),
              onPressed: () async {
                if (mediaTypes == MediaTypes.Image ||
                    mediaTypes == MediaTypes.Video ||
                    mediaTypes == MediaTypes.Document) {
                  print('Image Forward Pressed');
                  final List<String> afterSplitting =
                      _chatContainer[index].keys.first.split('/');

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => SelectConnection(
                                mediaType: _mediaTypes[index],
                                textContent: _chatContainer[index]
                                    .values
                                    .first
                                    .split('+')[1],
                                mediaFile:
                                    File(_chatContainer[index].keys.first),
                                extra: '.${afterSplitting.last}',
                              )));
                } else if (mediaTypes == MediaTypes.Voice) {
                  print('Voice Left Swipe');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => SelectConnection(
                                mediaType: MediaTypes.Voice,
                                mediaFile:
                                    File(_chatContainer[index].keys.first),
                              )));
                } else if (mediaTypes == MediaTypes.Text) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => SelectConnection(
                                textContent: _chatContainer[index]
                                        .keys
                                        .first
                                        .contains('[[[@]]]')
                                    ? _chatContainer[index]
                                        .keys
                                        .first
                                        .split('[[[@]]]')[1]
                                    : _chatContainer[index].keys.first,
                                mediaType: MediaTypes.Text,
                              )));
                } else if (mediaTypes == MediaTypes.Location) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => SelectConnection(
                                mediaType: MediaTypes.Location,
                                extra: _chatContainer[index].keys.first,
                              )));
                }
              },
            ),
            if (mediaTypes != MediaTypes.Location)
              IconButton(
                iconSize: 30,
                icon: Icon(
                  Entypo.share,
                  color: Colors.lightBlue,
                ),
                onPressed: () async {
                  print('Image Share Pressed');

                  if (mediaTypes != MediaTypes.Text)
                    await Share.shareFiles(
                      [_chatContainer[index].keys.first],
                      subject: 'Share From Generation',
                    );
                  else
                    await Share.share(
                      _chatContainer[index].keys.first,
                      subject: 'Share From Generation',
                    );
                },
              ),
            IconButton(
              iconSize: 30,
              icon: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: () => _deleteForMe(index),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteForMe(int index) {
    print('Delete Chat Message For Me');

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
          builder: (context, set) => AlertDialog(
                elevation: 0.0,
                backgroundColor: Color.fromRGBO(34, 48, 60, 0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
                title: Center(
                  child: Text(
                    'Conform to Delete for me?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                content: Container(
                  height: this._mediaTypes[index] != MediaTypes.Text &&
                          this._mediaTypes[index] != MediaTypes.Location
                      ? MediaQuery.of(context).size.height / 7
                      : MediaQuery.of(context).size.height / 15,
                  width: MediaQuery.of(context).size.width,
                  child: ListView(
                    children: [
                      if (this._mediaTypes[index] != MediaTypes.Text &&
                          this._mediaTypes[index] != MediaTypes.Location)
                        Row(
                          children: [
                            Theme(
                                data: ThemeData(
                                  unselectedWidgetColor: Colors.green,
                                ),
                                child: Checkbox(
                                    activeColor: Colors.green,
                                    value: this._deleteMediaFromInternalStorage,
                                    onChanged: (response) {
                                      print(response);
                                      if (mounted) {
                                        setState(() {
                                          this._deleteMediaFromInternalStorage =
                                              response;
                                          Navigator.pop(context);
                                          _deleteForMe(index);
                                        });
                                      }
                                    })),
                            SizedBox(
                              width: 5.0,
                            ),
                            Expanded(
                              child: TextButton(
                                child: Text(
                                  'Delete Media From Storage',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  if (mounted) {
                                    setState(() {
                                      this._deleteMediaFromInternalStorage =
                                          !this._deleteMediaFromInternalStorage;
                                      Navigator.pop(context);
                                      _deleteForMe(index);
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _deleteForMeCommonPart(
                            index,
                            buttonLabel: 'Cancel',
                            buttonTextColor: Colors.red,
                          ),
                          _deleteForMeCommonPart(
                            index,
                            buttonLabel: 'Sure',
                            buttonTextColor: Colors.lightGreenAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
    );
  }

  Widget _deleteForMeCommonPart(int index,
      {@required String buttonLabel, @required Color buttonTextColor}) {
    return TextButton(
      child: Text(
        buttonLabel,
        style: TextStyle(
          color: buttonTextColor,
          fontSize: 16.0,
        ),
      ),
      style: ElevatedButton.styleFrom(
        primary: Color.fromRGBO(34, 48, 60, 0.0),
      ),
      onPressed: () async {
        if (buttonLabel == 'Cancel')
          Navigator.pop(context);
        else {
          final bool responseIs = await _localStorageHelper.deleteChatMessage(
              widget._userName,
              message: _chatContainer[index].keys.first,
              time: _chatContainer[index].values.first,
              reference: _response[index] ? 1 : 0,
              mediaType: _mediaTypes[index].toString());

          print('Chat Delete Response: $responseIs');
          if (responseIs) {
            if (this._mediaTypes[index] != MediaTypes.Text &&
                this._mediaTypes[index] != MediaTypes.Location &&
                this._deleteMediaFromInternalStorage) {
              print(
                  'Permission Accepted: Delete From Permission Storage Persimission Aceepted');

              /// Delete MediaFiles from Internal Storage
              try {
                await File(_chatContainer[index]
                            .keys
                            .first
                            .toString()
                            .contains('file:///')
                        ? _chatContainer[index]
                            .keys
                            .first
                            .toString()
                            .split('file:///')[1]
                        : _chatContainer[index].keys.first.toString())
                    .delete(recursive: true)
                    .whenComplete(() => print('Media File Deletion Complete'));

                if (_mediaTypes[index].toString() ==
                    MediaTypes.Video.toString())
                  await File(_chatContainer[index]
                          .values
                          .first
                          .toString()
                          .split('+')[2])
                      .delete(recursive: true)
                      .whenComplete(
                          () => print('Video Thumbnail Deletion Complete'));

                print('File Deleted From Internal Storage in Delete For Me');
              } catch (e) {
                print(
                    'Delete Media From Internal Storage in Delete For Me Error: ${e.toString()}');
              }
            } else {
              print(
                  'Permission Denied: Delete From Permission Storage Permission Denied');
            }

            Navigator.pop(context);

            print('MediaTypes Index: ${_mediaTypes[index]}');

            if (_mediaTypes[index] == MediaTypes.Text ||
                _mediaTypes[index] == MediaTypes.Voice) {
              print('Pop Second Time');
              Navigator.pop(context);
            }

            if (mounted) {
              setState(() {
                _chatContainer.removeAt(index);
                _response.removeAt(index);
                _mediaTypes.removeAt(index);
              });
            }

            try {
              showToast(
                'Message Deleted Successfully',
                fToast,
                fontSize: 16.0,
                toastColor: Colors.amber,
                toastGravity: ToastGravity.CENTER,
              );
            } catch (e) {
              print('Context Matching Unexpected Error: ${e.toString()}');
            }
          } else {
            Navigator.pop(context);

            try {
              showToast(
                'Chat Message Delete Error',
                fToast,
                toastColor: Colors.red,
                fontSize: 16.0,
                toastGravity: ToastGravity.CENTER,
              );
            } catch (e) {
              print('Context Matching Unexpected Error: ${e.toString()}');
            }
          }
        }
      },
    );
  }

  void _makeGenerationPhoneCall() async {
    if (!await _nativeCallback.callToCheckNetworkConnectivity())
      _showDiaLog(titleText: 'No Internet Connection');
    else {
      String phoneNumber =
          await _management.phoneNumberExtractor(widget._userName);

      if (phoneNumber != null && phoneNumber != '') {
        phoneNumber =
            !phoneNumber.contains('+') ? '+$phoneNumber' : phoneNumber;

        print('Phone number is: $phoneNumber');

        final bool res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);

        print('Phone Calling Response: $res');
      } else {
        print('Connected User Phone Number not found');
        _showDiaLog(
            titleText: 'Not Found',
            contentText: 'Connected user not registered phone number');
      }
    }
  }
}
