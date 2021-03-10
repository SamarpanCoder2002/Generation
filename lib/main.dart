import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shrinkchat/FrontEnd/MainScreen/MainWindow.dart';
import 'package:shrinkchat/FrontEnd/MenuList/ProfileScreen.dart';
import 'package:shrinkchat/FrontEnd/MenuList/SettingsMenu.dart';
import 'package:slide_drawer/slide_drawer.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Settings(),
  ));
}

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return SlideDrawer(
      duration: Duration(seconds: 1),
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.deepPurple,
          Colors.deepPurpleAccent,
          Colors.blue,
          Colors.blueAccent
        ],
      ),
      items: [
        MenuItem('Home', icon: Icons.home, onTap: () {
          print("Home Clicked");
        }),
        MenuItem('Project', icon: Icons.work, onTap: () {
          print("Home Clicked");
        }),
        MenuItem('Favourite', icon: Icons.live_tv_rounded, onTap: () {
          print("Home Clicked");
        }),
        MenuItem('Profile', icon: Icons.account_box_outlined, onTap: () {
         Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
        }),
        MenuItem('Setting', icon: Icons.settings, onTap: () {
          //SettingChange();
          print("Settings Clicked");
          Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsWindow()));
        }),
      ],
      child: MainScreen(),
    );
  }
}
