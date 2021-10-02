import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/FrontEnd/MenuScreen/Settings/chat_wallpaper_maker.dart';
import 'package:generation/FrontEnd/MenuScreen/Settings/chat_history_maker_and_media_view.dart';
import 'package:generation/FrontEnd/MenuScreen/Settings/settings_notification_screen.dart';
import 'package:generation/FrontEnd/MenuScreen/Settings/phone_call_config.dart';

class SettingsWindow extends StatefulWidget {
  @override
  _SettingsWindowState createState() => _SettingsWindowState();
}

class _SettingsWindowState extends State<SettingsWindow> {
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
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontFamily: 'Lora',
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(
            height: 40.0,
          ),
          everySettingsItem(
              mainText: 'Notification',
              icon: Icons.notification_important_outlined,
              smallDescription: 'Different Notification Customization'),
          SizedBox(
            height: 15.0,
          ),
          everySettingsItem(
              mainText: 'Chat Wallpaper',
              icon: Icons.wallpaper_outlined,
              smallDescription: 'Change Chat Common Wallpaper'),
          SizedBox(
            height: 15.0,
          ),
          everySettingsItem(
              mainText: 'Generation Direct Calling Setting',
              icon: Icons.call,
              smallDescription: 'Add Phone Number to Receive Call'),
          SizedBox(
            height: 15.0,
          ),
          everySettingsItem(
              mainText: 'Chat History',
              icon: Entypo.text_document_inverted,
              smallDescription: 'Chat History Including Media'),
          SizedBox(
            height: 15.0,
          ),
          everySettingsItem(
              mainText: 'Storage',
              icon: Icons.storage,
              smallDescription: 'Storage Usage'),
          SizedBox(
            height: 30.0,
          ),
          Center(
            child: Text(
              'Copyright © 2021 @ Generation',
              style: TextStyle(
                color: Colors.lightBlue,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget everySettingsItem(
      {required String mainText,
      required IconData icon,
      required String smallDescription}) {
    return OpenContainer(
      closedElevation: 0.0,
      openColor: const Color.fromRGBO(34, 48, 60, 1),
      middleColor: const Color.fromRGBO(34, 48, 60, 1),
      closedColor: const Color.fromRGBO(34, 48, 60, 1),
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: Duration(milliseconds: 500),
      openBuilder: (_, __) {
        switch (mainText) {
          case 'Notification':
            return SettingsNotificationConfiguration();

          case 'Chat Wallpaper':
            return ChatWallPaperMaker(allUpdatePermission: true, userName: '');

          case 'Generation Direct Calling Setting':
            return PhoneNumberConfig();

          case 'Chat History':
            return ChatHistoryMakerAndMediaViewer(
                historyOrMediaChoice: HistoryOrMediaChoice.History);

          case 'Storage':
            return ChatHistoryMakerAndMediaViewer(
                historyOrMediaChoice: HistoryOrMediaChoice.Media);
        }
        return Center(
          child: Text(
            'Sorry, Not yet Implemented',
            style: TextStyle(color: Colors.red, fontSize: 18.0),
          ),
        );
      },
      closedBuilder: (_, __) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 70.0,
          margin: EdgeInsets.only(
            left: 20.0,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.green,
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Text(
                    mainText,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white70,
                    ),
                  )
                ],
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(
                    top: 5.0,
                    left: 40.0,
                  ),
                  child: Text(
                    smallDescription,
                    style: TextStyle(
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
