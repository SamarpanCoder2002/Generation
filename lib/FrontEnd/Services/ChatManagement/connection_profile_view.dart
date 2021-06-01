import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:generation/FrontEnd/MenuScreen/Settings/connection_media_view.dart';

class ConnectionProfileView extends StatefulWidget {
  final String profileImagePath;
  final String userName;

  ConnectionProfileView(
      {@required this.profileImagePath, @required this.userName});

  @override
  _ConnectionProfileViewState createState() => _ConnectionProfileViewState();
}

class _ConnectionProfileViewState extends State<ConnectionProfileView> {
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();

  bool _bgStatus = true;
  bool _fgStatus = true;

  String _userAbout = '';
  String _userJoinDate = '';
  String _userJoinTime = '';

  void _extractNotifyInformation() async {
    final bool _bgTempStatus =
        await _localStorageHelper.extractImportantTableData(
            userName: widget.userName,
            extraImportant: ExtraImportant.BGNStatus);
    final bool _fgTempStatus =
        await _localStorageHelper.extractImportantTableData(
            userName: widget.userName,
            extraImportant: ExtraImportant.FGNStatus);

    final String _userTempJoinDate =
        await _localStorageHelper.extractImportantTableData(
            extraImportant: ExtraImportant.CreationDate,
            userName: widget.userName);

    final String _userTempJoinTime =
        await _localStorageHelper.extractImportantTableData(
            extraImportant: ExtraImportant.CreationTime,
            userName: widget.userName);

    final String _userTempAbout =
        await _localStorageHelper.extractImportantTableData(
            extraImportant: ExtraImportant.About, userName: widget.userName);

    if (mounted) {
      setState(() {
        this._bgStatus = _bgTempStatus;
        this._fgStatus = _fgTempStatus;
        this._userAbout = _userTempAbout;
        this._userJoinDate = _userTempJoinDate;
        this._userJoinTime = _userTempJoinTime;
      });
    }
  }

  @override
  void initState() {
    _extractNotifyInformation();
    super.initState();
  }

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
        _firstPortionInformation('About', this._userAbout),
        SizedBox(
          height: 30.0,
        ),
        _firstPortionInformation('Join Date', this._userJoinDate),
        SizedBox(
          height: 30.0,
        ),
        _firstPortionInformation('Join Time', this._userJoinTime),
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
            status: _bgStatus),
        SizedBox(
          height: 40.0,
        ),
        _connectionMenuOptions(
            notificationName: 'Online Notification', status: _fgStatus),
      ],
    );
  }

  Widget _connectionMenuOptions(
      {@required String notificationName, @required bool status}) {
    return Container(
      padding: EdgeInsets.only(
        right: 10.0,
        left: 15.0,
      ),
      alignment: Alignment.center,
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
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 15.0,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    status ? 'Activated' : 'Deactivated',
                    textAlign: TextAlign.left,
                    style:
                        TextStyle(color: !status ? Colors.red : Colors.green),
                  ),
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
                    color: status ? Colors.red : Colors.green,
                  ),
                ),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                    side: BorderSide(
                      color: status ? Colors.red : Colors.green,
                    ),
                  ),
                ),
                onPressed: () async {
                  if (notificationName ==
                      'Background Notification Annotation') {
                    print('Background Button');

                    await _localStorageHelper.updateImportantTableExtraData(
                        userName: widget.userName,
                        updatedVal: this._bgStatus ? '0' : '1',
                        extraImportant: ExtraImportant.BGNStatus);

                    if (mounted) {
                      setState(() {
                        this._bgStatus = !this._bgStatus;
                      });
                    }
                  } else {
                    print('Online Button');

                    await _localStorageHelper.updateImportantTableExtraData(
                        userName: widget.userName,
                        updatedVal: this._fgStatus ? '0' : '1',
                        extraImportant: ExtraImportant.FGNStatus);

                    if (mounted) {
                      setState(() {
                        this._fgStatus = !this._fgStatus;
                      });
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mediaAndReportVisibilitySection({@required String name}) {
    return OpenContainer(
      closedColor: const Color.fromRGBO(34, 48, 60, 1),
      middleColor: const Color.fromRGBO(34, 48, 60, 1),
      openColor: const Color.fromRGBO(34, 48, 60, 1),
      closedElevation: 0.0,
      transitionDuration: Duration(milliseconds: 500),
      transitionType: ContainerTransitionType.fadeThrough,
      openBuilder: (_, __) {
        if (name == 'Media Visibility') {
          return ParticularConnectionMediaView(
            selectedConnectionUserName: widget.userName,
            profileImagePath: widget.profileImagePath,
          );
        } else
          return Center();
      },
      closedBuilder: (_, __) => SizedBox(
        height: 50.0,
        child: Container(
            padding: EdgeInsets.only(left: 15.0),
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
      ),
    );
  }
}
