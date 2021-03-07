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
                      fontSize: 25.0,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "Logs",
                    style: TextStyle(
                      fontSize: 25.0,
                    ),
                  ),
                ),
                Tab(
                  icon: Icon(Icons.camera_alt_outlined),
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
    return Container(
      margin: EdgeInsets.only(right: 40.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Colors.green,
          width: 1.0,
        ),
      ),
      width: MediaQuery.of(context).size.width / 4,
      height: 10.0,
      //color: Colors.red,
      child: CircleAvatar(
        backgroundImage: ExactAssetImage('images/sam.jpg'),
      ),
    );
  }

  Widget chatList(BuildContext context) {
    return SafeArea(
        child: Container(
      margin: EdgeInsets.only(top: 35.0, bottom: 10.0),
      padding: EdgeInsets.only(top: 18.0, bottom: 5.0),
      height: MediaQuery.of(context).size.height * (5.5 / 8),
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
      // child: ListView.builder(
      //   itemCount: 20,
      //   itemBuilder: (context, position) {
      //     return Card(
      //       child: Text(
      //         "Label is",
      //         style: TextStyle(fontSize: 20.0),
      //       ),
      //       color: Colors.red,
      //     );
      //   },
      // ),
    ));
  }
}
