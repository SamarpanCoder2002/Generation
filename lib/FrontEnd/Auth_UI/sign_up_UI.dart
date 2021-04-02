import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:generation/Backend/Service/email_pwd_auth.dart';
import 'package:generation/Backend/Service/google_auth.dart';
import 'package:generation/FrontEnd/Auth_UI/log_in_UI.dart';

class SignUpAuthentication extends StatefulWidget {
  @override
  _SignUpAuthenticationState createState() => _SignUpAuthenticationState();
}

class _SignUpAuthenticationState extends State<SignUpAuthentication> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _pwdShowPermission, _confirmPwdShowPermission;

  TextEditingController _email;
  TextEditingController _pwd;
  TextEditingController _confirmPwd;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pwdShowPermission = true;
    _confirmPwdShowPermission = true;

    _email = TextEditingController();
    _pwd = TextEditingController();
    _confirmPwd = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _email.dispose();
    _pwd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: ListView(
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 6,
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
                        decoration: InputDecoration(
                          labelText: "Email",
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
                          decoration: InputDecoration(
                            labelText: "Password",
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
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
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
                            } else if (this._confirmPwd.text != this._pwd.text)
                              return "Password and Confirm Password not Same";
                            return null;
                          }),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 5.0,
                              primary: Colors.amber,
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
                            "Log-in",
                            style: TextStyle(fontSize: 25.0),
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
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 5.0,
                              primary: Colors.green,
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
                            style: TextStyle(fontSize: 25.0),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              print("Proceed with Sign-Up");
                              EmailAndPasswordAuth emailAndPwdAuth =
                                  EmailAndPasswordAuth(context,
                                      this._email.text, this._pwd.text);
                              await emailAndPwdAuth.signUp();
                            } else {
                              print("Can't Proceed with Sign-up");
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Center(
                      child: Text(
                        "OR Log-In With",
                        style: TextStyle(
                          fontSize: 18.0,
                          letterSpacing: 1.0,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 20.0),
                      alignment: Alignment.center,
                      child: GestureDetector(
                        child: Image.asset(
                          'images/gg.png',
                          width: 45.0,
                        ),
                        onTap: () async {
                          await GoogleAuth().logIn(context);
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
    );
  }

  void showAlertBox(String _title, String _content) {
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
}
