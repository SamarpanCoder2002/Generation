import 'package:emoji_picker/emoji_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:generation/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';

// ignore: must_be_immutable
class ChatScreenSetUp extends StatefulWidget {
  String _userName;

  ChatScreenSetUp(this._userName);

  @override
  _ChatScreenSetUpState createState() => _ChatScreenSetUpState();
}

class _ChatScreenSetUpState extends State<ChatScreenSetUp>
    with TickerProviderStateMixin {
  ScrollController scrollController;
  List<Map<String, String>> chatContainer = [];
  TextEditingController inputText = TextEditingController();
  bool _showEmojiPicker = false;

  Management management = Management();

  String _senderMail;
  List<bool> response = [];

  void senderMail() async {
    _senderMail =
        await LocalStorageHelper().fetchSendingInformation(widget._userName);
  }

  @override
  void initState() {
    super.initState();
    senderMail();

    // ScrollController Initialization
    scrollController = ScrollController(
      initialScrollOffset: 0.0,
    );

    // For AutoScroll to the end position
    if (scrollController.hasClients)
      scrollController.jumpTo(scrollController.position.maxScrollExtent);

    management.getConversationMessages(this._senderMail).listen((event) {
      List<dynamic> messages = event.data()['connections'].values.first;
      if (messages.isNotEmpty) {
        setState(() {
          Map<String, dynamic> lastMessages = messages.last;
          chatContainer.add({
            '${lastMessages.keys.first}': "${lastMessages.values.first}",
          });
          response.add(true);

          // For AutoScroll to the end position
          if (scrollController.hasClients)
            scrollController
                .jumpTo(scrollController.position.maxScrollExtent + 100);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    "images/sam.jpg",
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
            });
          }
          return false;
        }
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        return true;
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
                  controller: scrollController,
                  itemCount: chatContainer.length,
                  itemBuilder: (context, position) {
                    if (response.length > 0 && response[position] == false)
                      return senderList(context, position);
                    return receiverList(context, position);
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

                            scrollController.jumpTo(
                                scrollController.position.maxScrollExtent);
                          },
                          controller: inputText,
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
                    child: IconButton(
                      icon: Icon(
                        Icons.send_rounded,
                        size: 30.0,
                        color: Colors.green,
                      ),
                      onPressed: () async {
                        print("Send Pressed");
                        if (inputText.text.isNotEmpty) {
                          response.add(false);
                          setState(() {
                            chatContainer.add({
                              '${inputText.text}':
                                  "${DateTime.now().hour}:${DateTime.now().minute}",
                            });
                            inputText.clear();
                            print(chatContainer);
                          });

                          scrollController.jumpTo(
                              scrollController.position.maxScrollExtent + 100);

                          management.addConversationMessages(
                              this._senderMail, chatContainer);
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
                      setState(() {
                        inputText.text += item.emoji;
                      });
                    },
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget senderList(BuildContext context, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width / 3, right: 5.0),
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.lightBlue,
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
              chatContainer[index].keys.first,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {},
          ),
        ),
        Container(
          alignment: Alignment.centerRight,
          margin: EdgeInsets.only(right: 5.0, bottom: 5.0),
          child: Text(
            chatContainer[index].values.first,
            style: TextStyle(color: Colors.lightBlue),
          ),
        ),
      ],
    );
  }

  Widget receiverList(BuildContext context, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          margin: EdgeInsets.only(
              right: MediaQuery.of(context).size.width / 3, left: 5.0),
          padding: EdgeInsets.only(top: 5.0),
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color.fromRGBO(60, 80, 100, 1),
              elevation: 0.0,
              padding: EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
            ),
            child: Text(
              chatContainer[index].keys.first,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {},
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(left: 5.0, bottom: 5.0),
          child: Text(
            chatContainer[index].values.first,
            style: TextStyle(color: Colors.lightBlue),
          ),
        ),
      ],
    );
  }
}
