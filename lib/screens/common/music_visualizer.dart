import "package:flutter/material.dart";

class MusicVisualizer extends StatelessWidget {
  final List<Color>? colors;
  final List<int>? duration;
  final int? barCount;
  final Curve? curve;

  const MusicVisualizer({
    Key? key,
    @required this.colors,
    @required this.duration,
    @required this.barCount,
    this.curve = Curves.easeInQuad,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List<Widget>.generate(
            barCount!,
                (index) => VisualComponent(
                curve: curve!,
                duration: duration![index % 5],
                color: colors![index % 4])));
  }
}

class VisualComponent extends StatefulWidget {
  final int? duration;
  final Color? color;
  final Curve? curve;

  const VisualComponent(
      {Key? key,
        @required this.duration,
        @required this.color,
        @required this.curve})
      : super(key: key);

  @override
  _VisualComponentState createState() => _VisualComponentState();
}

class _VisualComponentState extends State<VisualComponent>
    with SingleTickerProviderStateMixin {
  Animation<double>? animation;
  AnimationController? animationController;

  @override
  void initState() {
    super.initState();
    animate();
  }

  @override
  void dispose() {
    animation!.removeListener(() {});
    animation!.removeStatusListener((status) {});
    animationController!.stop();
    animationController!.reset();
    animationController!.dispose();
    super.dispose();
  }

  void animate() {
    animationController = AnimationController(
        duration: Duration(milliseconds: widget.duration!), vsync: this);
    final curvedAnimation =
    CurvedAnimation(parent: animationController!, curve: widget.curve!);
    animation = Tween<double>(begin: 0, end: 50).animate(curvedAnimation)
      ..addListener(() {
        update();
      });
    animationController!.repeat(reverse: true);
  }

  void update() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: animation!.value,
      decoration: BoxDecoration(
          color: widget.color, borderRadius: BorderRadius.circular(5)),
    );
  }
}
