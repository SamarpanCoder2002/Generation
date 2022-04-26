import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:generation/db_operations/db_models.dart';
import 'package:generation/db_operations/helper.dart';
import 'package:generation/db_operations/types.dart';

class DBOperations {
  FirebaseFirestore get _getInstance => FirebaseFirestore.instance;

  String get currUid => FirebaseAuth.instance.currentUser?.uid ?? "";

  String get currEmail => FirebaseAuth.instance.currentUser?.email ?? "";

  FirebaseStorage get _storageInstance => FirebaseStorage.instance;

  Future<String> _fToken() async =>
      await FirebaseMessaging.instance.getToken() ?? "";

  Future<bool> isAccountCreatedBefore() async {
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await _getInstance.doc('${DBPath.userCollection}/$currUid').get();

    return documentSnapshot.data() != null;
  }

  Future<Map<String, dynamic>> createAccount(
      {required String name,
      required String about,
      required String profilePic}) async {
    final Map<String, dynamic> _response = {};
    String profilePicRemote = profilePic;

    try {
      if (!profilePic.startsWith('https') && !profilePic.startsWith('http')) {
        final _isValid = Validator.profilePic(File(profilePic));
        if (!_isValid) {
          _response["success"] = false;
          _response["message"] = DBStatement.profilePicRestriction;
          return _response;
        }
        profilePicRemote = await uploadMediaToStorage(
            DBHelper.profileImgPath(currUid), File(profilePic),
            reference: StorageHelper.profilePicRef);
      }

      final _token = await _fToken();
      final _profile = ProfileModel.getJson(
          iName: name,
          iAbout: about,
          iEmail: currEmail,
          iProfilePic: profilePicRemote,
          iToken: _token);

      await _getInstance
          .doc('${DBPath.userCollection}/$currUid')
          .set(_profile, SetOptions(merge: true));

      _response["success"] = true;
      _response["message"] = DBStatement.profileCompleted;
    } catch (e) {
      print("ERROR in create Account: ${e.toString()}");
      _response["success"] = false;
      _response["message"] = "$e";
    }

    return _response;
  }

  Future<String> uploadMediaToStorage(String fileName, File file,
      {required String reference}) async {
    try {
      String? downLoadUrl;

      final firebaseStorageRef =
          _storageInstance.ref(reference).child(fileName);

      final UploadTask uploadTask = firebaseStorageRef.putFile(file);

      await uploadTask.whenComplete(() async {
        downLoadUrl = await firebaseStorageRef.getDownloadURL();
        print("Download Url: $downLoadUrl}");
      });


      return downLoadUrl ?? "";
    } catch (e) {
      return "Upload Incomplete";
    }
  }
}
