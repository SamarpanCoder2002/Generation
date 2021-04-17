import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:generation/BackendAndDatabaseManager/firebase_services/email_pwd_auth.dart';
import 'package:generation/BackendAndDatabaseManager/firebase_services/google_auth.dart';

import 'package:generation/FrontEnd/Auth_UI/log_in_UI.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SignUpAuthentication extends StatefulWidget {
  @override
  _SignUpAuthenticationState createState() => _SignUpAuthenticationState();
}

class _SignUpAuthenticationState extends State<SignUpAuthentication> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _pwdShowPermission, _confirmPwdShowPermission;

  bool _progressPermission;

  TextEditingController _email;
  TextEditingController _pwd;
  TextEditingController _confirmPwd;

  @override
  void initState() {
    super.initState();
    _pwdShowPermission = true;
    _confirmPwdShowPermission = true;
    _progressPermission = false;

    _email = TextEditingController();
    _pwd = TextEditingController();
    _confirmPwd = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _pwd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 48, 60, 1),
      body: ModalProgressHUD(
        inAsyncCall: _progressPermission,
        color: Color.fromRGBO(0, 0, 0, 0.1),
        progressIndicator: CircularProgressIndicator(
          backgroundColor: Colors.black87,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: ListView(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 10,
                      ),
                      Center(
                        child: Text(
                          "Sign-Up",
                          style: TextStyle(
                            fontSize: 30.0,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 60,
                        child: TextFormField(
                          controller: this._email,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(
                              color: Colors.white70,
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.lightBlue)),
                          ),
                          validator: (inputValue) {
                            RegExp _emailRegex = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                            if (_emailRegex.hasMatch(inputValue)) {
                              return null;
                            }
                            return "Enter Valid Email";
                          },
                        ),
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 60,
                        child: TextFormField(
                            controller: this._pwd,
                            obscureText: _pwdShowPermission,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle: TextStyle(
                                color: Colors.white70,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.lightBlue)),
                              suffixIcon: IconButton(
                                icon: _pwdShowPermission
                                    ? Icon(
                                        Entypo.eye,
                                        color: Colors.redAccent,
                                      )
                                    : Icon(
                                        Entypo.eye_with_line,
                                        color: Colors.green,
                                      ),
                                onPressed: () {
                                  if (_pwdShowPermission) {
                                    setState(() {
                                      _pwdShowPermission = false;
                                    });
                                  } else {
                                    setState(() {
                                      _pwdShowPermission = true;
                                    });
                                  }
                                },
                              ),
                            ),
                            validator: (inputValue) {
                              if ((inputValue.length >= 8)) {
                                return null;
                              }
                              return "Password should be more than or equal to 8 characters";
                            }),
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 60,
                        child: TextFormField(
                            controller: this._confirmPwd,
                            obscureText: _confirmPwdShowPermission,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              labelStyle: TextStyle(
                                color: Colors.white70,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.lightBlue)),
                              suffixIcon: IconButton(
                                icon: _confirmPwdShowPermission
                                    ? Icon(
                                        Entypo.eye,
                                        color: Colors.redAccent,
                                      )
                                    : Icon(
                                        Entypo.eye_with_line,
                                        color: Colors.green,
                                      ),
                                onPressed: () {
                                  if (_confirmPwdShowPermission) {
                                    setState(() {
                                      _confirmPwdShowPermission = false;
                                    });
                                  } else {
                                    setState(() {
                                      _confirmPwdShowPermission = true;
                                    });
                                  }
                                },
                              ),
                            ),
                            validator: (inputValue) {
                              if ((inputValue.length < 8)) {
                                return "Password should be more than or equal to 8 characters";
                              } else if (this._confirmPwd.text !=
                                  this._pwd.text)
                                return "Password and Confirm Password not Same";
                              return null;
                            }),
                      ),
                      SizedBox(
                        height: 50.0,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(
                                MediaQuery.of(context).size.width - 60, 30.0),
                            elevation: 5.0,
                            primary: Color.fromRGBO(57, 60, 80, 1),
                            padding: EdgeInsets.only(
                              left: 20.0,
                              right: 20.0,
                              top: 7.0,
                              bottom: 7.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                            )),
                        child: Text(
                          "Sign-Up",
                          style: TextStyle(
                            fontSize: 25.0,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            print("Proceed with Sign-Up");
                            setState(() {
                              _progressPermission = true;
                            });
                            EmailAndPasswordAuth emailAndPwdAuth =
                                EmailAndPasswordAuth(
                                    context, this._email.text, this._pwd.text);
                            await emailAndPwdAuth.signUp();
                            setState(() {
                              _progressPermission = false;
                            });
                          } else {
                            print("Can't Proceed with Sign-up");
                          }
                        },
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      Center(
                        child: Text(
                          "OR Connect With",
                          style: TextStyle(
                            fontSize: 18.0,
                            letterSpacing: 1.0,
                            color: Color.fromRGBO(87, 255, 51, 1),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20.0),
                        alignment: Alignment.center,
                        child: GestureDetector(
                          child: Image.asset(
                            'assets/images/gg.png',
                            width: 45.0,
                          ),
                          onTap: () async {
                            setState(() {
                              _progressPermission = true;
                            });
                            await GoogleAuth().logIn(context);
                            setState(() {
                              _progressPermission = false;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        width: 300.0,
                        child: ElevatedButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.0,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Text(
                                "Log-In",
                                style: TextStyle(
                                  color: Colors.lightBlueAccent,
                                  fontSize: 13.0,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            primary: Color.fromRGBO(34, 48, 60, 1),
                          ),
                          onPressed: () {
                            print("Log-in Switcher");
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => LogInAuthentication()));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showAlertBox(String _title, String _content) {
    showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
              elevation: 5.0,
              backgroundColor: Color.fromRGBO(34, 48, 60, 0.6),
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
