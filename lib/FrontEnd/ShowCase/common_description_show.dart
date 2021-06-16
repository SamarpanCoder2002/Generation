import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void notificationDescription(
    {@required String title, @required String content, @required BuildContext context}) {
  showModalBottomSheet(
      backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
      elevation: 5.0,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40.0), topRight: Radius.circular(40.0)),
      ),
      context: context,
      builder: (_) => Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * (1/5),
        padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.amber, fontSize: 18.0),
              ),
            ),
            SizedBox(height: 10.0,),
            Center(
              child: Text(
                content,
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
            SizedBox(height: 10.0,),
          ],
        ),
      ));
}