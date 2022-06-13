import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoShowProvider extends ChangeNotifier {
  late VideoPlayerController _videoController;

  initialize(File file) {
    _videoController = VideoPlayerController.file(file);
    _videoController.initialize().then((value) {
      _videoController.play();
      _videoController.setLooping(true);
    });
  }

  VideoPlayerController getController() => _videoController;

  pauseVideo(){
    if(!_videoController.value.isPlaying) return;

    _videoController.pause();
    notifyListeners();
  }

  playVideo(){
    if(_videoController.value.isPlaying) return;

    _videoController.play();
    notifyListeners();
  }

  playPauseController(){
    if(_videoController.value.isPlaying) {
      pauseVideo();
    } else {
      playVideo();
    }
  }

  @override
  void dispose() {
    _videoController.pause();
    _videoController.dispose();
    notifyListeners();
    super.dispose();
  }

  Future<Duration> getVideoDuration(File file)async{
    VideoPlayerController controller = VideoPlayerController.file(file);
    await controller.initialize();
    return controller.value.duration;
  }
}
