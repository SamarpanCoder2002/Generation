import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';

import 'package:generation/FrontEnd/MainScreen/ChatCollection.dart';
import 'package:generation/FrontEnd/MainScreen/applications_section.dart';
import 'package:generation/FrontEnd/MainScreen/LogsCollection.dart';
import 'package:generation/FrontEnd/MenuScreen/ProfileScreen.dart';
import 'package:generation/FrontEnd/MenuScreen/SettingsMenu.dart';
import 'package:generation/FrontEnd/Services/search_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Color.fromRGBO(34, 48, 60, 1),
          drawer: Drawer(
            elevation: 10.0,
            child: Container(
              color: Color.fromRGBO(34, 48, 60, 1),
              height: double.maxFinite,
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  IconButton(
                      icon: Icon(Icons.account_box_outlined),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Profile()));
                      }),
                  IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingsWindow()));
                      }),
                  IconButton(
                      icon: Icon(Icons.feedback),
                      onPressed: () {
                        print("Exit Clicked");
                      }),
                  IconButton(
                      icon: Icon(Icons.exit_to_app),
                      onPressed: () {
                        print("Exit Clicked");
                        SystemNavigator.pop();
                      }),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            brightness: Brightness.dark,
            backgroundColor: Color.fromRGBO(25, 39, 52, 1),
            elevation: 10.0,
            shadowColor: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40.0),
                bottomRight: Radius.circular(40.0),
              ),
              side: BorderSide(width: 0.7),
            ),
            title: Text(
              "Generation",
              style: TextStyle(
                  fontSize: 25.0, fontFamily: 'Lora', letterSpacing: 1.0),
            ),
            actions: [
              Container(
                padding: EdgeInsets.only(
                  right: 20.0,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.supervised_user_circle_outlined,
                    size: 25.0,
                  ),
                  onPressed: () {
                    print("New User Add");
                  },
                ),
              )
            ],
            bottom: TabBar(
              indicatorPadding: EdgeInsets.only(left: 20.0, right: 20.0),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 2.0, color: Colors.lightBlue),
                  insets: EdgeInsets.symmetric(horizontal: 15.0)),
              automaticIndicatorColorAdjustment: true,
              labelStyle: TextStyle(
                fontFamily: 'Lora',
                fontWeight: FontWeight.w500,
                letterSpacing: 1.0,
              ),
              onTap: (index) {
                print("\nIndex is: $index");
                setState(() {
                  _currentTab = index;
                });
              },
              tabs: [
                Tab(
                  child: Text(
                    "Chats",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontFamily: 'Lora',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "Logs",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontFamily: 'Lora',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.store,
                    size: 25.0,
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: floatingButton(),
          body: TabBarView(
            children: [
              ChatScreen(),
              ScreenLogs(),
              ApplicationList(),
            ],
          ),
        ));
  }

  Widget floatingButton() {
    if (_currentTab == 0 || _currentTab == 1) {
      return FabCircularMenu(
        fabColor: Color.fromRGBO(20, 200, 50, 1),
        fabOpenIcon: Icon(
          Icons.search_rounded,
          color: Colors.white,
          size: 30.0,
        ),
        fabOpenColor: Color.fromRGBO(200, 20, 50, 1),
        fabIconBorder: CircleBorder(
          side: BorderSide(width: 0.2, color: Colors.black45),
        ),
        fabCloseIcon: Icon(
          Icons.close_outlined,
          color: Colors.white,
          size: 30.0,
        ),
        ringDiameter: 325.0,
        ringWidth: 80.0,
        ringColor: Color.fromRGBO(64, 80, 120, 0.6),
        animationCurve: Curves.easeInOutSine,
        children: [
          IconButton(
              icon: Icon(
                Icons.person_search_rounded,
                size: 50.0,
                color: Color.fromRGBO(255, 24, 255, 1),
              ),
              onPressed: () async {
                print('Search based on Text');
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => Search()));
              }),
          IconButton(
              icon: Icon(
                Icons.settings_voice_sharp,
                size: 50.0,
                color: Color.fromRGBO(255, 24, 255, 1),
              ),
              onPressed: () {
                print('Home');
              }),
        ],
      );
    }
    return null;
  }
}
