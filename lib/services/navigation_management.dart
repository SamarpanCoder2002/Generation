import 'package:flutter/material.dart';

class Navigation {
  static void intent(BuildContext context, Widget nextWidget) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => nextWidget));
  }
}
