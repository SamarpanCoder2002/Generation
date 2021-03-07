import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shrinkchat/MainWindow.dart';
import 'package:slide_drawer/slide_drawer.dart';

void main(){
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SlideDrawer(
        duration: Duration(seconds: 1),
        backgroundGradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.deepPurple, Colors.deepPurpleAccent, Colors.blue, Colors.blueAccent],
        ),
        items: [
          MenuItem('Home', icon: Icons.home, onTap: (){print("Home Clicked");}),
          MenuItem('Project', icon: Icons.work, onTap: (){print("Home Clicked");}),
          MenuItem('Favourite', icon: Icons.live_tv_rounded,  onTap: (){print("Home Clicked");}),
          MenuItem('Profile', icon: Icons.account_box_outlined,  onTap: (){print("Home Clicked");}),
          MenuItem('Setting', icon: Icons.settings,  onTap: (){print("Home Clicked");}),
        ],
        child: MainScreen(),
      ),
    )
  );
}