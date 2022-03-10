import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/providers/chat_scroll_provider.dart';
import 'package:generation/providers/messaging_provider.dart';
import 'package:generation/services/show_google_map.dart';
import 'package:generation/types/types.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../providers/sound_provider.dart';

class MessagingSection extends StatelessWidget {
  final BuildContext context;

  const MessagingSection({Key? key, required this.context}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int _totalChatMessages =
        Provider.of<ChatBoxMessagingProvider>(context).getTotalMessages();

    return _totalChatMessages > 0
        ? _chatBoxContainingMessages()
        : _noChatBoxMessagesSection();
  }

  _commonMessageLayout(
      {required String messageId,
      required dynamic messageData,
      required int index}) {
    return Align(
      alignment:
          messageData[MessageData.holder] == MessageHolderType.other.toString()
              ? Alignment.centerLeft
              : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45, minWidth: 100),
        child: Card(
          elevation: 0,
          shadowColor: AppColors.pureWhiteColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: messageData[MessageData.holder] ==
                  MessageHolderType.other.toString()
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
      child: Linkify(
        text: messageData[MessageData.message],
        onOpen: (link) async {
          try {
            await launch(link.url);
          } catch (e) {
            throw 'Could not launch $link';
          }
        },
        linkStyle: const TextStyle(color: AppColors.lightBlueColor),
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
            messageData[MessageData.time],
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
    if (messageData[MessageData.type] == ChatMessageType.text.toString()) {
      return _textMessageSection(messageData: messageData);
    } else if (messageData[MessageData.type] ==
        ChatMessageType.image.toString()) {
      return _imageMessageSection(messageData: messageData);
    } else if (messageData[MessageData.type] ==
        ChatMessageType.audio.toString()) {
      return _audioMessageSection(messageData: messageData);
    } else if (messageData[MessageData.type] ==
        ChatMessageType.video.toString()) {
      return _videoMessageSection(messageData: messageData);
    } else if (messageData[MessageData.type] ==
        ChatMessageType.document.toString()) {
      return _documentMessageSection(messageData: messageData);
    } else if (messageData[MessageData.type] ==
        ChatMessageType.location.toString()) {
      return _locationMessageSection(messageData: messageData);
    }
  }

  _imageMessageSection({messageData, bool fromVideo = false}) {
    return InkWell(
      onTap: () async {
        await OpenFile.open(messageData[MessageData.message]!);
      },
      child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: 300,
              maxWidth: MediaQuery.of(context).size.width - 110),
          child: Card(
            elevation: 2,
            shadowColor: AppColors.pureWhiteColor,
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: PhotoView(
                enableRotation: false,
                backgroundDecoration:
                    const BoxDecoration(color: AppColors.pureWhiteColor),
                imageProvider: FileImage(File(fromVideo
                    ? messageData[MessageData.thumbnail]!
                    : messageData[MessageData.message]!)),
                minScale: PhotoViewComputedScale.covered,
                errorBuilder: (_, __, ___) => const Center(
                  child: Text(
                    "Image Not Found... 😔",
                    style: TextStyle(
                        fontSize: 20, color: AppColors.pureWhiteColor),
                  ),
                ),
              ),
            ),
          )),
    );
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
          .audioPlaying(messageData[MessageData.message]);
    }

    _loadingProgress() => Expanded(
          child: Container(
            width: double.maxFinite,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: LinearPercentIndicator(
                percent: _getCurrentSongPath == messageData[MessageData.message]
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
            isSongPlaying &&
                    _getCurrentSongPath == messageData[MessageData.message]
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
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
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
        _getCurrentSongPath == messageData[MessageData.message]
            ? _currentLoadingTime.toString()
            : "00:00",
        style: TextStyle(
            fontSize: 12, color: AppColors.pureWhiteColor.withOpacity(0.8)),
      ),
    );
  }

  _chatBoxContainingMessages() {
    final bool _isFocused = Provider.of<ChatBoxMessagingProvider>(context)
        .hasTextFieldFocus(context);

    // Provider.of<ChatScrollProvider>(context).animateToBottom(scrollDuration: 1);

    return SizedBox(
        width: double.maxFinite,
        height: _isFocused
            ? MediaQuery.of(context).size.height / 2.1
            : MediaQuery.of(context).size.height / 1.22,
        child: ListView.separated(
          controller: Provider.of<ChatScrollProvider>(context).getController(),
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

  _noChatBoxMessagesSection() {
    return Container(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height / 2,
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: AppColors.oppositeMsgDarkModeColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(offset: Offset(0, 1), blurRadius: 5)
                ]),
            child: Text(
              "Messages are End-to-End Encrypted.\nNo other Third Party Person, Organization or even Generation Team can't read your messages",
              textAlign: TextAlign.center,
              style:
                  TextStyleCollection.terminalTextStyle.copyWith(fontSize: 14),
            ),
          ),
          Center(
            child: Text(
              "Start Your Messaging 👇",
              style:
                  TextStyleCollection.headingTextStyle.copyWith(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  _videoMessageSection({messageData}) {
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: 300, maxWidth: MediaQuery.of(context).size.width - 110),
      child: Stack(
        children: [
          _imageMessageSection(messageData: messageData, fromVideo: true),
          InkWell(
            onTap: () async {
              print("Ok Video");
              await OpenFile.open(messageData[MessageData.message]);
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 110,
              height: 300,
              child: IconButton(
                icon: const Icon(
                  Icons.play_circle_outline_outlined,
                  size: 60,
                  color: AppColors.darkBorderGreenColor,
                ),
                onPressed: () async {
                  print("Message Data: ${messageData[MessageData.message]}");
                  await OpenFile.open(messageData[MessageData.message]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  _documentMessageSection({messageData}) {
    _pdfMaintainerWidget() => Stack(
          children: [
            PdfView(
              path: messageData[MessageData.message],
            ),
            Center(
              child: GestureDetector(
                child: const Icon(
                  Icons.open_in_new_rounded,
                  size: 40.0,
                  color: Colors.blue,
                ),
                onTap: () async {
                  final openResult =
                      await OpenFile.open(messageData[MessageData.message]);

                  /// Make Toast Here to Show message if file not open
                },
              ),
            ),
          ],
        );

    _otherDocumentMaintainerWidget() => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                messageData[MessageData.message].split("/").last,
                style: TextStyleCollection.terminalTextStyle
                    .copyWith(fontSize: 14),
              ),
              IconButton(
                  onPressed: () async {
                    final openResult =
                        await OpenFile.open(messageData[MessageData.message]);

                    /// Make Toast Here to Show message if file not open
                  },
                  icon: const Icon(
                    Icons.open_in_new,
                    color: AppColors.pureWhiteColor,
                  ))
            ],
          ),
        );

    return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: messageData[MessageData.extensionForDocument] == 'pdf'
                ? 300
                : 100,
            maxWidth: MediaQuery.of(context).size.width - 110),
        child: Card(
          elevation: 2,
          color: messageData[MessageData.holder] ==
                  MessageHolderType.other.toString()
              ? AppColors.oppositeMsgDarkModeColor
              : AppColors.myMsgDarkModeColor,
          shadowColor: AppColors.pureWhiteColor,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: messageData[MessageData.extensionForDocument] == 'pdf'
                ? _pdfMaintainerWidget()
                : _otherDocumentMaintainerWidget(),
          ),
        ));
  }

  _locationMessageSection({messageData}) {
    return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: 300, maxWidth: MediaQuery.of(context).size.width - 110),
        child: Card(
          elevation: 2,
          color: messageData[MessageData.holder] ==
                  MessageHolderType.other.toString()
              ? AppColors.oppositeMsgDarkModeColor
              : AppColors.myMsgDarkModeColor,
          shadowColor: AppColors.pureWhiteColor,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: showMapSection(
                latitude: messageData["message"]["latitude"],
                longitude: messageData["message"]["longitude"]),
          ),
        ));
  }
}
