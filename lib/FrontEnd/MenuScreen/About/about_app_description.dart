import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'About Generation',
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: 20.0, left: 20.0, right: 20.0, top: 10.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "A Private, Secure, End-to-End Encrypted Messaging app that helps you to connect with your connections without any Ads, promotion. No other third party person, organization, or even Generation Team can't read your messages. Nobody can't take screenshot or can't do screen recording of this app.",
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.white70, fontSize: 16.0),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: 20.0, left: 20.0, right: 20.0, top: 10.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Alert:  If you registered your mobile number and if any connection will call you, your number will visible in their call Logs.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.redAccent, fontSize: 16.0),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: 20.0, left: 20.0, right: 20.0, top: 10.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Messages and Activity except Audio Calling\nare End-to-End Encrypted',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.amber, fontSize: 16.0),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: 20.0, left: 20.0, right: 20.0, top: 30.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Hope You Enjoying this app',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.lightBlue, fontSize: 18.0),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: 20.0, left: 20.0, right: 20.0, top: 50.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Creator\nSamarpan Dasgupta',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.lightBlue, fontSize: 18.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
