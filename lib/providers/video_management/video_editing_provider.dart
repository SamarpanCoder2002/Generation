import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_editor/domain/bloc/controller.dart';

class VideoEditingProvider extends ChangeNotifier {
  late ValueNotifier<double> _exportingProgress;
  late ValueNotifier<bool> _isExporting;
  final double height = 60;

  bool _exported = false;
  String _exportText = "";
  late VideoEditorController _controller;

  initialize(String filePath, int durationInSecond) {
    //if(_controller.initialized) dispose();

    _exportingProgress = ValueNotifier<double>(0.0);
    _isExporting = ValueNotifier<bool>(false);

    _controller = VideoEditorController.file(File(filePath),
        maxDuration: Duration(seconds: durationInSecond))
      ..initialize().then((value) {
        notifyListeners();
      });
  }

  isExporting() => _isExporting;

  getController() => _controller;

  exportingProgress() => _exportingProgress;

  updateExportingProgress(double updatedValue) {
    _exportingProgress.value = updatedValue;
    notifyListeners();
  }

  updateIsExportingValue(bool updatedValue) {
    _isExporting.value = updatedValue;
    notifyListeners();
  }

  isExported() => _exported;

  updatedExportedValue(bool updatedValue) {
    _exported = updatedValue;
    notifyListeners();
  }

  getExportedText() => _exportText;

  updatedExportedText(String updatedText) {
    _exportText = updatedText;
    notifyListeners();
  }

  destructor() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
  }

  getVideoMetadata(File file) async {
    final VideoEditorController _sampleController = VideoEditorController.file(file);
    await _sampleController.initialize();

    return _sampleController.video.value;
  }

  Future<Duration> getVideoDuration(File file)async{
    final value = await getVideoMetadata(file);
    return value.duration;
  }
}
