import 'package:flutter/material.dart';

class Navigation {
  static void intent(BuildContext context, Widget nextWidget,
      {VoidCallback? afterWork}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => nextWidget))
        .then((value) => {if (afterWork != null) afterWork()});
  }

  static void intentStraight(BuildContext context, Widget nextWidget) {
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => nextWidget), (route) => false);
  }
}
