import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:generation/FrontEnd/MainScreen/MainWindow.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

class GoogleAuth {
  final GlobalKey<FormState> _userNameKey = GlobalKey<FormState>();
  TextEditingController _userName = TextEditingController();

  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> logIn(BuildContext context) async {
    try {
      if (!await googleSignIn.isSignedIn()) {
        final user = await googleSignIn.signIn();
        if (user == null)
          print("Already Signed In");
        else {
          final GoogleSignInAuthentication googleAuth =
              await user.authentication;

          final OAuthCredential oAuthCredential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          final UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(oAuthCredential);

          DocumentSnapshot responseData = await FirebaseFirestore.instance
              .doc("generation_users/${userCredential.user.email}")
              .get();

          print(responseData.exists);

          if (!responseData.exists) {
            print("Email Not Present");
            await userNameChecking(context, userCredential.user.email);
          } else {
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => MainScreen()));

            showAlertBox(context, "Log-In Successful", "Enjoy this app");
          }
        }
      } else {
        print("Already Logged In");
        await logOut();
      }
    } catch (e) {
      print("Google LogIn Error: ${e.toString()}");
      showAlertBox(context, "Log In Error",
          "Log-in not Completed or\nEmail Already Present With Other Credentials");
    }
  }

  Future<bool> logOut() async {
    try {
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
      FirebaseAuth.instance.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  void showAlertBox(BuildContext context, String _title, String _content) {
    showDialog<String>(
        context: context,
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

  Future<void> userNameChecking(BuildContext context, String _email) async {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text("Set User Name"),
              content: Form(
                key: this._userNameKey,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 5,
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
                                    .doc(_email)
                                    .set({
                                  'user_name': this._userName.text,
                                  "creation_date": DateFormat('dd-MM-yyyy')
                                      .format(DateTime.now()),
                                  "creation_time":
                                      "${DateFormat('hh:mm a').format(DateTime.now())}",
                                  "connections": {},
                                });

                                print("Log-In Successful: User Name: $_email");

                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => MainScreen()),
                                    (route) => false);

                                showAlertBox(context, "Log-In Successful",
                                    "Enjoy this app");
                              } else {
                                Navigator.pop(context);
                                showAlertBox(context, "User Name Already Exist",
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
