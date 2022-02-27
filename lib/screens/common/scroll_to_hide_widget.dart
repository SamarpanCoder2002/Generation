import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../config/size_collection.dart';

class ScrollToHideWidget extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;
  final Duration duration;
  final double height;

  const ScrollToHideWidget(
      {Key? key,
      required this.child,
      required this.scrollController,
      this.height = SizeCollection.kBottomNavigationBarHeight,
      this.duration = const Duration(milliseconds: 200)})
      : super(key: key);

  @override
  _ScrollToHideWidgetState createState() => _ScrollToHideWidgetState();
}

class _ScrollToHideWidgetState extends State<ScrollToHideWidget> {
  bool _isVisible = true;

  @override
  void initState() {
    widget.scrollController.addListener(listener);
    super.initState();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(listener);
    super.dispose();
  }

  void listener() {
    final scrollDirection =
        widget.scrollController.position.userScrollDirection;
    if (scrollDirection == ScrollDirection.forward) {
      show();
    } else if (scrollDirection == ScrollDirection.reverse) {
      hide();
    }
  }

  show() {
    if (!_isVisible && mounted) {
      setState(() => _isVisible = true);
    }
  }

  hide() {
    if (_isVisible && mounted) {
      setState(() => _isVisible = false);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: widget.duration,
        child: Wrap(children: [widget.child]),
        height: _isVisible ? widget.height : 0,
      );
}
