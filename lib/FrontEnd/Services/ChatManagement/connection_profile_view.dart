import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ConnectionProfileView extends StatefulWidget {
  final String profileImagePath;
  final String userName;

  ConnectionProfileView(
      {@required this.profileImagePath, @required this.userName});

  @override
  _ConnectionProfileViewState createState() => _ConnectionProfileViewState();
}

class _ConnectionProfileViewState extends State<ConnectionProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
      body: CustomScrollView(slivers: <Widget>[
        _takeSilverAppBar(),
        SliverList(
            delegate: SliverChildListDelegate([
          SizedBox(
            height: 20.0,
          ),
          _mediaAndReportVisibilitySection(name: 'Media Visibility'),
          Divider(
            thickness: 3.0,
            height: 40.0,
            color: Colors.black26,
          ),
          _notificationButtons(),
          Divider(
            thickness: 3.0,
            height: 40.0,
            color: Colors.black26,
          ),
          _generalInformationCenter(),
          Divider(
            thickness: 3.0,
            height: 40.0,
            color: Colors.black26,
          ),
          _mediaAndReportVisibilitySection(name: 'Report a Problem'),
          SizedBox(
            height: 10.0,
          ),
        ]))
      ]),
    );
  }

  Widget _takeSilverAppBar() {
    return SliverAppBar(
      pinned: true,
      brightness: Brightness.dark,
      backgroundColor: const Color.fromRGBO(25, 39, 52, 1),
      automaticallyImplyLeading: false,
      expandedHeight: MediaQuery.of(context).size.height * 0.5,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          left: 0.0,
          bottom: 0.0,
        ),
        title: Container(
          width: MediaQuery.of(context).size.width,
          color: Color.fromRGBO(0, 0, 0, 0.15),
          padding: EdgeInsets.only(left: 20.0, bottom: 16.0),
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.bottomLeft,
          child: Text(
            widget.userName.length <= 17
                ? widget.userName
                : '${widget.userName.replaceRange(17, widget.userName.length, '...')}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ),
        background: widget.profileImagePath != ''
            ? Image.file(
                File(widget.profileImagePath),
                fit: BoxFit.cover,
              )
            : Center(
                child: Text(
                  'No Profile Image Found',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20.0,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _generalInformationCenter() {
    return Column(
      children: [
        _firstPortionInformation('About', 'Sample About'),
        SizedBox(
          height: 30.0,
        ),
        _firstPortionInformation('Join Date', 'Sample Date'),
        SizedBox(
          height: 30.0,
        ),
        _firstPortionInformation('Join Time', 'Sample Time'),
      ],
    );
  }

  Widget _firstPortionInformation(String leftText, String rightText) {
    return Container(
      height: 30.0,
      //color: Colors.green,
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(
                left: 15.0,
              ),
              child: Text(
                leftText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Lora',
                  fontStyle: FontStyle.italic,
                  color: Colors.lightBlue,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: 10.0),
              alignment: Alignment.centerRight,
              child: Text(
                rightText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Lora',
                  fontStyle: FontStyle.italic,
                  color: Colors.green,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _connectionMenuOptions(
            notificationName: 'Background Notification Annotation',
            status: true),
        SizedBox(
          height: 30.0,
        ),
        _connectionMenuOptions(
            notificationName: '   Foreground Notification', status: true),
      ],
    );
  }

  Widget _connectionMenuOptions(
      {@required String notificationName, @required bool status}) {
    return Padding(
      padding: EdgeInsets.only(
        right: 10.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    notificationName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 15.0,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  status ? 'Activated' : 'Deactivated',
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: Text(
                  status ? 'Deactivate' : 'Activate',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                    side: BorderSide(
                      color: Colors.red,
                    ),
                  ),
                ),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mediaAndReportVisibilitySection({@required String name}) {
    return SizedBox(
      height: 50.0,
      child: ElevatedButton(
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              name,
              textAlign: TextAlign.left,
              style: TextStyle(
                color:
                    name == 'Media Visibility' ? Colors.lightBlue : Colors.red,
                fontSize: 16.0,
              ),
            )),
        style: ElevatedButton.styleFrom(
          elevation: 0.0,
          primary: const Color.fromRGBO(34, 48, 60, 1),
        ),
        onPressed: () {},
      ),
    );
  }
}
