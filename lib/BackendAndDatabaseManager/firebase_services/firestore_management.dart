import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:generation/BackendAndDatabaseManager/firebase_services/google_auth.dart';
import 'package:generation/FrontEnd/Auth_UI/sign_up_UI.dart';

class Management {
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

  void addConversationMessages(
      String _senderMail, List<dynamic> messageMap) {
    FirebaseFirestore.instance.doc("generation_users/$_senderMail").update({
      'connections': {
        '${FirebaseAuth.instance.currentUser.email}': messageMap,
      }
    });
  }

  Stream<DocumentSnapshot> getDatabaseData() {
    var take = FirebaseFirestore.instance
        .doc('generation_users/${FirebaseAuth.instance.currentUser.email}')
        .snapshots();
    return take;
  }
}
