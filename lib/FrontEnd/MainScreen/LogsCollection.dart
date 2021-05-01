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
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 48, 60, 1),
      body: Container(
        color: Color.fromRGBO(34, 48, 60, 1),
        height: MediaQuery.of(context).size.height,
        margin: EdgeInsets.only(top: 10.0, bottom: 13.0),
        child: chatList(context),
      ),
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
    return Card(
        elevation: 0.0,
        color: Color.fromRGBO(34, 48, 60, 1),
        child: Container(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color.fromRGBO(34, 48, 60, 1),
              onPrimary: Colors.lightBlueAccent,
              elevation: 0.0,
            ),
            onPressed: () {
              print("Logs Information");
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
                    backgroundImage: ExactAssetImage("assets/logo/logo.jpg"),
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
                      color: Colors.white,
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
