import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:generation/db_operations/db_models.dart';
import 'package:generation/db_operations/helper.dart';
import 'package:generation/db_operations/types.dart';
import 'package:generation/providers/connection_collection_provider.dart';
import 'package:generation/providers/connection_management_provider_collection/all_available_connections_provider.dart';
import 'package:generation/providers/connection_management_provider_collection/incoming_request_provider.dart';
import 'package:provider/provider.dart';

import '../providers/connection_management_provider_collection/sent_request_provider.dart';

class DBOperations {
  FirebaseFirestore get _getInstance => FirebaseFirestore.instance;

  String get currUid => FirebaseAuth.instance.currentUser?.uid ?? "";

  String get currEmail => FirebaseAuth.instance.currentUser?.email ?? "";

  FirebaseStorage get _storageInstance => FirebaseStorage.instance;

  Future<String> _fToken() async =>
      await FirebaseMessaging.instance.getToken() ?? "";

  Future<Map<String, dynamic>> isAccountCreatedBefore() async {
    final Map<String, dynamic> _response = {};

    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await _getInstance.doc('${DBPath.userCollection}/$currUid').get();

    _response["success"] = documentSnapshot.data() != null;
    _response["data"] = documentSnapshot.data() ?? {};
    return _response;
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
          iToken: _token,
          iId: currUid);

      await _getInstance
          .doc('${DBPath.userCollection}/$currUid')
          .set(_profile, SetOptions(merge: true));

      _response["success"] = true;
      _response["message"] = DBStatement.profileCompleted;
      _response["data"] = {
        "id": currUid,
        "email": currEmail,
        "name": name,
        "about": about,
        "profilePic": profilePicRemote,
      };
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

  Future<List> getConnectedUsersData(BuildContext context) async {
    final _connectedData = await _getInstance
        .collection(
            '${DBPath.userCollection}/$currUid/${DBPath.userConnections}')
        .get();

    Provider.of<ConnectionCollectionProvider>(context, listen: false)
        .setFreshData(_connectedData.docs);

    return _connectedData.docs;
  }

  Future<List> getReceivedRequestUsersData(BuildContext context) async {
    final _receivedData = await _getInstance
        .collection(
            '${DBPath.userCollection}/$currUid/${DBPath.userReceiveRequest}')
        .get();

    Provider.of<RequestConnectionsProvider>(context, listen: false)
        .setConnections(_receivedData.docs);

    return _receivedData.docs;
  }

  Future<List> getSentRequestUsersData(BuildContext context) async {
    final _sentData = await _getInstance
        .collection(
            '${DBPath.userCollection}/$currUid/${DBPath.userSentRequest}')
        .get();

    Provider.of<SentConnectionsProvider>(context, listen: false)
        .setConnections(_sentData.docs);

    return _sentData.docs;
  }

  Future<List> getAllUsersData(BuildContext context) async {
    final _allQueryData =
        await _getInstance.collection(DBPath.userCollection).get();

    return _allQueryData.docs;
  }

  Future<Map<String, dynamic>> getAvailableUsersData(BuildContext context) async {
    final Map<String,dynamic> _allAvailableUsersData = {};

    /// For All Users Fetch
    final _allQueryDataList = await getAllUsersData(context);
    for (var doc in _allQueryDataList) {
      if (doc.id != currUid) {
        _allAvailableUsersData[doc.id] = doc.data();
      }
    }

    /// For Connected Users Fetch
    final _connectedDataList = await getConnectedUsersData(context);
    for (final doc in _connectedDataList) {
      if (_allAvailableUsersData[doc.id] != null) {
        _allAvailableUsersData.remove(doc.id);
      }
    }

    /// For Received Users Fetch
    final _receivedDataList = await getReceivedRequestUsersData(context);
    for (final doc in _receivedDataList) {
      if (_allAvailableUsersData[doc.id] != null) {
        _allAvailableUsersData.remove(doc.id);
      }
    }

    /// For Sent Users Fetch
    final _sentDataList = await getSentRequestUsersData(context);
    for (final doc in _sentDataList) {
      if (_allAvailableUsersData[doc.id] != null) {
        _allAvailableUsersData.remove(doc.id);
      }
    }

    Provider.of<AllAvailableConnectionsProvider>(context, listen: false)
        .setConnections(_allAvailableUsersData.values.toList());

    print("All Available Users Data: $_allAvailableUsersData");

    return _allAvailableUsersData;
  }

  Future<bool> sendConnectionRequest({required currUserData, required String otherUserId, required Map<String,dynamic> otherUserData})async{
    try{
      await _getInstance.doc('${DBPath.userCollection}/$currUid/${DBPath.userSentRequest}/$otherUserId').set(otherUserData, SetOptions(merge: true));
      _getInstance.doc('${DBPath.userCollection}/$otherUserId/${DBPath.userReceiveRequest}/$currUid').set(currUserData, SetOptions(merge: true));
      return true;
    }catch(e){
      print("Error in Sent Connection Request: $e");
      return false;
    }
  }

  Future<bool> withdrawConnectionRequest({required currUserData, required String otherUserId, required otherUserData}) async{
    try{
      await _getInstance.doc('${DBPath.userCollection}/$currUid/${DBPath.userSentRequest}/$otherUserId').delete();
      _getInstance.doc('${DBPath.userCollection}/$otherUserId/${DBPath.userReceiveRequest}/$currUid').delete();
      return true;
    }catch(e){
      print("Error in Sent Connection Request: $e");
      return false;
    }
  }

  acceptConnectionRequest({required currUserData, required String otherUserId, required otherUserData}) async{
    await _getInstance.doc('${DBPath.userCollection}/$currUid/${DBPath.userConnections}/$otherUserId').set(otherUserData, SetOptions(merge: true));
     _getInstance.doc('${DBPath.userCollection}/$otherUserId/${DBPath.userConnections}/$currUid').set(currUserData, SetOptions(merge: true));
    _getInstance.doc('${DBPath.userCollection}/$currUid/${DBPath.userReceiveRequest}/$otherUserId').delete();
    return await withdrawConnectionRequest(currUserData: currUserData, otherUserId: otherUserId, otherUserData: otherUserData);
  }
}




















