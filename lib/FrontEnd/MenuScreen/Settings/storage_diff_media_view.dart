import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generation/BackendAndDatabaseManager/general_services/toast_message_manage.dart';
import 'package:open_file/open_file.dart';
import 'package:photo_view/photo_view.dart';

import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/FrontEnd/Preview/images_preview_screen.dart';

class StorageMediaCommonView extends StatefulWidget {
  final MediaTypes mediaTypes;
  final List<Map<String, String>> mediaSources;

  StorageMediaCommonView(
      {@required this.mediaTypes, @required this.mediaSources});

  @override
  _StorageMediaCommonViewState createState() => _StorageMediaCommonViewState();
}

class _StorageMediaCommonViewState extends State<StorageMediaCommonView> {
  final FToast _fToast = FToast();

  @override
  void initState() {
    _fToast.init(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
      body: _differentProceed(),
    );
  }

  Widget _differentProceed() {
    if (widget.mediaTypes == MediaTypes.Image)
      return _forImageAndVideoProcessing();
    else if (widget.mediaTypes == MediaTypes.Video)
      return _forImageAndVideoProcessing();
    else if (widget.mediaTypes == MediaTypes.Voice)
      return _audioAndDocView();
    else
      return _audioAndDocView();
  }

  Widget _forImageAndVideoProcessing() {
    return Container(
      padding: EdgeInsets.all(
        20.0,
      ),
      child: widget.mediaSources.isNotEmpty
          ? GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                for (int i = 0; i < widget.mediaSources.length; i++)
                  _imageAndVideoView(i),
              ],
            )
          : Center(
              child: Text(
                widget.mediaTypes == MediaTypes.Image
                    ? 'No Images Found'
                    : 'No Videos Found',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20.0,
                ),
              ),
            ),
    );
  }

  Widget _imageAndVideoView(int index) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: Duration(milliseconds: 500),
      middleColor: const Color.fromRGBO(34, 48, 60, 1),
      openColor: const Color.fromRGBO(34, 48, 60, 1),
      openBuilder: (_, __) => PreviewImageScreen(
        imageFile: File(widget.mediaTypes == MediaTypes.Image
            ? widget.mediaSources[index].keys.first.toString()
            : widget.mediaSources[index].keys.first.toString().split('+')[1]),
      ),
      closedBuilder: (_, __) => Stack(
        children: [
          PhotoView(
            imageProvider: FileImage(File(widget.mediaTypes == MediaTypes.Image
                ? widget.mediaSources[index].keys.first.toString()
                : widget.mediaSources[index].keys.first
                    .toString()
                    .split('+')[1])),
            loadingBuilder: (context, event) => Center(
              child: CircularProgressIndicator(),
            ),
            errorBuilder: (context, obj, stackTrace) => Center(
                child: Text(
              'Image not Found',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.red,
                fontFamily: 'Lora',
                letterSpacing: 1.0,
              ),
            )),
            enableRotation: true,
            minScale: PhotoViewComputedScale.covered,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: double.maxFinite,
              alignment: Alignment.bottomRight,
              color: Colors.black26,
              height: 20.0,
              child: Text(
                widget.mediaSources[index].values.first.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
          if (widget.mediaTypes == MediaTypes.Video)
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 100.0,
                  color: Colors.white,
                ),
                onTap: () async {
                  final OpenResult openResult = await OpenFile.open(widget
                      .mediaSources[index].keys.first
                      .toString()
                      .split('+')[0]);

                  openFileResultStatus(openResult: openResult);
                },
              ),
            ),
        ],
      ),
    );
  }

  void openFileResultStatus({@required OpenResult openResult}) {
    if (openResult.type == ResultType.permissionDenied)
      showToast('Permission Denied to Open File', _fToast);
    else if (openResult.type == ResultType.noAppToOpen)
      showToast('No App Found to Open', _fToast);
    else if (openResult.type == ResultType.error)
      showToast('Error in Opening File', _fToast);
    else if (openResult.type == ResultType.fileNotFound)
      showToast('Sorry, File Not Found', _fToast);
  }

  Widget _audioAndDocView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(
        top: 10.0,
        bottom: 10.0,
      ),
      child: ListView(
        shrinkWrap: true,
        children: widget.mediaSources
            .asMap()
            .map((mapIndex, e) => MapEntry(mapIndex, _everyFile(mapIndex)))
            .values
            .toList(),
      ),
    );
  }

  Widget _everyFile(int index) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 90.0,
      padding: EdgeInsets.only(
        left: 5.0,
        right: 5.0,
        top: 10.0,
        bottom: 10.0,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0.0,
          primary: const Color.fromRGBO(34, 48, 60, 1),
          onPrimary: Colors.lightBlueAccent,
        ),
        onPressed: () async {
          print(widget.mediaSources[index].keys.first.toString());
          final OpenResult openResult = await OpenFile.open(
            widget.mediaSources[index].keys.first.toString(),
          );

          openFileResultStatus(openResult: openResult);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: Icon(
                widget.mediaTypes == MediaTypes.Voice?Icons.audiotrack_rounded:Entypo.documents,
                size: 35.0,
                color: Colors.lightBlue,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 10.0,
                    ),
                    child: Text(
                      _compressFileName(index),
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 10.0,
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        widget.mediaSources[index].values.first.toString(),
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _compressFileName(int index) {
    return widget.mediaSources[index].keys.first
                .toString()
                .split('/')
                .last
                .length <=
            30
        ? widget.mediaSources[index].keys.first
            .toString()
            .split('/')
            .last
            .toString()
        : '${widget.mediaSources[index].keys.first.toString().split('/').last.replaceRange(30, widget.mediaSources[index].keys.first.toString().split('/').last.length, '...')}';
  }
}
