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
  TextEditingController _nickName = TextEditingController();
  TextEditingController _about = TextEditingController();

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

      showAlertBox(
          "Sign-Up Successful",
          "A Verification Link Sent to Your Registered Mail....\n\nPlease Verify Your Mail then Log-In",
          Colors.green);
    } catch (e) {
      print("Sign-up Error is: $e");
      if (e.toString() ==
          "[firebase_auth/email-already-in-use] The email address is already in use by another account.")
        showAlertBox(
          "Email Already Registered",
          "Try With Another Email",
          Colors.yellow,
        );
      else
        showAlertBox(
          "Sign-Up Error",
          "Undefine Error Occur... \n\nMake sure your phone Connected to the Internet",
          Colors.redAccent,
        );
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

          showAlertBox("Log-In Successful", "Enjoy this app", Colors.green);
        }
      } else {
        print("Email not Verified");
        FirebaseAuth.instance.signOut();
        showAlertBox(
          "Log-In Error",
          "Email Not Verified...\n\nA Verification Link Sent to Your Registered Mail.\n\nPlease Verify Your Email then Log in",
          Colors.redAccent,
        );
      }
    } catch (e) {
      print("Log-in Error: $e");
      showAlertBox(
          "Log-in Error", "Email or Password not Match", Colors.redAccent);
    }
  }

  void showAlertBox(
    String _title,
    String _content, [
    Color _titleColor = Colors.white,
  ]) {
    showDialog<String>(
        context: this._context,
        builder: (context) => AlertDialog(
              backgroundColor: Color.fromRGBO(34, 48, 60, 0.5),
              title: Text(
                _title,
                style: TextStyle(
                  color: _titleColor,
                ),
              ),
              content: Text(
                _content,
                style: TextStyle(
                  color: Colors.lightBlue,
                ),
              ),
            ));
  }

  Future<void> userNameChecking() async {
    showDialog(
        context: this._context,
        builder: (_) => AlertDialog(
              backgroundColor: Color.fromRGBO(34, 48, 60, 1),
              title: Center(
                child: Text(
                  "Set Additional Details",
                  style: TextStyle(color: Colors.lightBlue),
                ),
              ),
              content: Form(
                key: this._userNameKey,
                child: SizedBox(
                  width: double.maxFinite,
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      TextFormField(
                        controller: _userName,
                        style: TextStyle(color: Colors.white),
                        validator: (inputUserName) {
                          if (inputUserName.length < 6)
                            return "User Name At Least 6 Characters";
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "User Name",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.lightBlue),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        controller: _nickName,
                        style: TextStyle(color: Colors.white),
                        validator: (inputUserName) {
                          if (inputUserName.length < 6)
                            return "Nick Name At Least 6 Characters";
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Nick Name / Public Friendly Name",
                          labelStyle:
                              TextStyle(color: Colors.white70, fontSize: 14.0),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.lightBlue),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        controller: _about,
                        style: TextStyle(color: Colors.white),
                        validator: (inputUserName) {
                          if (inputUserName.length < 6)
                            return "About Should be At Least 6 Characters";
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "About Yourself",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.lightBlue),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
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
                                    .doc(_email)
                                    .set({
                                  'user_name': this._userName.text,
                                  'nick_name': this._nickName.text,
                                  'about': this._about.text,
                                  "creation_date": DateFormat('dd-MM-yyyy')
                                      .format(DateTime.now()),
                                  "creation_time":
                                      "${DateFormat('hh:mm a').format(DateTime.now())}",
                                  "connections": {},
                                });

                                print("Log-In Successful: User Name: $_email");

                                Navigator.pushAndRemoveUntil(
                                    this._context,
                                    MaterialPageRoute(
                                        builder: (_) => MainScreen()),
                                    (route) => false);

                                showAlertBox("Log-In Successful",
                                    "Enjoy this app", Colors.green);
                              } else {
                                Navigator.pop(this._context);
                                showAlertBox("User Name Already Exist",
                                    "Try Another User Name", Colors.yellow);
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
