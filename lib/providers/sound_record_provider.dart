import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:generation/services/directory_management.dart';
import 'package:record/record.dart';

import '../services/permission_management.dart';

class SoundRecorderProvider extends ChangeNotifier {
  final _record = Record();
  String? _voiceStoreDirPath;
  bool _isRecording = false;

  initialize() {

  }

  Future<bool> startRecording() async {
    //if (_flutterSoundRecorder.isRecording) return false;

    final _permissionForRecording =
        (await recordingPermission()) && (await storagePermission());
    if (!_permissionForRecording) return false;

    if (_voiceStoreDirPath == null) {
      _voiceStoreDirPath = await createVoiceStoreDir();
      notifyListeners();
    }

    print("Voice Store Dir Path: $_voiceStoreDirPath");

    final _voiceStoreFilePath = createAudioFile(dirPath: _voiceStoreDirPath!);

    print("Voice Store File PAth: $_voiceStoreFilePath");

    bool result = await _record.hasPermission();

    if(!result) return false;

    // Start recording
    await _record.start(
      path: _voiceStoreFilePath, // required
      encoder: AudioEncoder.AAC, // by default
      bitRate: 128000, // by default
      samplingRate: 44100, // by default
    );



    //print("Encoder Status: ${status}");

    ///return false;
    ///
     ///_flutterSoundRecorder.openRecorder();

    //print("Check null: ${_flutterSoundRecorder == null}");

    //_flutterSoundRecorder.openRecorderCompleted(1, true);


    _isRecording = true;
    notifyListeners();

    return true;
  }

  stopRecording() async {
    final _recordPath = _record.stop();
    _isRecording = false;
    notifyListeners();
    return _recordPath;
  }

  getRecordingStatus() => _isRecording;

  @override
  void dispose() {
    // stopRecording().then((value) {
    //   _flutterSoundRecorder.closeRecorder();
    // });
    super.dispose();
  }
}
