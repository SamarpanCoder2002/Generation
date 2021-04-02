import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:generation/Backend/Service/google_auth.dart';
import 'package:generation/FrontEnd/Auth_UI/log_in_UI.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          logOutButton(),
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
                  primary: Colors.white24,
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
                backgroundImage: ExactAssetImage('images/sam.jpg'),
              ),
            ),
          ),
          Expanded(
            child: Container(
              //color: Colors.blue,
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
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Container(
                          //color: Colors.yellow,
                          child: Center(
                            child: Text(
                              "Last Seen 12:00",
                              style: TextStyle(
                                fontFamily: 'Lora',
                                fontSize: 16.0,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget logOutButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
          primary: Colors.redAccent,
        ),
        child: Text(
          "Log-Out",
          style: TextStyle(
            fontSize: 25.0,
          ),
        ),
        onPressed: () async{
          print("Log-Out Event");
          bool response = await GoogleAuth().logOut();
          if(!response) {
            FirebaseAuth.instance.signOut();
          }
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LogInAuthentication()),
            (Route<dynamic> route) => false,
          );
        },
      ),
    );
  }
}
