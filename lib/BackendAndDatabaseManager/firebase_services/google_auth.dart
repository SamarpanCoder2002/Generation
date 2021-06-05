import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/encrytion_maker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:generation/FrontEnd/MainScreen/MainWindow.dart';
import 'package:generation/BackendAndDatabaseManager/general_services/toast_message_manage.dart';

class GoogleAuth {
  /// Regular Expression
  final RegExp _messageRegex = RegExp(r'[a-zA-Z0-9]');

  final GlobalKey<FormState> _userNameKey = GlobalKey<FormState>();
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _about = TextEditingController();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();
  final EncryptionMaker _encryptionMaker = EncryptionMaker();

  final FToast _fToast = FToast();

  Future<void> logIn(BuildContext context) async {
    try {
      if (!await googleSignIn.isSignedIn()) {
        final user = await googleSignIn.signIn();
        if (user == null)
          print("Google Sign In Not Completed");
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

          // if (responseData.exists)
          //   await FirebaseFirestore.instance
          //       .doc(
          //           'generation_users/${FirebaseAuth.instance.currentUser.email}')
          //       .delete();
          //
          // print("Email Not Present");
          // await userNameChecking(context, userCredential.user.email);

          if (!responseData.exists) {
            print("Email Not Present");
          } else {
            await FirebaseFirestore.instance
                .doc(
                    'generation_users/${FirebaseAuth.instance.currentUser.email}')
                .delete()
                .onError((e, stackTrace) => print(
                    'In Google Auth Delete User Old Profile from Database Error: ${e.toString()}'));
          }

          await userNameChecking(context, userCredential.user.email);
        }
      } else {
        print("Already Logged In");
        await logOut();
      }
    } catch (e) {
      print("Google LogIn Error: ${e.toString()}");
      showAlertBox(
          context,
          "Log In Error",
          "Log-in not Completed or\nEmail Already Present With Other Credentials\n\nIf You are trying after Delete My Account,\nplease close the app even from background\nand try to log-in again",
          Colors.redAccent);
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

  void showAlertBox(BuildContext context, String _title, String _content,
      [Color _titleColor = Colors.white]) {
    showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
              elevation: 5.0,
              backgroundColor: Color.fromRGBO(34, 48, 60, 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
              title: Text(
                _title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _titleColor,
                  fontSize: 18.0,
                ),
              ),
              content: Text(
                _content,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.lightBlue,
                  fontSize: 16.0,
                ),
              ),
            ));
  }

  Future<void> userNameChecking(BuildContext context, String _email) async {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              elevation: 5.0,
              backgroundColor: Color.fromRGBO(34, 48, 60, 0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
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
                        autofocus: true,
                        controller: _userName,
                        style: TextStyle(color: Colors.white),
                        validator: (inputUserName) {
                          if (inputUserName.length < 6)
                            return "User Name At Least 6 Characters";
                          else if (inputUserName.contains(' ') ||
                              inputUserName.contains('@'))
                            return "Space and '@' Not Allowed...User '_' instead of space";
                          else if (inputUserName.contains('__'))
                            return "'__' Not Allowed...User '_' instead of '__'";
                          else if (!_messageRegex.hasMatch(inputUserName))
                            return "Sorry,Only Emoji Not Supported";
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
                        child: TextButton(
                          style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0),
                            side: BorderSide(
                              color: Colors.green,
                            ),
                          )),
                          child: Text(
                            "Save",
                            style:
                                TextStyle(fontSize: 18.0, color: Colors.green),
                          ),
                          onPressed: () async {
                            if (_userNameKey.currentState.validate()) {
                              print("ok");

                              /// Hide Keyboard
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');

                              /// Flutter Toast Initialization and show
                              _fToast.init(context);
                              showToast(
                                'Wait, We Creating Your Account',
                                _fToast,
                                fontSize: 18.0,
                                toastColor: Colors.amber,
                                toastGravity: ToastGravity.TOP,
                              );

                              final QuerySnapshot
                                  querySnapShotForUserNameChecking =
                                  await FirebaseFirestore.instance
                                      .collection('generation_users')
                                      .where('user_name',
                                          isEqualTo: this._userName.text)
                                      .get();

                              print(querySnapShotForUserNameChecking.docs);

                              if (querySnapShotForUserNameChecking
                                  .docs.isEmpty) {
                                final String _getToken =
                                    await FirebaseMessaging.instance.getToken();

                                final String currDate = DateFormat('dd-MM-yyyy')
                                    .format(DateTime.now());

                                final String currTime =
                                    "${DateFormat('hh:mm a').format(DateTime.now())}";

                                FirebaseFirestore.instance
                                    .collection("generation_users")
                                    .doc(_email)
                                    .set({
                                  'user_name': _encryptionMaker
                                      .encryptionMaker(this._userName.text),
                                  'about': _encryptionMaker
                                      .encryptionMaker(this._about.text),
                                  'connection_request': {},
                                  'creation_date': _encryptionMaker
                                      .encryptionMaker(currDate),
                                  'creation_time': _encryptionMaker
                                      .encryptionMaker(currTime),
                                  'connections': {},
                                  'total_connections':
                                      _encryptionMaker.encryptionMaker('0'),
                                  'activity': {},
                                  'token': _encryptionMaker
                                      .encryptionMaker(_getToken),
                                  'profile_pic': '',
                                  'phone_number': '',
                                });

                                await _localStorageHelper
                                    .createTableForStorePrimaryData();

                                await _localStorageHelper
                                    .insertOrUpdateDataForThisAccount(
                                  userMail:
                                      FirebaseAuth.instance.currentUser.email,
                                  userName: this._userName.text,
                                  userToken: _getToken,
                                  userAbout: this._about.text,
                                  userAccCreationDate: currDate,
                                  userAccCreationTime: currTime,
                                );

                                await _localStorageHelper
                                    .createTableForUserActivity(
                                        this._userName.text);

                                await _localStorageHelper
                                    .createTableForRemainingLinks();

                                await _localStorageHelper
                                    .createTableForNotificationGlobalConfig();
                                await _localStorageHelper
                                    .insertDataForNotificationGlobalConfig();

                                print("Log-In Successful: User Name: $_email");

                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => MainScreen()),
                                    (route) => false);

                                showAlertBox(context, "Log-In Successful",
                                    "Enjoy this app", Colors.green);
                              } else {
                                showAlertBox(context, "User Name Already Exist",
                                    "Try Another User Name", Colors.amber);
                              }
                            } else {
                              print("Not Validate");
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }
}
