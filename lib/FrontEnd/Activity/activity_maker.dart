import 'dart:io';

import 'package:circle_list/circle_list.dart';
import 'package:circle_list/radial_drag_gesture_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import 'package:generation_official/FrontEnd/Activity/status_text_container.dart';
import 'package:generation_official/FrontEnd/Preview/images_preview_screen.dart';

activityList(
    {@required BuildContext context,
    @required List<String> allConnectionsUserName}) {
  return showDialog(
    context: context,
    builder: (context) => activityListOptions(context, allConnectionsUserName),
  );
}

activityListOptions(BuildContext context, List<String> allConnectionsUserName) {
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
                    final PickedFile pickedFile = await picker.getImage(
                      source: ImageSource.camera,
                      imageQuality: 50,
                    );

                    if(pickedFile != null){
                      print(pickedFile.path);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PreviewImageScreen(
                            imageFile: File(pickedFile.path),
                            purpose: 'status',
                            allConnectionUserName: allConnectionsUserName,
                          ),
                        ),
                      );
                    }
                  },
                  onLongPress: () async {
                    print("Take Image");

                    final PickedFile pickedFile = await picker.getImage(
                        source: ImageSource.gallery, imageQuality: 50);

                    if (pickedFile != null) {
                      print(pickedFile.path);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PreviewImageScreen(
                            imageFile: File(pickedFile.path),
                            purpose: 'status',
                            allConnectionUserName: allConnectionsUserName,
                          ),
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
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              elevation: 5.0,
                              backgroundColor:
                                  const Color.fromRGBO(34, 48, 60, 0.6),
                              title: Text(
                                "Video Player in Development Mode",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16.0,
                                  fontFamily: 'Lora',
                                  letterSpacing: 1.0,
                                ),
                              ),
                              content: Text(
                                "Due to Some Problem, We can't introduce it for now...\nBut We will introduce this feature soon",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  fontFamily: 'Lora',
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ));

                    // final PickedFile pickedFile = await picker.getVideo(
                    //     source: ImageSource.camera,
                    //     maxDuration: Duration(minutes: 1));
                    //
                    // print(pickedFile.path);
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (_) => VideoPreview(
                    //               File(pickedFile.path),
                    //               purpose: 'status',
                    //               allConnectionUserName:
                    //                   allConnectionsUserName,
                    //             )));
                  },
                  onLongPress: () async {
                    // final PickedFile pickedFile = await picker.getVideo(
                    //     source: ImageSource.gallery,
                    //     maxDuration: Duration(minutes: 1));
                    //
                    // print(pickedFile.path);
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (_) => VideoPreview(
                    //               File(pickedFile.path),
                    //               purpose: 'status',
                    //               allConnectionUserName:
                    //                   allConnectionsUserName,
                    //             )));
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
