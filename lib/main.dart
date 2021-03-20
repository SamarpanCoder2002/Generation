import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:generation/FrontEnd/MainScreen/MainWindow.dart';
import 'package:generation/FrontEnd/MenuScreen/ProfileScreen.dart';
import 'package:generation/FrontEnd/MenuScreen/SettingsMenu.dart';
import 'package:slide_drawer/slide_drawer.dart';

void main() {
  runApp(MaterialApp(
    title: "Generation",
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
      duration: Duration(milliseconds: 800),
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
        MenuItem('Profile', icon: Icons.account_box_outlined, onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Profile()));
        }),
        MenuItem('Setting', icon: Icons.settings, onTap: () {
          //SettingChange();
          print("Settings Clicked");
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SettingsWindow()));
        }),
        MenuItem('Feedback', icon: Icons.feedback, onTap: () {
          print("Feedback Clicked");
        }),
        MenuItem('Exit', icon: Icons.exit_to_app, onTap: () {
          print("Exit Clicked");
          SystemNavigator.pop();
        }),
      ],
      child: MainScreen(),
    );
  }
}
