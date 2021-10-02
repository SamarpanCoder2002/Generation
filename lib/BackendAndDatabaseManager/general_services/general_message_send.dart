import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/encrytion_maker.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:generation/BackendAndDatabaseManager/general_services/notification_configuration.dart';

class GeneralMessage {
  final String sendMessage, storeMessage, sendTime, storeTime;
  final MediaTypes mediaType;
  final List<String> selectedUsersName;
  String extraText;

  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();
  final SendNotification _sendNotification = SendNotification();
  final Management _management = Management();
  final EncryptionMaker _encryptionMaker = EncryptionMaker();

  GeneralMessage(
      {required this.sendMessage,
      required this.storeMessage,
      required this.sendTime,
      required this.storeTime,
      required this.mediaType,
      required this.selectedUsersName,
      this.extraText = ''});

  Future<String> fetchAccountUserName() async {
    final String _accUserName =
        await _localStorageHelper.extractImportantDataFromThatAccount(
            userMail: FirebaseAuth.instance.currentUser!.email.toString());
    return _accUserName;
  }

  Future<void> storeInLocalStorage() async {
    this.selectedUsersName.forEach((everyUser) async {
      await _localStorageHelper.insertNewMessages(
          everyUser,
          this._encryptionMaker.encryptionMaker(this.storeMessage),
          this.mediaType,
          0,
          this._encryptionMaker.encryptionMaker(this.storeTime));
    });
  }

  Future<void> storeInFireStore() async {
    this.selectedUsersName.forEach((everyUser) async {
      final String _connectionToken =
          await _localStorageHelper.extractToken(userName: everyUser);

      final String _userMail = await _localStorageHelper
          .extractImportantDataFromThatAccount(userName: everyUser);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapShot = await FirebaseFirestore.instance
          .doc("generation_users/$_userMail")
          .get();

      /// Initialize Temporary List
      List<dynamic> sendingMessages = [];

      /// Store Updated sending messages list
      sendingMessages = documentSnapShot.data()!['connections']
          [FirebaseAuth.instance.currentUser!.email.toString().toString()];

      /// Add data to temporary Storage of Sending
      sendingMessages.add({
        this._encryptionMaker.encryptionMaker(this.sendMessage):
            this._encryptionMaker.encryptionMaker(this.sendTime),
      });

      /// Data Store in FireStore
      await _management.addConversationMessages(
          _userMail, sendingMessages, documentSnapShot.data()!['connections']);

      /// For Send Notification to Connected User
      if (mediaType == MediaTypes.Text)
        _sendNotification.messageNotificationClassifier(this.mediaType,
            connectionToken: _connectionToken,
            currAccountUserName: await fetchAccountUserName(),
            textMsg: '');
      else
        _sendNotification.messageNotificationClassifier(
          this.mediaType,
          connectionToken: _connectionToken,
          currAccountUserName: await fetchAccountUserName(),
        );
    });
  }
}
