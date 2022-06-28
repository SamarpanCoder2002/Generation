import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:generation/config/types.dart';
import 'package:generation/screens/entry_screens/splash_screen.dart';
import 'package:generation/services/encryption_operations.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:generation/services/native_operations.dart';
import 'package:generation/services/navigation_management.dart';
import 'package:generation/services/toast_message_show.dart';
import 'package:http/http.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:generation/config/text_collection.dart';
import 'package:generation/db_operations/db_models.dart';
import 'package:generation/db_operations/config.dart';
import 'package:generation/db_operations/types.dart';
import 'package:generation/providers/connection_collection_provider.dart';
import 'package:generation/providers/connection_management_provider_collection/all_available_connections_provider.dart';
import 'package:generation/providers/connection_management_provider_collection/incoming_request_provider.dart';
import 'package:provider/provider.dart';

import '../providers/connection_management_provider_collection/sent_request_provider.dart';
import '../providers/network_management_provider.dart';
import '../services/debugging.dart';
import '../services/local_data_management.dart';

class DBOperations {
  final MessagingOperation _messagingOperation = MessagingOperation();
  final LocalStorage _localStorage = LocalStorage();

  FirebaseFirestore get _getInstance => FirebaseFirestore.instance;

  String get currUid => FirebaseAuth.instance.currentUser?.uid ?? "";

  String get currEmail => FirebaseAuth.instance.currentUser?.email ?? "";

  FirebaseStorage get _storageInstance => FirebaseStorage.instance;

  initializeFirebase() async {
    try {
      //if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
      // }
    } catch (e) {
      debugShow(
          'Error in Storage Element Delete Firebase Initialization: ${e.toString()}');
      debugShow('Firebase Already Initialized');
    }
  }

  isConnectedToDB(context) async {
    final _isNetworkPresent =
        await Provider.of<NetworkManagementProvider>(context, listen: false)
            .isNetworkActive;
    if (!_isNetworkPresent) {
      debugShow("Network not found");
      Provider.of<NetworkManagementProvider>(context, listen: false)
          .noNetworkMsg(context, showCenterToast: true);
      return;
    }

    final _isCreatedBefore = await isAccountCreatedBefore();
    if (_isCreatedBefore['success']) return;

    showToast(title: "Account Not Found", toastIconType: ToastIconType.info);

    DataManagement.clearSharedStorage();
    _localStorage.closeDatabase();
    Navigation.intentStraight(context, const SplashScreen());
  }

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
      required String profilePic,
      bool update = false}) async {
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
      final _profile = ProfileModel.getEncodedJson(
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
      _response["message"] =
          update ? DBStatement.profileUpdated : DBStatement.profileCompleted;
      _response["data"] = {
        "id": currUid,
        "email": currEmail,
        "name": name,
        "about": about,
        "profilePic": profilePicRemote,
      };
    } catch (e) {
      debugShow("ERROR in create Account: ${e.toString()}");
      _response["success"] = false;
      _response["message"] = "$e";
    }

    return _response;
  }

  Future<bool> updateCurrentAccount(updatedData) async {
    try {
      updatedData[DBPath.token] = await _fToken();

      await _getInstance
          .doc('${DBPath.userCollection}/$currUid')
          .set(updatedData, SetOptions(merge: true));

      return true;
    } catch (e) {
      debugShow("ERROR in update Current Account: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> getRemoteAnyAccData(String userId) async {
    final _docData =
        await _getInstance.doc('${DBPath.userCollection}/$userId').get();
    return _docData.data();
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
        debugShow("Download Url: $downLoadUrl}");
      });

      return downLoadUrl ?? "";
    } catch (e) {
      debugShow("Upload Error: $e");
      return "";
    }
  }

  Future<List> getConnectedUsersData(BuildContext context) async {
    final _connectedData = await _getInstance
        .collection(
            '${DBPath.userCollection}/$currUid/${DBPath.userConnections}')
        .get();

    // Provider.of<ConnectionCollectionProvider>(context, listen: false)
    //     .manageRemoteDataCollection(_connectedData.docs);

    return _connectedData.docs.map((doc) => doc.data()).toList();
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

    try {
      Provider.of<SentConnectionsProvider>(context, listen: false)
          .setConnections(_sentData.docs);
    } catch (e) {
      debugShow('Error in getSentRequestUsersData: $e');
    }

    return _sentData.docs;
  }

  Future<List> getAllUsersData(BuildContext context) async {
    final _allQueryData =
        await _getInstance.collection(DBPath.userCollection).get();

    return _allQueryData.docs;
  }

  Future<Map<String, dynamic>> getAvailableUsersData(
      BuildContext context) async {
    final Map<String, dynamic> _allAvailableUsersData = {};

    /// For All Users Fetch
    final _allQueryDataList = await getAllUsersData(context);
    for (var doc in _allQueryDataList) {
      if (doc.id != currUid) {
        _allAvailableUsersData[doc.id] = doc.data();
      }
    }

    /// For Connected Users Fetch
    final _localConnectedData =
        Provider.of<ConnectionCollectionProvider>(context, listen: false)
            .getAllChatConnectionData();
    final _connectedDataList = _localConnectedData.isEmpty
        ? await getConnectedUsersData(context)
        : _localConnectedData;
    for (final doc in _connectedDataList) {
      if (_allAvailableUsersData[doc["id"]] != null) {
        _allAvailableUsersData.remove(doc["id"]);
      }
    }

    /// For Received Users Fetch
    final _receivedDataList = await getReceivedRequestUsersData(
        context); // Provider.of<RequestConnectionsProvider>(context, listen: false).getRequestConnections();//
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

    return _allAvailableUsersData;
  }

  Future<bool> sendConnectionRequest(
      {required currUserData,
      required String otherUserId,
      required Map<String, dynamic> otherUserData}) async {
    try {
      await _getInstance
          .doc(
              '${DBPath.userCollection}/$currUid/${DBPath.userSentRequest}/$otherUserId')
          .set(otherUserData, SetOptions(merge: true));
      _getInstance
          .doc(
              '${DBPath.userCollection}/$otherUserId/${DBPath.userReceiveRequest}/$currUid')
          .set(currUserData, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugShow("Error in Sent Connection Request: $e");
      return false;
    }
  }

  Future<bool> withdrawConnectionRequest(
      {required currUserData,
      required String otherUserId,
      required otherUserData}) async {
    try {
      await _getInstance
          .doc(
              '${DBPath.userCollection}/$currUid/${DBPath.userSentRequest}/$otherUserId')
          .delete();
      _getInstance
          .doc(
              '${DBPath.userCollection}/$otherUserId/${DBPath.userReceiveRequest}/$currUid')
          .delete();
      return true;
    } catch (e) {
      debugShow("Error in Sent Connection Request: $e");
      return false;
    }
  }

  acceptConnectionRequest(
      {required currUserData,
      required String otherUserId,
      required otherUserData}) async {
    try {
      await _getInstance
          .doc(
              '${DBPath.userCollection}/$currUid/${DBPath.userConnections}/$otherUserId')
          .set(otherUserData, SetOptions(merge: true));
      _getInstance
          .doc(
              '${DBPath.userCollection}/$otherUserId/${DBPath.userConnections}/$currUid')
          .set(currUserData, SetOptions(merge: true));
      _getInstance
          .doc(
              '${DBPath.userCollection}/$currUid/${DBPath.userReceiveRequest}/$otherUserId')
          .delete();
      _getInstance
          .doc(
              '${DBPath.userCollection}/$otherUserId/${DBPath.userSentRequest}/$currUid')
          .delete();
      return true;
    } catch (e) {
      debugShow("ERROR in Accept Connection Request: $e");
      return false;
    }
  }

  removeConnectedUser({required String otherUserId}) async {
    try {
      _getInstance
          .doc(
              '${DBPath.userCollection}/$currUid/${DBPath.userConnections}/$otherUserId/${DBPath.data}/${DBPath.messages}')
          .delete();
      // _getInstance
      //     .doc(
      //         '${DBPath.userCollection}/$currUid/${DBPath.userConnections}/$otherUserId/${DBPath.data}/${DBPath.activities}')
      //     .delete();
      await _getInstance
          .doc(
              '${DBPath.userCollection}/$currUid/${DBPath.userConnections}/$otherUserId')
          .delete();

      _getInstance
          .doc(
              '${DBPath.userCollection}/$otherUserId/${DBPath.userConnections}/$currUid/${DBPath.data}/${DBPath.messages}')
          .delete();
      // _getInstance
      //     .doc(
      //         '${DBPath.userCollection}/$otherUserId/${DBPath.userConnections}/$currUid/${DBPath.data}/${DBPath.activities}')
      //     .delete();
      _getInstance
          .doc(
              '${DBPath.userCollection}/$otherUserId/${DBPath.userConnections}/$currUid')
          .delete();

      await _getInstance
          .doc(
              '${DBPath.userCollection}/$otherUserId/${DBPath.specialRequest}/${DBPath.removeConn}')
          .set({
        DBPath.data: FieldValue.arrayUnion([currUid]),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugShow("ERROR in Remove Connected User: $e");
      return false;
    }
  }

  rejectIncomingRequest({required String otherUserId}) async {
    try {
      await _getInstance
          .doc(
              '${DBPath.userCollection}/$currUid/${DBPath.userReceiveRequest}/$otherUserId')
          .delete();
      _getInstance
          .doc(
              '${DBPath.userCollection}/$otherUserId/${DBPath.userSentRequest}/$currUid')
          .delete();
      return true;
    } catch (e) {
      debugShow("Error in Sent Connection Request: $e");
      return false;
    }
  }

  Future<bool> sendMessage(
      {required String partnerId,
      required dynamic msgData,
      required String token,
      required String title,
      required String body,
      bool isNotificationPermitted = false,
      String? image}) async {
    try {
      await _getInstance
          .doc(
              '${DBPath.userCollection}/$partnerId/${DBPath.userConnections}/$currUid/${DBPath.contents}/${DBPath.messages}')
          .set({
        DBPath.data: FieldValue.arrayUnion(
            [Secure.encode(DataManagement.toJsonString(msgData))])
      }, SetOptions(merge: true));

      if (isNotificationPermitted) {
        _messagingOperation.sendNotification(
            deviceToken: token,
            title: title,
            body: body,
            image: image,
            connId: currUid);
      }

      return true;
    } catch (e) {
      debugShow("ERROR in send MSg: $e");
      return false;
    }
  }

  resetRemoteOldChatMessages(String partnerId) {
    _getInstance
        .doc(
            '${DBPath.userCollection}/$currUid/${DBPath.userConnections}/$partnerId/${DBPath.contents}/${DBPath.messages}')
        .set({DBPath.data: []}, SetOptions(merge: true));
  }

  Future<bool> deleteMediaFromFirebaseStorage(String fileName,
      {bool specialPurpose = false}) async {
    try {
      try {
        if (specialPurpose && Firebase.apps.isEmpty) {
          await Firebase.initializeApp();
        }
      } catch (e) {
        debugShow(
            'Error in Storage Element Delete Firebase Initialization: ${e.toString()}');
        debugShow('Firebase Already Initialized');
      }

      final Reference reference =
          FirebaseStorage.instance.ref().storage.refFromURL(fileName);

      await reference.delete();

      debugShow("File Deleted");

      return true;
    } catch (e) {
      debugShow("Delete From Firebase Storage Exception: ${e.toString()}");
      return false;
    }
  }

  updateActiveStatus(Map<String, dynamic> status) async {
    final _data = {
      DBPath.status: Secure.encode(DataManagement.toJsonString(status))
    };

    if (status["status"] == UserStatus.online.toString()) {
      final _getToken = await _fToken();
      _data[DBPath.token] = Secure.encode(_getToken);
    }

    await _getInstance.doc('${DBPath.userCollection}/$currUid').update(_data);
  }

  updateNotificationStatus(bool updatedNotification) async {
    await _getInstance.doc('${DBPath.userCollection}/$currUid').update(
        {DBPath.notification: Secure.encode(updatedNotification.toString())});
  }

  updateParticularConnectionNotificationStatus(
      String connId, bool updatedNotification) async {
    await _getInstance.doc('${DBPath.userCollection}/$currUid').update({
      DBPath.notificationDeactivated: updatedNotification
          ? FieldValue.arrayUnion([Secure.encode(connId)])
          : FieldValue.arrayRemove([Secure.encode(connId)])
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getWallpaperData() async =>
      await _getInstance.collection(DBPath.wallpaperCollection).get();

  updateToken() async {
    if (!await NativeCallback().checkInternet()) return;

    final _getToken = await _fToken();
    await _getInstance
        .doc('${DBPath.userCollection}/$currUid')
        .update({DBPath.token: Secure.encode(_getToken)});
  }

  resetRemoveSpecialRequest() {
    _getInstance
        .doc(
            '${DBPath.userCollection}/$currUid/${DBPath.specialRequest}/${DBPath.removeConn}')
        .set({DBPath.data: []});
  }

  Future<String?> addActivity(Map<String, dynamic> data) async {
    if (data['type'] != ActivityContentType.text.toString()) {
      data["message"] = await uploadMediaToStorage(
          DBHelper.activityPath(
              currUid, data["message"].toString().split("/").last),
          File(data["message"]),
          reference: StorageHelper.activityRef(currUid));
    }

    await _getInstance
        .doc(
            '${DBPath.userCollection}/$currUid/${DBPath.activities}/${DBPath.data}')
        .set({
      DBPath.data: FieldValue.arrayUnion(
          [Secure.encode(DataManagement.toJsonString(data))]),
    }, SetOptions(merge: true));

    return Secure.encode(DataManagement.toJsonString(data));
  }

  Future<bool> deleteParticularActivity(data) async {
    try {
      await _getInstance
          .doc(
              '${DBPath.userCollection}/$currUid/${DBPath.activities}/${DBPath.data}')
          .set({
        DBPath.data: FieldValue.arrayRemove([data]),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }

  deleteForEveryoneMsg(String msgId, String partnerId) async {
    try {
      await _getInstance
          .doc(
              '${DBPath.userCollection}/$partnerId/${DBPath.userConnections}/$currUid/${DBPath.contents}/${DBPath.specialOperation}')
          .set({
        SpecialOperationTypes.deleteMsg: FieldValue.arrayUnion([msgId])
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      debugShow("ERROR in deleteForEveryoneMsg: $e");
      return false;
    }
  }

  deleteSpecialOperationMsgIdSet(partnerId) async {
    try {
      await _getInstance
          .doc(
              '${DBPath.userCollection}/$partnerId/${DBPath.userConnections}/$currUid/${DBPath.contents}/${DBPath.specialOperation}')
          .set({SpecialOperationTypes.deleteMsg: []}, SetOptions(merge: true));

      return true;
    } catch (e) {
      debugShow("ERROR in deleteSpecialOperationMsgIdSet: $e");
      return false;
    }
  }
}

class RealTimeOperations {
  FirebaseFirestore get _getInstance => FirebaseFirestore.instance;

  String get currUid => FirebaseAuth.instance.currentUser?.uid ?? "";

  Stream<QuerySnapshot<Map<String, dynamic>>> getConnectedUsers() =>
      _getInstance
          .collection(
              '${DBPath.userCollection}/$currUid/${DBPath.userConnections}')
          .snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> getReceivedRequestUsers() =>
      _getInstance
          .collection(
              '${DBPath.userCollection}/$currUid/${DBPath.userReceiveRequest}')
          .snapshots();

  Stream<
      DocumentSnapshot<
          Map<String,
              dynamic>>> getChatMessages(String partnerId) => _getInstance
      .doc(
          '${DBPath.userCollection}/$currUid/${DBPath.userConnections}/$partnerId/${DBPath.contents}/${DBPath.messages}')
      .snapshots();

  Stream<
      DocumentSnapshot<
          Map<String,
              dynamic>>> getActivityData(String partnerId) => _getInstance
      .doc(
          '${DBPath.userCollection}/$partnerId/${DBPath.activities}/${DBPath.data}')
      .snapshots();

  Stream<DocumentSnapshot<Map<String, dynamic>>> getConnectionData(
          String partnerId) =>
      _getInstance.doc('${DBPath.userCollection}/$partnerId').snapshots();

  Stream<
      DocumentSnapshot<
          Map<String,
              dynamic>>> getRemoveConnectionRequestData() => _getInstance
      .doc(
          '${DBPath.userCollection}/$currUid/${DBPath.specialRequest}/${DBPath.removeConn}')
      .snapshots();

  Stream<DocumentSnapshot<Map<String, dynamic>>>
      getRealTimeSpecialOperationsData(String partnerId) => _getInstance
          .doc(
              '${DBPath.userCollection}/$currUid/${DBPath.userConnections}/$partnerId/${DBPath.contents}/${DBPath.specialOperation}')
          .snapshots();
}

class MessagingOperation {
  Future<int> sendNotification(
      {required String deviceToken,
      required String title,
      required String body,
      String? image,
      required String connId}) async {
    final String _serverKey =
        DataManagement.getEnvData(EnvFileKey.serverKey) ?? '';

    final Response response = await post(
      Uri.parse(NotifyManagement.sendNotificationUrl),
      headers: NotifyManagement.sendNotificationHeader(_serverKey),
      body: NotifyManagement.bodyData(
          title: title,
          body: body,
          deviceToken: deviceToken,
          image: image,
          connId: connId),
    );

    debugShow('Response is: ${response.statusCode}    ${response.body}');

    return response.statusCode;
  }
}
