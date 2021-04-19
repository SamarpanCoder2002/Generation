import 'dart:io';

import 'package:circle_list/circle_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:generation/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation/FrontEnd/Services/search_screen.dart';
import 'file:///C:/Users/dasgu/AndroidStudioProjects/generation/lib/FrontEnd/status_view/status_text_container.dart';
import 'package:generation/FrontEnd/Store/images_preview_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:animations/animations.dart';

import 'ChatScreen.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isLoading = false;
  List<String> allConnectionsUserName = [];

  List<Map<String, dynamic>> allConnectionActivity;
  FToast fToast;

  ScrollController storyController = ScrollController();

  Management management = Management();
  final LocalStorageHelper localStorageHelper = LocalStorageHelper();

  int statusCurrIndex = 0;

  void fetchRealTimeData() async {
    setState(() {
      isLoading = true;
    });

    management.getDatabaseData().listen((event) async {
      Map<String, dynamic> allConnectionActivityTake =
          event.data()['activity'] as Map;

      allConnectionActivity.clear();
      Map<String, dynamic> myStatusTempStore = Map<String, dynamic>();

      // Activity Collection Take
      allConnectionActivityTake.forEach((connectionMail, connectionActivity) {
        if (connectionActivity.toList().isEmpty) {
          print("Empty Container");
        } else {
          List<dynamic> particularConnectionActivity =
              allConnectionActivityTake[connectionMail] as List;

          if (connectionMail == 'My Activity') {
            myStatusTempStore = {
              connectionMail: particularConnectionActivity,
            };
          } else {
            if (mounted) {
              setState(() {
                allConnectionActivity.add({
                  connectionMail: particularConnectionActivity,
                });
              });
            }
          }
        }
      });

      if (mounted) {
        setState(() {
          allConnectionActivity.insert(0, myStatusTempStore);
        });
      }

      print("All Connection Activity: $allConnectionActivity");

      // Connection Request Take
      if (event.data()['connection_request'].length > 0) {
        if (mounted) {
          Map<String, Object> allConnectionRequest =
              event.data()['connection_request']; // Take All Connection Request

          allConnectionRequest
              .forEach((connectionName, connectionStatus) async {
            if (connectionStatus.toString() == 'Request Accepted' ||
                connectionStatus.toString() == 'Invitation Accepted') {
              // User All Information Take

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
                    documentSnapshot['about'],
                    documentSnapshot.id,
                  );
                }

                if (mounted) {
                  setState(() {
                    allConnectionsUserName.insert(
                        0, documentSnapshot['user_name']);
                  });
                }
              } else
                print("Already Connection Added");
            }
          });
        }
      }
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    print("Initialization");
    allConnectionsUserName = [];
    allConnectionActivity = [];

    fToast = FToast();
    fToast.init(context);

    fetchRealTimeData();
  }

  @override
  Widget build(BuildContext context) {
    return chatScreen(context);
  }

  Widget chatScreen(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color.fromRGBO(20, 200, 50, 1),
          child: Icon(
            Icons.search_rounded,
            color: Colors.white,
            size: 30.0,
          ),
          onPressed: () async {
            print('Search based on Text');
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => Search()));
          }),
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
      //color: Colors.white,
      margin: EdgeInsets.only(
        top: 23.0,
        left: 10.0,
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * (1 / 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allConnectionActivity.length,
        itemBuilder: (context, position) {
          return statusList(context, position);
        },
      ),
    );
  }

  Widget statusList(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.only(right: MediaQuery.of(context).size.width / 18),
      child: GestureDetector(
        onTap: () {},
        child: Stack(
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
                statusCurrIndex = 0;
                return allConnectionActivity[index].values.first.length > 0
                    ? ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        controller: storyController,
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            allConnectionActivity[index].values.first.length,
                        itemBuilder: (context, position) {
                          Map<String, dynamic> activityItem =
                              allConnectionActivity[index]
                                  .values
                                  .first[position];

                          List<String> colorValues =
                              activityItem.values.first.toString().split("+");

                          int r = int.parse(colorValues[0]);
                          int g = int.parse(colorValues[1]);
                          int b = int.parse(colorValues[2]);
                          double opacity = double.parse(colorValues[3]);
                          double fontSize = double.parse(colorValues[4]);

                          String activityText = activityItem.keys.first;

                          return GestureDetector(
                            onHorizontalDragEnd: (DragEndDetails details) {
                              if (allConnectionActivity[index]
                                      .values
                                      .first
                                      .length ==
                                  statusCurrIndex) {
                                Navigator.pop(context);
                              } else {
                                details.primaryVelocity > 0
                                    ? statusCurrIndex -= 1
                                    : statusCurrIndex += 1;

                                storyController.animateTo(
                                    MediaQuery.of(context).size.width *
                                        statusCurrIndex,
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeOut);
                              }
                            },
                            child: Container(
                              color: Color.fromRGBO(r, g, b, opacity),
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 20.0, top: 20.0),
                              child: Center(
                                child: Scrollbar(
                                  showTrackOnHover: true,
                                  thickness: 10.0,
                                  radius: const Radius.circular(30.0),
                                  child: Text(
                                    activityText,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      color: Colors.white,
                                      fontFamily: 'Lora',
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          "No Activity Present",
                          style: TextStyle(
                            fontSize: 30.0,
                            color: Colors.red,
                            fontFamily: 'Lora',
                            letterSpacing: 1.0,
                          ),
                        ),
                      );
              },
              closedBuilder: (context, closeWidget) {
                return CircleAvatar(
                  backgroundImage: ExactAssetImage(
                    "assets/images/sam.jpg",
                  ),
                  radius: 50.0,
                );
              },
            ),
            index == 0
                ? Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * (1 / 8) - 30,
                      left: 60.0,
                    ),
                    child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.lightBlue,
                        ),
                        child: GestureDetector(
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 30.0,
                          ),
                          onTap: activityList,
                        )),
                  )
                : SizedBox(),
          ],
        ),
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
                      backgroundImage: ExactAssetImage('assets/images/sam.jpg'),
                    ),
                    onTap: () {
                      print("Pic Pressed");
                    },
                  ),
                ),
                OpenContainer(
                  closedColor: const Color.fromRGBO(31, 51, 71, 1),
                  openColor: const Color.fromRGBO(31, 51, 71, 1),
                  middleColor: const Color.fromRGBO(31, 51, 71, 1),
                  closedElevation: 0.0,
                  openElevation: 0.0,
                  transitionDuration: Duration(milliseconds: 500),
                  transitionType: ContainerTransitionType.fadeThrough,
                  onClosed: (value) {
                    if (allConnectionsUserName.length > 1) {
                      setState(() {
                        String _latestUserName =
                            allConnectionsUserName.removeAt(
                                allConnectionsUserName.indexOf(_userName));
                        allConnectionsUserName.insert(0, _latestUserName);
                      });
                    }
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
                    );
                  },
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

  activityList() {
    return showDialog(
      context: context,
      builder: (context) => activityListOptions(),
    );
  }

  activityListOptions() {
    final ImagePicker picker = ImagePicker();
    return AlertDialog(
      elevation: 0.3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      backgroundColor: Color.fromRGBO(34, 48, 60, 1),
      title: Center(
        child: Text(
          "Activity",
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
                      Icons.text_fields_rounded,
                      color: Colors.lightGreen,
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StatusTextContainer(allConnectionsUserName),
                          ));
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
                      Icons.image_rounded,
                      color: Colors.lightGreen,
                    ),
                    onTap: () async {
                      final PickedFile pickedFile =
                          await picker.getImage(source: ImageSource.camera);

                      print(pickedFile.path);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PreviewImageScreen(
                              imagePath: File(pickedFile.path).path),
                        ),
                      );
                    },
                    onLongPress: () async {
                      print("Take Image");

                      final PickedFile pickedFile =
                          await picker.getImage(source: ImageSource.gallery);

                      if (pickedFile != null) {
                        print(pickedFile.path);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PreviewImageScreen(
                                imagePath: File(pickedFile.path).path),
                          ),
                        );
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
                    child: Icon(
                      Icons.video_collection_rounded,
                      color: Colors.lightGreen,
                    ),
                    onTap: () async {
                      final PickedFile pickedFile =
                          await picker.getVideo(source: ImageSource.camera);

                      print(pickedFile.path);
                    },
                    onLongPress: () async {
                      final PickedFile pickedFile =
                          await picker.getVideo(source: ImageSource.gallery);

                      print(pickedFile.path);
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
                      Icons.create,
                      color: Colors.lightGreen,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
