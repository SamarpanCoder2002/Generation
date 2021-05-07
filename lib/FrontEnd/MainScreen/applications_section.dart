import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:circle_list/circle_list.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:image_picker/image_picker.dart';

class ApplicationList extends StatefulWidget {
  @override
  _ApplicationListState createState() => _ApplicationListState();
}

class _ApplicationListState extends State<ApplicationList> {
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 48, 60, 1),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Center(
            child: CircleList(
          initialAngle: 55,
          outerRadius: MediaQuery.of(context).size.width / 2.2,
          innerRadius: MediaQuery.of(context).size.width / 5,
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
                fontSize: 65.0,
                fontFamily: 'Lora',
              ),
            ),
          ),
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.blue,
                    width: 3,
                  )),
              child: GestureDetector(
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.lightGreen,
                  size: 40.0,
                ),
              ),
            ),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.blue,
                    width: 3,
                  )),
              child: GestureDetector(
                child: Icon(
                  Icons.video_collection,
                  color: Colors.lightGreen,
                  size: 40.0,
                ),
              ),
            ),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.blue,
                    width: 3,
                  )),
              child: GestureDetector(
                onTap: () async {},
                child: Icon(
                  Entypo.documents,
                  color: Colors.lightGreen,
                  size: 40.0,
                ),
              ),
            ),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.blue,
                    width: 3,
                  )),
              child: GestureDetector(
                onTap: () async {},
                child: Icon(
                  Icons.location_on_rounded,
                  color: Colors.lightGreen,
                  size: 40.0,
                ),
              ),
            ),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.blue,
                    width: 3,
                  )),
              child: GestureDetector(
                child: Icon(
                  Icons.music_note_rounded,
                  color: Colors.lightGreen,
                  size: 40.0,
                ),
                onTap: () async {},
              ),
            ),
          ],
        )),
      ),
    );
  }
}
