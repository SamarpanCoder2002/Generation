import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/providers/messaging_provider.dart';
import 'package:generation/types/types.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

import '../../providers/sound_provider.dart';

class MessagingSection extends StatelessWidget {
  final BuildContext context;

  const MessagingSection({Key? key, required this.context}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height / 1.2,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount:
              Provider.of<ChatBoxMessagingProvider>(context).getTotalMessages(),
          itemBuilder: (_, index) {
            final messageData =
                Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                    .getParticularMessage(index);

            return _commonMessageLayout(
                messageId: messageData.keys.toList()[0].toString(),
                messageData: messageData.values.toList()[0],
                index: index);
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(
              height: 10,
            );
          },
        ));
  }

  _commonMessageLayout(
      {required String messageId,
      required dynamic messageData,
      required int index}) {
    return Align(
      alignment: messageData["holder"] == MessageHolderType.other.toString()
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 45),
        child: Card(
          elevation: 0,
          shadowColor: AppColors.pureWhiteColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: messageData["holder"] == MessageHolderType.other.toString()
              ? AppColors.oppositeMsgDarkModeColor
              : AppColors.myMsgDarkModeColor,
          child: Stack(
            children: [
              _getPerfectMessageContainer(messageData: messageData),
              _messageTimingAndStatus(messageData: messageData),
              if (messageData["type"] == ChatMessageType.audio.toString())
                _audioPlayingLoadingTime(messageData: messageData),
            ],
          ),
        ),
      ),
    );
  }

  _textMessageSection({required dynamic messageData}) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 15, top: 8, bottom: 28),
      child: ReadMoreText(
        messageData["message"],
        trimLines: 5,
        trimMode: TrimMode.Line,
        trimCollapsedText: 'Show more',
        trimExpandedText: 'Show less',
        moreStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.pureWhiteColor,
            decoration: TextDecoration.underline),
        lessStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.pureWhiteColor,
            decoration: TextDecoration.underline),
        style: const TextStyle(fontSize: 14, color: AppColors.pureWhiteColor),
      ),
    );
  }

  _messageTimingAndStatus({messageData}) {
    return Positioned(
      bottom: 3,
      right: 10,
      child: Row(
        children: [
          Text(
            "20:58",
            style: TextStyle(
                fontSize: 12, color: AppColors.pureWhiteColor.withOpacity(0.8)),
          ),
          const SizedBox(
            width: 5,
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 3),
            child: Icon(Icons.done_outlined,
                size: 20, color: AppColors.pureWhiteColor),
          )
        ],
      ),
    );
  }

  _getPerfectMessageContainer({required dynamic messageData}) {
    if (messageData["type"] == ChatMessageType.text.toString()) {
      return _textMessageSection(messageData: messageData);
    } else if (messageData["type"] == ChatMessageType.image.toString()) {
      return _imageMessageSection(messageData: messageData);
    } else if (messageData["type"] == ChatMessageType.audio.toString()) {
      return _audioMessageSection(messageData: messageData);
    }
  }

  _imageMessageSection({messageData}) {
    return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: 300, maxWidth: MediaQuery.of(context).size.width - 110),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: PhotoView(
            backgroundDecoration:
                const BoxDecoration(color: AppColors.pureWhiteColor),
            imageProvider: NetworkImage(messageData["message"]),
            minScale: PhotoViewComputedScale.covered,
            errorBuilder: (_, __, ___) => const Center(
              child: Text(
                "Image Not Found... 😔",
                style: TextStyle(fontSize: 20, color: AppColors.pureWhiteColor),
              ),
            ),
          ),
        ));
  }

  _audioMessageSection({messageData}) {
    final bool isSongPlaying =
        Provider.of<SongManagementProvider>(context).isSongPlaying();

    final String _getCurrentSongPath =
        Provider.of<SongManagementProvider>(context).getSongPath();

    final double? _currentLoadingTime =
        Provider.of<SongManagementProvider>(context).getCurrentLoadingTime();

    _songPlayManagement() async {
      await Provider.of<SongManagementProvider>(context, listen: false)
          .audioPlaying(messageData["message"]);
    }

    _loadingProgress() => Expanded(
          child: Container(
            width: double.maxFinite,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: LinearPercentIndicator(
                percent: _getCurrentSongPath == messageData["message"]
                    ? _currentLoadingTime ?? 1.0
                    : 0.0,
                backgroundColor: Colors.black26,
                progressColor: AppColors.lightBlueColor),
          ),
        );

    _controllingButton() {
      return IconButton(
          onPressed: _songPlayManagement,
          icon: Icon(
            isSongPlaying && _getCurrentSongPath == messageData["message"]
                ? Icons.pause
                : Icons.play_arrow,
            color: AppColors.pureWhiteColor,
            size: 30,
          ));
    }

    return ConstrainedBox(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 110),
      child: Container(
        width: double.maxFinite,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            _controllingButton(),
            _loadingProgress(),
          ],
        ),
      ),
    );
  }

  _audioPlayingLoadingTime({messageData}) {
    final _currentLoadingTime =
        Provider.of<SongManagementProvider>(context).getShowingTiming();

    final String _getCurrentSongPath =
        Provider.of<SongManagementProvider>(context).getSongPath();

    return Positioned(
      bottom: 6,
      right: MediaQuery.of(context).size.width / 2 - 12,
      child: Text(
        _getCurrentSongPath == messageData["message"]
            ? _currentLoadingTime.toString()
            : "00:00",
        style: TextStyle(
            fontSize: 12, color: AppColors.pureWhiteColor.withOpacity(0.8)),
      ),
    );
  }
}
