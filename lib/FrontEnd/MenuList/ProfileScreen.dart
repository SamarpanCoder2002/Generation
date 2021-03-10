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
          SizedBox(height: 30.0,),
          otherInformation(context),
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

  Widget otherInformation(BuildContext context){
    return Container(
      height: MediaQuery.of(context).size.height,
      margin: EdgeInsets.only(bottom: 20.0),
      color: Colors.green,
    );
  }
}
