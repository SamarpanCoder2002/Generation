import 'package:flutter/material.dart';
import 'package:generation/model/activity_model.dart';
import 'package:generation/providers/time_provider.dart';
import 'package:provider/provider.dart';

import '../../types/types.dart';

class ActivityProvider extends ChangeNotifier {
  int _currentPageIndex = 0;
  int _animationBarCurrentIndex = 0;
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late BuildContext context;

  final List<String> _monthCollection = [
    "Jan",
    "Feb",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "Sept",
    "Oct",
    "Nov",
    "Dec"
  ];

  getParticularMonth(index) => _monthCollection[index];

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
      durationInSec = _currentActivityData.type == ActivityContentType.video.toString()
          ? int.parse(_currentActivityData.additionalThings["duration"])
          : 5;
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

  getAnimationController() => _animationController;

  List<dynamic> _activityCollection = [];

  setActivityCollection(List<dynamic> incoming) {
    _activityCollection = incoming;
    notifyListeners();
  }

  addNewActivity(incoming) {
    _activityCollection.add(incoming);
    notifyListeners();
  }

  getPageController() => _pageController;

  getPageIndex() => _currentPageIndex;

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
      Navigator.pop(context);
      return;
    }
    if (!isForward && _currentPageIndex == 0) return;

    setUpdatedIndex(isForward ? _currentPageIndex + 1 : _currentPageIndex - 1);
  }

  getActivityCollection() => _activityCollection;

  getLengthOfActivityCollection() => _activityCollection.length;

  ActivityModel? getParticularActivity(index) {
    if (index > _activityCollection.length - 1) return null;

    final _activityData = _activityCollection[index];
    return ActivityModel.getJson(
        type: _activityData["type"],
        holderId: _activityData["holderId"],
        date: _activityData["date"],
        time: _activityData["time"],
        message: _activityData["message"],
        additionalThings: _activityData["additionalThings"] ?? {});
  }

  pauseActivityAnimation() {
    _animationController.stop();
    notifyListeners();
  }

  resumeActivityAnimation() {
    _animationController.forward();
    notifyListeners();
  }
}
