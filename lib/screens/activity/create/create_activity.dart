import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/time_collection.dart';

import 'package:generation/screens/common/video_show_screen.dart';
import 'package:generation/services/device_specific_operations.dart';
import 'package:generation/services/toast_message_show.dart';
import 'package:generation/types/types.dart';
import 'package:provider/provider.dart';

import '../../../config/text_style_collection.dart';
import '../../../providers/activity/activity_screen_provider.dart';
import '../../../providers/messaging_provider.dart';

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

  @override
  void initState() {
    changeOnlyNavigationBarColor(navigationBarColor: AppColors.pureBlackColor);
    super.initState();
  }

  @override
  void dispose() {
    _textActivityController.dispose();
    changeOnlyNavigationBarColor(navigationBarColor: AppColors.backgroundDarkMode);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureBlackColor,
      floatingActionButton: widget.activityContentType == ActivityContentType.text
          ? _textActivityMakeButton()
          : null,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: _getRealBody(),
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
        // TODO: Handle this case.
        break;
      case ActivityContentType.poll:
        // TODO: Handle this case.
        break;
    }

    return const Center();
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
                fontSize: 20, color: AppColors.pureWhiteColor.withOpacity(0.8)),
          ),
        ),
      );

  _activityTextCreationSection() => Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width / 2,
        color: AppColors.backgroundDarkMode,
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
          bottom: widget.activityContentType == ActivityContentType.text ? 100 : 10),
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

  void _onSendButtonPressed() {
    final Map<String, dynamic> map = {};
    final DateTime _dateTime = DateTime.now();
    map["type"] = widget.activityContentType.toString();
    map["date"] =
        "${_dateTime.day} ${Provider.of<ActivityProvider>(context, listen: false).getParticularMonth(_dateTime.month)}, ${_dateTime.year}";
    map["time"] = Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .getCurrentTime(dateTime: _dateTime);
    map["holderId"] = _dateTime.toString();

    switch (widget.activityContentType) {
      case ActivityContentType.text:
        map["message"] = _textActivityController.text;
        map["additionalThings"] = {
          "backgroundColor": pickColor,
          "textColor": AppColors.pureWhiteColor
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
        // TODO: Handle this case.
        break;
      case ActivityContentType.poll:
        // TODO: Handle this case.
        break;
    }

    Provider.of<ActivityProvider>(context, listen: false).addNewActivity(map);
    showToast(context,
        title: "Activity Added",
        toastIconType: ToastIconType.success,
        toastDuration: 10);
    Navigator.pop(context);

    if(widget.activityContentType == ActivityContentType.video && int.parse(widget.data["duration"])>Timings.videoDurationInSec) Navigator.pop(context);
  }

  _videoActivityCreationSection() {
    return Stack(
      children: [
        VideoShowScreen(file: widget.data["file"]),
        _bottomSection(),
      ],
    );
  }
}
