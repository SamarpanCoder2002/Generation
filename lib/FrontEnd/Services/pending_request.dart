import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PendingConnections extends StatefulWidget {
  @override
  _PendingConnectionsState createState() => _PendingConnectionsState();
}

class _PendingConnectionsState extends State<PendingConnections> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 48, 60, 1),
      body: Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ListView(
          shrinkWrap: true,

        ),
      ),
    );
  }
}
