import 'package:flutter/material.dart';
import 'package:generation/config/text_collection.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/model/activity_model.dart';
import 'package:generation/services/local_data_management.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:provider/provider.dart';

import '../../config/types.dart';
import '../sound_provider.dart';

class ActivityProvider extends ChangeNotifier {
  int _currentPageIndex = 0;
  int _animationBarCurrentIndex = 0;
  int _startFrom = 0;
  PageController _pageController = PageController();
  final LocalStorage _localStorage = LocalStorage();
  final DBOperations _dbOperation = DBOperations();
  late AnimationController _animationController;
  late BuildContext context;
  bool _replyBtnClicked = false;
  List<dynamic> _activityCollection = [];

  startFrom(int incoming) {
    _startFrom = incoming;
    _pageController = PageController(initialPage: incoming);
    _currentPageIndex = incoming;
    _animationBarCurrentIndex = incoming;
    notifyListeners();
  }

  int get getStartingIndex => _startFrom;

  bool isReplyBtnClicked() => _replyBtnClicked;

  updateReplyBtnClicked(bool status) {
    _replyBtnClicked = status;
    notifyListeners();
  }

  getAnimationBarCurrentIndex() => _animationBarCurrentIndex;

  disposeAnimationController() {
    _animationBarCurrentIndex = 0;
    _currentPageIndex = 0;
    notifyListeners();
    _animationController.dispose();
  }

  void _loadActivity() {
    _animationController.stop();
    _animationController.reset();

    final _currentActivityData =
        Provider.of<ActivityProvider>(context, listen: false)
            .getParticularActivity(_currentPageIndex);

    int durationInSec = 5;

    if (_currentActivityData != null) {
      if (_currentActivityData.type == ActivityContentType.video.toString() ||
          _currentActivityData.type == ActivityContentType.audio.toString() ||
          _currentActivityData.type == ActivityContentType.poll.toString()) {
        durationInSec =
            int.parse(_currentActivityData.additionalThings["duration"]);

        if (_currentActivityData.type == ActivityContentType.audio.toString()) {
          durationInSec += 1;
        }
      }
    }

    _animationController.duration = Duration(seconds: durationInSec);
    _animationController.forward();
  }

  initializeAnimationController(
      TickerProvider tickerProvider, BuildContext context) {
    _animationController = AnimationController(vsync: tickerProvider);

    this.context = context;

    if (_animationBarCurrentIndex == 0) _loadActivity();

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.stop();
        _animationController.reset();

        _stopCurrentPlayingActivitySong();

        if (_animationBarCurrentIndex == _activityCollection.length - 1) {
          disposeAnimationController();
          Navigator.pop(context);
        } else {
          setUpdatedIndex(_animationBarCurrentIndex + 1);
          _loadActivity();
        }
      }
    });
  }

  AnimationController getAnimationController() => _animationController;

  addNewActivity(Map<String, dynamic> map, String holderId) {
    _localStorage.insertUpdateTableForActivity(
        tableName: holderId == _dbOperation.currUid
            ? DbData.myActivityTable
            : DataManagement.generateTableNameForNewConnectionActivity(
                holderId),
        activityId: map["id"],
        activityHolderId: map["holderId"],
        activityType: map["type"],
        date: map["date"],
        time: map["time"],
        msg: map["message"],
        additionalData: map["additionalThings"],
        dbOperation: DBOperation.insert);
  }

  getPageController() => _pageController;

  int getPageIndex() => _currentPageIndex;

  setUpdatedIndex(int changedPageIndex) {
    _currentPageIndex = changedPageIndex;
    _animationBarCurrentIndex = changedPageIndex;
    _pageController.animateToPage(changedPageIndex,
        duration: const Duration(milliseconds: 100),
        curve: Curves.fastOutSlowIn);
    _loadActivity();
    notifyListeners();
  }

  forwardOrBackwardActivity(bool isForward, BuildContext context) {
    if (isForward && _currentPageIndex == _activityCollection.length - 1) {
      disposeAnimationController();
      _stopCurrentPlayingActivitySong();
      Navigator.pop(context);
      return;
    }
    if (!isForward && _currentPageIndex == 0) return;

    _stopCurrentPlayingActivitySong();
    setUpdatedIndex(isForward ? _currentPageIndex + 1 : _currentPageIndex - 1);
  }

  setActivityCollection(List<dynamic> incoming) {
    _activityCollection = incoming;
    notifyListeners();
  }

  List<dynamic> getActivityCollection() => _activityCollection;

  int getLengthOfActivityCollection() => _activityCollection.length;

  clearActivityCollection() {
    _activityCollection.clear();
    notifyListeners();
  }

  ActivityModel? getParticularActivity(index) {
    if (index > _activityCollection.length - 1) return null;

    final _activityData = _activityCollection[index];
    return ActivityModel.getJson(
        type: _activityData["type"],
        holderId: _activityData["holderId"],
        date: _activityData["date"],
        time: _activityData["time"],
        message: _activityData["message"],
        additionalThings: _activityData["additionalThings"] == null
            ? {}
            : DataManagement.fromJsonString(_activityData["additionalThings"]),
        id: _activityData["id"]);
  }

  pauseActivityAnimation() {
    _animationController.stop();
    notifyListeners();
  }

  resumeActivityAnimation() {
    _animationController.forward();
    notifyListeners();
  }

  resumeAnimationForNewest(int newestIndex) {
    final _newestActivityData = Provider.of<ActivityProvider>(context)
        .getParticularActivity(newestIndex);

    int durationInSec = 5;

    if (_newestActivityData != null) {
      if (_newestActivityData.type == ActivityContentType.video.toString() ||
          _newestActivityData.type == ActivityContentType.audio.toString() ||
          _newestActivityData.type == ActivityContentType.poll.toString()) {
        durationInSec =
            int.parse(_newestActivityData.additionalThings["duration"]);

        if (_newestActivityData.type == ActivityContentType.audio.toString()) {
          durationInSec += 1;
        }
      }
    }

    _animationController.duration = Duration(seconds: durationInSec);
    _animationController.forward();
  }

  void _stopCurrentPlayingActivitySong() {
    final _isPlaying =
        Provider.of<SongManagementProvider>(context, listen: false)
            .isSongPlaying();
    if (_isPlaying) {
      Provider.of<SongManagementProvider>(context, listen: false)
          .stopSong(update: false);
    }
  }
}
