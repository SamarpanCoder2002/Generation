import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:generation/BackendAndDatabaseManager/firebase_services/firestore_management.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 48, 60, 1),
      body: ListView(
        children: [
          SizedBox(
            height: 20.0,
          ),
          firstPortion(context),
          SizedBox(
            height: 50.0,
          ),
          otherInformation(context, "Public Name", "Samarpan",
              Icon(Icons.arrow_right_alt_rounded)),
          otherInformation(
              context, "Total Contacts", "20", Icon(Icons.done_rounded)),
          otherInformation(
              context, "Total Status", "100", Icon(Icons.done_rounded)),
          otherInformation(
              context, "Total Logs", "50", Icon(Icons.done_rounded)),
          Management().logOutButton(context),
        ],
      ),
    );
  }

  Widget firstPortion(BuildContext context) {
    return Container(
      //color: Colors.yellow,
      height: 110,
      child: Row(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Color.fromRGBO(34, 48, 60, 1),
                  onPrimary: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80),
                  )),
              onPressed: () {
                print("Profile Picture Clicked");
              },
              child: CircleAvatar(
                radius: 50.0,
                backgroundImage: ExactAssetImage('assets/logo/logo.jpg'),
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Column(
                children: [
                  SizedBox(
                    height: 20.0,
                  ),
                  Center(
                    child: Text(
                      "Samarpan Dasgupta",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'Lora',
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Container(
                          //color: Colors.yellow,
                          child: Center(
                            child: Text(
                              "Last Active 12:00",
                              style: TextStyle(
                                fontFamily: 'Lora',
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 40.0,
                      ),
                      Expanded(
                        child: Container(
                          //color: Colors.green,
                          child: Center(
                            child: Text(
                              "Time Spend 12:00:00",
                              style: TextStyle(
                                fontFamily: 'Lora',
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget otherInformation(BuildContext context, String leftText,
      String rightText, Widget iconData) {
    return Container(
      height: 60.0,
      margin: EdgeInsets.only(bottom: 30.0),
      //color: Colors.green,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                leftText,
                style: TextStyle(
                  fontSize: 20.0,
                  fontFamily: 'Lora',
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 60.0,
          ),
          Container(
            margin: EdgeInsets.only(right: 10.0),
            child: Text(
              rightText,
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Lora',
                fontStyle: FontStyle.italic,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
