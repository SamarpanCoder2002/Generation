import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/encrytion_maker.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';

class Management {
  final LocalStorageHelper localStorageHelper = LocalStorageHelper();
  final EncryptionMaker _encryptionMaker = EncryptionMaker();

  late String _currAccountUserName;

  _userNameExtractFromLocalDatabase() async {
    _currAccountUserName =
        await localStorageHelper.extractImportantDataFromThatAccount(
            userMail: FirebaseAuth.instance.currentUser!.email.toString());
  }

  Management({bool takeTotalUserName = true}) {
    if (takeTotalUserName) _userNameExtractFromLocalDatabase();
  }

  Future<void> addConversationMessages(String _senderMail,
      List<dynamic> messageMap, dynamic messageCollection) async {
    messageCollection[FirebaseAuth.instance.currentUser!.email.toString().toString()] =
        messageMap;

    print('Message Collection is: $messageCollection');

    await FirebaseFirestore.instance
        .doc("generation_users/$_senderMail")
        .update({
      'connections': messageCollection,
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getDatabaseData() {
    final Stream<DocumentSnapshot<Map<String, dynamic>>> streamDocumentSnapShot = FirebaseFirestore
        .instance
        .doc('generation_users/${FirebaseAuth.instance.currentUser!.email.toString()}')
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
          "${selectedBGColor.red} + ${selectedBGColor.green} + ${selectedBGColor.blue} + ${selectedBGColor.opacity}+$fontSize",
    );

    if (allConnectionUserName.isNotEmpty) {
      try {
        allConnectionUserName.forEach((String connectionUserName) async {
          String _userMail =
              await localStorageHelper.extractImportantDataFromThatAccount(
                  userName: connectionUserName);

          DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore.instance
              .doc("generation_users/$_userMail")
              .get();

          Map<String, dynamic> activityCollection =
              documentSnapshot.data()!["activity"] as Map<String, dynamic>;
          List<dynamic>? currConnection = activityCollection[
              FirebaseAuth.instance.currentUser!.email.toString().toString()];

          if (currConnection == null) currConnection = [];

          currConnection.add({
            _encryptionMaker.encryptionMaker("$activityText+MediaTypes.Text"):
                _encryptionMaker.encryptionMaker(
                    "${selectedBGColor.red}+${selectedBGColor.green}+${selectedBGColor.blue}+${selectedBGColor.opacity}+$fontSize+$_currTime"),
          });

          activityCollection[FirebaseAuth.instance.currentUser!.email.toString()
              .toString()] = currConnection;

          await FirebaseFirestore.instance
              .doc("generation_users/$_userMail")
              .update({
            "activity": activityCollection,
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
      {String mediaType = "image"}) async {
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
        final String imageUrl = await uploadMediaToStorage(imgFile, context,
            reference: "ActivityMedia/");

        final String _currTime = DateTime.now().toString();

        await localStorageHelper.insertDataInUserActivityTable(
          tableName: _currAccountUserName,
          statusLinkOrString: "${imgFile.path}+$imageUrl",
          mediaTypes: MediaTypes.Image,
          activityTime: _currTime,
          extraText: manuallyText,
        );

        allConnectionUserName.forEach((String connectionUserName) async {
          String _userMail =
              await localStorageHelper.extractImportantDataFromThatAccount(
                  userName: connectionUserName);

          DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore.instance
              .doc('generation_users/$_userMail')
              .get();

          Map<String, dynamic> activityCollection =
              documentSnapshot.data()!['activity'] as Map<String, dynamic>;
          List<dynamic>? currConnection = activityCollection[
              FirebaseAuth.instance.currentUser!.email.toString().toString()];

          if (currConnection == null) currConnection = [];

          currConnection.add({
            _encryptionMaker.encryptionMaker(imageUrl):
                _encryptionMaker.encryptionMaker(
                    '$manuallyText++++++$mediaType++++++$_currTime'),
          });

          activityCollection[FirebaseAuth.instance.currentUser!.email.toString()
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

  Future<String> uploadMediaToStorage(File filePath, BuildContext context,
      {required String reference}) async {
    try {
      String? downLoadUrl;

      final String fileName =
          '${FirebaseAuth.instance.currentUser!.uid}${DateTime.now().day}${DateTime.now().month}${DateTime.now().year}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}${DateTime.now().millisecond}';

      final Reference firebaseStorageRef =
          FirebaseStorage.instance.ref(reference).child(fileName);

      print('Firebase Storage Reference: $firebaseStorageRef');

      final UploadTask uploadTask = firebaseStorageRef.putFile(filePath);

      await uploadTask.whenComplete(() async {
        print("Media Uploaded");
        downLoadUrl = await firebaseStorageRef.getDownloadURL();
        print("Download Url: $downLoadUrl}");
      });

      return downLoadUrl!;
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
      try {
        if (specialPurpose && Firebase.apps.length == 0)
          await Firebase.initializeApp();
      } catch (e) {
        print(
            'Error in Storage Element Delete Firebase Initialization: ${e.toString()}');
        print('Firebase Already Initialized');
      }

      final Reference reference =
          FirebaseStorage.instance.ref().storage.refFromURL(fileName);
      print('Reference is: $reference');

      await reference.delete();

      print("File Deleted");
    } catch (e) {
      print("Delete From Firebase Storage Exception: ${e.toString()}");
    }
  }

  Future<void> deleteParticularActivityLink(
      {required String fileName, required String connectionMail}) async {
    try {
      await FirebaseFirestore.instance
          .doc('generation_users/activity/$fileName')
          .delete();
    } catch (e) {
      print('Delete Particular Activity Link Error: ${e.toString()}');
    }
  }

  Future<String?> uploadPollingOptionsToPollingStoreInFireStore(
      Map<String, dynamic> map) async {
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
      final String? id = await uploadPollingOptionsToPollingStoreInFireStore(
          _pollMapPollOptions);
      final String _currTime = DateTime.now().toString();

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

      await localStorageHelper.insertDataInUserActivityTable(
        tableName: this._currAccountUserName,
        statusLinkOrString:
            '${_pollMap['question'].toString()}$id[[[question]]]$_answerCollection[[[question]]]-1',
        activityTime: _currTime,
        activitySpecialOptions: ActivitySpecialOptions.Polling,
      );

      if (id != null) {
        final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore
            .instance
            .doc('generation_users/${FirebaseAuth.instance.currentUser!.email.toString()}')
            .get();
        final Map<String, dynamic> _connectionsMap =
            documentSnapshot.data()!['activity'];

        print('Connection Map: $_connectionsMap');

        _connectionsMap
            .forEach((connectionUserName, connectionUserMessages) async {
          final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore
              .instance
              .doc('generation_users/$connectionUserName')
              .get();
          final Map<String, dynamic> activityCollection =
              documentSnapshot.data()!['activity'];

          List<dynamic>? currConnection = activityCollection[
              FirebaseAuth.instance.currentUser!.email.toString().toString()];

          if (currConnection == null) currConnection = [];

          currConnection.add({
            _encryptionMaker.encryptionMaker(
                    '$id+ActivitySpecialOptions.Polling+${_pollMap['question'].toString()}+$_currTime'):
                _encryptionMaker.encryptionMaker(_answerCollection),
          });

          activityCollection[FirebaseAuth.instance.currentUser!.email.toString()
              .toString()] = currConnection;

          print('Activity Collection: $activityCollection');

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

  Future<void> uploadNewProfilePicToFireStore(
      {required File file,
      required BuildContext context,
      required String userMail}) async {
    try {
      final String _uploadedProfilePicUrl = await uploadMediaToStorage(
          file, context,
          reference: 'profilePictures/');

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore.instance
          .doc('generation_users/$userMail')
          .get();

      if (documentSnapshot.data()!['profile_pic'].toString() != '')
        await deleteFilesFromFirebaseStorage(
            _encryptionMaker.decryptionMaker(
                documentSnapshot.data()!['profile_pic'].toString()),
            specialPurpose: true);

      await localStorageHelper.insertProfilePictureInImportant(
          imagePath: file.path,
          imageUrl: _uploadedProfilePicUrl,
          mail: FirebaseAuth.instance.currentUser!.email.toString());

      await FirebaseFirestore.instance
          .doc('generation_users/$userMail')
          .update({
        'profile_pic': _encryptionMaker.encryptionMaker(_uploadedProfilePicUrl),
      });
    } catch (e) {
      print('Profile Pic Upload Error: ${e.toString()}');
    }
  }

  Future<String>? phoneNumberExtractor(String _userName) async {
    final String _userMail = await localStorageHelper
        .extractImportantDataFromThatAccount(userName: _userName);

    final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .doc('generation_users/$_userMail')
        .get();

    return documentSnapshot.get('phone_number').toString() == ''
        ? ''
        : _encryptionMaker
            .decryptionMaker(documentSnapshot.get('phone_number').toString());
  }
}
