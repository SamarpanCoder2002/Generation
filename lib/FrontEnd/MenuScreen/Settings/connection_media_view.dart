import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:generation/FrontEnd/MenuScreen/Settings/storage_diff_media_view.dart';

class ParticularConnectionMediaView extends StatefulWidget {
  final String selectedConnectionUserName;
  final String profileImagePath;

  ParticularConnectionMediaView({required this.selectedConnectionUserName,
    required this.profileImagePath});

  @override
  _ParticularConnectionMediaViewState createState() =>
      _ParticularConnectionMediaViewState();
}

class _ParticularConnectionMediaViewState
    extends State<ParticularConnectionMediaView> {
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();

  List<Map<String, String>> _allImages = [];
  List<Map<String, String>> _allVideos = [];
  List<Map<String, String>> _allAudios = [];
  List<Map<String, String>> _allDocs = [];

  void _extractImportantMediaTypes() async {
    final takeTempImages =
    await _localStorageHelper.extractParticularChatMediaByRequirement(
        tableName: widget.selectedConnectionUserName,
        mediaType: MediaTypes.Image);

    print('Take it: $takeTempImages');

    if (mounted) {
      setState(() {
        this._allImages = takeTempImages;
      });
    }

    final takeTempVideos =
    await _localStorageHelper.extractParticularChatMediaByRequirement(
        tableName: widget.selectedConnectionUserName,
        mediaType: MediaTypes.Video);

    if (mounted) {
      setState(() {
        this._allVideos = takeTempVideos;
      });
    }

    final takeTempAudios =
    await _localStorageHelper.extractParticularChatMediaByRequirement(
        tableName: widget.selectedConnectionUserName,
        mediaType: MediaTypes.Voice);

    if (mounted) {
      setState(() {
        this._allAudios = takeTempAudios;
      });
    }

    final takeTempDocs =
    await _localStorageHelper.extractParticularChatMediaByRequirement(
        tableName: widget.selectedConnectionUserName,
        mediaType: MediaTypes.Document);

    if (mounted) {
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
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.only(
                  right: 20.0,
                  top: 5.0,
                ),
                child: CircleAvatar(
                  radius: 23.0,
                  backgroundImage: _getImageWithProvider(),
                ),
              ),
              Text(
                widget.selectedConnectionUserName.length <= 16
                    ? widget.selectedConnectionUserName
                    : '${widget.selectedConnectionUserName.replaceRange(
                    16, widget.selectedConnectionUserName.length, '...')}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          bottom: TabBar(
            indicatorPadding: EdgeInsets.only(left: 20.0, right: 20.0),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 2.0, color: Colors.lightBlue),
                insets: EdgeInsets.symmetric(
                  horizontal: 5.0,
                )),
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
                  "Image",
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Video",
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
              mediaTypes: MediaTypes.Image,
              mediaSources: this._allImages,
              userName: widget.selectedConnectionUserName,
            ),
            StorageMediaCommonView(
              mediaTypes: MediaTypes.Video,
              mediaSources: this._allVideos,
              userName: widget.selectedConnectionUserName,
            ),
            StorageMediaCommonView(
              mediaTypes: MediaTypes.Voice,
              mediaSources: this._allAudios,
              userName: widget.selectedConnectionUserName,
            ),
            StorageMediaCommonView(
              mediaTypes: MediaTypes.Document,
              mediaSources: this._allDocs,
              userName: widget.selectedConnectionUserName,
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider<Object>? _getImageWithProvider() {
    if (widget.profileImagePath == '')
      return ExactAssetImage(
        "assets/logo/logo.jpg",
      );
    return FileImage(File(widget.profileImagePath));
  }
}
