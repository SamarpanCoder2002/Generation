import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shrinkchat/Backend/InformationContainer.dart';
import 'package:shrinkchat/DefaultValueStore/ColorSet.dart';

class ChatScreen extends StatefulWidget {

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Information _information = Information();
  List _store;
  ColorModeChange _colorModeChange = ColorModeChange();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _store = _information.informationReturn();
    //_colorModeChange.darkMode();
  }

  @override
  Widget build(BuildContext context) {
    return chatScreen(context);
  }

  Widget chatScreen(BuildContext context) {
    return ListView(
      children: [
        statusBarContainer(context),
        chatList(context),
      ],
    );
  }

  Widget statusBarContainer(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 23.0,
        left: 5.0,
        right: 5.0,
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * (1 / 8),
      //color: Colors.greenAccent,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, position) {
          return statusList(context);
        },
      ),
    );
  }

  Widget statusList(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: Colors.white24,
          onPrimary: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(80),
          )),
      onPressed: () {
        print("Status Image Clicked");
      },
      child: CircleAvatar(
        radius: 50.0,
        backgroundImage: ExactAssetImage('images/sam.jpg'),
      ),
    );
  }

  Widget chatList(BuildContext context) {
    return SafeArea(
        child: Container(
      margin: EdgeInsets.only(top: 35.0, bottom: 10.0),
      padding: EdgeInsets.only(top: 18.0, bottom: 5.0),
      height: MediaQuery.of(context).size.height * (5.15 / 8),
      decoration: BoxDecoration(
        color: Colors.white,
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
        itemCount: _store[0].length,
        itemBuilder: (context, position) {
          return chatTile(context, position);
        },
      ),
    ));
  }

  Widget chatTile(BuildContext context, int index) {
    return Card(
        child: Container(
      padding: EdgeInsets.only(left: 1.0, right: 1.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: _colorModeChange.everyChatColor,
          onPrimary: Colors.lightBlueAccent,
        ),
        onPressed: () {
          print("Pressed");
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
                  backgroundImage: ExactAssetImage(_store[0][0]),
                ),
                onTap: () {
                  print("Pic Pressed");
                },
              ),
            ),
            Container(
              //color: Colors.redAccent,
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width / 2 + 20,
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: Column(
                children: [
                  Text(
                    _store[1][0],
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 12.0,
                  ),
                  Container(
                    //color: Colors.blueGrey,
                    //padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      _store[2][0],
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black45,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                //color: Colors.deepPurpleAccent,
                padding: EdgeInsets.only(
                  right: 20.0,
                  top: 2.0,
                  bottom: 2.0,
                ),
                child: Column(
                  children: [
                    Container(
                        child: Text(
                          _store[3][0],
                      style: TextStyle(fontSize: 12.0, color: Colors.blue),
                    )),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      child: Icon(
                        _store[4][0],
                        color: _store[5][0],
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
