import 'package:flutter/material.dart';
import 'package:generation/services/directory_management.dart';
import 'package:record/record.dart';

import '../services/debugging.dart';
import '../services/permission_management.dart';

class SoundRecorderProvider extends ChangeNotifier {
  final _record = Record();
  String? _voiceStoreDirPath;
  bool _isRecording = false;
  final PermissionManagement _permissionManagement = PermissionManagement();

  Future<bool> startRecording() async {
    final _permissionForRecording =
        (await _permissionManagement.recordingPermission()) &&
            (await _permissionManagement.storagePermission());
    if (!_permissionForRecording) return false;

    if (_voiceStoreDirPath == null) {
      _voiceStoreDirPath = await createVoiceStoreDir();
      notifyListeners();
    }

    debug("Voice Store Dir Path: $_voiceStoreDirPath");

    final _voiceStoreFilePath = createAudioFile(dirPath: _voiceStoreDirPath!, name: 'Voice Message');

    debug("Voice Store File PAth: $_voiceStoreFilePath");

    bool result = await _record.hasPermission();

    if (!result) return false;

    // Start recording
    await _record.start(
      path: _voiceStoreFilePath, // required
      encoder: AudioEncoder.AAC, // by default
      bitRate: 128000, // by default
      samplingRate: 44100, // by default
    );

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
    _record.stop();
    super.dispose();
  }
}
