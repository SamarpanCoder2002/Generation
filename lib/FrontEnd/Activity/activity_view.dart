import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';

import 'package:generation_official/BackendAndDatabaseManager/Dataset/data_type.dart';
import 'package:generation_official/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:generation_official/FrontEnd/Activity/animation_controller.dart';

class ActivityView extends StatefulWidget {
  final String takeParticularConnectionUserName;

  ActivityView({@required this.takeParticularConnectionUserName});

  @override
  _ActivityViewState createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView>
    with TickerProviderStateMixin {
  // Regular Expression for Media Detection
  final RegExp _mediaRegex =
      RegExp(r"(http(s?):)|([/|.|\w|\s])*\.(?:jpg|gif|png)");

  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();

  // Important Controller for Activity View
  //VideoPlayerController _videoController;
  PageController _activityPageViewController;
  AnimationController _animationController;

  // Will Take all Activity Collection of Current User
  List<dynamic> _currUserActivityCollection = [];

  // Activity Number Initialized
  int _activityCurrIndex = 0;

  // Helper Function to Call _loadActivity Function
  void _callLoader({int activityPosition = 0}) {
    if (_mediaRegex
        .hasMatch(_currUserActivityCollection[activityPosition]['Status'])) {
      if (_currUserActivityCollection[activityPosition]['Media'] ==
          MediaTypes.Video.toString()) {
        _loadActivity(
            activityType: 'video',
            videoUrl: _currUserActivityCollection[activityPosition]['Status']);
      } else
        _loadActivity(animateToPage: false);
    } else {
      _loadActivity(animateToPage: false);
    }
  }

  void _collectCurrUserActivity() async {
    final List<Map<String, dynamic>> _activityDataCollect =
        await _localStorageHelper.extractActivityForParticularUserName(
            widget.takeParticularConnectionUserName);

    print('Current User Data Collect: $_activityDataCollect');

    if (_activityDataCollect == null || _activityDataCollect.length == 0) {
      if (mounted) {
        setState(() {
          _currUserActivityCollection.add({
            'Status': 'No Activity Present',
            'Status_Time': DateTime.now().toString(),
            'Media': MediaTypes.Text.toString(),
            'Bg_Information': '0+0+0+1.0+25.0',
          });
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _currUserActivityCollection = _activityDataCollect;
        });
      }
    }

    _callLoader(); // Initially Call Loader
  }

  @override
  void initState() {
    // If Have Some Activity of Current User
    if (widget.takeParticularConnectionUserName != null) {
      _collectCurrUserActivity();

      SystemChrome.setEnabledSystemUIOverlays([]); // Android StatusBar Hide

      // For EveryActivity Controller and EveryActivity Animation Controller
      _activityPageViewController = PageController();
      _animationController = AnimationController(vsync: this);

      // Animation Status Initialized with Add Listner Mode
      _animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.stop();
          _animationController.reset();
          if (mounted) {
            setState(() {
              if (_activityCurrIndex + 1 < _currUserActivityCollection.length) {
                _activityCurrIndex += 1;
                _callLoader(activityPosition: _activityCurrIndex);
              } else {
                /// Code For Debugging Purpose
                // _activityCurrIndex = 0; // When All Status Over
                // _callLoader(activityPosition: _activityCurrIndex);

                Navigator.pop(context);
              }
            });
          }
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.takeParticularConnectionUserName != null &&
        _currUserActivityCollection.length > 0) {
      // Some Controller Dispose else may give error after current context getting pop
      //_videoController?.dispose();
      _animationController.dispose();
      _activityPageViewController.dispose();

      SystemChrome.setEnabledSystemUIOverlays(
          SystemUiOverlay.values); // Android StatusBar Show
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      body: activityViewer(),
    );
  }

  Widget activityViewer() {
    try {
      return GestureDetector(
        onTapUp: _onTapUp,
        onTapDown: _onTapDown,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: Stack(
          children: [
            PageView.builder(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              controller: _activityPageViewController,
              itemCount: _currUserActivityCollection.length,
              itemBuilder: (context, i) {
                final Map<String, dynamic> activityItem =
                    _currUserActivityCollection[_activityCurrIndex];

                if (_mediaRegex.hasMatch(activityItem['Status'])) {
                  final String mediaDetector = activityItem[
                      'Media']; // MediaItem(Image/Video) Separated by '++++++'

                  return mediaDetector == MediaTypes.Image.toString()
                      ? imageActivityView(activityItem['Status'],
                          activityItem['ExtraActivityText'])
                      : videoActivityView(activityItem['Status'],
                          activityItem['ExtraActivityText']);
                }
                return textActivityView(activityItem['Bg_Information'],
                    activityItem['Status']); // If Current Activity is not Media
              },
            ),
            Positioned(
              top: 10.0,
              left: 5.0,
              right: 5.0,
              child: Row(
                children: _currUserActivityCollection
                    .asMap()
                    .map((mapIndex, e) {
                      return MapEntry(
                          mapIndex,
                          AnimatedBar(
                            animController: _animationController,
                            position: mapIndex,
                            currentIndex: _activityCurrIndex,
                          ));
                    })
                    .values
                    .toList(),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      print(e.toString());
      return Container(
        color: Color.fromRGBO(34, 48, 60, 1),
        child: Center(
          child: Text(
            "No Activity Present",
            style: TextStyle(
              fontSize: 30.0,
              color: Colors.red,
              fontFamily: 'Lora',
              letterSpacing: 1.0,
            ),
          ),
        ),
      );
    }
  }

  Widget textActivityView(String activityItem, String activityText) {
    List<String> colorAndFontValues = activityItem.split('+');

    final int r = int.parse(colorAndFontValues[0]);
    final int g = int.parse(colorAndFontValues[1]);
    final int b = int.parse(colorAndFontValues[2]);
    final double opacity = double.parse(colorAndFontValues[3]);
    final double fontSize = double.parse(colorAndFontValues[4]);

    return Container(
      color: Color.fromRGBO(r, g, b, opacity),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
      child: Center(
        child: Scrollbar(
          showTrackOnHover: true,
          thickness: 10.0,
          radius: const Radius.circular(30.0),
          child: Text(
            activityText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              color: activityText == 'No Activity Present'
                  ? Colors.red
                  : Colors.white,
              fontFamily: 'Lora',
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget videoActivityView(String videoUrl, String mediaDetector) {
    // if (_videoController != null && _videoController.value.isInitialized) {
    //   return SizedBox(
    //       width: MediaQuery.of(context).size.width,
    //       height: MediaQuery.of(context).size.height,
    //       child: Stack(
    //         children: [
    //           Center(
    //             child: FittedBox(
    //               fit: BoxFit.cover,
    //               child: SizedBox(
    //                 width: _videoController.value.size.width,
    //                 height: _videoController.value.size.height,
    //                 child: Center(),
    //                 //VideoPlayer(_videoController),
    //               ),
    //             ),
    //           ),
    //           bottomTextActivityView(mediaDetector),
    //         ],
    //       ));
    // }

    /// For Video Play Error
    _animationController.duration = Duration(seconds: 5);
    _animationController.forward();
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: CircularProgressIndicator()),
          SizedBox(
            height: 10.0,
          ),
          Center(
            child: Text(
              'Video Playing Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontFamily: 'Lora',
                letterSpacing: 1.0,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget imageActivityView(String imagePath, String extraActivityText) {
    return Stack(
      children: [
        PhotoView(
          imageProvider: FileImage(File(imagePath)),
          loadingBuilder: (context, event) => Center(
            child: CircularProgressIndicator(),
          ),
          errorBuilder: (context, obj, stackTrace) => Center(
              child: Text(
            'Image not Found',
            style: TextStyle(
              fontSize: 23.0,
              color: Colors.red,
              fontFamily: 'Lora',
              letterSpacing: 1.0,
            ),
          )),
          enableRotation: true,
          minScale: 0.5,
        ),
        // Center(
        //   child: Image.file(
        //     File(imagePath),
        //   ),
        //
        // ),
        bottomTextActivityView(extraActivityText),
      ],
    );
  }

  Widget bottomTextActivityView(String extraActivityText) {
    return extraActivityText != ''
        ? Scrollbar(
            showTrackOnHover: true,
            thickness: 10.0,
            child: Container(
              color: const Color.fromRGBO(0, 0, 0, 0.1),
              width: MediaQuery.of(context).size.width,
              height: 100.0,
              padding: const EdgeInsets.only(
                left: 5.0,
                right: 5.0,
                bottom: 3.0,
                top: 3.0,
              ),
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height - 105,
                bottom: 5,
              ),
              alignment: Alignment.center,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Center(
                    child: Text(
                      extraActivityText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : const Center();
  }

  void _loadActivity(
      {String activityType = 'text',
      bool animateToPage = true,
      String videoUrl = ""}) {
    _animationController.stop();
    _animationController.reset();

    print("Url is: $videoUrl");

    if (activityType == 'video') {
      try {
        // _videoController = null;
        // _videoController?.dispose(); // ?. => in a confused or excited state

        // _videoController = VideoPlayerController.network(
        //   videoUrl,
        // )..initialize().then((_) {
        //     setState(() {});
        //
        //     _videoController.setVolume(0.0);
        //
        //     if (_videoController.value.isInitialized) {
        //       _animationController.duration = _videoController.value.duration;
        //       _videoController.play();
        //       _animationController.forward();
        //     } else {
        //       _animationController.duration = Duration(seconds: 5);
        //       _animationController.forward();
        //     }
        //   });
      } catch (e) {
        _animationController.duration = Duration(seconds: 5);
        _animationController.forward();
      }
    } else {
      _animationController.duration = Duration(seconds: 5);
      _animationController.forward();
    }

    if (animateToPage) {
      _activityPageViewController.animateToPage(_activityCurrIndex,
          duration: Duration(milliseconds: 1), curve: Curves.easeInOut);
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (details.primaryVelocity == 0.0) {
      print("Now Work For OnTapUp and OnTapDown");
    } else {
      setState(() {
        if (details.primaryVelocity > 0) {
          if (_activityCurrIndex - 1 >= 0) {
            _activityCurrIndex -= 1;
          }
        } else {
          if (_activityCurrIndex + 1 < _currUserActivityCollection.length) {
            _activityCurrIndex += 1;
          } else {
            Navigator.pop(context);
          }
        }
      });

      if (_activityCurrIndex == _currUserActivityCollection.length) {
        Navigator.pop(context);
      } else {
        _callLoader(activityPosition: _activityCurrIndex);
      }
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (_mediaRegex
        .hasMatch(_currUserActivityCollection[_activityCurrIndex]['Status'])) {
      if (_currUserActivityCollection[_activityCurrIndex]['Media'] ==
          MediaTypes.Video.toString()) {
        // if (_videoController.value.isInitialized) {
        //   _videoController.pause();
        //   _animationController.stop();
        // } else {
        //   _videoController.play();
        //   _animationController.forward();
        // }
      } else {
        _animationController.stop();
      }
    } else
      _animationController.stop();
  }

  void _onTapUp(TapUpDetails details) {
    if (_mediaRegex
        .hasMatch(_currUserActivityCollection[_activityCurrIndex]['Status'])) {
      if (_currUserActivityCollection[_activityCurrIndex]['Media'] ==
          MediaTypes.Video.toString()) {
        // if (_videoController.value.isInitialized) {
        //   _videoController.pause();
        //   _animationController.stop();
        // } else {
        //   _videoController.play();
        //   _animationController.forward();
        // }
      } else {
        _animationController.forward();
      }
    } else
      _animationController.forward();
  }
}
