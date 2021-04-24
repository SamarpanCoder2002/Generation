import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:generation_official/BackendAndDatabaseManager/Dataset/data_type.dart';

import 'package:generation_official/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation_official/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

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

  // Some Boolean Value
  bool _showEmojiPicker = false, _isChatOpenFirstTime = true;

  // Object Initialization
  final Management _management = Management();
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();

  final FlutterSoundRecorder _flutterSoundRecorder = FlutterSoundRecorder();

  // Sender Mail Take out
  String _senderMail;

  // Changer Changeable icon
  final Icon _senderIcon = Icon(
    Icons.send_rounded,
    size: 30.0,
    color: Colors.green,
  );

  final Icon _voiceIcon = Icon(
    Icons.keyboard_voice_rounded,
    size: 30.0,
    color: Colors.green,
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
                  messages.forEach((everyMessage) {
                    _incomingInformationContainer =
                        everyMessage.values.first.toString().split('+');

                    _chatContainer.add({
                      '${everyMessage.keys.first}':
                          '${_incomingInformationContainer[0]}',
                    });
                    _response.add(true); // Chat Position Status Added

                    switch (_incomingInformationContainer[1]) {
                      case 'MediaTypes.Text':
                        _mediaTypes.add(MediaTypes.Text);
                        break;
                      case 'MediaTypes.Voice':
                        _mediaTypes.add(MediaTypes.Voice);
                    }

                    print("MediaTypes: ${_incomingInformationContainer[1]}");

                    // Store Data in local Storage
                    _localStorageHelper.insertNewMessages(widget._userName,
                        everyMessage.keys.first.toString(), MediaTypes.Text, 1);
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
                title: Text("Firestore Problem"),
                content: Text(e.toString()),
              ));
    }
  }

  @override
  void initState() {
    super.initState();
    _senderMailDataFetch();

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
  }

  @override
  void dispose() {
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
              widget._userName,
              style: TextStyle(color: Colors.white, fontSize: 20.0),
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
        body: mainBody(context),
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
                  IconButton(
                    icon: const Icon(
                      Icons.emoji_emotions_rounded,
                      color: Colors.orangeAccent,
                      size: 30.0,
                    ),
                    onPressed: () {
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
                            hintText: 'Type Here',
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.lightBlue)),
                          ),
                        ),
                      )),
                  Expanded(
                    child: IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        size: 30.0,
                        color: Colors.brown,
                      ),
                      onPressed: () {
                        print("Options Pressed");
                      },
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: _iconChanger ? _voiceIcon : _senderIcon,
                      onTap: _iconChanger ? _voiceSend : _messageSend,
                      onLongPress: () {
                        if (mounted) {
                          setState(() {
                            _iconChanger = !_iconChanger;
                          });
                        }
                      },
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
                  : Color.fromRGBO(102, 102, 255, 1),
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
      BuildContext context, int index, bool _response) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          margin: _response
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
          alignment: _response ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            height: 70.0,
            width: 200.0,
            decoration: BoxDecoration(
              color: _response
                  ? Color.fromRGBO(60, 80, 100, 1)
                  : Color.fromRGBO(102, 102, 255, 1),
              borderRadius: _response
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
                GestureDetector(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Color.fromRGBO(10, 255, 30, 1),
                      size: 40.0,
                    ),
                    onTap: () {}),
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
                          top: 20.0,
                        ),
                        child: LinearPercentIndicator(
                          //width: 140.0,
                          lineHeight: 5.0,
                          percent: 0.15,
                          backgroundColor: Colors.black26,
                          progressColor:
                              _response ? Colors.lightBlue : Colors.amber,
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
                                '0:00',
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
                                '12:00',
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
          alignment: _response ? Alignment.centerLeft : Alignment.centerRight,
          margin: _response
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

  _messageSend() async {
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
        _localStorageHelper.insertNewMessages(widget._userName,
            _chatContainer.last.keys.first.toString(), MediaTypes.Text, 0);

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

  _voiceSend() async {
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
                  "${DateTime.now().hour}:${DateTime.now().minute}+${MediaTypes.Voice}",
            });

            // Add Data to the UI related all chat Container
            _chatContainer.add({
              '${_inputTextController.text}':
                  '${DateTime.now().hour}:${DateTime.now().minute}',
            });

            _response
                .add(false); // Add the data _response to chat related container

            _mediaTypes.add(MediaTypes.Voice); // Add MediaType

            _inputTextController.clear(); // Get Clear the InputBox
          });
        }

        // Scroll to Bottom
        _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent + 100);

        print('MediaTypes.Text: ${MediaTypes.Voice}');

        // Data Store in Local Storage
        _localStorageHelper.insertNewMessages(widget._userName,
            _chatContainer.last.keys.first.toString(), MediaTypes.Voice, 0);

        // Data Store in Firestore
        _management.addConversationMessages(this._senderMail, sendingMessages);
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text("Voice Send Problem"),
              content: Text(e.toString()),
            );
          });
    }
  }
}
