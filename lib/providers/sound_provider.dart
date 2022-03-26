import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SongManagementProvider extends ChangeNotifier {
  String? _currentSongPath;
  String? _showingTime;
  bool _isSongPlaying = false;
  final _justAudioPlayer = AudioPlayer();
  double _currAudioPlayingTime = 0.0;

  setSongPlaying({bool update = true}) {
    _isSongPlaying = true;
    if(update) notifyListeners();
  }

  unsetSongPlaying({bool update = true}) {
    _isSongPlaying = false;
    if(update) notifyListeners();
  }

  bool isSongPlaying() => _isSongPlaying;
  //bool isSongPlayingNative() => _justAudioPlayer.playing;

  getSongPath() => _currentSongPath ?? "";

  getTotalDuration() =>
      _justAudioPlayer.duration?.inMicroseconds.ceilToDouble() ?? 0.0;

  getCurrentDuration() => _currAudioPlayingTime;

  getShowingTiming() => _showingTime ?? "00:00";

  getCurrentLoadingTime() {
    final _currentTime = getCurrentDuration() / getTotalDuration();
    return _currentTime > 1.0 ? 1.0 : _currentTime;
  }

  _reset({bool update = true}) {
    _currAudioPlayingTime = 0.0;
    unsetSongPlaying(update: update);
  }

  audioPlaying(String playingSongPath, {bool update = true}) async {
    try {
      _justAudioPlayer.positionStream.listen((event) {
        _currAudioPlayingTime = event.inMicroseconds.ceilToDouble();
        final minute = event.inMinutes;
        final second = event.inSeconds;
        _showingTime =
            "${minute < 10 ? "0$minute" : minute}:${second < 10 ? "0$second" : second}";
        if(update) notifyListeners();
      });

      _justAudioPlayer.playerStateStream.listen((event) {
        if (event.processingState == ProcessingState.completed) {
          _justAudioPlayer.stop();
          _reset();
        }
      });


      if (_currentSongPath != playingSongPath) {
        await _justAudioPlayer.setFilePath(playingSongPath);

        /// use this for local storage file
        /// await _justAudioPlayer.setUrl(playingSongPath);/// Use fo Url

        _currentSongPath = playingSongPath;
        setSongPlaying(update: update);

        await _justAudioPlayer.play();
      } else {
        print(_justAudioPlayer.processingState);
        if (_justAudioPlayer.processingState == ProcessingState.idle) {
          await _justAudioPlayer.setFilePath(_currentSongPath!);
          setSongPlaying(update: update);

          await _justAudioPlayer.play();
        } else if (_justAudioPlayer.playing) {
          unsetSongPlaying(update: update);

          await _justAudioPlayer.pause();
        } else if (_justAudioPlayer.processingState == ProcessingState.ready) {
          setSongPlaying(update: update);

          await _justAudioPlayer.play();
        } else if (_justAudioPlayer.processingState ==
            ProcessingState.completed) {
        }
      }
    } catch (e) {
      print('Audio Playing Error: $e');
    }
  }

  stopSong({bool update = true}) async {
    if (!_justAudioPlayer.playing) return;
    _justAudioPlayer.stop();
    _reset(update: update);
    notifyListeners();
  }

  pauseSong() async {
    if (!_justAudioPlayer.playing) return;
    await _justAudioPlayer.pause();
    notifyListeners();
  }

  playSong() async {
    if (_justAudioPlayer.playing) return;
    await _justAudioPlayer.play();
    notifyListeners();
  }

  Future<int?> getDurationInSec(String audioPath) async {
    final _audioDuration = await _justAudioPlayer.setFilePath(audioPath);
    if (_audioDuration == null) return null;

    return _audioDuration.inSeconds;
  }
}
