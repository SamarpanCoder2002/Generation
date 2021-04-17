import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PreviewImageScreen extends StatefulWidget {
  final String imagePath;

  PreviewImageScreen({@required this.imagePath});

  @override
  _PreviewImageScreenState createState() => _PreviewImageScreenState();
}

class _PreviewImageScreenState extends State<PreviewImageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 48, 60, 1),
      floatingActionButton: floatingActionButtonCall(),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Image.file(
          File(widget.imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  floatingActionButtonCall() {
    return Container(
      padding: EdgeInsets.only(
        bottom: 5.0,
        left: 15.0,
      ),
      child: Row(
        children: [
          Container(
            height: 60.0,
            child: IconButton(
              icon: const Icon(
                Icons.emoji_emotions_rounded,
                color: Colors.orangeAccent,
                size: 30.0,
              ),
              onPressed: () {
                //Close the keyboard
                SystemChannels.textInput.invokeMethod('TextInput.hide');

                // if (mounted) {
                //   setState(() {
                //     _chatBoxHeight -= 50;
                //     _showEmojiPicker = true;
                //   });
                // }
              },
            ),
          ),
          Expanded(
            child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                constraints: BoxConstraints.loose(
                    Size(MediaQuery.of(context).size.width * 0.7, 100.0)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  color: Theme.of(context).primaryColor,
                ),
                child: Scrollbar(
                  showTrackOnHover: true,
                  thickness: 10.0,
                  radius: Radius.circular(30.0),
                  child: TextField(
                    cursorColor: Colors.white,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                    onTap: () {},
                    //controller: inputText,
                    maxLines: null,
                    // For Line Break
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide:
                            BorderSide(color: Colors.black54, width: 2.0),
                      ),
                      hintText: 'Type Here',
                      hintStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightBlue)),
                    ),
                  ),
                )),
          ),
          Container(
            //color: Theme.of(context).primaryColor,
            padding: EdgeInsets.only(left: 20.0),
            child: FloatingActionButton(
                backgroundColor: Colors.green,
                onPressed: () {},
                child: GestureDetector(
                  child: Icon(
                    Icons.send_rounded,
                    size: 30.0,
                    color: Colors.white,
                  ),
                  onTap: () {},
                )),
          ),
        ],
      ),
    );
  }
}
