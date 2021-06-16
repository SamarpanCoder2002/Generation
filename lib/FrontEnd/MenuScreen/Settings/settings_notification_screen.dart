import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:generation/FrontEnd/ShowCase/common_description_show.dart';

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
  bool _removeBirthStatus = false;
  bool _removeAnonymousStatus = false;

  void extractNotifyInformation() async {
    final bool _bgTempStatus =
        await _localStorageHelper.extractDataForNotificationConfigTable(
            nConfigTypes: NConfigTypes.BgNotification);
    final bool _fgTempStatus =
        await _localStorageHelper.extractDataForNotificationConfigTable(
            nConfigTypes: NConfigTypes.FGNotification);
    final bool _removeBirthTempStatus =
        await _localStorageHelper.extractDataForNotificationConfigTable(
            nConfigTypes: NConfigTypes.RemoveBirthNotification);
    final bool _anonymousTempStatus =
        await _localStorageHelper.extractDataForNotificationConfigTable(
            nConfigTypes: NConfigTypes.RemoveAnonymousNotification);

    if (mounted) {
      setState(() {
        this._bgStatus = _bgTempStatus;
        this._fgStatus = _fgTempStatus;
        this._removeBirthStatus = _removeBirthTempStatus;
        this._removeAnonymousStatus = _anonymousTempStatus;
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
        actions: [
          GestureDetector(
            child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(
                  right: 15.0,
                ),
                child: Text(
                  'Beta',
                  style: TextStyle(
                    color: Colors.amber,
                  ),
                )),
            onTap: () {
              print('Notification Configuration Beta Description');
            },
          ),
        ],
        brightness: Brightness.dark,
        backgroundColor: Color.fromRGBO(25, 39, 52, 1),
        elevation: 10.0,
        shadowColor: Colors.white70,
        title: Text(
          'Notification Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontFamily: 'Lora',
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(
            height: 30.0,
          ),
          _notificationOptions(
            mainText: 'BackGround Notification Annotation',
            status: this._bgStatus,
            fontSize: 14.0,
          ),
          SizedBox(
            height: 30.0,
          ),
          _notificationOptions(
              mainText: 'Online Notification', status: this._fgStatus),
          SizedBox(
            height: 30.0,
          ),
          SizedBox(
            height: 5.0,
            child: Divider(
              color: Colors.white12,
              thickness: 2.0,
            ),
          ),
          SizedBox(
            height: 30.0,
          ),
          _notificationOptions(
              mainText: 'Remove Birth Notification',
              status: this._removeBirthStatus),
          SizedBox(
            height: 30.0,
          ),
          _notificationOptions(
              mainText: 'Remove Anonymous Notification',
              status: this._removeAnonymousStatus),
          SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }

  Widget _notificationOptions({
    @required String mainText,
    @required bool status,
    double fontSize = 16.0,
  }) {
    return GestureDetector(
      onTap: () {
        switch (mainText) {
          case 'BackGround Notification Annotation':
            notificationDescription(
                title: mainText,
                context: context,
                content:
                    'Notification pop-up when the app is in Background. If Deactivated, notification will come silently but no pop-up.');
            break;
          case 'Online Notification':
            notificationDescription(
                title: mainText,
                context: context,
                content:
                    'When the app is open, notification come. If deactivated, no notification will come when app is open.');
            break;
          case 'Remove Birth Notification':
            notificationDescription(
                title: mainText,
                context: context,
                content:
                    'If Activated, When the app is opening, all notifications will remove.');
            break;
          case 'Remove Anonymous Notification':
            notificationDescription(
                title: mainText,
                context: context,
                content:
                    'If Activated, When you pressed Refresh Button in MainScreen, all notifications will remove');
            break;
        }
      },
      child: Container(
        height: 50,
        alignment: Alignment.center,
        padding: EdgeInsets.only(
          right: 15.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 5.0,
                        ),
                        child: Icon(
                          Icons.description_outlined,
                          color: Colors.lightBlue,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          mainText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 5.0,
                      left: 40.0,
                    ),
                    child: Text(
                      '${status ? 'Activated' : 'Deactivated'}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: status ? Colors.green : Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                elevation: 0.0,
                //backgroundColor: status ? Colors.red : Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                  side: BorderSide(
                    color: status ? Colors.red : Colors.green,
                  ),
                ),
              ),
              child: Text(
                status ? 'Deactivate' : 'Activate',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: status ? Colors.red : Colors.green,
                ),
              ),
              onPressed: () async {
                if (mainText.split(' ')[0] == 'BackGround') {
                  print('Background Button');

                  await _localStorageHelper
                      .updateDataForNotificationGlobalConfig(
                          updatedNotifyCondition: !_bgStatus,
                          nConfigTypes: NConfigTypes.BgNotification);

                  if (mounted) {
                    setState(() {
                      _bgStatus = !_bgStatus;
                    });
                  }
                } else if (mainText.split(' ')[0] == 'Online') {
                  print('Online Button');

                  await _localStorageHelper
                      .updateDataForNotificationGlobalConfig(
                          updatedNotifyCondition: !_fgStatus,
                          nConfigTypes: NConfigTypes.FGNotification);

                  if (mounted) {
                    setState(() {
                      _fgStatus = !_fgStatus;
                    });
                  }
                } else if (mainText.split(' ')[1] == 'Birth') {
                  print('Remove Birth Notification');

                  await _localStorageHelper
                      .updateDataForNotificationGlobalConfig(
                          updatedNotifyCondition: !this._removeBirthStatus,
                          nConfigTypes: NConfigTypes.RemoveBirthNotification);

                  if (mounted) {
                    setState(() {
                      this._removeBirthStatus = !this._removeBirthStatus;
                    });
                  }
                } else if (mainText.split(' ')[1] == 'Anonymous') {
                  print('Remove Anonymous Notification');

                  await _localStorageHelper
                      .updateDataForNotificationGlobalConfig(
                          updatedNotifyCondition: !this._removeAnonymousStatus,
                          nConfigTypes:
                              NConfigTypes.RemoveAnonymousNotification);

                  if (mounted) {
                    setState(() {
                      this._removeAnonymousStatus =
                          !this._removeAnonymousStatus;
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
