import 'package:flutter/material.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/model/activity_model.dart';
import 'package:generation/types/types.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import '../../../providers/activity/activity_screen_provider.dart';
import '../animation_controller.dart';

class ActivityViewer extends StatefulWidget {
  final ActivityModel activityData;

  const ActivityViewer({Key? key, required this.activityData})
      : super(key: key);

  @override
  State<ActivityViewer> createState() => _ActivityViewerState();
}

class _ActivityViewerState extends State<ActivityViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentActivity(),
    );
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
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: PhotoView(
        imageProvider: NetworkImage(widget.activityData.message),
      ),
    );
  }

  _getCurrentActivity() {
    if (widget.activityData.type == ActivityType.text.toString()) {
      return _textActivityShow();
    } else if (widget.activityData.type == ActivityType.image.toString()) {
      return _imageActivityShow();
    } else if (widget.activityData.type == ActivityType.video.toString()) {
      return const Center(
        child: Text("Video"),
      );
    } else if (widget.activityData.type == ActivityType.poll.toString()) {
      return const Center(
        child: Text("Poll"),
      );
    }
  }
}
