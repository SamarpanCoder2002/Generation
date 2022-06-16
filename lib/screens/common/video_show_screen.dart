import 'dart:io';

import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/providers/video_management/video_show_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../services/debugging.dart';

class VideoShowScreen extends StatefulWidget {
  final File file;

  const VideoShowScreen({Key? key, required this.file}) : super(key: key);

  @override
  State<VideoShowScreen> createState() => _VideoShowScreenState();
}

class _VideoShowScreenState extends State<VideoShowScreen> {
  late dynamic _videoController;

  @override
  void initState() {
    Provider.of<VideoShowProvider>(context, listen: false)
        .initialize(widget.file);
    super.initState();
  }

  @override
  void dispose() {
    debug("AT DISPOSE VIDEO SHOW SCREEN");
    _videoController.pause();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _videoController = Provider.of<VideoShowProvider>(context).getController();

    return Scaffold(
      backgroundColor: AppColors.backgroundDarkMode,
      body: SizedBox(
        width: MediaQuery.of(context).size.height,
        height: MediaQuery.of(context).size.height,
        child: AspectRatio(
          aspectRatio: _videoController.value.aspectRatio,
          child: VideoPlayer(_videoController),
        ),
      ),
    );
  }
}
