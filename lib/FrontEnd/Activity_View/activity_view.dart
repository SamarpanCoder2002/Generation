//import 'package:better_player/better_player.dart';
import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';

class ActivityView extends StatefulWidget {
  final List<Map<String, dynamic>> allConnectionActivity;
  final int index;
  final ScrollController storyController;

  ActivityView(this.allConnectionActivity, this.index, this.storyController);

  @override
  _ActivityViewState createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  final RegExp _imageRegex =
      RegExp(r"(http(s?):)|([/|.|\w|\s])*\.(?:jpg|gif|png)");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(0, 0, 0, 1),
      body: statusView(
          widget.allConnectionActivity, widget.index, widget.storyController),
    );
  }

  Widget statusView(List<Map<String, dynamic>> allConnectionActivity, int index,
      ScrollController storyController) {
    int statusCurrIndex = 0;
    try {
      return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        controller: storyController,
        scrollDirection: Axis.horizontal,
        itemCount: allConnectionActivity[index].values.first.length,
        itemBuilder: (context, position) {
          Map<String, dynamic> activityItem =
              allConnectionActivity[index].values.first[position];

          if (_imageRegex.hasMatch(activityItem.keys.first)) {
            print("Yes this is Media");

            print(activityItem.values.first);

            List<String> mediaDetector =
                activityItem.values.first.toString().split('++++++');

            return GestureDetector(
              onHorizontalDragEnd: (DragEndDetails details) async {
                if (details.primaryVelocity == 0.0) {
                  print("Nothing to do");
                } else {
                  if (statusCurrIndex + 1 ==
                      allConnectionActivity[index].values.first.length) {
                    //print("Video Playing State: ${betterPlayerController.isPlaying()}");

                    // if (betterPlayerController.isPlaying()) {
                    //   print("Video Playing");
                    //   betterPlayerController.dispose(forceDispose: true);
                    //   //await betterPlayerController.pause();
                    // }
                    Navigator.pop(context);
                  } else {
                    details.primaryVelocity > 0
                        ? statusCurrIndex -= 1
                        : statusCurrIndex += 1;

                    storyController.animateTo(
                        MediaQuery.of(context).size.width * statusCurrIndex,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut);
                  }
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    mediaDetector[1] == 'image'
                        ? Center(
                            child: CachedNetworkImage(
                              imageUrl: activityItem.keys.first,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              //fit: BoxFit.fitWidth,
                            ),
                          )
                        : SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: Center(
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: BetterPlayer.network(
                                    activityItem.keys.first,
                                    betterPlayerConfiguration:
                                        BetterPlayerConfiguration(
                                      aspectRatio: 16 / 9,
                                      autoDispose: true,
                                      autoPlay: true,
                                    )),
                              ),
                            )),
                    mediaDetector[0] != ''
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
                        : Center(),
                  ],
                ),
              ),
            );
          } else {
            List<String> colorValues =
                activityItem.values.first.toString().split("+");

            int r = int.parse(colorValues[0]);
            int g = int.parse(colorValues[1]);
            int b = int.parse(colorValues[2]);
            double opacity = double.parse(colorValues[3]);
            double fontSize = double.parse(colorValues[4]);

            String activityText = activityItem.keys.first;

            return GestureDetector(
              onHorizontalDragEnd: (DragEndDetails details) {
                print(details.primaryVelocity);
                if (statusCurrIndex + 1 ==
                    allConnectionActivity[index].values.first.length) {
                  Navigator.pop(context);
                } else {
                  if (details.primaryVelocity > 0)
                    statusCurrIndex -= 1;
                  else if (details.primaryVelocity < 0) statusCurrIndex += 1;

                  storyController.animateTo(
                      MediaQuery.of(context).size.width * statusCurrIndex,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut);
                }
              },
              child: Container(
                color: Color.fromRGBO(r, g, b, opacity),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                padding:
                    const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
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
              ),
            );
          }
        },
      );
    } catch (e) {
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
}
