import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SupportMenuMaker extends StatefulWidget {
  const SupportMenuMaker({Key key}) : super(key: key);

  @override
  _SupportMenuMakerState createState() => _SupportMenuMakerState();
}

class _SupportMenuMakerState extends State<SupportMenuMaker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Color.fromRGBO(25, 39, 52, 1),
        elevation: 10.0,
        shadowColor: Colors.white70,
        title: Text(
          'Support',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
      ),
      body: Center(),
    );
  }
}
