import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SongManagementProvider extends ChangeNotifier {
  String? _currentSongPath;
  String? _showingTime;
  bool _isSongPlaying = false;
  final _justAudioPlayer = AudioPlayer();
  double _currAudioPlayingTime = 0.0;

  setSongPlaying() {
    _isSongPlaying = true;
    notifyListeners();
  }

  unsetSongPlaying() {
    _isSongPlaying = false;
    notifyListeners();
  }

  isSongPlaying() => _isSongPlaying;

  getSongPath() => _currentSongPath ?? "";

  getTotalDuration() =>
      _justAudioPlayer.duration?.inMicroseconds.ceilToDouble() ?? 0.0;

  getCurrentDuration() => _currAudioPlayingTime;

  getShowingTiming() => _showingTime ?? "00:00";

  getCurrentLoadingTime() {
    final _currentTime = getCurrentDuration() / getTotalDuration();
    return _currentTime > 1.0 ? 1.0 : _currentTime;
  }

  _reset() {
    _currAudioPlayingTime = 0.0;
    unsetSongPlaying();
  }

  audioPlaying(String playingSongPath) async {
    try {
      _justAudioPlayer.positionStream.listen((event) {
        _currAudioPlayingTime = event.inMicroseconds.ceilToDouble();
        final minute = event.inMinutes;
        final second = event.inSeconds;
        _showingTime =
            "${minute < 10 ? "0$minute" : minute}:${second < 10 ? "0$second" : second}";
        notifyListeners();
      });

      _justAudioPlayer.playerStateStream.listen((event) {
        if (event.processingState == ProcessingState.completed) {
          _justAudioPlayer.stop();
          _reset();
        }
      });

      if (_currentSongPath != playingSongPath) {
        /// await _justAudioPlayer.setFilePath(playingSongPath);/// use this for local storage file
        await _justAudioPlayer.setUrl(playingSongPath);

        _currentSongPath = playingSongPath;
        setSongPlaying();

        await _justAudioPlayer.play();
      } else {
        print(_justAudioPlayer.processingState);
        if (_justAudioPlayer.processingState == ProcessingState.idle) {
          await _justAudioPlayer.setFilePath(_currentSongPath!);
          setSongPlaying();

          await _justAudioPlayer.play();
        } else if (_justAudioPlayer.playing) {
          unsetSongPlaying();

          await _justAudioPlayer.pause();
        } else if (_justAudioPlayer.processingState == ProcessingState.ready) {
          setSongPlaying();

          await _justAudioPlayer.play();
        } else if (_justAudioPlayer.processingState ==
            ProcessingState.completed) {}
      }
    } catch (e) {
      print('Audio Playing Error');
    }
  }
}
