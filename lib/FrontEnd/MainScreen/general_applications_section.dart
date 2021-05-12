import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:circle_list/circle_list.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:generation_official/BackendAndDatabaseManager/Dataset/data_type.dart';
import 'package:generation_official/FrontEnd/Services/multiple_message_send_connection_selection.dart';

import 'package:image_picker/image_picker.dart';

class ApplicationList extends StatefulWidget {
  @override
  _ApplicationListState createState() => _ApplicationListState();
}

class _ApplicationListState extends State<ApplicationList> {
  final ImagePicker picker = ImagePicker();
  final TextEditingController _mediaController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

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
                onTap: () async {
                  _imageOrVideoSend(imageSource: ImageSource.camera);
                },
                onLongPress: () async {
                  _imageOrVideoSend(imageSource: ImageSource.gallery);
                },
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
                onTap: () async {
                  _imageOrVideoSend(imageSource: ImageSource.camera, type: 'video');
                },
                onLongPress: () async {
                  _imageOrVideoSend(imageSource: ImageSource.gallery, type: 'video');
                },
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

  void _imageOrVideoSend(
      {@required ImageSource imageSource, String type = 'image'}) async {
    PickedFile pickedFile;
    type == 'image'
        ? pickedFile =
            await picker.getImage(source: imageSource, imageQuality: 50)
        : pickedFile = await picker.getVideo(
            source: imageSource, maxDuration: Duration(seconds: 15));

    if(pickedFile != null)
    _extraTextManagement(File(pickedFile.path),
        type == 'image' ? MediaTypes.Image : MediaTypes.Video);
  }

  void _extraTextManagement(File file, MediaTypes mediaTypes) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        elevation: 5.0,
        backgroundColor: Color.fromRGBO(34, 48, 60, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(
            40.0,
          )),
        ),
        title: Center(
          child: Text(
            'Something About That',
            style: TextStyle(
              color: Colors.lightBlue,
              fontSize: 14.0,
              fontFamily: 'Lora',
              fontStyle: FontStyle.italic,
              letterSpacing: 1.0,
            ),
          ),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: TextField(
                controller: _mediaController,
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                    labelText: 'Type Here',
                    labelStyle: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Lora',
                      letterSpacing: 1.0,
                      fontStyle: FontStyle.italic,
                    ),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.lightBlue))),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: IconButton(
                icon: Icon(
                  Icons.send_rounded,
                  color: Colors.green,
                  size: 30.0,
                ),
                onPressed: () async {
                  Navigator.pop(context);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => SelectConnection(
                                mediaType: mediaTypes,
                                mediaFile: file,
                                extraText: _mediaController.text,
                              )));

                  _mediaController.clear();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
