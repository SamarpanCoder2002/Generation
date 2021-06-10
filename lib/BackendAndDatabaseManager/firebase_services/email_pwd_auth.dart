import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/encrytion_maker.dart';
import 'package:intl/intl.dart';

import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:generation/FrontEnd/Auth_UI/log_in_UI.dart';
import 'package:generation/FrontEnd/MainScreen/main_window.dart';
import 'package:generation/BackendAndDatabaseManager/general_services/toast_message_manage.dart';

class EmailAndPasswordAuth {
  String _email, _pwd;
  BuildContext _context;

  /// Regular Expression
  final RegExp _messageRegex = RegExp(r'[a-zA-Z0-9]');

  final GlobalKey<FormState> _userNameKey = GlobalKey<FormState>();
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();
  final EncryptionMaker _encryptionMaker = EncryptionMaker();

  TextEditingController _userName = TextEditingController();
  TextEditingController _about = TextEditingController();

  final FToast _fToast = FToast();

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

        // if (responseData.exists)
        //   await FirebaseFirestore.instance
        //       .doc(
        //           'generation_users/${FirebaseAuth.instance.currentUser.email}')
        //       .delete();
        //
        // print("Email Not Present");
        // await userNameChecking();

        if (!responseData.exists) {
          print("Email Not Present");
        } else {
          await FirebaseFirestore.instance
              .doc(
                  'generation_users/${FirebaseAuth.instance.currentUser.email}')
              .delete()
              .onError((e, stackTrace) => print(
                  'In Email-Password Auth Delete User Old Profile from Database Error: ${e.toString()}'));
        }

        await userNameChecking(_context);
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

  Future<void> userNameChecking(BuildContext context) async {
    showDialog(
        context: this._context,
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

                              QuerySnapshot querySnapShotForUserNameChecking =
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
                                    this._context,
                                    MaterialPageRoute(
                                        builder: (_) => MainScreen()),
                                    (route) => false);

                                showAlertBox("Log-In Successful",
                                    "Enjoy this app", Colors.green);
                              } else {
                                showAlertBox("User Name Already Exist",
                                    "Try Another User Name", Colors.amber);
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
