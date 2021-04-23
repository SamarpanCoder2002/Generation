import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:generation_official/BackendAndDatabaseManager/firebase_services/email_pwd_auth.dart';
import 'package:generation_official/FrontEnd/Auth_UI/sign_up_UI.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LogInAuthentication extends StatefulWidget {
  @override
  _LogInAuthenticationState createState() => _LogInAuthenticationState();
}

class _LogInAuthenticationState extends State<LogInAuthentication> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RegExp _emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  bool _pwdShowPermission;
  bool _progressPermission;

  TextEditingController _email, _pwd;

  @override
  void initState() {
    super.initState();
    _pwdShowPermission = true;
    _progressPermission = false;

    _email = TextEditingController();
    _pwd = TextEditingController();
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
        color: Color.fromRGBO(0, 0, 0, 0.1),
        inAsyncCall: _progressPermission,
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
                        height: MediaQuery.of(context).size.height / 4,
                      ),
                      Center(
                        child: Text(
                          "Log-In",
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
                          style: TextStyle(color: Colors.white),
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
                            style: TextStyle(color: Colors.white),
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
                        height: 5.0,
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(right: 15.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            primary: Color.fromRGBO(34, 48, 60, 1),
                          ),
                          child: Text(
                            "Forgot Password ?",
                            style: TextStyle(
                              color: Color.fromRGBO(255, 87, 51, 1),
                            ),
                          ),
                          onPressed: () {
                            if (_emailRegex.hasMatch(this._email.text)) {
                              FirebaseAuth.instance.sendPasswordResetEmail(
                                  email: this._email.text);
                              showAlertBox(
                                  "Email Reset Link Send",
                                  "Check Your Email.....\nPassword Must be At Least 8 Characters",
                                  Colors.green);
                            } else
                              showAlertBox(
                                "Not a Email Format",
                                "Please Give a valid Email",
                                Colors.redAccent,
                              );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 30.0,
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
                          "Log-In",
                          style: TextStyle(
                            fontSize: 25.0,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            print("Proceed with Log-In");
                            setState(() {
                              _progressPermission = true;
                            });
                            EmailAndPasswordAuth emailAndPwdAuth =
                                EmailAndPasswordAuth(
                                    context, this._email.text, this._pwd.text);
                            await emailAndPwdAuth.logIn();
                            setState(() {
                              _progressPermission = false;
                            });
                          } else {
                            print("Can't Proceed with Log-In");
                          }
                        },
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      SizedBox(
                        width: 250.0,
                        child: ElevatedButton(
                          child: Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.0,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Text(
                                "Sign-Up",
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
                            print("Sign-Up Switcher");
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SignUpAuthentication()));
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

  void showAlertBox(String _title, String _content,
      [Color _titleColor = Colors.white]) {
    showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Color.fromRGBO(34, 48, 60, 0.6),
              title: Text(
                _title,
                style: TextStyle(color: _titleColor),
              ),
              content: Text(
                _content,
                style: TextStyle(
                  color: Colors.lightBlue,
                  letterSpacing: 1.0,
                ),
              ),
            ));
  }
}
