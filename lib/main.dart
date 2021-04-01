import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:generation/FrontEnd/MainScreen/MainWindow.dart';
import 'package:generation/FrontEnd/Auth_UI/sign_up_UI.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    title: "Generation",
    debugShowCheckedModeBanner: false,
    home: FirebaseAuth.instance.currentUser == null
        ? SignUpAuthentication()
        : MainScreen(),
  ));
}
