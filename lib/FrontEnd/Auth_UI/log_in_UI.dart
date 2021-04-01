import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:generation/Backend/email_pwd_auth.dart';
import 'package:generation/FrontEnd/Auth_UI/sign_up_UI.dart';
import 'package:generation/FrontEnd/MainScreen/MainWindow.dart';

class LogInAuthentication extends StatefulWidget {
  @override
  _LogInAuthenticationState createState() => _LogInAuthenticationState();
}

class _LogInAuthenticationState extends State<LogInAuthentication> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _pwdShowPermission;

  TextEditingController _email, _pwd;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pwdShowPermission = true;
    _email = TextEditingController();
    _pwd = TextEditingController();
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
                        decoration: InputDecoration(labelText: "Email"),
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
                      height: 5.0,
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      margin: EdgeInsets.only(right: 15.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          primary: Colors.white12,
                        ),
                        child: Text(
                          "Forget Password ?",
                          style: TextStyle(
                            color: Colors.brown,
                          ),
                        ),
                        onPressed: () {},
                      ),
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
                            "Sign-Up",
                            style: TextStyle(fontSize: 25.0),
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
                            "Log-In",
                            style: TextStyle(fontSize: 25.0),
                          ),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              print("Proceed with Log-In");
                              EmailAndPasswordAuth emailAndPwdAuth =
                                  EmailAndPasswordAuth(context,
                                      this._email.text, this._pwd.text);
                              emailAndPwdAuth.logIn();
                            } else {
                              print("Can't Proceed with Log-In");
                            }
                          },
                        ),
                      ],
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
}
