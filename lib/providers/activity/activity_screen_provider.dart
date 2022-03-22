import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/model/activity_model.dart';
import 'package:generation/types/types.dart';

class ActivityProvider extends ChangeNotifier {
  int _currentPageIndex = 0;
  int _animationBarCurrentIndex = 0;
  final PageController _pageController = PageController();
  late AnimationController _animationController;

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

    _animationController.duration = const Duration(seconds: 5);
    _animationController.forward();
  }

  initializeAnimationController(
      TickerProvider tickerProvider, BuildContext context) {
    _animationController = AnimationController(vsync: tickerProvider);

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

  List<dynamic> _activityCollection = [
    {
      "type": ActivityType.text.toString(),
      "message": "Samarpan Dasgupta is a Passionate Programmer.",
      "date": "21 March, 2022",
      "time": "08:10 PM",
      "holderId": "1",
      "additionalThings": {
        "backgroundColor": Colors.blueAccent,
        "textColor": AppColors.pureWhiteColor
      }
    },
    {
      "type": ActivityType.image.toString(),
      "message":
          "https://pbs.twimg.com/profile_images/1278494917174587392/TKQueGE7_400x400.jpg",
      "date": "21 March, 2022",
      "time": "08:10 PM",
      "holderId": "2"
    },
    {
      "type": ActivityType.text.toString(),
      "message": "Samarpan Dasgupta is a Passionate Programmer.",
      "date": "21 March, 2022",
      "time": "08:10 PM",
      "holderId": "3",
      "additionalThings": {
        "backgroundColor": Colors.lightBlue,
        "textColor": Colors.black
      }
    },
    {
      "type": ActivityType.image.toString(),
      "message":
          "https://pbs.twimg.com/profile_images/1278494917174587392/TKQueGE7_400x400.jpg",
      "date": "21 March, 2022",
      "time": "08:10 PM",
      "holderId": "4"
    },
    {
      "type": ActivityType.text.toString(),
      "message": "Samarpan Dasgupta is a Passionate Programmer.",
      "date": "21 March, 2022",
      "time": "08:10 PM",
      "holderId": "5",
      "additionalThings": {
        "backgroundColor": Colors.blueAccent,
        "textColor": AppColors.pureWhiteColor
      }
    },
    {
      "type": ActivityType.image.toString(),
      "message":
          "https://pbs.twimg.com/profile_images/1278494917174587392/TKQueGE7_400x400.jpg",
      "date": "21 March, 2022",
      "time": "08:10 PM",
      "holderId": "6"
    },
    {
      "type": ActivityType.text.toString(),
      "message": "Samarpan Dasgupta is a Passionate Programmer.",
      "date": "21 March, 2022",
      "time": "08:10 PM",
      "holderId": "7",
      "additionalThings": {
        "backgroundColor": Colors.lightBlue,
        "textColor": Colors.black
      }
    },
    {
      "type": ActivityType.image.toString(),
      "message":
          "https://pbs.twimg.com/profile_images/1278494917174587392/TKQueGE7_400x400.jpg",
      "date": "21 March, 2022",
      "time": "08:10 PM",
      "holderId": "8"
    },
  ];

  setActivityCollection(List<dynamic> incoming){
    _activityCollection = incoming;
    notifyListeners();
  }

  addNewActivity(incoming){
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

  ActivityModel getParticularActivity(index) {
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
