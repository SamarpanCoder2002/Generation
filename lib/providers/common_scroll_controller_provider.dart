import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MessageScreenScrollingProvider extends ChangeNotifier {
  final ScrollController? _scrollController = ScrollController();
  bool _isMainAppBarVisible = true;

  getScrollController() => _scrollController;

  startListening() => _scrollController?.addListener(_listener);

  stopListening() => _scrollController?.removeListener(_listener);

  isMainAppBarVisible() => _isMainAppBarVisible;

  @override
  void dispose() {
    stopListening();
    _scrollController?.dispose();
    super.dispose();
  }

  void _listener() {
    final scrollDirection = _scrollController?.position.userScrollDirection;

    if (scrollDirection == ScrollDirection.forward) {
      _isMainAppBarVisible = true;
      notifyListeners();
    } else if (scrollDirection == ScrollDirection.reverse) {
      _isMainAppBarVisible = false;
      notifyListeners();
    }
  }
}
