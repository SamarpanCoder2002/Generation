import 'dart:io';

import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:generation/BackendAndDatabaseManager/Dataset/this_account_important_data.dart';
import 'package:generation/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation/BackendAndDatabaseManager/general_services/toast_message_manage.dart';
import 'package:generation/FrontEnd/Preview/images_preview_screen.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final Management _management = Management();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false;

  FToast _fToast = FToast();

  @override
  void initState() {
    _fToast.init(context);
    ImportantThings.findImageUrlAndUserName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
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
      ),
    );
  }

  Widget firstPortion(BuildContext context) {
    return Container(
      //color: Colors.yellow,
      height: 130,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 10.0,
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Stack(
              children: [
                OpenContainer(
                  closedColor: const Color.fromRGBO(34, 48, 60, 1),
                  openColor: const Color.fromRGBO(34, 48, 60, 1),
                  middleColor: const Color.fromRGBO(34, 48, 60, 1),
                  closedElevation: 0.0,
                  transitionDuration: Duration(
                    milliseconds: 800,
                  ),
                  transitionType: ContainerTransitionType.fadeThrough,
                  openBuilder: (context, openWidget) {
                    return PreviewImageScreen(
                      imageFile:
                          File(ImportantThings.thisAccountProfileImagePath),
                    );
                  },
                  closedBuilder: (context, closeWidget) {
                    return CircleAvatar(
                      backgroundImage: ImportantThings
                                  .thisAccountProfileImagePath ==
                              ''
                          ? const ExactAssetImage(
                              "assets/logo/logo.jpg",
                            )
                          : FileImage(
                              File(ImportantThings.thisAccountProfileImagePath),
                            ),
                      radius: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? MediaQuery.of(context).size.height * (1.2 / 8) / 2.5
                          : MediaQuery.of(context).size.height *
                              (2.5 / 8) /
                              2.5,
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? MediaQuery.of(context).size.height * (0.7 / 8) - 10
                        : MediaQuery.of(context).size.height * (1.5 / 8) - 10,
                    left: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? MediaQuery.of(context).size.width / 3 - 65
                        : MediaQuery.of(context).size.width / 8 - 15,
                  ),
                  child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.lightBlue,
                      ),
                      child: GestureDetector(
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? MediaQuery.of(context).size.height *
                                  (1.3 / 8) /
                                  2.5 *
                                  (3.5 / 6)
                              : MediaQuery.of(context).size.height *
                                  (1.3 / 8) /
                                  2,
                        ),
                        onTap: () async {
                          final PickedFile _pickedFile =
                              await _imagePicker.getImage(
                            source: ImageSource.camera,
                            imageQuality: 50,
                          );

                          print('PickedFile: $_pickedFile');

                          if (_pickedFile != null)
                            await _manageTakeImageAsProfilePic(_pickedFile);
                        },
                        onLongPress: () async {
                          final PickedFile _pickedFile =
                              await _imagePicker.getImage(
                            source: ImageSource.gallery,
                            imageQuality: 50,
                          );

                          print('PickedFile: $_pickedFile');

                          if (_pickedFile != null)
                            await _manageTakeImageAsProfilePic(_pickedFile);
                        },
                      )),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 10.0,
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
                      ImportantThings.thisAccountUserName,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'Lora',
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        letterSpacing: 1.0,
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
                              "Last Active\n12:00",
                              textAlign: TextAlign.center,
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
                              "Time Spend\n 12:00:00",
                              textAlign: TextAlign.center,
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

  Future<void> _manageTakeImageAsProfilePic(PickedFile _pickedFile) async {
    try {
      showToast(
        'Applying Changes',
        _fToast,
        seconds: 8,
        fontSize: 18.0,
      );

      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      await _management.uploadNewProfilePicToFireStore(
          file: File(_pickedFile.path),
          context: context,
          userMail: FirebaseAuth.instance.currentUser.email);

      if (ImportantThings.thisAccountProfileImagePath != '') {
        try {
          await File(ImportantThings.thisAccountProfileImagePath)
              .delete(recursive: true)
              .whenComplete(() => print('Old Profile Image Deleted'));
        } catch (e) {
          print(
              'Exception: Delete Old Profile Picture Exception: ${e.toString()}');
        }
      }

      if (mounted) {
        setState(() {
          ImportantThings.thisAccountProfileImagePath =
              File(_pickedFile.path).path;
          _isLoading = false;
        });
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                elevation: 5.0,
                backgroundColor: const Color.fromRGBO(34, 48, 60, 0.6),
                title: Text(
                  'An Error Occured',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18.0,
                  ),
                ),
                content: Text(
                    'Please Close the Profile Screen and\nRe-Open To Continue', style: TextStyle(color: Colors.white,),),
              ));
    }
  }
}
