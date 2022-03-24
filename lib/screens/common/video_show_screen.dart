import 'dart:io';

import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:video_player/video_player.dart';

class VideoShowScreen extends StatefulWidget {
  final File file;

  const VideoShowScreen({Key? key, required this.file}) : super(key: key);

  @override
  State<VideoShowScreen> createState() => _VideoShowScreenState();
}

class _VideoShowScreenState extends State<VideoShowScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    _videoController = VideoPlayerController.file(widget.file);

    _initialize();
    super.initState();
  }

  @override
  void dispose() {
    _videoController.pause();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

  void _initialize() {
    _videoController.initialize().then((value) {
      setState(() {});
      _videoController.play();
      _videoController.setLooping(true);
    });
  }
}
