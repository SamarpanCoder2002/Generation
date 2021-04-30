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
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:generation_official/FrontEnd/Preview/images_preview_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:file_picker/file_picker.dart';

import 'package:generation_official/BackendAndDatabaseManager/Dataset/data_type.dart';
import 'package:generation_official/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation_official/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';

// ignore: must_be_immutable
class ChatScreenSetUp extends StatefulWidget {
  String _userName;

  ChatScreenSetUp(this._userName);

  @override
  _ChatScreenSetUpState createState() => _ChatScreenSetUpState();
}

class _ChatScreenSetUpState extends State<ChatScreenSetUp>
    with TickerProviderStateMixin {
  bool _iconChanger = true;
  bool _isMicrophonePermissionGranted = false;
  bool _isLoading = false;

  double _audioDownloadProgress = 0;
  double _currAudioPlayingTime;

  int _lastAudioPlayingIndex;

  // For Control the Scrolling
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
  );

  // All Container List
  final List<Map<String, String>> _chatContainer = [];
  final List<bool> _response = [];
  final List<MediaTypes> _mediaTypes = [];

  // For Controller Text in Field
  final TextEditingController _inputTextController = TextEditingController();
  final TextEditingController _mediaTextController = TextEditingController();

  // Some Boolean Value
  bool _showEmojiPicker = false, _isChatOpenFirstTime = true;

  // Object Initialization
  final Management _management = Management();
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();

  //final AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

  final AudioPlayer _justAudioPlayer = AudioPlayer();
  final Dio _dio = Dio();

  final ImagePicker _picker = ImagePicker();

  FlutterSoundRecorder _flutterSoundRecorder;
  Directory _audioDirectory;

  // Sender Mail Take out
  String _senderMail;

  String _totalDuration;
  String _loadingTime;

  String _hintText;

  IconData _iconData = Icons.play_arrow_rounded;

  // Changer Changeable icon
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

  void _senderMailDataFetch() async {
    _senderMail = await LocalStorageHelper().fetchEmail(widget._userName);
  }

  _extractHistoryDataFromSqLite() async {
    try {
      List<Map<String, dynamic>> messagesGet = [];
      messagesGet =
          await _localStorageHelper.extractMessageData(widget._userName);

      // If messagesList not Empty
      if (messagesGet.isNotEmpty) {
        for (Map<String, dynamic> message in messagesGet) {
          // Change Every Message Value to List
          List<dynamic> messageContainer = message.values.toList();

          // For chat open Every First Time
          if (_isChatOpenFirstTime) {
            if (mounted) {
              setState(() {
                _isChatOpenFirstTime = false;

                // For AutoScroll to the end position
                if (_scrollController.hasClients)
                  _scrollController
                      .jumpTo(_scrollController.position.maxScrollExtent);
              });
            }
          }

          // If there is no opponent's person messages
          if (messageContainer.isEmpty) {
            print("No messages in ChatContainer");
          } else {
            if (mounted) {
              setState(() {
                _chatContainer.add({
                  messageContainer[0].toString():
                      messageContainer[1].toString(),
                });
                if (messageContainer[2] == 1)
                  _response.add(true);
                else
                  _response.add(false);

                if (messageContainer[3] == MediaTypes.Text.toString()) {
                  _mediaTypes.add(MediaTypes.Text);
                } else if (messageContainer[3] == MediaTypes.Voice.toString()) {
                  _mediaTypes.add(MediaTypes.Voice);
                } else if (messageContainer[3] == MediaTypes.Image.toString()) {
                  _mediaTypes.add(MediaTypes.Image);
                } else if (messageContainer[3] == MediaTypes.Video.toString()) {
                  _mediaTypes.add(MediaTypes.Video);
                }

                if (mounted) {
                  setState(() {
                    // For AutoScroll to the end position
                    if (_scrollController.hasClients)
                      _scrollController
                          .jumpTo(_scrollController.position.maxScrollExtent);
                  });
                }
              });
            }
          }
        }
        if (mounted) {
          setState(() {
            if (_scrollController.hasClients)
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
          });
        }
      } else {
        if (_isChatOpenFirstTime) {
          if (mounted) {
            setState(() {
              _isChatOpenFirstTime = false;
            });
          }
        }
      }
      _extractDataFromFireStore(); // After Get the old Conversation messages from SqLite, Take Data from Firestore
    } catch (e) {
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
      // Fetch Data from FireStore
      _management.getDatabaseData().listen((event) {
        if (event.data()['connections'].length < 0) {
          print("No Connections Present");
        } else {
          // Checking If Sender Mail Present or Not
          if (event.data()['connections'].containsKey(this._senderMail)) {
            // Take Corresponding messages of that Contact
            List<dynamic> messages = [];
            messages = event.data()['connections'][this._senderMail];

            // If messageContainer not Empty
            if (messages.isNotEmpty) {
              // Checking Chat is open for the first time or not
              if (_isChatOpenFirstTime) {
                if (mounted) {
                  setState(() {
                    _isChatOpenFirstTime = false;
                  });
                }
              }

              if (mounted) {
                setState(() {
                  // Take Map of Connections
                  Map<String, dynamic> allConnections =
                      event.data()['connections'] as Map;

                  // Particular connection messages set to Empty
                  allConnections[this._senderMail] = [];

                  // Update Data in FireStore
                  FirebaseFirestore.instance
                      .doc(
                          'generation_users/${FirebaseAuth.instance.currentUser.email}')
                      .update({
                    'connections': allConnections,
                  });

                  List<String> _incomingInformationContainer = [];

                  // Taking all the remaining messages to store in local container
                  messages.forEach((everyMessage) async {
                    _incomingInformationContainer =
                        everyMessage.values.first.toString().split('+');

                    switch (_incomingInformationContainer[1]) {
                      case 'MediaTypes.Text': // If Message Type is Text
                        // Store Data in local Storage
                        await _localStorageHelper.insertNewMessages(
                            widget._userName,
                            everyMessage.keys.first.toString(),
                            MediaTypes.Text,
                            1,
                            _incomingInformationContainer[0]);

                        if (mounted) {
                          setState(() {
                            _mediaTypes.add(
                                MediaTypes.Text); // Insert About Media Type

                            _chatContainer.add({
                              // Current Running information Store
                              '${everyMessage.keys.first}':
                                  '${_incomingInformationContainer[0]}',
                            });

                            _response.add(true); // Chat Position Status Added
                          });
                        }

                        break;
                      case 'MediaTypes.Voice': // If Message type is voice

                        PermissionStatus storagePermissionStatus =
                            await Permission.storage
                                .request(); // Take User Permission To Take Voice

                        if (storagePermissionStatus.isGranted) {
                          if (mounted) {
                            setState(() {
                              _isLoading = true;
                            });
                          }

                          final Directory directory =
                              await getExternalStorageDirectory(); // Find Directory To Storage

                          final recordingStorage = await Directory(
                                  directory.path + '/Recordings/')
                              .create(); // Create New Folder about the desire location

                          final String currTime =
                              DateTime.now().toString(); // Current Time Take

                          if (mounted) {
                            setState(() {
                              _mediaTypes
                                  .add(MediaTypes.Voice); // add New Media Type

                              _chatContainer.add({
                                // Take Messages in Local Container
                                '${recordingStorage.path}$currTime${_incomingInformationContainer[2]}':
                                    '${_incomingInformationContainer[0]}',
                              });

                              _response.add(true); // Chat Position Status Added
                            });
                          }

                          // Download the voice from the Firebase Storage and delete from storage permanently
                          await _dio
                              .download(everyMessage.keys.first.toString(),
                                  '${recordingStorage.path}$currTime${_incomingInformationContainer[2]}',
                                  onReceiveProgress: _downLoadOnReceiveProgress)
                              .whenComplete(() async {
                            await _management.deleteFilesFromFirebaseStorage(
                                everyMessage.keys.first.toString());
                          });

                          print(
                              'Recorded Path: ${recordingStorage.path}$currTime${_incomingInformationContainer[2]}');

                          // Store Data in local Storage
                          _localStorageHelper.insertNewMessages(
                              widget._userName,
                              '${recordingStorage.path}$currTime${_incomingInformationContainer[2]}',
                              MediaTypes.Voice,
                              1,
                              _incomingInformationContainer[0]);

                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                        break;

                      case 'MediaTypes.Image':
                        _manageMedia(
                            _incomingInformationContainer, everyMessage);
                        break;
                      case 'MediaTypes.Video':
                        _manageMedia(
                            _incomingInformationContainer, everyMessage);
                        break;
                    }
                  });

                  // For AutoScroll to the end position
                  if (_scrollController.hasClients)
                    _scrollController.jumpTo(
                        _scrollController.position.maxScrollExtent + 100);
                });
              }
            } else {
              print("No message Here");
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

  void _manageMedia(
      List<String> _incomingInformationContainer, dynamic everyMessage) async {
    print('Samarpan: $_incomingInformationContainer, $everyMessage');

    PermissionStatus storagePermissionStatus = await Permission.storage
        .request(); // Take User Permission To Take Voice

    if (storagePermissionStatus.isGranted) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final Directory directory =
          await getExternalStorageDirectory(); // Find Directory To Storage

      Directory _newDirectory;

      if (_incomingInformationContainer[1] == MediaTypes.Image.toString())
        _newDirectory = await Directory('${directory.path}/Images/')
            .create(); // Create New Folder about the desire location
      else
        _newDirectory = await Directory('${directory.path}/Videos/')
            .create(); // Create New Folder about the desire location

      print('New Directory: ${_newDirectory.path}');

      final String currTime =
          DateTime.now().toString().split(' ').join('_'); // Current Time Take

      // Download the voice from the Firebase Storage and delete from storage permanently
      await _dio
          .download(
        everyMessage.keys.first.toString(),
        _incomingInformationContainer[1] == MediaTypes.Image.toString()
            ? '${_newDirectory.path}$currTime.jpg'
            : '${_newDirectory.path}$currTime.mp4',
        //onReceiveProgress: _downLoadOnReceiveProgress
      )
          .whenComplete(() async {
        await _management
            .deleteFilesFromFirebaseStorage(everyMessage.keys.first.toString());
      });

      print('Recorded Path: ${_newDirectory.path}$currTime');

      // Store Data in local Storage
      _localStorageHelper.insertNewMessages(
          widget._userName,
          _incomingInformationContainer[1] == MediaTypes.Image.toString()
              ? '${_newDirectory.path}$currTime.jpg'
              : '${_newDirectory.path}$currTime.mp4',
          _incomingInformationContainer[1] == MediaTypes.Image.toString()
              ? MediaTypes.Image
              : MediaTypes.Video,
          1,
          '${_incomingInformationContainer[0]}+${_incomingInformationContainer[2]}');

      if (mounted) {
        setState(() {
          _incomingInformationContainer[1] == MediaTypes.Image.toString()
              ? _mediaTypes.add(MediaTypes.Image)
              : _mediaTypes.add(MediaTypes.Video); // add New Media Type

          _chatContainer.add({
            // Take Messages in Local Container
            _incomingInformationContainer[1] == MediaTypes.Image.toString()
                    ? '${_newDirectory.path}$currTime.jpg'
                    : '${_newDirectory.path}$currTime.mp4':
                '${_incomingInformationContainer[0]}+${_incomingInformationContainer[2]}',
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
  }

  void _permissionSetForRecording() async {
    try {
      final PermissionStatus recordingPermissionStatus =
          await Permission.microphone.request();

      if (recordingPermissionStatus.isGranted) {
        _isMicrophonePermissionGranted = true;
        _flutterSoundRecorder = FlutterSoundRecorder(); // Initialize
        await _flutterSoundRecorder.openAudioSession(); // Active Audio Session
        await _makeDirectoryOnce(); // Make Directory One Time
      } else
        print("Permission Denied");
    } catch (e) {
      print("Record Permission Status Error: ${e.toString()}");
      _permissionSetForRecording();
    }
  }

  Future<void> _makeDirectoryOnce() async {
    final directory = await getExternalStorageDirectory();
    print("Located Directory is: " + directory.path);

    _audioDirectory = await Directory(directory.path + '/Recordings/')
        .create(); // This directory will create Once in whole Application
  }

  @override
  void initState() {
    super.initState();
    _senderMailDataFetch();

    _hintText = 'Type Here...';
    _mediaTextController.text = '';

    _currAudioPlayingTime = 100;

    _totalDuration = '';
    _loadingTime = '0:00';

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    if (_isChatOpenFirstTime) {
      _extractHistoryDataFromSqLite();
    }

    if (mounted) {
      setState(() {
        // For AutoScroll to the end position
        if (_scrollController.hasClients)
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }

    _permissionSetForRecording();
  }

  @override
  void dispose() {
    _justAudioPlayer.dispose();
    _flutterSoundRecorder.closeAudioSession();
    _mediaTextController.dispose();
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
        backgroundColor: Color.fromRGBO(34, 48, 60, 1),
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Color.fromRGBO(25, 39, 52, 1),
          elevation: 10.0,
          shadowColor: Colors.white70,
          leading: Row(
            children: <Widget>[
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: GestureDetector(
                  child: CircleAvatar(
                    radius: 23.0,
                    backgroundImage: ExactAssetImage(
                      "assets/images/sam.jpg",
                    ),
                  ),
                  onTap: () {
                    print("Pic Pressed");
                  },
                ),
              ),
            ],
          ),
          title: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0.0,
              primary: Color.fromRGBO(25, 39, 52, 1),
              onSurface: Theme.of(context).primaryColor,
            ),
            child: Text(
              widget._userName.length <= 10
                  ? widget._userName
                  : '${widget._userName.replaceRange(10, widget._userName.length, '...')}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontFamily: 'Lora',
                letterSpacing: 1.0,
              ),
            ),
            onPressed: () {
              print("Name Clicked");
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.call,
                color: Colors.green,
              ),
              highlightColor: Color.fromRGBO(0, 200, 200, 0.3),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.videocam_rounded,
                color: Colors.redAccent,
              ),
              highlightColor: Color.fromRGBO(0, 200, 200, 0.3),
              onPressed: () {},
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
    double _chatBoxHeight = MediaQuery.of(context).size.height - 155;
    return WillPopScope(
      onWillPop: () async {
        if (_showEmojiPicker) {
          if (mounted) {
            setState(() {
              _showEmojiPicker = false;
              _chatBoxHeight = MediaQuery.of(context).size.height - 155;
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
        margin: EdgeInsets.only(
          top: 20.0,
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
                    if (_mediaTypes[position] == MediaTypes.Text)
                      return textConversationList(
                          context, position, _response[position]);
                    else if (_mediaTypes[position] == MediaTypes.Image ||
                        _mediaTypes[position] == MediaTypes.Video)
                      return imageConversationList(
                          context, position, _response[position]);
                    return voiceConversationList(
                        context, position, _response[position]);
                  },
                ),
              ),
            ),
            Container(
              //color: Colors.pinkAccent,
              padding: EdgeInsets.only(bottom: 5.0),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: GestureDetector(
                      child: const Icon(
                        Icons.emoji_emotions_rounded,
                        color: Colors.orangeAccent,
                      ),
                      onTap: () {
                        //Close the keyboard
                        SystemChannels.textInput.invokeMethod('TextInput.hide');

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
                  Container(
                      width: MediaQuery.of(context).size.width * 0.65,
                      constraints: BoxConstraints.loose(Size(
                          MediaQuery.of(context).size.width * 0.65, 100.0)),
                      child: Scrollbar(
                        showTrackOnHover: true,
                        thickness: 10.0,
                        radius: Radius.circular(30.0),
                        child: TextField(
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          onTap: () {
                            if (mounted) {
                              setState(() {
                                _showEmojiPicker = false;
                                _chatBoxHeight =
                                    MediaQuery.of(context).size.height - 155;
                              });
                            }

                            _scrollController.jumpTo(
                                _scrollController.position.maxScrollExtent);
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
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide(
                                  color: Colors.lightGreen, width: 2.0),
                            ),
                            hintText: _hintText,
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Lora',
                              letterSpacing: 2.0,
                              fontStyle: FontStyle.italic,
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.lightBlue)),
                          ),
                        ),
                      )),
                  Expanded(
                    child: IconButton(
                      icon: _iconChanger ? _voiceIcon : _senderIcon,
                      onPressed: _iconChanger ? _voiceController : _textSend,
                    ),
                  ),
                  SizedBox(
                    height: 2.0,
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

  Widget textConversationList(BuildContext context, int index, bool _response) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          margin: _response
              ? EdgeInsets.only(
                  right: MediaQuery.of(context).size.width / 3, left: 5.0)
              : EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 3, right: 5.0),
          alignment: _response ? Alignment.centerLeft : Alignment.centerRight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: _response
                  ? Color.fromRGBO(60, 80, 100, 1)
                  : Color.fromRGBO(102, 150, 255, 1),
              elevation: 0.0,
              padding: EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
            ),
            child: Text(
              _chatContainer[index].keys.first,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {},
          ),
        ),
        Container(
          alignment: _response ? Alignment.centerLeft : Alignment.centerRight,
          margin: _response
              ? EdgeInsets.only(left: 5.0, bottom: 5.0)
              : EdgeInsets.only(right: 5.0, bottom: 5.0),
          child: Text(
            _chatContainer[index].values.first,
            style: TextStyle(color: Colors.lightBlue),
          ),
        ),
      ],
    );
  }

  Widget voiceConversationList(
      BuildContext context, int index, bool _responseValue) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
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
            width: 200.0,
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
                      onLongPress: () => chatMicrophoneOnLongPressAction(),
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
                SizedBox(
                  width: 5.0,
                ),
                Expanded(
                  //color: Color.fromRGBO(86, 121, 192, 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          top: 26.0,
                        ),
                        padding: EdgeInsets.only(right: 10.0),
                        child: LinearPercentIndicator(
                          percent: _justAudioPlayer.duration == null
                              ? 0
                              : _lastAudioPlayingIndex == index
                                  ? _currAudioPlayingTime /
                                      _justAudioPlayer.duration.inMicroseconds
                                          .ceilToDouble()
                                  : 0,
                          backgroundColor: Colors.black26,
                          progressColor:
                              _responseValue ? Colors.lightBlue : Colors.amber,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: 10.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _lastAudioPlayingIndex == index
                                    ? _loadingTime
                                    : '0:00',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            Expanded(
                              child: Text(
                                _lastAudioPlayingIndex == index
                                    ? _totalDuration
                                    : '',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        Container(
          alignment:
              _responseValue ? Alignment.centerLeft : Alignment.centerRight,
          margin: _responseValue
              ? EdgeInsets.only(
                  left: 5.0,
                  bottom: 5.0,
                  top: 5.0,
                )
              : EdgeInsets.only(
                  right: 5.0,
                  bottom: 5.0,
                  top: 5.0,
                ),
          child: Text(
            _chatContainer[index].values.first,
            style: TextStyle(color: Colors.lightBlue),
          ),
        ),
      ],
    );
  }

  Widget imageConversationList(
      BuildContext context, int index, bool _responseValue) {
    print(_chatContainer[index].values.first);

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
          child: _mediaTypes[index] == MediaTypes.Image
              ? OpenContainer(
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
                    milliseconds: 900,
                  ),
                  transitionType: ContainerTransitionType.fadeThrough,
                  openBuilder: (context, openWidget) {
                    return PreviewImageScreen(
                      imageFile: File(_chatContainer[index].keys.first),
                    );
                  },
                  closedBuilder: (context, closeWidget) => Container(
                    alignment: Alignment.center,
                    child: PhotoView(
                      imageProvider:
                          FileImage(File(_chatContainer[index].keys.first)),
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
                      minScale: 0.5,
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:
                          ExactAssetImage('assets/images/sam.jpg', scale: 10.0),
                    ),
                    color: _responseValue
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
                  child: Center(
                    child: IconButton(
                      iconSize: 100.0,
                      icon: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await OpenFile.open(_chatContainer[index].keys.first);
                      },
                    ),
                  ),
                ),
        ),
        if (_chatContainer[index].values.first.split('+')[1] != '')
          Scrollbar(
            showTrackOnHover: true,
            thickness: 10.0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              //height: 60.0,
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
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
                color: _responseValue
                    ? Color.fromRGBO(60, 80, 100, 1)
                    : Color.fromRGBO(102, 102, 255, 1),
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
          ),
        Container(
          alignment:
              _responseValue ? Alignment.centerLeft : Alignment.centerRight,
          margin: _responseValue
              ? EdgeInsets.only(
                  left: 5.0,
                  bottom: 5.0,
                  top: 5.0,
                )
              : EdgeInsets.only(
                  right: 5.0,
                  bottom: 5.0,
                  top: 5.0,
                ),
          child: Text(
            _chatContainer[index].values.first.split('+')[0],
            style: TextStyle(color: Colors.lightBlue),
          ),
        ),
      ],
    );
  }

  void _textSend() async {
    try {
      print("Send Pressed");
      if (_inputTextController.text.isNotEmpty) {
        // Take Document Data related to old messages
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
            // Add data to temporary Storage of Sending
            sendingMessages.add({
              '${_inputTextController.text}':
                  "${DateTime.now().hour}:${DateTime.now().minute}+${MediaTypes.Text}",
            });

            // Add Data to the UI related all chat Container
            _chatContainer.add({
              '${_inputTextController.text}':
                  "${DateTime.now().hour}:${DateTime.now().minute}",
            });

            _response
                .add(false); // Add the data _response to chat related container

            _mediaTypes.add(MediaTypes.Text); // Add MediaType

            _inputTextController.clear(); // Get Clear the InputBox

            _iconChanger = true;
          });
        }

        // Scroll to Bottom
        _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent + 100);

        print('MediaTypes.Text: ${MediaTypes.Text}');

        // Data Store in Local Storage
        await _localStorageHelper.insertNewMessages(
            widget._userName,
            _chatContainer.last.keys.first.toString(),
            MediaTypes.Text,
            0,
            _chatContainer.last.values.first.toString());

        // Data Store in Firestore
        _management.addConversationMessages(this._senderMail, sendingMessages);
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
    }

    // For Recording Action
    if (_flutterSoundRecorder.isStopped) {
      if (mounted) {
        setState(() {
          _hintText = 'Recording....';
        });
      }
      _flutterSoundRecorder
          .startRecorder(
            toFile: _audioDirectory.path + '${DateTime.now()}.mp3',
          )
          .then((value) => print("Recording"));
    } else {
      // For recording stop after action
      if (mounted) {
        setState(() {
          _hintText = 'Type Here...';
        });
      }
      final String recordedFilePath =
          await _flutterSoundRecorder.stopRecorder();

      print("recordedFilePath: $recordedFilePath");

      _voiceSend(recordedFilePath);
    }
  }

  void _voiceSend(String recordedFilePath,
      {String audioExtension = '.mp3'}) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
      print("Start");
    }

    final String downloadUrl =
        await _management.uploadMediaToStorage(File(recordedFilePath), context);
    print("Voice Download Url: $downloadUrl");

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      print("End");
    }

    final DocumentSnapshot documentSnapShot = await FirebaseFirestore.instance
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
        // Add data to temporary Storage of Sending
        sendingMessages.add({
          downloadUrl:
              '${DateTime.now().hour}:${DateTime.now().minute}+${MediaTypes.Voice}+$audioExtension',
        });

        // Add Data to the UI related all chat Container
        _chatContainer.add({
          recordedFilePath: '${DateTime.now().hour}:${DateTime.now().minute}',
        });

        _response
            .add(false); // Add the data _response to chat related container

        _mediaTypes.add(MediaTypes.Voice); // Add MediaType

        _inputTextController.clear(); // Get Clear the InputBox
      });

      // Data Store in Local Storage
      await _localStorageHelper.insertNewMessages(
          widget._userName,
          recordedFilePath,
          MediaTypes.Voice,
          0,
          _chatContainer.last.values.first.toString());

      // Data Store in Firestore
      _management.addConversationMessages(this._senderMail, sendingMessages);
    }
  }

  void _imageSend(File _takeImageFile,
      {MediaTypes mediaTypesForSend = MediaTypes.Image,
      String extraText = ''}) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final String _imageDownLoadUrl =
        await _management.uploadMediaToStorage(_takeImageFile, context);

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

    if (mounted) {
      if (_sendingMessages == null) _sendingMessages = [];

      setState(() {
        // Add data to temporary Storage of Sending
        _sendingMessages.add({
          _imageDownLoadUrl:
              '${DateTime.now().hour}:${DateTime.now().minute}+$mediaTypesForSend+$extraText',
        });

        // Add Data to the UI related all Chat Container
        _chatContainer.add({
          _takeImageFile.path:
              '${DateTime.now().hour}:${DateTime.now().minute}+$extraText',
        });

        _response
            .add(false); // Add the data _response to chat related container

        _mediaTypes.add(mediaTypesForSend); // Add MediaType

        _inputTextController.clear(); // Get Clear the InputBox
      });

      // Data Store in Local Storage
      await _localStorageHelper.insertNewMessages(
          widget._userName,
          _takeImageFile.path,
          mediaTypesForSend,
          0,
          _chatContainer.last.values.first.toString());

      // Data Store in Firestore
      _management.addConversationMessages(this._senderMail, _sendingMessages);
    }
  }

  void chatMicrophoneOnTapAction(int index) async {
    _justAudioPlayer.positionStream.listen((event) {
      print("Going Duration: $event");

      if (mounted) {
        setState(() {
          _currAudioPlayingTime = event.inMicroseconds.ceilToDouble();
          _loadingTime = '${event.inMinutes} : ${event.inSeconds}';
        });
      }
    });

    _justAudioPlayer.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        print('Present 7');
        print('Audio Play Completed');
        _justAudioPlayer.stop();
        if (mounted) {
          setState(() {
            _loadingTime = '0:00';
            _iconData = Icons.play_arrow_rounded;
          });
        }
      }
    });

    if (_lastAudioPlayingIndex != index) {
      print('Present 1');
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
    } else {
      print('Present 2');
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
        print('Present 6');
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

        print('Present 5');
        await _justAudioPlayer.play();
      } else if (_justAudioPlayer.processingState ==
          ProcessingState.completed) {}
    }
  }

  void _downLoadOnReceiveProgress(int countReceive, int totalReceive) {
    if (mounted) {
      setState(() {
        _audioDownloadProgress = countReceive / totalReceive;
      });
    }
  }

  void chatMicrophoneOnLongPressAction() async {
    if (_justAudioPlayer.playing) {
      await _justAudioPlayer.stop();
      if (mounted) {
        setState(() {
          print('Present 7');
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
                                  ImageSource.camera);
                            },
                            onLongPress: () async {
                              await _connectionExtraTextManagement(
                                  ImageSource.gallery);
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
                            onTap: () async {},
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
                            onTap: () async {
                              //final PickedFile pickedFile = await _picker.get
                            },
                            onLongPress: () async {
                              await _connectionExtraTextManagement(
                                  ImageSource.gallery,
                                  type: 'video');
                            },
                            child: Icon(
                              Icons.video_collection,
                              color: Colors.lightGreen,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ));
  }

  Future<void> _connectionExtraTextManagement(ImageSource imageSource,
      {String type = 'image'}) async {
    PickedFile _pickedFile;
    FilePickerResult _videoFilePickerResult;

    if (type == 'image')
      _pickedFile = await _picker.getImage(
        source: imageSource,
        imageQuality: 50,
      );
    else
      _videoFilePickerResult = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
        allowCompression: true,
      );

    if (_pickedFile != null || _videoFilePickerResult != null) {
      Navigator.pop(context);
      //print(_pickedFile.path);
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
              'Something About Picture',
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
                      labelText: 'Type Here',
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
                  onPressed: () {
                    Navigator.pop(context);
                    if (type == 'image')
                      _imageSend(File(_pickedFile.path),
                          extraText: _mediaTextController.text);
                    else {
                      _videoFilePickerResult.files.forEach((everyFile) {
                        _imageSend(File(everyFile.path),
                            extraText: _mediaTextController.text,
                            mediaTypesForSend: MediaTypes.Video);
                      });
                    }
                    _mediaTextController.clear();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
