import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AnimatedBar extends StatelessWidget {
  final AnimationController animController;
  final int position;
  final int currentIndex;

  const AnimatedBar({
    Key key,
    @required this.animController,
    @required this.position,
    @required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Flexible(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: <Widget>[
              _buildLoadingContainer(
                double.infinity,
                position < currentIndex
                    ? Colors.lightGreenAccent
                    : Colors.white,
              ),
              position == currentIndex
                  ? AnimatedBuilder(
                      animation: animController,
                      builder: (context, child) {
                        return _buildLoadingContainer(
                          constraints.maxWidth * animController.value,
                          null,
                          linearGradient: LinearGradient(colors: [
                            Colors.redAccent,
                            Colors.lightGreenAccent,
                          ]),
                        );
                      },
                    )
                  : const SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }

  Container _buildLoadingContainer(double width, Color color,
      {LinearGradient linearGradient}) {
    return Container(
      height: 5.0,
      width: width,
      decoration: BoxDecoration(
        color: color,
        gradient: linearGradient,
        border: Border.all(
          color: Colors.black26,
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(3.0),
      ),
    );
  }
}
