import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:slide_drawer/slide_drawer.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(length: 3, vsync: this);
  }

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
        )
      ),
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
        elevation: 5.0,
        shadowColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        child: Container(
          padding: EdgeInsets.only(left: 1.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
              onPrimary: Colors.lightBlueAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0))),
            ),
            onPressed: () {
              print("Pressed");
            },
            child: Row(
              children: [
                Container(
                  //color: Colors.green,
                  padding: EdgeInsets.only(
                    top: 3.0,
                    bottom: 3.0,
                  ),
                  child: GestureDetector(
                    child: CircleAvatar(
                      radius: 35.0,
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
                          style: TextStyle(fontSize: 15.0, color: Colors.blue),
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
