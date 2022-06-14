import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/time_collection.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/providers/activity/poll_creator_provider.dart';
import 'package:generation/screens/common/video_show_screen.dart';
import 'package:generation/services/device_specific_operations.dart';
import 'package:generation/services/local_data_management.dart';
import 'package:generation/services/toast_message_show.dart';
import 'package:generation/config/types.dart';
import 'package:loading_overlay/loading_overlay.dart';

import 'package:provider/provider.dart';

import '../../../config/text_style_collection.dart';
import '../../../providers/activity/activity_screen_provider.dart';
import '../../../providers/chat/messaging_provider.dart';
import '../../../providers/sound_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../common/music_visualizer.dart';

class CreateActivity extends StatefulWidget {
  final ActivityContentType activityContentType;
  final Map<String, dynamic> data;

  const CreateActivity(
      {Key? key, required this.activityContentType, this.data = const {}})
      : super(key: key);

  @override
  State<CreateActivity> createState() => _CreateActivityState();
}

class _CreateActivityState extends State<CreateActivity> {
  Color pickColor = AppColors.normalBlueColor;
  final TextEditingController _textActivityController = TextEditingController();
  final DBOperations _dbOperation = DBOperations();
  bool _isLoading = false;

  @override
  void initState() {
    changeSystemNavigationAndStatusBarColor(
        statusBarColor: AppColors.transparentColor,
        navigationBarColor: Colors.black12.withOpacity(0));
    super.initState();
  }

  @override
  void dispose() {
    // final _isDarkMode =
    //     Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();
    _textActivityController.dispose();
    changeOnlyNavigationBarColor(
        navigationBarColor: AppColors.getBgColor(true));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      color: AppColors.pureBlackColor.withOpacity(0.6),
      progressIndicator: const CircularProgressIndicator(
        color: AppColors.lightBorderGreenColor,
      ),
      child: WillPopScope(
        onWillPop: () async {
          if (widget.activityContentType == ActivityContentType.audio) {
            print("At Here on Will Pop");
            Provider.of<SongManagementProvider>(context, listen: false)
                .stopSong();
          }
          return true;
        },
        child: Scaffold(
          backgroundColor: AppColors.pureBlackColor,
          floatingActionButton:
              widget.activityContentType == ActivityContentType.text
                  ? _textActivityMakeButton()
                  : null,
          body: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: _getRealBody(),
          ),
        ),
      ),
    );
  }

  _getRealBody() {
    switch (widget.activityContentType) {
      case ActivityContentType.text:
        return _textActivityCreationSection();
      case ActivityContentType.image:
        return _imageActivityCreationSection();
      case ActivityContentType.video:
        return _videoActivityCreationSection();
      case ActivityContentType.audio:
        return _audioActivityCreationSection();
      case ActivityContentType.poll:
        return _pollActivityCreationSection();
    }
  }

  _textActivityCreationSection() => SingleChildScrollView(
        child: Column(
          children: [
            _activityTextSection(),
            _activityTextCreationSection(),
          ],
        ),
      );

  _activityTextSection() => Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 1.13,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        color: pickColor,
        alignment: Alignment.center,
        child: TextField(
          controller: _textActivityController,
          cursorColor: AppColors.pureWhiteColor,
          textAlign: TextAlign.center,
          maxLines: null,
          style: TextStyleCollection.terminalTextStyle.copyWith(fontSize: 20),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Type Anything Here',
            hintStyle: TextStyleCollection.terminalTextStyle.copyWith(
                fontSize: 20, color: AppColors.pureWhiteColor.withOpacity(0.6)),
          ),
        ),
      );

  _activityTextCreationSection() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width / 2,
      color: AppColors.getBgColor(_isDarkMode),
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 2,
        child: ColorPicker(
          colorPickerWidth: MediaQuery.of(context).size.width,
          labelTextStyle: TextStyleCollection.terminalTextStyle,
          pickerAreaHeightPercent: 0.05,
          displayThumbColor: false,
          pickerColor: pickColor,
          paletteType: PaletteType.rgbWithBlue,
          onColorChanged: (Color color) {
            if (mounted) {
              setState(() {
                pickColor = color;
              });
            }
          },
        ),
      ),
    );
  }

  _textActivityMakeButton() {
    if (_textActivityController.text.isNotEmpty) return _sendButton();
  }

  _otherActivityMakeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _containerToInput(),
          _sendButton(bgColor: AppColors.messageWritingSectionColor)
        ],
      ),
    );
  }

  _containerToInput() {
    return Container(
      height: 40,
      width: MediaQuery.of(context).size.width - 80,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: AppColors.messageWritingSectionColor),
      child: _textMessageWritingSection(),
    );
  }

  _textMessageWritingSection() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 180,
      child: TextField(
        controller: _textActivityController,
        style: TextStyleCollection.terminalTextStyle.copyWith(fontSize: 14),
        maxLines: null,
        cursorColor: AppColors.pureWhiteColor,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(bottom: 10, left: 20),
          border: InputBorder.none,
          hintText: "Write Something Here",
          hintStyle: TextStyleCollection.searchTextStyle.copyWith(
              color: AppColors.pureWhiteColor.withOpacity(0.8), fontSize: 14),
        ),
      ),
    );
  }

  _sendButton({Color bgColor = AppColors.darkBorderGreenColor}) {
    return Container(
      margin: EdgeInsets.only(
          bottom: widget.activityContentType == ActivityContentType.text
              ? 100
              : 10),
      child: FloatingActionButton(
        backgroundColor: bgColor,
        child: Image.asset(
          "assets/images/send.png",
          width: 35,
        ),
        onPressed: _onSendButtonPressed,
      ),
    );
  }

  _imageActivityCreationSection() {
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Image.file(
            File(widget.data["path"]),
            //fit: BoxFit.cover,
          ),
        ),
        _bottomSection()
      ],
    );
  }

  _bottomSection() => Align(
        alignment: Alignment.bottomCenter,
        child: _otherActivityMakeSection(),
      );

  void _onSendButtonPressed() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final Map<String, dynamic> map = {};
    final DateTime _dateTime = DateTime.now();
    map["type"] = widget.activityContentType.toString();
    map["time"] = Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .getCurrentTime(dateTime: _dateTime);
    map["date"] = Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .getCurrentDate(dateTime: _dateTime);
    map["holderId"] = _dbOperation.currUid;
    map["id"] = DateTime.now().toString();

    switch (widget.activityContentType) {
      case ActivityContentType.text:
        map["message"] = _textActivityController.text;
        map["additionalThings"] = <String, dynamic>{
          "backgroundColor": {
            'red': pickColor.red.toString(),
            'green': pickColor.green.toString(),
            'blue': pickColor.blue.toString(),
            'opacity': pickColor.opacity.toString()
          },
          "textColor": {
            'red': AppColors.pureWhiteColor.red.toString(),
            'green': AppColors.pureWhiteColor.green.toString(),
            'blue': AppColors.pureWhiteColor.blue.toString(),
            'opacity': AppColors.pureWhiteColor.opacity.toString()
          }
        };
        break;
      case ActivityContentType.image:
        map["message"] = widget.data["path"];
        map["additionalThings"] = {
          "text": _textActivityController.text,
        };
        break;
      case ActivityContentType.video:
        map["message"] = widget.data["file"].path;
        map["additionalThings"] = {
          "text": _textActivityController.text,
          "thumbnail": widget.data["thumbnail"],
          "duration": widget.data["duration"]
        };
        break;
      case ActivityContentType.audio:
        map["message"] = widget.data["path"];
        map["additionalThings"] = {
          "text": _textActivityController.text,
          "duration": widget.data["duration"]
        };
        break;
      case ActivityContentType.poll:
        map["message"] = json.encode(widget.data).toString();
        map["additionalThings"] = {
          "text": _textActivityController.text,
          "duration": widget.data["duration"]
        };
        break;
    }

    final _serverStoredData = await _dbOperation.addActivity({...map});
    map["additionalThings"]["remoteData"] =
        DataManagement.toJsonString(_serverStoredData);

    print('Modified activity data: $map');

    Provider.of<ActivityProvider>(context, listen: false)
        .addNewActivity({...map}, map["holderId"]);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    showToast(context,
        title: "Activity Added",
        toastIconType: ToastIconType.success,
        toastDuration: 10);

    if (widget.activityContentType == ActivityContentType.audio) {
      Provider.of<SongManagementProvider>(context, listen: false)
          .stopSong(update: false);
    }

    if (widget.activityContentType == ActivityContentType.poll) {
      Provider.of<PollCreatorProvider>(context, listen: false).reset();
      Navigator.pop(context);
      Navigator.pop(context);
    }

    Navigator.pop(context);

    if (widget.activityContentType == ActivityContentType.video &&
        int.parse(widget.data["duration"]) >= Timings.videoDurationInSec) {
      Navigator.pop(context);
    }
  }

  _videoActivityCreationSection() {
    return Stack(
      children: [
        VideoShowScreen(file: widget.data["file"]),
        _bottomSection(),
      ],
    );
  }

  _audioActivityCreationSection() {
    Provider.of<SongManagementProvider>(context, listen: false)
        .audioPlaying(widget.data["path"], update: false);

    return Stack(
      children: [
        //_isPlaying?
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          child: MusicVisualizer(
            barCount: 30,
            colors: WaveForm.colors,
            duration: Timings.waveFormDuration,
          ),
        ),
        //:const Center(child: Text("Song Playing Completed", style: TextStyleCollection.secondaryHeadingTextStyle,),),
        _bottomSection(),
      ],
    );
  }

  _pollActivityCreationSection() {
    return Stack(
      children: [_pollShowingSection(), _bottomSection()],
    );
  }

  _pollShowingSection() => Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 100),
        alignment: Alignment.center,
        color: AppColors.backgroundDarkMode,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _pollInstructionSection(),
            // Polls.viewPolls(
            //   question: Text(
            //     widget.data["question"],
            //     style: TextStyleCollection.secondaryHeadingTextStyle,
            //   ),
            //   children: [
            //     ...widget.data["answer"].map((answer) =>
            //         Polls.options(title: answer.keys.toList()[0], value: 0)),
            //   ],
            // ),
          ],
        ),
      );

  _pollInstructionSection() => Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(bottom: 30),
        child: Text(
          "This is the Poll Looks Like When You Create Your Activity. You Can Vote After Create Activity.",
          textAlign: TextAlign.center,
          style: TextStyleCollection.secondaryHeadingTextStyle
              .copyWith(color: AppColors.orangeTextColor),
        ),
      );
}
