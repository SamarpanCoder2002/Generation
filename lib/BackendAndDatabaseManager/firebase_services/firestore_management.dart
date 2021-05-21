import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:generation/BackendAndDatabaseManager/Dataset/data_type.dart';
import 'package:generation/BackendAndDatabaseManager/firebase_services/google_auth.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:generation/FrontEnd/Auth_UI/sign_up_UI.dart';

class Management {
  final LocalStorageHelper localStorageHelper = LocalStorageHelper();
  String _currAccountUserName;

  _userNameExtractFromLocalDatabase() async {
    _currAccountUserName =
        await localStorageHelper.extractImportantDataFromThatAccount(
            userMail: FirebaseAuth.instance.currentUser.email);
  }

  Management({bool takeTotalUserName = true}) {
    if (takeTotalUserName) _userNameExtractFromLocalDatabase();
  }

  Widget logOutButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
          primary: Colors.redAccent,
        ),
        child: Text(
          "Log-Out",
          style: TextStyle(
            fontSize: 25.0,
          ),
        ),
        onPressed: () async {
          print("Log-Out Event");
          bool response = await GoogleAuth().logOut();
          if (!response) {
            FirebaseAuth.instance.signOut();
          }
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => SignUpAuthentication()),
            (Route<dynamic> route) => false,
          );
        },
      ),
    );
  }

  Future<void> addConversationMessages(
      String _senderMail, List<dynamic> messageMap) async {
    await FirebaseFirestore.instance
        .doc("generation_users/$_senderMail")
        .update({
      'connections': {
        '${FirebaseAuth.instance.currentUser.email}': messageMap,
      }
    });
  }

  Stream<DocumentSnapshot> getDatabaseData() {
    final Stream<DocumentSnapshot> streamDocumentSnapShot = FirebaseFirestore
        .instance
        .doc('generation_users/${FirebaseAuth.instance.currentUser.email}')
        .snapshots();

    return streamDocumentSnapShot;
  }

  Future<bool> addTextActivityToFireStore(
      String activityText,
      Color selectedBGColor,
      List<String> allConnectionUserName,
      double fontSize) async {
    final String _currTime = DateTime.now().toString();

    await localStorageHelper.insertDataInUserActivityTable(
      tableName: _currAccountUserName,
      statusLinkOrString: activityText,
      mediaTypes: MediaTypes.Text,
      activityTime: _currTime,
      bgInformation:
          '${selectedBGColor.red} + ${selectedBGColor.green} + ${selectedBGColor.blue} + ${selectedBGColor.opacity}+$fontSize',
    );

    if (allConnectionUserName.isNotEmpty) {
      try {
        allConnectionUserName.forEach((String connectionUserName) async {
          String _userMail =
              await localStorageHelper.extractImportantDataFromThatAccount(
                  userName: connectionUserName);

          DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
              .doc('generation_users/$_userMail')
              .get();

          Map<String, dynamic> activityCollection =
              documentSnapshot.data()['activity'] as Map;
          List<dynamic> currConnection = activityCollection[
              FirebaseAuth.instance.currentUser.email.toString()];

          if (currConnection == null) currConnection = [];

          currConnection.add({
            '$activityText+MediaTypes.Text':
                '${selectedBGColor.red}+${selectedBGColor.green}+${selectedBGColor.blue}+${selectedBGColor.opacity}+$fontSize+$_currTime',
          });

          activityCollection[FirebaseAuth.instance.currentUser.email
              .toString()] = currConnection;

          await FirebaseFirestore.instance
              .doc('generation_users/$_userMail')
              .update({
            'activity': activityCollection,
          });
        });

        return true;
      } catch (e) {
        print("Text Status Update Error: ${e.toString()}");
        return false;
      }
    } else
      return true;
  }

  Future<bool> mediaActivityToStorageAndFireStore(
      File imgFile,
      String manuallyText,
      List<String> allConnectionUserName,
      BuildContext context,
      {String mediaType = 'image'}) async {
    if (allConnectionUserName.isEmpty) {
      await localStorageHelper.insertDataInUserActivityTable(
        tableName: _currAccountUserName,
        statusLinkOrString: imgFile.path,
        mediaTypes: MediaTypes.Image,
        activityTime: DateTime.now().toString(),
        extraText: manuallyText,
      );
      return true;
    } else {
      try {
        final String imageUrl = await uploadMediaToStorage(imgFile, context);

        final String _currTime = DateTime.now().toString();

        await localStorageHelper.insertDataInUserActivityTable(
          tableName: _currAccountUserName,
          statusLinkOrString: '${imgFile.path}+$imageUrl',
          mediaTypes: MediaTypes.Image,
          activityTime: _currTime,
          extraText: manuallyText,
        );

        allConnectionUserName.forEach((String connectionUserName) async {
          String _userMail =
              await localStorageHelper.extractImportantDataFromThatAccount(
                  userName: connectionUserName);

          DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
              .doc('generation_users/$_userMail')
              .get();

          Map<String, dynamic> activityCollection =
              documentSnapshot.data()['activity'] as Map;
          List<dynamic> currConnection = activityCollection[
              FirebaseAuth.instance.currentUser.email.toString()];

          if (currConnection == null) currConnection = [];

          currConnection.add({
            imageUrl: '$manuallyText++++++$mediaType++++++$_currTime',
          });

          activityCollection[FirebaseAuth.instance.currentUser.email
              .toString()] = currConnection;

          await FirebaseFirestore.instance
              .doc('generation_users/$_userMail')
              .update({
            'activity': activityCollection,
          });
        });

        return true;
      } catch (e) {
        print("Image Activity Update Error: ${e.toString()}");
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text("Upload Error in Other Account"),
                  content: Text(e.toString()),
                ));
        return false;
      }
    }
  }

  Future<String> uploadMediaToStorage(
      File filePath, BuildContext context) async {
    try {
      String downLoadUrl;

      final String fileName =
          '${FirebaseAuth.instance.currentUser.uid}${DateTime.now().day}${DateTime.now().month}${DateTime.now().year}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}${DateTime.now().millisecond}';

      final Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(fileName);

      final UploadTask uploadTask = firebaseStorageRef.putFile(filePath);

      await uploadTask.whenComplete(() async {
        print("Media Uploaded");
        downLoadUrl = await firebaseStorageRef.getDownloadURL();
        print("Download Url: $downLoadUrl}");
      });

      return downLoadUrl;
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text("Image Upload Error"),
                content: Text(e.toString()),
              ));
      return "Upload Incomplete";
    }
  }

  Future<void> deleteFilesFromFirebaseStorage(String fileName,
      {bool specialPurpose = false}) async {
    try {
      final String filePath = fileName.split('/')[fileName.split('/').length-1].split('?')[0];

      print('Deleted File: $filePath');

      try {
        if (specialPurpose) await Firebase.initializeApp();
      } catch (e) {
        print(
            'Error in Storage Element Delete Firebase Initialization: ${e.toString()}');

        print('Firebase Already Initialized');
      }

      print('File Path: $filePath');

      await FirebaseStorage.instance.ref().child(filePath).delete();

      print("File Deleted");
    } catch (e) {
      print("Delete From Firebase Storage Exception: ${e.toString()}");
    }
  }

  Future<void> deleteParticularActivityLink(
      {@required String fileName, @required String connectionMail}) async {
    try {
      await FirebaseFirestore.instance
          .doc('generation_users/activity/$fileName')
          .delete();
    } catch (e) {
      print('Delete Particular Activity Link Error: ${e.toString()}');
    }
  }

  Future<String> addPollingToFireStore(Map<String, dynamic> map) async {
    try {
      final DocumentReference documentReference = await FirebaseFirestore
          .instance
          .collection('polling_collection')
          .add(map);
      return documentReference.id.toString();
    } catch (e) {
      print('\n Polling Add Error: ${e.toString()}');
      return null;
    }
  }

  Future<void> addPollIdInLocalAndFireStore(Map<String, dynamic> _pollMap,
      Map<String, dynamic> _pollMapPollOptions) async {
    try {
      final String id = await addPollingToFireStore(_pollMapPollOptions);

      if (id != null) {
        final String _currTime = DateTime.now().toString();

        final DocumentSnapshot documentSnapshot = await FirebaseFirestore
            .instance
            .doc('generation_users/${FirebaseAuth.instance.currentUser.email}')
            .get();
        final Map<String, dynamic> _connectionsMap =
            documentSnapshot.data()['connections'];

        _connectionsMap
            .forEach((connectionUserName, connectionUserMessages) async {
          final DocumentSnapshot documentSnapshot = await FirebaseFirestore
              .instance
              .doc('generation_users/$connectionUserName')
              .get();
          final Map<String, dynamic> activityCollection =
              documentSnapshot.data()['activity'];

          List<dynamic> currConnection = activityCollection[
              FirebaseAuth.instance.currentUser.email.toString()];

          if (currConnection == null) currConnection = [];

          String _answerCollection = '';

          print('PollMapTake is: $_pollMap');

          _pollMap.forEach((key, value) {
            print('key is: $key');

            if (key != 'question') {
              if (_answerCollection == '')
                _answerCollection = key.toString();
              else
                _answerCollection += '+${key.toString()}';
            }
          });

          print('Answer Collection: $_answerCollection');

          currConnection.add({
            '$id+ActivitySpecialOptions.Polling+${_pollMap['question'].toString()}+$_currTime':
                _answerCollection,
          });

          activityCollection[FirebaseAuth.instance.currentUser.email
              .toString()] = currConnection;

          await localStorageHelper.insertDataInUserActivityTable(
            tableName: this._currAccountUserName,
            statusLinkOrString:
                '${_pollMap['question'].toString()}$id[[[question]]]$_answerCollection[[[question]]]-1',
            activityTime: _currTime,
            activitySpecialOptions: ActivitySpecialOptions.Polling,
          );

          await FirebaseFirestore.instance
              .doc('generation_users/$connectionUserName')
              .update({
            'activity': activityCollection,
          });
        });
      }
    } catch (e) {
      print('Add Poll in Local And FireStore Error: ${e.toString()}');
    }
  }
}
