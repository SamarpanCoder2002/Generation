import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ScreenLogs extends StatefulWidget {
  @override
  _ScreenLogsState createState() => _ScreenLogsState();
}

class _ScreenLogsState extends State<ScreenLogs> {
  @override
  Widget build(BuildContext context) {
    return screenLogsList(context);
  }

  Widget screenLogsList(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      margin: EdgeInsets.only(top: 10.0, bottom: 13.0),
      child: chatList(context),
    );
  }

  Widget chatList(BuildContext context) {
    return ListView.builder(
      itemCount: 30,
      itemBuilder: (context, position) {
        return chatTile(context);
      },
    );
  }

  Widget chatTile(BuildContext context) {
    double _elevation = 0.0;
    return Card(
        child: Container(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          onPrimary: Colors.lightBlueAccent,
          animationDuration: Duration(seconds: 1),
          elevation: _elevation,
        ),
        onPressed: () {
          print("Logs Information");
          setState(() {
            _elevation = 10.0;
          });
        },
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: 5.0,
                bottom: 5.0,
              ),
              child: CircleAvatar(
                radius: 30.0,
                backgroundImage: ExactAssetImage("images/sam.jpg"),
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width / 2 + 20,
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: Text(
                "Samarpan Dasgupta",
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: Container(
                //color: Colors.deepPurpleAccent,
                child: Row(
                  children: [
                    Expanded(
                        child: IconButton(
                            icon: Icon(
                              Icons.call,
                              color: Colors.lightGreen,
                            ),
                            onPressed: () {
                              print("Call Clicked");
                            })),
                    Expanded(
                        child: IconButton(
                            icon: Icon(
                              Icons.video_call_rounded,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              print("Video Clicked");
                            })),
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
