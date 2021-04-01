import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:generation/FrontEnd/MainScreen/ChatCollection.dart';
import 'package:generation/FrontEnd/MainScreen/applications_section.dart';
import 'package:generation/FrontEnd/MainScreen/LogsCollection.dart';
import 'package:slide_drawer/slide_drawer.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentTab = 0;
  File _image;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            brightness: Brightness.dark,
            elevation: 20.0,
            shadowColor: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40.0),
                  bottomRight: Radius.circular(40.0)),
            ),
            title: Text(
              "Generation",
              style: TextStyle(
                  fontSize: 25.0, fontFamily: 'Lora', letterSpacing: 1.0),
            ),
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                SlideDrawer.of(context).toggle();
              },
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
              indicatorPadding: EdgeInsets.only(left: 20.0, right: 22.0),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: TextStyle(
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0),
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
        fabColor: Color.fromRGBO(0, 230, 150, 1),
        fabOpenIcon: Icon(
          Icons.search_rounded,
          color: Colors.white,
          size: 30.0,
        ),
        fabOpenColor: Color.fromRGBO(192, 192, 240, 1),
        fabIconBorder: CircleBorder(
          side: BorderSide(width: 0.2, color: Colors.black45),
        ),
        fabCloseIcon: Icon(
          Icons.close_outlined,
          color: Colors.red,
          size: 30.0,
        ),
        ringDiameter: 325.0,
        ringWidth: 80.0,
        ringColor: Color.fromRGBO(64, 196, 255, 0.6),
        animationCurve: Curves.easeInOutSine,
        children: [
          IconButton(
              icon: Icon(
                Icons.person_search_rounded,
                size: 50.0,
                color: Color.fromRGBO(16, 24, 255, 1),
              ),
              onPressed: () {
                print('Home');
              }),
          IconButton(
              icon: Icon(
                Icons.settings_voice_sharp,
                size: 50.0,
                color: Color.fromRGBO(16, 24, 255, 1),
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
