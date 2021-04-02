import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:generation/FrontEnd/MainScreen/MainWindow.dart';
import 'package:generation/FrontEnd/Auth_UI/sign_up_UI.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Backend/Service/google_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    title: "Generation",
    debugShowCheckedModeBanner: false,
    home: await differentContext(),
  ));
}

Future<Widget> differentContext() async {
  if (FirebaseAuth.instance.currentUser == null) return SignUpAuthentication();

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
}
