import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:generation_official/BackendAndDatabaseManager/Dataset/data_type.dart';
import 'package:generation_official/BackendAndDatabaseManager/firebase_services/google_auth.dart';
import 'package:generation_official/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:generation_official/FrontEnd/Auth_UI/sign_up_UI.dart';

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

  Future<void> addConversationMessages(String _senderMail, List<dynamic> messageMap) async{
    await FirebaseFirestore.instance.doc("generation_users/$_senderMail").update({
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
    // DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
    //     .doc('generation_users/${FirebaseAuth.instance.currentUser.email}')
    //     .get();
    //
    // Map<String, dynamic> activityCollection =
    //     documentSnapshot.data()['activity'] as Map;
    // List<dynamic> currConnection = activityCollection['My Activity'];
    //
    // if (currConnection == null) currConnection = [];
    //
    // currConnection.add({
    //   activityText:
    //       '${selectedBGColor.red} + ${selectedBGColor.green} + ${selectedBGColor.blue} + ${selectedBGColor.opacity}+$fontSize',
    // });
    //
    // activityCollection['My Activity'] = currConnection;
    //
    // await FirebaseFirestore.instance
    //     .doc('generation_users/${FirebaseAuth.instance.currentUser.email}')
    //     .update({
    //   'activity': activityCollection,
    // });

    await localStorageHelper.insertDataInUserActivityTable(
      tableName: _currAccountUserName,
      statusLinkOrString: activityText,
      mediaTypes: MediaTypes.Text,
      activityTime: DateTime.now().toString(),
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
            activityText:
                '${selectedBGColor.red}+${selectedBGColor.green}+${selectedBGColor.blue}+${selectedBGColor.opacity}+$fontSize',
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

        await localStorageHelper.insertDataInUserActivityTable(
          tableName: _currAccountUserName,
          statusLinkOrString: '${imgFile.path}+$imageUrl',
          mediaTypes: MediaTypes.Image,
          activityTime: DateTime.now().toString(),
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
            imageUrl: '$manuallyText++++++$mediaType',
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
      final String filePath = fileName
          .replaceAll(
              'https://firebasestorage.googleapis.com/v0/b/generation-official-291b6.appspot.com/o/',
              '')
          .split('?')[0];

      print('Deleted File: $filePath');

      try {
        if (specialPurpose) await Firebase.initializeApp();
      } catch (e) {
        print(
            'Error in Storage Element Delete Firebase Initialization: ${e.toString()}');

        print('Firebase Already Initialized');
      }

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
}
