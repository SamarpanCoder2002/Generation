import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ColorModeChange{
  Color appBarColor, bgColor, everyChatColor, chatBgColor;

  ColorModeChange(){
    lightMode();
  }


  void lightMode(){
     appBarColor = Colors.blue;
     bgColor = Colors.white24;
     everyChatColor = Colors.white;
     chatBgColor = Colors.white;
  }
  void darkMode(){
    appBarColor = Colors.black45;
    bgColor = Colors.black45;
    everyChatColor = Colors.black45;
    chatBgColor = Colors.black45;
  }

}