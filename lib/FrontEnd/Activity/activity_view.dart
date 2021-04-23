import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:generation/FrontEnd/Activity/animation_controller.dart';

class ActivityView extends StatefulWidget {
  final List<Map<String, dynamic>> allConnectionActivity;
  final int index;

  ActivityView(this.allConnectionActivity, this.index);

  @override
  _ActivityViewState createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView>
    with TickerProviderStateMixin {
  // Regular Expression for Media Detection
  final RegExp _mediaRegex =
      RegExp(r"(http(s?):)|([/|.|\w|\s])*\.(?:jpg|gif|png)");

  // Important Controller for Activity View
  VideoPlayerController _videoController;
  PageController _activityPageViewController;
  AnimationController _animationController;

  // Will Take all Activity Collection of Current User
  List<dynamic> _currUserActivityCollection;

  // Activity Number Initialized
  int _activityCurrIndex = 0;

  // Helper Function to Call _loadActivity Function
  void _callLoader({int activityPosition = 0}) {
    if (_mediaRegex
        .hasMatch(_currUserActivityCollection[activityPosition].keys.first)) {
      if (_currUserActivityCollection[activityPosition]
              .values
              .first
              .toString()
              .split('++++++')[1] ==
          'video') {
        _loadActivity(
            activityType: 'video',
            videoUrl: _currUserActivityCollection[activityPosition].keys.first);
      } else
        _loadActivity(animateToPage: false);
    } else {
      _loadActivity(animateToPage: false);
    }
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]); // Android StatusBar Hide

    // If Have Some Activity of Current User
    if (widget.allConnectionActivity[widget.index].length > 0) {
      // For EveryActivity Controller and EveryActivity Animation Controller
      _activityPageViewController = PageController();
      _animationController = AnimationController(vsync: this);

      // Take All Activity Collection of Current User
      _currUserActivityCollection =
          widget.allConnectionActivity[widget.index].values.first;

      _callLoader(); // Initially Call Loader

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
    // TODO: implement dispose

    // Some Controller Dispose else may give error after current context getting pop
    _videoController?.dispose();
    _animationController.dispose();
    _activityPageViewController.dispose();

    SystemChrome.setEnabledSystemUIOverlays(
        SystemUiOverlay.values); // Android StatusBar Show

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

                if (_mediaRegex.hasMatch(activityItem.keys.first)) {
                  final List<String> mediaDetector = activityItem.values.first
                      .toString()
                      .split(
                          '++++++'); // MediaItem(Image/Video) Separated by '++++++'
                  return mediaDetector[1] == 'image'
                      ? imageActivityView(
                          activityItem.keys.first, mediaDetector)
                      : videoActivityView(
                          activityItem.keys.first, mediaDetector);
                }
                return textActivityView(
                    activityItem); // If Current Activity is not Media
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

  Widget textActivityView(Map<String, dynamic> activityItem) {
    List<String> colorValues = activityItem.values.first.toString().split("+");

    int r = int.parse(colorValues[0]);
    int g = int.parse(colorValues[1]);
    int b = int.parse(colorValues[2]);
    double opacity = double.parse(colorValues[3]);
    double fontSize = double.parse(colorValues[4]);

    String activityText = activityItem.keys.first;

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
              color: Colors.white,
              fontFamily: 'Lora',
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget videoActivityView(String videoUrl, List<String> mediaDetector) {
    if (_videoController != null && _videoController.value.isInitialized) {
      return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Center(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              ),
              bottomTextActivityView(mediaDetector),
            ],
          ));
    }

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

  Widget imageActivityView(String imageUrl, List<String> mediaDetector) {
    return Stack(
      children: [
        Center(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            //fit: BoxFit.fitWidth,
          ),
        ),
        bottomTextActivityView(mediaDetector),
      ],
    );
  }

  Widget bottomTextActivityView(List<String> mediaDetector) {
    return mediaDetector[0] != ''
        ? Scrollbar(
            showTrackOnHover: true,
            thickness: 10.0,
            child: Container(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              padding: EdgeInsets.only(
                left: 5.0,
                right: 5.0,
                bottom: 5.0,
              ),
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height - 105,
                bottom: 5,
              ),
              height: 100.0,
              //alignment: Alignment.bottomCenter,
              child: ListView(
                children: [
                  Center(
                    child: Text(
                      mediaDetector[0],
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Center();
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
        _videoController = null;
        _videoController?.dispose(); // ?. => in a confused or excited state

        _videoController = VideoPlayerController.network(
          videoUrl,
        )..initialize().then((_) {
            setState(() {});

            _videoController.setVolume(0.0);
            if (_videoController.value.isInitialized) {
              _animationController.duration = _videoController.value.duration;
              _videoController.play();
              _animationController.forward();
            } else {
              _animationController.duration = Duration(seconds: 5);
              _animationController.forward();
            }
          });
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
        .hasMatch(_currUserActivityCollection[_activityCurrIndex].keys.first)) {
      if (_currUserActivityCollection[_activityCurrIndex]
              .values
              .first
              .toString()
              .split('++++++')[1] ==
          'video') {
        if (_videoController.value.isInitialized) {
          _videoController.pause();
          _animationController.stop();
        } else {
          _videoController.play();
          _animationController.forward();
        }
      } else {
        _animationController.stop();
      }
    } else
      _animationController.stop();
  }

  void _onTapUp(TapUpDetails details) {
    if (_mediaRegex
        .hasMatch(_currUserActivityCollection[_activityCurrIndex].keys.first)) {
      if (_currUserActivityCollection[_activityCurrIndex]
              .values
              .first
              .toString()
              .split('++++++')[1] ==
          'video') {
        if (_videoController.value.isInitialized) {
          _videoController.pause();
          _animationController.stop();
        } else {
          _videoController.play();
          _animationController.forward();
        }
      } else {
        _animationController.forward();
      }
    } else
      _animationController.forward();
  }
}
