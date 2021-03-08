import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:slide_drawer/slide_drawer.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            elevation: 20.0,
            shadowColor: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40.0),
                  bottomRight: Radius.circular(40.0)),
            ),
            title: Text(
              "ShrinkChat",
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
              //controller: _tabController,
              indicatorPadding: EdgeInsets.only(left: 20.0, right: 22.0),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: TextStyle(
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0),
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
                    Icons.camera_alt_outlined,
                    size: 25.0,
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FabCircularMenu(
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
            fabCloseIcon: Icon(Icons.close_outlined, color: Colors.red, size:30.0,),
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
                    color:Color.fromRGBO(16, 24, 255, 1),
                  ),
                  onPressed: () {
                    print('Home');
                  }),
            ],
          ),
          body: TabBarView(
            children: [
              chatScreen(context),
              Container(),
              Container(),
            ],
          ),
        ));
  }

  Widget chatScreen(BuildContext context) {
    return ListView(
      children: [
        statusBarContainer(context),
        chatList(context),
      ],
    );
  }

  Widget statusBarContainer(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 23.0,
        left: 5.0,
        right: 5.0,
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * (1 / 8),
      //color: Colors.greenAccent,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, position) {
          return statusList(context);
        },
      ),
    );
  }

  Widget statusList(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: Colors.white24,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(80),
          )),
      onPressed: () {
        print("Status Image Clicked");
      },
      child: CircleAvatar(
        radius: 50.0,
        backgroundImage: ExactAssetImage('images/sam.jpg'),
      ),
    );
  }

  Widget chatList(BuildContext context) {
    return SafeArea(
        child: Container(
      margin: EdgeInsets.only(top: 35.0, bottom: 10.0),
      padding: EdgeInsets.only(top: 18.0, bottom: 5.0),
      height: MediaQuery.of(context).size.height * (5.15 / 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            spreadRadius: 0.0,
            offset: Offset(0.0, -5.0), // shadow direction: bottom right
          )
        ],
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40.0), topRight: Radius.circular(40.0)),
        border: Border.all(
          color: Colors.black26,
          width: 1.0,
        ),
      ),
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, position) {
          return chatTile(context);
        },
      ),
    ));
  }

  Widget chatTile(BuildContext context) {
    return Card(
        child: Container(
      padding: EdgeInsets.only(left: 1.0, right: 1.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          onPrimary: Colors.lightBlueAccent,
        ),
        onPressed: () {
          print("Pressed");
        },
        child: Row(
          children: [
            Container(
              //color: Colors.green,
              padding: EdgeInsets.only(
                top: 5.0,
                bottom: 5.0,
              ),
              child: GestureDetector(
                child: CircleAvatar(
                  radius: 30.0,
                  backgroundImage: ExactAssetImage("images/sam.jpg"),
                ),
                onTap: () {
                  print("Pic Pressed");
                },
              ),
            ),
            Container(
              //color: Colors.redAccent,
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width / 2 + 20,
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: Column(
                children: [
                  Text(
                    "Samarpan Dasgupta",
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 12.0,
                  ),
                  Container(
                    //color: Colors.blueGrey,
                    //padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      "New Message Alert",
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black45,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                //color: Colors.deepPurpleAccent,
                padding: EdgeInsets.only(
                  right: 20.0,
                  top: 2.0,
                  bottom: 2.0,
                ),
                child: Column(
                  children: [
                    Container(
                        child: Text(
                      "12:00",
                      style: TextStyle(fontSize: 12.0, color: Colors.blue),
                    )),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      child: Icon(
                        Icons.surround_sound,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
