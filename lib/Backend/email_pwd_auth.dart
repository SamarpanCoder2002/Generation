import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:generation/FrontEnd/Auth_UI/log_in_UI.dart';
import 'package:generation/FrontEnd/MainScreen/MainWindow.dart';

class EmailAndPasswordAuth {
  String _email, _pwd;
  BuildContext _context;

  EmailAndPasswordAuth([this._context, this._email, this._pwd]) {
    //Close the keyboard
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  Future<void> signUp() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: this._email, password: this._pwd);
      userCredential.user.sendEmailVerification();

      FirebaseAuth.instance.signOut();

      Navigator.pop(this._context);
      Navigator.push(this._context,
          MaterialPageRoute(builder: (_) => LogInAuthentication()));

      showAlertBox("Sign-Up Successful",
          "A Verification Link Sent to Your Registered Mail....\nPlease Verify Your Mail and Log-In");
    } catch (e) {
      print("Sign-up Error is: $e");
      if (e.toString() ==
          "[firebase_auth/email-already-in-use] The email address is already in use by another account.")
        showAlertBox("Email Already Registered", "Try With Another Email");
      else
        showAlertBox("Sign-Up Error",
            "Undefine Error Occur... \nMake sure your phone Connected to the Internet");
    }
  }

  Future<void> logIn() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: this._email, password: this._pwd);

      if (userCredential.user.emailVerified) {
        Navigator.pop(this._context);
        Navigator.push(
            this._context, MaterialPageRoute(builder: (_) => MainScreen()));

        showAlertBox("Log-In Successful", "Enjoy this app");
      } else {
        print("Email not Verified");
        FirebaseAuth.instance.signOut();
        showAlertBox("Log-In Error",
            "Email Not Verified...\nA Verification Link Sent to Your Registered Mail.\nPlease Verify Your Email then Log in");
      }
    } catch (e) {
      print("Log-in Error: $e");
      showAlertBox("Log-in Error", "Email or Password not Matched");
    }
  }

  void showAlertBox(String _title, String _content) {
    showDialog<String>(
        context: this._context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.black54,
              title: Text(
                _title,
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                _content,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ));
  }


}
