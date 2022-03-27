import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/model/activity_model.dart';
import 'package:generation/providers/activity/poll_show_provider.dart';
import 'package:generation/screens/common/video_show_screen.dart';
import 'package:generation/types/types.dart';
import 'package:music_visualizer/music_visualizer.dart';
import 'package:photo_view/photo_view.dart';
import 'package:polls/polls.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/time_collection.dart';
import '../../../providers/activity/activity_screen_provider.dart';
import '../../../providers/sound_provider.dart';

class ActivityViewer extends StatefulWidget {
  final ActivityModel activityData;

  const ActivityViewer({Key? key, required this.activityData})
      : super(key: key);

  @override
  State<ActivityViewer> createState() => _ActivityViewerState();
}

class _ActivityViewerState extends State<ActivityViewer> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);

    if (widget.activityData.type == ActivityContentType.audio.toString()) {
      Provider.of<SongManagementProvider>(context, listen: false)
          .audioPlaying(widget.activityData.message);
    }
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final _scrollDirection = _scrollController.position.userScrollDirection;

    if (ScrollDirection.values.contains(_scrollDirection)) {
      Provider.of<ActivityProvider>(context, listen: false)
          .pauseActivityAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final bool _isSongPlaying =
            Provider.of<SongManagementProvider>(context, listen: false)
                .isSongPlaying();

        print("Here: $_isSongPlaying");

        if (_isSongPlaying) {
          Provider.of<SongManagementProvider>(context, listen: false)
              .stopSong(update: false);
        }

        return true;
      },
      child: Scaffold(
        body: _getCurrentActivity(),
      ),
    );
  }

  _getCurrentActivity() {
    if (widget.activityData.type == ActivityContentType.text.toString()) {
      return _textActivityShow();
    } else if (widget.activityData.type ==
        ActivityContentType.image.toString()) {
      return _imageActivityShow();
    } else if (widget.activityData.type ==
        ActivityContentType.video.toString()) {
      return _videoActivityShow();
    } else if (widget.activityData.type ==
        ActivityContentType.audio.toString()) {
      return _audioActivityShow();
    } else if (widget.activityData.type ==
        ActivityContentType.poll.toString()) {
      return _pollActivityShow();
    }
  }

  _textActivityShow() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: widget.activityData.additionalThings["backgroundColor"],
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            widget.activityData.message,
            overflow: TextOverflow.ellipsis,
            maxLines: 20,
            textAlign: TextAlign.center,
            style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
                fontSize: 20,
                color: widget.activityData.additionalThings["textColor"]),
          ),
        ),
      ),
    );
  }

  _imageActivityShow() {
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: PhotoView(
            imageProvider: FileImage(File(widget.activityData.message)),
            loadingBuilder: (_, __) => Center(
              child: Text(
                "Loading...",
                style: TextStyleCollection.terminalTextStyle
                    .copyWith(fontSize: 16),
              ),
            ),
            errorBuilder: (_, __, ___) => Center(
              child: Text(
                "Error...",
                style: TextStyleCollection.terminalTextStyle
                    .copyWith(fontSize: 16),
              ),
            ),
          ),
        ),
        _bottomExtraTextSection(),
      ],
    );
  }

  _bottomExtraTextSection() {
    if (widget.activityData.additionalThings["text"] == null ||
        widget.activityData.additionalThings["text"] == "") {
      return const Center();
    }

    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: AppColors.pureBlackColor.withOpacity(0.2),
          alignment: Alignment.center,
          height: 150,
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              child: Linkify(
                text: widget.activityData.additionalThings["text"],
                onOpen: (link) async {
                  try {
                    await launch(link.url);
                  } catch (e) {
                    throw 'Could not launch $link';
                  }
                },
                linkStyle: TextStyleCollection.terminalTextStyle
                    .copyWith(fontSize: 16),
                style: TextStyleCollection.terminalTextStyle
                    .copyWith(fontSize: 16),
                options: const LinkifyOptions(humanize: false),
              )),
        ));
  }

  _videoActivityShow() {
    return Stack(
      children: [
        VideoShowScreen(file: File(widget.activityData.message)),
        _bottomExtraTextSection(),
      ],
    );
  }

  _audioActivityShow() {
    return Stack(
      children: [
        _audioShowScreen(),
        _bottomExtraTextSection(),
      ],
    );
  }

  _audioShowScreen() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      color: AppColors.pureBlackColor,
      child: MusicVisualizer(
        barCount: 30,
        colors: WaveForm.colors,
        duration: Timings.waveFormDuration,
      ),
    );
  }

  _pollActivityShow() {
    return Stack(
      children: [
        _pollShowScreen(),
        //Text("Samarpan" , style: TextStyleCollection.terminalTextStyle,),
        _bottomExtraTextSection(),
      ],
    );
  }

  _pollShowScreen() {
    final _pollShowProvider = Provider.of<PollShowProvider>(context);
    final _pollAnsCollection = _pollShowProvider.getPollAnswers();

    print("Updated Data: ${_pollShowProvider.getIndexedAnswerValue(0)}");

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: AppColors.backgroundDarkMode,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Polls(
            backgroundColor: AppColors.pureWhiteColor,
            currentUser: _pollShowProvider.getCurrentUser(),
            voteData: _pollShowProvider.getUsersVoted(),
            creatorID: '1',
            children: [
              ..._pollAnsCollection.map((answer) => Polls.options(
                  title: answer,
                  value: _pollShowProvider.getIndexedAnswerValue(
                      _pollAnsCollection.indexOf(answer))))
            ],
            question: Text(
              _pollShowProvider.getPollQuestion(),
              style: TextStyleCollection.secondaryHeadingTextStyle,
            ),
            onVote: (choice) =>
                Provider.of<PollShowProvider>(context, listen: false)
                    .increaseIndexedAnswerValue(choice - 1),
          ),
        ],
      ),
    );
  }
}
