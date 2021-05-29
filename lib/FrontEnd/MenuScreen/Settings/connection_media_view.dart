import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:generation/FrontEnd/MenuScreen/Settings/storage_view_diff_form.dart';

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

  List<Map<String,String>> _allImages = [];
  List<Map<String,String>> _allVideos = [];
  List<Map<String,String>> _allAudios = [];
  List<Map<String,String>> _allDocs = [];

  void _extractImportantMediaTypes() async {
    final takeTempImages =
        await _localStorageHelper.extractParticularChatMediaByRequirement(
            tableName: widget.selectedConnectionUserName,
            mediaType: MediaTypes.Image);

    if(mounted){
      setState(() {
        this._allImages = takeTempImages;
      });
    }

    final takeTempVideos =
        await _localStorageHelper.extractParticularChatMediaByRequirement(
            tableName: widget.selectedConnectionUserName,
            mediaType: MediaTypes.Video);

    if(mounted){
      setState(() {
        this._allVideos = takeTempVideos;
      });
    }

    final takeTempAudios =
        await _localStorageHelper.extractParticularChatMediaByRequirement(
            tableName: widget.selectedConnectionUserName,
            mediaType: MediaTypes.Voice);

    if(mounted){
      setState(() {
        this._allAudios = takeTempAudios;
      });
    }

     final takeTempDocs =
        await _localStorageHelper.extractParticularChatMediaByRequirement(
            tableName: widget.selectedConnectionUserName,
            mediaType: MediaTypes.Document);

    if(mounted){
      setState(() {
        this._allDocs = takeTempDocs;
      });
    }
  }

  @override
  void initState() {
    _extractImportantMediaTypes();
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
        body: TabBarView(
          children: [
            StorageMediaCommonView(
                mediaTypes: MediaTypes.Image, mediaSources: this._allImages),
            StorageMediaCommonView(
                mediaTypes: MediaTypes.Video, mediaSources: this._allVideos),
            StorageMediaCommonView(
                mediaTypes: MediaTypes.Voice, mediaSources: this._allAudios),
            StorageMediaCommonView(
                mediaTypes: MediaTypes.Document, mediaSources: this._allDocs),
          ],
        ),
      ),
    );
  }
}
