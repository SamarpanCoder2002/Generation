import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:generation/FrontEnd/Auth_UI/sign_up_UI.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  _IntroductionScreenState createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
      body: Align(
        alignment: Alignment.center,
        child: ListView(
          shrinkWrap: true,
          children: [
            Center(
              child: CircleAvatar(
                radius: 70,
                backgroundImage: ExactAssetImage('assets/logo/logo.png'),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Center(
              child: Text(
                'Generation',
                style: TextStyle(color: Colors.white, fontSize: 25.0),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                "A Private, Secure, End-to-End Encrypted Messaging app that helps you to connect with your connections without any Ads, promotion. No other third party person, organization, or even Generation Team can't read your messages.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  "Your Privacy our biggest priority.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.amber, fontSize: 16.0),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                        side: BorderSide(color: Colors.green)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      'Get Started',
                      style: TextStyle(color: Colors.green, fontSize: 18.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => SignUpAuthentication()));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
