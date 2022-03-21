import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ChatScrollProvider extends ChangeNotifier {
  final ScrollController _scrollController = ScrollController();

  getController() => _scrollController;

  animateToBottom({scrollDuration = 750, bool shouldNotify = true}) {
    if(!_scrollController.hasClients || !_scrollController.hasListeners) return;

    Timer(const Duration(milliseconds: 100), () {
      _scrollController
          .animateTo(
        _scrollController.position.maxScrollExtent,
        curve: Curves.fastLinearToSlowEaseIn,
        duration: Duration(milliseconds: scrollDuration),
      )
          .whenComplete(() {
       if(shouldNotify) notifyListeners();
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

    if (scrollDirection == ScrollDirection.forward) {
      _isMainAppBarVisible = false;
      notifyListeners();
    } else if (scrollDirection == ScrollDirection.reverse) {
      _isMainAppBarVisible = true;
      notifyListeners();
    }
  }
}
