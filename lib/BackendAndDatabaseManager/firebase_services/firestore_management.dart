import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:generation/BackendAndDatabaseManager/firebase_services/google_auth.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:generation/FrontEnd/Auth_UI/sign_up_UI.dart';

class Management {
  final LocalStorageHelper localStorageHelper = LocalStorageHelper();

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

  void addConversationMessages(String _senderMail, List<dynamic> messageMap) {
    FirebaseFirestore.instance.doc("generation_users/$_senderMail").update({
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

  Future<bool> addTextActivityTextToFireStore(
      String activityText,
      Color selectedBGColor,
      List<String> allConnectionUserName,
      double fontSize) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .doc('generation_users/${FirebaseAuth.instance.currentUser.email}')
        .get();

    Map<String, dynamic> activityCollection =
        documentSnapshot.data()['activity'] as Map;
    List<dynamic> currConnection = activityCollection['My Activity'];

    if (currConnection == null) currConnection = [];

    currConnection.add({
      activityText:
          '${selectedBGColor.red} + ${selectedBGColor.green} + ${selectedBGColor.blue} + ${selectedBGColor.opacity}+$fontSize',
    });

    activityCollection['My Activity'] = currConnection;

    await FirebaseFirestore.instance
        .doc('generation_users/${FirebaseAuth.instance.currentUser.email}')
        .update({
      'activity': activityCollection,
    });

    if (allConnectionUserName.isNotEmpty) {
      try {
        allConnectionUserName.forEach((String connectionUserName) async {
          String _userMail =
              await localStorageHelper.fetchEmail(connectionUserName);

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
      return false;
  }
}
