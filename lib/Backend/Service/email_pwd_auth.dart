import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:generation/FrontEnd/Auth_UI/log_in_UI.dart';
import 'package:generation/FrontEnd/MainScreen/MainWindow.dart';
import 'package:intl/intl.dart';

class EmailAndPasswordAuth {
  String _email, _pwd;
  BuildContext _context;
  final GlobalKey<FormState> _userNameKey = GlobalKey<FormState>();
  TextEditingController _userName = TextEditingController();

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
        DocumentSnapshot responseData = await FirebaseFirestore.instance
            .doc("generation_users/${userCredential.user.email}")
            .get();

        print(responseData.exists);

        if (!responseData.exists) {
          print("Email Not Present");
          await userNameChecking();
        } else {
          Navigator.pop(this._context);
          Navigator.push(
              this._context, MaterialPageRoute(builder: (_) => MainScreen()));

          showAlertBox("Log-In Successful", "Enjoy this app");
        }
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

  Future<void> userNameChecking() async {
    showDialog(
        context: this._context,
        builder: (_) => AlertDialog(
              title: Text("Set User Name"),
              content: Form(
                key: this._userNameKey,
                child: SizedBox(
                  height: MediaQuery.of(this._context).size.height / 5,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          controller: _userName,
                          validator: (inputUserName) {
                            if (inputUserName.length < 6)
                              return "User Name At Least 6 Characters";
                            else if (inputUserName.contains('@')) {
                              return "@ Can't Consider in User Name";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "User Name",
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              )),
                          child: Text(
                            "Save",
                            style:
                                TextStyle(fontSize: 18.0, color: Colors.white),
                          ),
                          onPressed: () async {
                            if (_userNameKey.currentState.validate()) {
                              print("ok");

                              QuerySnapshot querySnapShot =
                                  await FirebaseFirestore.instance
                                      .collection('generation_users')
                                      .where('user_name',
                                          isEqualTo: this._userName.text)
                                      .get();
                              print(querySnapShot.docs.isEmpty);

                              if (querySnapShot.docs.isEmpty) {
                                FirebaseFirestore.instance
                                    .collection("generation_users")
                                    .doc(this._email)
                                    .set({
                                  'user_name': this._userName.text,
                                  "creation_date": DateFormat('dd-MM-yyyy')
                                      .format(DateTime.now()),
                                  "creation_time":
                                      "${DateTime.now().hour}:${DateTime.now().minute}",
                                });

                                Navigator.pushAndRemoveUntil(
                                    this._context,
                                    MaterialPageRoute(
                                        builder: (_) => MainScreen()),
                                    (route) => false);

                                showAlertBox(
                                    "Log-In Successful", "Enjoy this app");
                              } else {
                                Navigator.pop(this._context);
                                showAlertBox("User Name Already Exist",
                                    "Try Another User Name");
                              }
                            } else {
                              print("Not Validate");
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ));
  }
}
