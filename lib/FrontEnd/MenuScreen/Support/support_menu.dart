import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
              extraText: 'About Any New Feature in your Mind',
            ),
            _getListOption(
              icon: Icon(
                Icons.featured_play_list_outlined,
                size: 30.0,
                color: Colors.amber,
              ),
              title: 'Send Feedback',
              extraText: 'About Your Experience of that App',
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
      transitionDuration: Duration(milliseconds: 500,),
      openBuilder: (_, __) {
        print(title);
        if(title == 'Report a Problem')
          return ProblemMaker();
        return Center();
      },
      closedBuilder: (_, __) {
        return Container(
          height: 80.0,
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
              SizedBox(
                width: 30.0,
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
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
