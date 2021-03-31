import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_switch/flutter_switch.dart';

class SettingsWindow extends StatefulWidget {
  @override
  _SettingsWindowState createState() => _SettingsWindowState();
}

class _SettingsWindowState extends State<SettingsWindow> {
  bool _colorModeStatus = false, _notificationState = false, _lockState = false;
  Icon _lastSeenIcons = Icon(
    Icons.done_rounded,
    color: Colors.lightGreenAccent,
    size: 40.0,
  );
  bool _rightIcon = true, _index = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(
            fontSize: 23.0,
            fontFamily: 'Lora',
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(bottom: 20.0),
        //color: Colors.lightBlueAccent,
        child: ListView(
          children: <Widget>[
            Container(
              //color: Colors.red,
              height: MediaQuery.of(context).size.height * (1 / 8),
              child: rowsTheme(
                  context,
                  "Theme",
                  "Dark",
                  "Light",
                  Colors.purpleAccent[100],
                  Colors.lightBlueAccent,
                  Icons.nights_stay_rounded,
                  Icons.wb_sunny_sharp,
                  Colors.purpleAccent,
                  Colors.deepPurpleAccent,
                  Colors.yellowAccent,
                  Colors.white,
                  Colors.white,
                  Colors.deepPurple),
            ),
            SizedBox(
              height: 30.0,
            ),
            Container(
              //color: Colors.amberAccent,
              //height: MediaQuery.of(context).size.height * (1 / 8),
              child: rowsNotification(
                  context,
                  "Notification",
                  "On",
                  "Off",
                  Color.fromRGBO(0, 255, 0, 0.3),
                  Color.fromRGBO(255, 0, 0, 0.3),
                  null,
                  null,
                  Colors.lightGreenAccent,
                  Colors.red,
                  null,
                  null,
                  Colors.white,
                  Colors.black54),
            ),
            SizedBox(
              height: 40.0,
            ),
            Container(
              //color: Colors.green,
              //height: MediaQuery.of(context).size.height * (1 / 8),
              child: numberChange(),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                "Visibility",
                style: TextStyle(
                    fontSize: 25.0,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.0),
              ),
            ),
            SizedBox(
              height: 25.0,
            ),
            Container(
              child: lastSeenVisibility("Last Seen"),
            ),
            SizedBox(
              height: 30.0,
            ),
            Container(
              child: statusVisibility(),
            ),
            SizedBox(
              height: 30.0,
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                "Security",
                style: TextStyle(
                    fontSize: 25.0,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.0),
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Container(
              child: lock(),
            ),
          ],
        ),
      ),
    );
  }

  Widget rowsTheme(
      BuildContext context,
      String leftText,
      String onText,
      String offText,
      Color onBgColor,
      Color offBgColor,
      IconData onIcon,
      IconData offIcon,
      Color onCircleColor,
      Color offCircleColor,
      Color onIconColor,
      Color offIconColor,
      Color onTextColor,
      Color offTextColor) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            alignment: Alignment.center,
            //color: Colors.white,
            child: Text(
              leftText,
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 20.0,
                  fontFamily: 'Lora',
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic),
            ),
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            //color: Colors.lightBlueAccent,
            child: FlutterSwitch(
              value: _colorModeStatus,
              height: 40.0,
              width: 100.0,
              toggleSize: 35.0,
              showOnOff: true,
              switchBorder: Border.all(
                width: 1.0,
              ),
              toggleBorder: Border.all(width: 1.0),
              activeToggleColor: onCircleColor,
              activeIcon: Icon(
                onIcon,
                color: onIconColor,
              ),
              activeColor: onBgColor,
              activeTextColor: onTextColor,
              activeText: onText,
              inactiveToggleColor: offCircleColor,
              inactiveIcon: Icon(
                offIcon,
                color: offIconColor,
                size: 20.0,
              ),
              inactiveColor: offBgColor,
              inactiveTextColor: offTextColor,
              inactiveText: offText,
              onToggle: (index) {
                setState(() {
                  _colorModeStatus = index;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget rowsNotification(
      BuildContext context,
      String leftText,
      String onText,
      String offText,
      Color onBgColor,
      Color offBgColor,
      IconData onIcon,
      IconData offIcon,
      Color onCircleColor,
      Color offCircleColor,
      Color onIconColor,
      Color offIconColor,
      Color onTextColor,
      Color offTextColor) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            alignment: Alignment.center,
            //color: Colors.white,
            child: Text(
              leftText,
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 20.0,
                  fontFamily: 'Lora',
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic),
            ),
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            //color: Colors.lightBlueAccent,
            child: FlutterSwitch(
              value: _notificationState,
              height: 40.0,
              width: 100.0,
              toggleSize: 35.0,
              showOnOff: true,
              switchBorder: Border.all(
                width: 1.0,
              ),
              toggleBorder: Border.all(width: 1.0),
              activeToggleColor: onCircleColor,
              activeIcon: Icon(
                onIcon,
                color: onIconColor,
              ),
              activeColor: onBgColor,
              activeTextColor: onTextColor,
              activeText: onText,
              inactiveToggleColor: offCircleColor,
              inactiveIcon: Icon(
                offIcon,
                color: offIconColor,
                size: 20.0,
              ),
              inactiveColor: offBgColor,
              inactiveTextColor: offTextColor,
              inactiveText: offText,
              onToggle: (index) {
                setState(() {
                  _notificationState = index;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget numberChange() {
    return Row(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.center,
            //color: Colors.red,
            child: Text(
              "Change Number",
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 20.0,
                  fontFamily: 'Lora',
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic),
            ),
          ),
        ),
        Expanded(
          child: Container(
            //color: Colors.blueAccent,
            child: IconButton(
              icon: Icon(
                Icons.note_add,
                size: 35.0,
                color: Colors.lightGreenAccent,
              ),
              onPressed: () {
                print("Change");
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget lastSeenVisibility(String _description) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            alignment: Alignment.center,
            child: Text(
              _description,
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Lora',
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            child: IconButton(
              highlightColor: Color.fromRGBO(0, 0, 250, 1),
              splashColor: Color.fromRGBO(0, 0, 250, 0.3),
              icon: _lastSeenIcons,
              onPressed: () {
                setState(() {
                  if (_rightIcon == true) {
                    _lastSeenIcons = Icon(
                      Icons.close_rounded,
                      color: Colors.red,
                      size: 30.0,
                    );
                    _rightIcon = false;
                  } else {
                    _lastSeenIcons = Icon(
                      Icons.done_rounded,
                      color: Colors.green,
                      size: 40.0,
                    );
                    _rightIcon = true;
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget statusVisibility() {
    return Row(
      children: <Widget>[
        Expanded(
            child: Container(
          alignment: Alignment.center,
          child: Text(
            "Status",
            style: TextStyle(
              fontSize: 20.0,
              fontFamily: 'Lora',
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          ),
        )),
        Expanded(
          child: FlutterSwitch(
            showOnOff: true,
            width: 110,
            activeSwitchBorder: Border.all(width: 1.0),
            activeToggleBorder: Border.all(width: 1.0),
            activeText: "Everyone",
            activeTextColor: Colors.redAccent,
            activeColor: Colors.lightGreenAccent,
            activeToggleColor: Colors.green,
            inactiveSwitchBorder: Border.all(width: 1.0),
            inactiveToggleBorder: Border.all(width: 1.0),
            inactiveText: "Contacts",
            inactiveTextColor: Colors.deepOrange,
            inactiveColor: Colors.yellowAccent,
            inactiveToggleColor: Colors.amber,
            value: _index,
            onToggle: (index) {
              setState(() {
                _index = index;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget lock() {
    return Row(
      children: <Widget>[
        Expanded(
            child: Container(
          alignment: Alignment.center,
          child: Text(
            "Lock",
            style: TextStyle(
              fontSize: 20.0,
              fontFamily: 'Lora',
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          ),
        )),
        Expanded(
          child: FlutterSwitch(
            showOnOff: true,
            width: 110,
            activeSwitchBorder: Border.all(width: 1.0),
            activeToggleBorder: Border.all(width: 1.0),
            activeText: "Enable",
            activeTextColor: Colors.redAccent,
            activeColor: Colors.lightGreenAccent,
            activeToggleColor: Colors.green,
            inactiveSwitchBorder: Border.all(width: 1.0),
            inactiveToggleBorder: Border.all(width: 1.0),
            inactiveText: "Disable",
            inactiveTextColor: Colors.yellow,
            inactiveColor: Color.fromRGBO(250, 0, 0, 0.5),
            inactiveToggleColor: Colors.red,
            value: _lockState,
            onToggle: (index) {
              setState(() {
                _lockState = index;
              });
            },
          ),
        ),
      ],
    );
  }
}
