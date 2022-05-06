import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ChatScrollProvider extends ChangeNotifier {
  final ScrollController _scrollController = ScrollController();
  bool _comeAtTop = false;

  getController() => _scrollController;

  animateToBottom(
      {scrollDuration = 750, bool shouldNotify = true, int milliSec = 100}) {
    if (!_scrollController.hasClients || !_scrollController.hasListeners) {
      return;
    }

    Timer(Duration(milliseconds: milliSec), () {
      _scrollController
          .animateTo(
        _scrollController.position.maxScrollExtent,
        curve: Curves.fastLinearToSlowEaseIn,
        duration: Duration(milliseconds: scrollDuration),
      )
          .whenComplete(() {
        if (shouldNotify) notifyListeners();
      });
    });
  }

  bool _isMainAppBarVisible = true;

  startListening() => _scrollController.addListener(_listener);

  stopListening() => _scrollController.removeListener(_listener);

  isMainAppBarVisible() => _isMainAppBarVisible;

  @override
  void dispose() {
    stopListening();
    _scrollController.dispose();
    super.dispose();
  }

  void _listener() {
    final scrollDirection = _scrollController.position.userScrollDirection;

    if (!_comeAtTop && _scrollController.position.pixels == 0) {
      print("At Top of Chat Messaging Section");
      /// Call Next Amount of local messages from here
      _comeAtTop = true;
      notifyListeners();
    }

    if (scrollDirection == ScrollDirection.forward) {
      if (_scrollController.position.pixels > 800) _comeAtTop = false;
      _isMainAppBarVisible = false;
      notifyListeners();
    } else if (scrollDirection == ScrollDirection.reverse) {
      _isMainAppBarVisible = true;
      notifyListeners();
    }
  }
}