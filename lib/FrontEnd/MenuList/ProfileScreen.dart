import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
          signInButton(
              context, "images/gg.png", "Sign in With Google", 40.0, 21.0),
          SizedBox(
            height: 10.0,
          ),
          signInButton(
              context, "images/fbook.png", "Sign in With Facebook", 40.0, 18.0),
          SizedBox(
            height: 5.0,
          ),
          query(),
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

  Widget signInButton(BuildContext context, String iconData, String message,
      double imageSize, double fontSize) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width / 7,
        right: MediaQuery.of(context).size.width / 7,
      ),
      padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 10.0, bottom: 10.0),
      child: Center(
        child: RaisedButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40.0),
              side: BorderSide(
                width: 1.0,
              )),
          color: Colors.white,
          elevation: 7.0,
          padding: EdgeInsets.only(
            top: 8.0,
            bottom: 8.0,
            left: 15.0,
          ),
          child: Row(
            children: [
              Image.asset(
                iconData,
                width: imageSize,
              ),
              SizedBox(
                width: 20.0,
              ),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(fontSize: fontSize, color: Colors.black38),
                ),
              )
            ],
          ),
          onPressed: () {
            print("Authenticate With Google");
          },
        ),
      ),
      // child:
    );
  }

  Widget query(){
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          elevation: 0,
        ),
        onPressed: () {
          print("Information Alert");
        },
        child: Text(
          "Why Use It? Read Here",
          style: TextStyle(color: Colors.blue, fontSize: 20.0),
        ));
  }
}
