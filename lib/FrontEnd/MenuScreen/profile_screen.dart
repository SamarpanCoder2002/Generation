import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:generation/BackendAndDatabaseManager/firebase_services/delete_my_account_service.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/this_account_important_data.dart';
import 'package:generation/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation/BackendAndDatabaseManager/general_services/toast_message_manage.dart';
import 'package:generation/FrontEnd/Preview/images_preview_screen.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _userAbout = '', _userAccCreationDate = '', _userAccCreationTime = '';

  final FToast _fToast = FToast();

  final Management _management = Management();
  final ImagePicker _imagePicker = ImagePicker();
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();

  bool _isLoading = false;

  void _getOtherProfileInformation() async {
    final String userTempAbout =
        await _localStorageHelper.extractImportantTableData(
            extraImportant: ExtraImportant.About,
            userMail: FirebaseAuth.instance.currentUser.email);

    final String userTempAccCreationDate =
        await _localStorageHelper.extractImportantTableData(
            extraImportant: ExtraImportant.CreationDate,
            userMail: FirebaseAuth.instance.currentUser.email);

    final String userTempAccCreationTime =
        await _localStorageHelper.extractImportantTableData(
            extraImportant: ExtraImportant.CreationTime,
            userMail: FirebaseAuth.instance.currentUser.email);

    if (mounted) {
      setState(() {
        this._userAbout = userTempAbout;
        this._userAccCreationDate = userTempAccCreationDate;
        this._userAccCreationTime = userTempAccCreationTime;
      });

      print(this._userAbout);
      print(this._userAccCreationDate);
      print(this._userAccCreationTime);
    }
  }

  @override
  void initState() {
    _fToast.init(context);
    ImportantThings.findImageUrlAndUserName();
    _getOtherProfileInformation();
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
            otherInformation('About', this._userAbout),
            otherInformation('Join Date', this._userAccCreationDate),
            otherInformation('Join Time', this._userAccCreationTime),
            _logOutButton(context),
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
                  closedShape: CircleBorder(),
                  closedElevation: 0.0,
                  transitionDuration: Duration(
                    milliseconds: 500,
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
          Expanded(
            child: Container(
              alignment: Alignment.center,
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
          ),
        ],
      ),
    );
  }

  Widget otherInformation(String leftText, String rightText) {
    return Container(
      height: 60.0,
      margin: EdgeInsets.only(bottom: 30.0),
      //color: Colors.green,
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                leftText,
                style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: 'Lora',
                  fontStyle: FontStyle.italic,
                  color: Colors.lightBlue,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: 10.0),
              alignment: Alignment.centerRight,
              child: Text(
                rightText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Lora',
                  fontStyle: FontStyle.italic,
                  color: Colors.green,
                  letterSpacing: 1.0,
                ),
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
        seconds: 5,
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
                  'Please Close the Profile Screen and\nRe-Open To Continue',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ));
    }
  }

  Widget _logOutButton(BuildContext context) {
    return Center(
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
            side: BorderSide(
              color: Colors.red,
            ),
          ),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          alignment: Alignment.center,
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              Expanded(
                child: Text(
                  'Delete My Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
        onPressed: () async {
          await _deleteConformation();
        },
      ),
    );
  }

  Future<void> _deleteConformation() async {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: const Color.fromRGBO(34, 48, 60, 0.6),
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              title: Center(
                child: Text(
                  'Sure to Delete Your Account?',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18.0,
                  ),
                ),
              ),
              content: Container(
                height: 200.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(
                      child: Text(
                        'If You delete this account, your entire data will lost forever...\n\nDo You Want to Continue?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          child: Text(
                            'Cancel',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.green,
                            ),
                          ),
                          style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0),
                            side: BorderSide(color: Colors.green),
                          )),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: Text(
                            'Sure',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0),
                            side: BorderSide(color: Colors.red),
                          )),
                          onPressed: () async {
                            Navigator.pop(context);

                            if (mounted) {
                              setState(() {
                                _isLoading = true;
                              });
                            }
                            print("Deletion Event");

                            await deleteMyGenerationAccount();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ));
  }
}
