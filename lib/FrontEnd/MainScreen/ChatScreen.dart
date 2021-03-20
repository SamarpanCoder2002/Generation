import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ChatScreenUI {
  String _currentMessage;
  int _messageOwnerIndex;

  ChatScreenUI(this._currentMessage, this._messageOwnerIndex);
}

class ChatScreenSetUp extends StatefulWidget {
  @override
  _ChatScreenSetUpState createState() => _ChatScreenSetUpState();
}

class _ChatScreenSetUpState extends State<ChatScreenSetUp>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backwardsCompatibility: true,
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
            onSurface: Theme.of(context).primaryColor,
          ),
          child: Text(
            "রাত জাগা তারা",
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
              color: Colors.white,
            ),
            highlightColor: Color.fromRGBO(0, 200, 200, 0.3),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.videocam_rounded,
              color: Colors.white,
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
    return ListView(
      children: <Widget>[
        Container(
          //color: Colors.black12,
          height: MediaQuery.of(context).size.height * 0.820,
        ),
        SizedBox(
          height: 5.0,
        ),
        Row(
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.emoji_emotions_rounded,
                color: Colors.orangeAccent,
                size: 30.0,
              ),
              onPressed: () {
                print("Emoji Pressed");
              },
            ),
            Container(
                //color: Colors.blue,
                width: MediaQuery.of(context).size.width * 0.65,
                //height: 50.0,
                constraints: BoxConstraints.loose(
                    Size(MediaQuery.of(context).size.width * 0.65, 100.0)),
                child: Scrollbar(
                  showTrackOnHover: true,
                  thickness: 10.0,
                  radius: Radius.circular(30.0),
                  child: TextField(
                    maxLines: null, // For Line Break
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        borderSide:
                            BorderSide(color: Colors.lightGreen, width: 3.0),
                      ),
                      hintText: 'Your Messages Here',
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
                onPressed: () {
                  print("Send Pressed");
                },
              ),
            ),
          ],
        ),
        SizedBox(
          height: 3.0,
        ),
      ],
    );
  }
}
