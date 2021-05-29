import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/FrontEnd/Preview/images_preview_screen.dart';
import 'package:photo_view/photo_view.dart';

class StorageMediaCommonView extends StatefulWidget {
  final MediaTypes mediaTypes;
  final List<String> mediaSources;

  StorageMediaCommonView(
      {@required this.mediaTypes, @required this.mediaSources});

  @override
  _StorageMediaCommonViewState createState() => _StorageMediaCommonViewState();
}

class _StorageMediaCommonViewState extends State<StorageMediaCommonView> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
      body: (widget.mediaTypes == MediaTypes.Image ||
              widget.mediaTypes == MediaTypes.Video)
          ? _forImageAndVideoProcessing()
          : _forAudioAndDocProcessing(),
    );
  }

  Widget _forImageAndVideoProcessing() {
    return Container(
      padding: EdgeInsets.all(
        20.0,
      ),
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
        shrinkWrap: true,
        children: [
          for (int i = 0; i < widget.mediaSources.length; i++) _gridView(i),
        ],
      ),
    );
  }

  Widget _gridView(int index) {
    return Container(
      child: OpenContainer(
        openBuilder: (_, __) => PreviewImageScreen(
          imageFile: File(widget.mediaSources[index]),
        ),
        closedBuilder: (_, __) => Stack(
          children: [
            PhotoView(
              imageProvider: FileImage(File(widget.mediaSources[index])),
              loadingBuilder: (context, event) => Center(
                child: CircularProgressIndicator(),
              ),
              errorBuilder: (context, obj, stackTrace) => Center(
                  child: Text(
                'Image not Found',
                style: TextStyle(
                  fontSize: 23.0,
                  color: Colors.red,
                  fontFamily: 'Lora',
                  letterSpacing: 1.0,
                ),
              )),
              enableRotation: true,
              minScale: PhotoViewComputedScale.covered,
            ),

          ],
        ),
      ),
    );
  }

  Widget _forAudioAndDocProcessing() {
    return Center();
  }
}
