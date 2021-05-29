import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';

class ParticularConnectionMediaView extends StatefulWidget {
  final String selectedConnectionUserName;

  ParticularConnectionMediaView({@required this.selectedConnectionUserName});

  @override
  _ParticularConnectionMediaViewState createState() =>
      _ParticularConnectionMediaViewState();
}

class _ParticularConnectionMediaViewState
    extends State<ParticularConnectionMediaView> {
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();

  void findIt() async {
    await _localStorageHelper.extractParticularChatMediaByRequirement(
        tableName: widget.selectedConnectionUserName,
        mediaType: MediaTypes.Image);
  }

  @override
  void initState() {
    findIt();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Color.fromRGBO(25, 39, 52, 1),
          elevation: 10.0,
          shadowColor: Colors.white70,
          title: Text(
            'Media Files',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          bottom: TabBar(
            indicatorPadding: EdgeInsets.only(left: 20.0, right: 20.0),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 2.0, color: Colors.lightBlue),
            ),
            automaticIndicatorColorAdjustment: true,
            labelStyle: TextStyle(
              fontFamily: 'Lora',
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            ),
            onTap: (index) {
              print("\nIndex is: $index");
              if (mounted) {
                // setState(() {
                //   _currIndex = index;
                // });
              }
            },
            tabs: [
              Tab(
                child: Text(
                  "Images",
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Videos",
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Audio",
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Doc",
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
