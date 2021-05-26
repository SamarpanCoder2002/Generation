import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';

class SettingsNotificationConfiguration extends StatefulWidget {
  const SettingsNotificationConfiguration({Key key}) : super(key: key);

  @override
  _SettingsNotificationConfigurationState createState() =>
      _SettingsNotificationConfigurationState();
}

class _SettingsNotificationConfigurationState
    extends State<SettingsNotificationConfiguration> {
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();

  bool _bgStatus = true;
  bool _fgStatus = true;

  void extractNotifyInformation() async {
    final bool _bgTempStatus = await _localStorageHelper
        .extractDataForNotificationConfigTable(bgNotify: true);
    final bool _fgTempStatus =
        await _localStorageHelper.extractDataForNotificationConfigTable();

    if (mounted) {
      setState(() {
        _bgStatus = _bgTempStatus;
        _fgStatus = _fgTempStatus;
      });
    }
  }

  @override
  void initState() {
    extractNotifyInformation();
    super.initState();
  }

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
          'Notification Configuration',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontFamily: 'Lora',
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 30.0,
          ),
          _notificationOptions(
              mainText: 'BackGround Notification', status: _bgStatus),
          SizedBox(
            height: 25.0,
          ),
          _notificationOptions(
              mainText: 'Online Notification', status: _fgStatus)
        ],
      ),
    );
  }

  Widget _notificationOptions(
      {@required String mainText, @required bool status}) {
    return Container(
      height: 50,
      //color: Colors.redAccent,
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        right: 15.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 5.0,
                      right: 20.0,
                    ),
                    child: Icon(
                      status
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_off_outlined,
                      color: status ? Colors.green : Colors.redAccent,
                    ),
                  ),
                  Text(
                    mainText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 5.0,
                    left: 50.0,
                  ),
                  child: Text(
                    'Status: ${status ? 'Activated' : 'Deactivated'}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ],
          ),
          TextButton(
            style: TextButton.styleFrom(
              elevation: 0.0,
              backgroundColor: status ? Colors.red : Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
            ),
            child: Text(
              status ? 'Deactivate' : 'Activate',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              if (mainText.split(' ')[0] == 'BackGround') {
                print('Background Button');

                await _localStorageHelper.updateDataForNotificationGlobalConfig(
                    updatedNotifyCondition: !_bgStatus, bgNotify: true);

                if (mounted) {
                  setState(() {
                    _bgStatus = !_bgStatus;
                  });
                }
              } else {
                print('Online Button');

                await _localStorageHelper.updateDataForNotificationGlobalConfig(
                    updatedNotifyCondition: !_fgStatus);

                if (mounted) {
                  setState(() {
                    _fgStatus = !_fgStatus;
                  });
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
