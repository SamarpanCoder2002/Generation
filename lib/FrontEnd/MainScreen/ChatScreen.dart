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
        backgroundColor: Theme.of(context).primaryColor,
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
            "সমর্পন দাশগুপ্ত ",
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
              color: Colors.lightGreenAccent,
            ),
            highlightColor: Color.fromRGBO(0, 200, 200, 0.3),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.videocam_rounded,
              color: Colors.lightGreenAccent,
            ),
            highlightColor: Color.fromRGBO(0, 200, 200, 0.3),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, position) {
          return Container();
        },
      ),
    );
  }
}
