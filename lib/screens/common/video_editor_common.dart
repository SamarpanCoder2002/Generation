import 'dart:async';

import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/providers/video_management/video_editing_provider.dart';
import 'package:generation/screens/activity/create/create_activity.dart';
import 'package:generation/services/navigation_management.dart';
import 'package:provider/provider.dart';
import 'package:video_editor/video_editor.dart';

import '../../types/types.dart';

class VideoEditingScreen extends StatefulWidget {
  final String path;
  final String thumbnailPath;
  final VideoType videoType;
  final int durationInSecond;

  const VideoEditingScreen(
      {Key? key,
      required this.path,
      required this.videoType,
      required this.thumbnailPath,
      this.durationInSecond = 30})
      : super(key: key);

  @override
  _VideoEditingScreenState createState() => _VideoEditingScreenState();
}

class _VideoEditingScreenState extends State<VideoEditingScreen> {
  final double height = 60;

  @override
  void initState() {
    Provider.of<VideoEditingProvider>(context, listen: false)
        .initialize(widget.path, widget.durationInSecond);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _controller =
        Provider.of<VideoEditingProvider>(context).getController();

    if (_controller == null) return const Center();

    return WillPopScope(
      onWillPop: () async {
        Provider.of<VideoEditingProvider>(context, listen: false).destructor();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDarkMode,
        body: _controller.initialized
            ? SafeArea(
                child: Stack(children: [
                Column(children: [
                  _topNavBar(),
                  Expanded(
                      child: DefaultTabController(
                          length: 2,
                          child: Column(children: [
                            _realVideoViewWithTabBarView(),
                            _bottomTabBarHeading(),
                            //_customSnackBar(),
                            _videoExportingStatus(),
                          ])))
                ])
              ]))
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _topNavBar() {
    final _controller =
        Provider.of<VideoEditingProvider>(context).getController();

    if (_controller == null) return const Center();

    _commonOption({required IconData iconData, required VoidCallback onTap}) =>
        Expanded(
          child: InkWell(
            onTap: onTap,
            child: Icon(
              iconData,
              color: AppColors.pureWhiteColor,
            ),
          ),
        );

    return SafeArea(
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            _commonOption(
                iconData: Icons.rotate_left,
                onTap: () => _controller.rotate90Degrees(RotateDirection.left)),
            _commonOption(
                iconData: Icons.rotate_right,
                onTap: () =>
                    _controller.rotate90Degrees(RotateDirection.right)),
            _commonOption(iconData: Icons.crop, onTap: _openCropScreen),
            //_commonOption(iconData: Icons.save_alt, onTap: _exportCover),
            _commonOption(
                iconData: Icons.done_outline_outlined, onTap: _exportVideo),
          ],
        ),
      ),
    );
  }

  void _openCropScreen() => Navigation.intent(
      context,
      CropScreen(
          controller:
              Provider.of<VideoEditingProvider>(context).getController()));

  void _exportVideo() async {
    final VideoEditorController _controller =
        Provider.of<VideoEditingProvider>(context, listen: false)
            .getController();

    Provider.of<VideoEditingProvider>(context, listen: false)
        .updateIsExportingValue(true);

    bool _firstStat = true;

    await _controller.exportVideo(
      onProgress: (statics) {
        print("First: ${statics.getTime()}");
        if (_firstStat) {
          _firstStat = false;
        } else {
          print("Get Time: ${statics.getTime()}");
          Provider.of<VideoEditingProvider>(context, listen: false)
              .updateExportingProgress(statics.getTime() /
                  _controller.video.value.duration.inMilliseconds);
        }
      },
      onCompleted: (file) async {
        Provider.of<VideoEditingProvider>(context, listen: false)
            .updateIsExportingValue(false);

        if (!mounted) return;
        if (file != null) {
          final _getVideoDuration =
              await Provider.of<VideoEditingProvider>(context, listen: false)
                  .getVideoDuration(file);

          Navigation.intent(
              context,
              CreateActivity(activityType: ActivityType.video, data: {
                "file": file,
                "thumbnail": widget.thumbnailPath,
                "duration": _getVideoDuration.inSeconds.ceil().toString()
              }));

          Provider.of<VideoEditingProvider>(context, listen: false)
              .updatedExportedText("Video Successfully Exported!");
        } else {
          Provider.of<VideoEditingProvider>(context, listen: false)
              .updatedExportedText("Error in Video Export!");
        }

        Provider.of<VideoEditingProvider>(context, listen: false)
            .updatedExportedValue(true);
        Future.delayed(
            const Duration(seconds: 2),
            () => Provider.of<VideoEditingProvider>(context, listen: false)
                .updatedExportedValue(false));
      },
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    final _controller =
        Provider.of<VideoEditingProvider>(context).getController();

    return _controller == null
        ? const []
        : [
            AnimatedBuilder(
              animation: _controller.video,
              builder: (_, __) {
                final duration = _controller.video.value.duration.inSeconds;
                final pos = _controller.trimPosition * duration;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: height / 4),
                  child: Row(children: [
                    Text(
                      formatter(Duration(seconds: pos.toInt())),
                      style: TextStyleCollection.terminalTextStyle,
                    ),
                    const Expanded(child: SizedBox()),
                    // OpacityTransition(
                    //   visible: _controller.isTrimming,
                    //   child: Row(mainAxisSize: MainAxisSize.min, children: [
                    //     Text(
                    //       formatter(Duration(seconds: start.toInt())),
                    //       style: TextStyleCollection.terminalTextStyle,
                    //     ),
                    //     const SizedBox(width: 10),
                    //     Text(
                    //       formatter(Duration(seconds: end.toInt())),
                    //       style: TextStyleCollection.terminalTextStyle,
                    //     ),
                    //   ]),
                    // )
                  ]),
                );
              },
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(vertical: height / 4),
              child: TrimSlider(
                  child: TrimTimeline(
                      controller: _controller,
                      margin: const EdgeInsets.only(top: 10)),
                  controller: _controller,
                  height: height,
                  horizontalMargin: height / 4),
            )
          ];
  }

  _realVideoViewWithTabBarView() {
    final _controller =
        Provider.of<VideoEditingProvider>(context).getController();

    return _controller == null
        ? const Center()
        : Expanded(
            child: Stack(alignment: Alignment.center, children: [
            CropGridViewer(
              controller: _controller,
              showGrid: false,
            ),
            if (!_controller.isPlaying)
              InkWell(
                onTap: _controller.video.play,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow,
                      color: AppColors.pureBlackColor),
                ),
              ),
          ]));
  }

  _bottomTabBarHeading() {
    return Container(
        height: 200,
        margin: const EdgeInsets.only(top: 10),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Padding(
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.content_cut,
                  color: AppColors.pureWhiteColor,
                )),
            Text(
              'Trim',
              style:
                  TextStyleCollection.terminalTextStyle.copyWith(fontSize: 14),
            )
          ]),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _trimSlider()),
        ]));
  }

  _videoExportingStatus() {
    return ValueListenableBuilder(
      valueListenable: Provider.of<VideoEditingProvider>(context).isExporting(),
      builder: (_, bool showing, __) => !showing
          ? const Center()
          : AlertDialog(
              backgroundColor: AppColors.oppositeMsgDarkModeColor,
              title: ValueListenableBuilder(
                valueListenable: Provider.of<VideoEditingProvider>(context)
                    .exportingProgress(),
                builder: (_, double value, __) => Center(
                  child: Text(
                    "Exporting video ${(value * 100).ceil()}%",
                    style: TextStyleCollection.terminalTextStyle
                        .copyWith(fontSize: 16),
                  ),
                ),
              ),
            ),
    );
  }
}

//-----------------//
//CROP VIDEO SCREEN//
//-----------------//
class CropScreen extends StatelessWidget {
  const CropScreen({Key? key, required this.controller}) : super(key: key);

  final VideoEditorController? controller;

  @override
  Widget build(BuildContext context) {
    if (controller == null) return const Center();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(children: [
            _inputSection(),
            const SizedBox(height: 15),
            _cropViewer(),
            const SizedBox(height: 15),
            _cropOptions(context),
          ]),
        ),
      ),
    );
  }

  _inputSection() => controller == null
      ? const Center()
      : Row(children: [
          Expanded(
            child: InkWell(
              onTap: () => controller!.rotate90Degrees(RotateDirection.left),
              child: const Icon(Icons.rotate_left),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => controller!.rotate90Degrees(RotateDirection.right),
              child: const Icon(Icons.rotate_right),
            ),
          )
        ]);

  _cropViewer() => controller == null
      ? const Center()
      : Expanded(
          child: CropGridViewer(controller: controller!, horizontalMargin: 60),
        );

  _cropOptions(context) => Row(children: [
        _cancelCrop(context),
        buildSplashTap("16:9", 16 / 9,
            padding: const EdgeInsets.symmetric(horizontal: 10)),
        buildSplashTap("1:1", 1 / 1),
        buildSplashTap("4:5", 4 / 5,
            padding: const EdgeInsets.symmetric(horizontal: 10)),
        buildSplashTap("NO", null, padding: const EdgeInsets.only(right: 10)),
        _makeCrop(context),
      ]);

  Widget buildSplashTap(
    String title,
    double? aspectRatio, {
    EdgeInsetsGeometry? padding,
  }) {
    return InkWell(
      onTap: () => controller == null
          ? const Center()
          : controller!.preferredCropAspectRatio = aspectRatio,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.aspect_ratio, color: AppColors.lightRedColor),
            Text(
              title,
              style: TextStyleCollection.secondaryHeadingTextStyle,
            ),
          ],
        ),
      ),
    );
  }

  _cancelCrop(context) => Expanded(
        child: InkWell(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: Text(
              "CANCEL",
              style:
                  TextStyleCollection.terminalTextStyle.copyWith(fontSize: 14),
            ),
          ),
        ),
      );

  _makeCrop(context) => Expanded(
        child: InkWell(
          onTap: () {
            //2 WAYS TO UPDATE CROP
            //WAY 1:

            if (controller == null) return;

            controller!.updateCrop();
            /*WAY 2:
                    controller.minCrop = controller.cacheMinCrop;
                    controller.maxCrop = controller.cacheMaxCrop;
                    */

            Navigator.pop(context);
          },
          child: Center(
            child: Text(
              "OK",
              style:
                  TextStyleCollection.terminalTextStyle.copyWith(fontSize: 14),
            ),
          ),
        ),
      );
}
