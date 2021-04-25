import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:generation_official/FrontEnd/MainScreen/MainWindow.dart';
import 'package:generation_official/FrontEnd/Auth_UI/sign_up_UI.dart';
import 'package:generation_official/BackendAndDatabaseManager/firebase_services/google_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: false);
  await Firebase.initializeApp();

  runApp(MaterialApp(
    title: "Generation",
    debugShowCheckedModeBanner: false,
    home: await differentContext(),
  ));
}

Future<Widget> differentContext() async {
  if (FirebaseAuth.instance.currentUser == null) return SignUpAuthentication();

  try {
    DocumentSnapshot responseData = await FirebaseFirestore.instance
        .doc("generation_users/${FirebaseAuth.instance.currentUser.email}")
        .get();

    print(responseData.exists);

    if (!responseData.exists) {
      print("Log-Out Event");
      bool response = await GoogleAuth().logOut();

      if (!response) FirebaseAuth.instance.signOut();
      return SignUpAuthentication();
    }
    return MainScreen();
  } catch (e) {
    print("Starting Error is: $e");
    return SignUpAuthentication();
  }
}
