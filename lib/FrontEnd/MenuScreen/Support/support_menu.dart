import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:generation/BackendAndDatabaseManager/general_services/toast_message_manage.dart';
import 'package:generation/FrontEnd/MenuScreen/Support/problem_report_maker.dart';

class SupportMenuMaker extends StatefulWidget {
  const SupportMenuMaker({Key key}) : super(key: key);

  @override
  _SupportMenuMakerState createState() => _SupportMenuMakerState();
}

class _SupportMenuMakerState extends State<SupportMenuMaker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Color.fromRGBO(25, 39, 52, 1),
        elevation: 10.0,
        shadowColor: Colors.white70,
        title: Text(
          'Support',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
      ),
      body: Container(
        // color: Colors.red,
        alignment: Alignment.topCenter,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            _getListOption(
                icon: Icon(
                  Icons.report_gmailerrorred_outlined,
                  size: 30.0,
                  color: Colors.red,
                ),
                title: 'Report a Problem',
                extraText: 'About App Crashing, Bugs Report'),
            _getListOption(
              icon: Icon(
                Icons.request_page_outlined,
                size: 30.0,
                color: Colors.green,
              ),
              title: 'Request a Feature',
              extraText: 'Any New Feature in your Mind',
            ),
            _getListOption(
              icon: Icon(
                Icons.featured_play_list_outlined,
                size: 30.0,
                color: Colors.amber,
              ),
              title: 'Send Feedback',
              extraText: 'Your Experience of that App',
            ),
            _getListOption(
              icon: Icon(
                Icons.attach_money_outlined,
                size: 30.0,
                color: Colors.green,
              ),
              title: 'Donate',
              extraText: 'Help Generation to Grow More',
            ),
          ],
        ),
      ),
    );
  }

  Widget _getListOption(
      {@required Icon icon,
      @required String title,
      @required String extraText}) {
    return OpenContainer(
      closedColor: const Color.fromRGBO(34, 48, 60, 1),
      middleColor: const Color.fromRGBO(34, 48, 60, 1),
      openColor: const Color.fromRGBO(34, 48, 60, 1),
      closedElevation: 0.0,
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: Duration(
        milliseconds: 500,
      ),
      openBuilder: (_, __) {
        print(title);
        if (title == 'Report a Problem')
          return SupportInputTaker(
            subject: 'Problem',
            appbarTitle: 'Describe Your Problem',
          );
        else if (title == 'Request a Feature')
          return SupportInputTaker(
            subject: 'Feature',
            appbarTitle: 'Describe the Feature',
          );
        else if (title == 'Send Feedback')
          return SupportInputTaker(
            subject: 'Feedback',
            appbarTitle: 'Write Your Feedback',
          );
        else if (title == 'Donate') return WhyDonate();
        return Center();
      },
      closedBuilder: (_, __) {
        return Container(
          height: 80.0,
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            top: 10.0,
            bottom: 10.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 10.0,
                ),
                child: icon,
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18.0,
                        ),
                      ),
                      Text(
                        extraText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WhyDonate extends StatelessWidget {
  final FToast _fToast = FToast();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Center(
              child: Text(
                'Why Donate in Generation?',
                style: TextStyle(color: Colors.amber, fontSize: 20.0),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                "I am Samarpan Dasgupta, the one and only developer of this app. This app has many features but not sufficient to give a better user experience. Being a Single Developer of this app, it's not possible to me to add such amazing features like end-to-end encrypted video calls and more awesome features to give users a better experience. Your small donation can help me to grow Generation and gives you a more personalized experience. Thank you in advance for your donation.",
                textAlign: TextAlign.justify,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18.0,
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                    side: BorderSide(color: Colors.green),
                  ),
                ),
                child: Text(
                  'Donate',
                  style: TextStyle(color: Colors.green, fontSize: 16.0),
                ),
                onPressed: () async {
                  print("Donation Button Pressed");
                  this._fToast.init(context);
                  try {
                    showToast('Please Wait', _fToast,
                        toastColor: Colors.amber,
                        fontSize: 18.0,
                        toastGravity: ToastGravity.TOP);

                    /// Link Added for Live Transaction on RazorPay
                    await launch('');
                  } catch (e) {
                    print(
                        'Payment Gateway Page OnBoarding Error: ${e.toString()}');
                    showToast('Sorry, Donation Section not Opening', _fToast,
                        toastColor: Colors.red,
                        fontSize: 16.0,
                        toastGravity: ToastGravity.TOP);
                  }
                },
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}
