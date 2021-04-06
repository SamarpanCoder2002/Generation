import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:generation/Backend/firebase_services/google_auth.dart';
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

  Future<void> connectionRequestManager(
      int index, QuerySnapshot searchResultSnapshot) async {
    DocumentSnapshot documentSnapShotCurrUser = await FirebaseFirestore.instance
        .collection('generation_users')
        .doc(FirebaseAuth.instance.currentUser.email)
        .get();

    Map<String, dynamic> connectionRequestCollectionCurrUser =
        documentSnapShotCurrUser.get('connection_request');

    Map<String, dynamic> connectionRequestCollectionRequestUser =
        searchResultSnapshot.docs[index]['connection_request'];

    if (!connectionRequestCollectionCurrUser
        .containsKey(searchResultSnapshot.docs[index].id)) {
      connectionRequestCollectionCurrUser.addAll({
        '${searchResultSnapshot.docs[index].id}': "Request Pending",
      });

      print("Add Request User Data to SQLite");

      connectionRequestCollectionRequestUser.addAll({
        '${FirebaseAuth.instance.currentUser.email}': "Invitation Came",
      });

      FirebaseFirestore.instance
          .doc('generation_users/${searchResultSnapshot.docs[index].id}')
          .update({
        'connection_request': connectionRequestCollectionRequestUser,
      });

      FirebaseFirestore.instance
          .doc('generation_users/${FirebaseAuth.instance.currentUser.email}')
          .update({
        'connection_request': connectionRequestCollectionCurrUser,
      });

      print("Updated");
    } else {
      if (searchResultSnapshot.docs[index]['connection_request']
              [FirebaseAuth.instance.currentUser.email] ==
          "Request Pending") {
        Map<String, dynamic> connectionsMapRequestUser =
            searchResultSnapshot.docs[index]['connections'];

        Map<String, dynamic> connectionsMapCurrUser =
            documentSnapShotCurrUser.get('connections');

        connectionRequestCollectionCurrUser.addAll({
          '${searchResultSnapshot.docs[index].id}': "Request Accepted",
        });

        connectionRequestCollectionRequestUser.addAll({
          '${FirebaseAuth.instance.currentUser.email}': "Invitation Accepted",
        });
        print("Add Invited User Data to SQLite");

        connectionsMapRequestUser.addAll({
          '${FirebaseAuth.instance.currentUser.email}': [],
        });

        connectionsMapCurrUser.addAll({
          '${searchResultSnapshot.docs[index].id}': [],
        });

        FirebaseFirestore.instance
            .doc('generation_users/${searchResultSnapshot.docs[index].id}')
            .update({
          'connection_request': connectionRequestCollectionRequestUser,
          'connections': connectionsMapRequestUser,
        });

        FirebaseFirestore.instance
            .doc('generation_users/${FirebaseAuth.instance.currentUser.email}')
            .update({
          'connection_request': connectionRequestCollectionCurrUser,
          'connections': connectionsMapCurrUser,
        });
      }
    }
  }
}
