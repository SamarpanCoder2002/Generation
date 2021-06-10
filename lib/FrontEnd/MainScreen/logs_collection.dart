import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:generation/BackendAndDatabaseManager/general_services/make_audio_call.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:generation/FrontEnd/Services/CallHistory/call_history_show.dart';

class ScreenLogs extends StatefulWidget {
  @override
  _ScreenLogsState createState() => _ScreenLogsState();
}

class _ScreenLogsState extends State<ScreenLogs> {
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();
  final List<Map<String, String>> _nameAndImageForCallLog = [];

  void _takeAllCallLogsCount() async {
    final List<Map<String, Object>> _connectedUserCollection =
        await _localStorageHelper.extractAllUsersName();

    _connectedUserCollection.forEach((userNameMap) async {
      final int totalCallLogs = await _localStorageHelper
          .countOrExtractTotalCallLogs(userNameMap.values.first.toString());

      if (totalCallLogs > 0) {
        final String _userProfilePicLocalPath =
            await _localStorageHelper.extractProfileImageLocalPath(
                userName: userNameMap.values.first.toString());

        final int totalCallLogs = await _localStorageHelper
            .countOrExtractTotalCallLogs(userNameMap.values.first.toString());

        print(totalCallLogs);

        if (totalCallLogs > 0) if (mounted) {
          setState(() {
            this._nameAndImageForCallLog.add({
              userNameMap.values.first.toString(): _userProfilePicLocalPath,
            });
          });
        }
      }
    });
  }

  @override
  void initState() {
    _takeAllCallLogsCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return screenLogsList(context);
  }

  Widget screenLogsList(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 48, 60, 1),
      body: Container(
        color: const Color.fromRGBO(34, 48, 60, 1),
        height: MediaQuery.of(context).size.height,
        margin: EdgeInsets.only(top: 10.0, bottom: 13.0),
        child: chatList(context),
      ),
    );
  }

  Widget chatList(BuildContext context) {
    return ListView.builder(
      itemCount: this._nameAndImageForCallLog.length,
      itemBuilder: (context, position) {
        return chatTile(context, position);
      },
    );
  }

  Widget chatTile(BuildContext context, int index) {
    return Card(
        elevation: 0.0,
        color: Color.fromRGBO(34, 48, 60, 1),
        child: Container(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color.fromRGBO(34, 48, 60, 1),
              onPrimary: Colors.lightBlueAccent,
              elevation: 0.0,
            ),
            onPressed: () {
              print("Logs Information");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ShowCallLogsData(this
                          ._nameAndImageForCallLog[index]
                          .keys
                          .first
                          .toString())));
            },
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: 5.0,
                    bottom: 5.0,
                  ),
                  child: CircleAvatar(
                    radius: 30.0,
                    backgroundImage: this
                                ._nameAndImageForCallLog[index]
                                .values
                                .first
                                .toString() ==
                            ''
                        ? ExactAssetImage("assets/logo/logo.jpg")
                        : FileImage(File(this
                            ._nameAndImageForCallLog[index]
                            .values
                            .first
                            .toString())),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                    child: Text(
                      _getUserName(index),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                IconButton(
                    icon: Icon(
                      Icons.call,
                      color: Colors.lightGreen,
                    ),
                    onPressed: () async {
                      print("Call Clicked");

                      final CallManagement _callManagement = CallManagement(
                          this.context,
                          this
                              ._nameAndImageForCallLog[index]
                              .keys
                              .first
                              .toString());

                      await _callManagement.makeGenerationPhoneCall();
                    }),
              ],
            ),
          ),
        ));
  }

  String _getUserName(int index) => this
              ._nameAndImageForCallLog[index]
              .keys
              .first
              .toString()
              .length <=
          20
      ? this._nameAndImageForCallLog[index].keys.first.toString()
      : '${this._nameAndImageForCallLog[index].keys.first.toString().replaceRange(20, this._nameAndImageForCallLog[index].keys.first.toString().length, '...')}';
}
