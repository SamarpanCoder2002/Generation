import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:generation/FrontEnd/Auth_UI/log_in_UI.dart';

class SignUpAuthentication extends StatefulWidget {
  @override
  _SignUpAuthenticationState createState() => _SignUpAuthenticationState();
}

class _SignUpAuthenticationState extends State<SignUpAuthentication> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
                          decoration: InputDecoration(labelText: "Password"),
                          validator: (inputValue) {
                            if ((inputValue.length >= 8)) {
                              return null;
                            }
                            return "Password should be more than or equal to 8 characters";
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
                                    builder: (context) =>
                                        LogInAuthentication()));
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
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              print("Proceed with Sign-Up");
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
                          // print("Google Sign in Tapped");
                          // var _gAuth = GoogleAuthenticate(context);
                          // await _gAuth.loginViaGoogle();
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
}
