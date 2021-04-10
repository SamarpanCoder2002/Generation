import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:generation/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';

import 'ChatScreen.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isLoading = false;
  List<String> allConnectionsUserName;

  Management management = Management();
  final LocalStorageHelper localStorageHelper = LocalStorageHelper();

  @override
  void initState() {
    print("Initialization");
    allConnectionsUserName = [];
    super.initState();

    management.getDatabaseData().listen((event) async {
      if (event.data()['connection_request'].length > 0) {
        if (mounted) {
          Map<String, Object> allConnectionRequest =
              event.data()['connection_request']; // Take All Connection Request

          setState(() {
            allConnectionRequest
                .forEach((connectionName, connectionStatus) async {
              if (connectionStatus.toString() == 'Request Accepted' ||
                  connectionStatus.toString() == 'Invitation Accepted') {
                // User All Information Take
                print("Here Also");
                DocumentSnapshot documentSnapshot = await FirebaseFirestore
                    .instance
                    .doc('generation_users/$connectionName')
                    .get();

                // Checking If Same USer NAme PResent in the list or not
                if (!allConnectionsUserName
                    .contains(documentSnapshot['user_name'])) {
                  // Make SqLite Table With User UserName
                  bool response = await localStorageHelper
                      .createTable(documentSnapshot['user_name']);
                  if (response) {
                    await localStorageHelper.insertAdditionalData(
                      documentSnapshot['user_name'],
                      documentSnapshot['nick_name'],
                      documentSnapshot['about'],
                      documentSnapshot.id,
                    );
                  }

                  setState(() {
                    allConnectionsUserName.insert(
                        0, documentSnapshot['user_name']);
                  });
                } else
                  print("Already Connection Added");
              }
            });
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return chatScreen(context);
  }

  Widget chatScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 48, 60, 1),
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
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * (1 / 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (context, position) {
          return statusList(context);
        },
      ),
    );
  }

  Widget statusList(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
          elevation: 0.0,
          shape: CircleBorder(),
          side: BorderSide(width: 1.0, color: Colors.blue)),
      onPressed: () {
        print("Status Clicked");
      },
      child: CircleAvatar(
        backgroundImage: ExactAssetImage(
          "images/sam.jpg",
        ),
        radius: 50.0,
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

              if (allConnectionsUserName.length > 1) {
                setState(() {
                  String _latestUserName = allConnectionsUserName
                      .removeAt(allConnectionsUserName.indexOf(_userName));
                  allConnectionsUserName.insert(0, _latestUserName);
                });
              }

              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.rightToLeft,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.slowMiddle,
                      child: ChatScreenSetUp(_userName)));
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
                      backgroundImage: ExactAssetImage('images/sam.jpg'),
                    ),
                    onTap: () {
                      print("Pic Pressed");
                    },
                  ),
                ),
                Container(
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
