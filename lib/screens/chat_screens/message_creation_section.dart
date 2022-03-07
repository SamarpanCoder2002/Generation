import 'package:flutter/material.dart';
import 'package:generation/config/images_path_collection.dart';
import 'package:generation/providers/messaging_provider.dart';
import 'package:generation/providers/sound_record_provider.dart';
import 'package:provider/provider.dart';
import 'package:music_visualizer/music_visualizer.dart';

import '../../config/colors_collection.dart';
import '../../config/text_style_collection.dart';
import '../../providers/chat_scroll_provider.dart';
import '../../types/types.dart';

class MessageCreationSection extends StatelessWidget {
  final BuildContext context;

  const MessageCreationSection({Key? key, required this.context})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _isRecording =
        Provider.of<SoundRecorderProvider>(context).getRecordingStatus();

    return Container(
      width: double.maxFinite,
      height: 60,
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            width: 0,
            color: AppColors.chatDarkBackgroundColor,
          )),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: _isRecording
            ? _recordingModeContainer()
            : _normalTextModeContainer(),
      ),
    );
  }

  _normalTextModeContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _containerToInput(),
        _messageAndVoiceSendButton(),
      ],
    );
  }

  _recordingModeContainer() {
    final List<Color> colors = [
      Colors.red[900]!,
      Colors.green[900]!,
      Colors.blue[900]!,
      Colors.brown[900]!
    ];

    final List<int> duration = [900, 700, 600, 800, 500];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(
            Icons.delete_outline_outlined,
            color: AppColors.pureWhiteColor,
          ),
          onPressed: () {
            Provider.of<SoundRecorderProvider>(context, listen: false).stopRecording();
          },
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width - 120,
          child: MusicVisualizer(
            barCount: 30,
            colors: colors,
            duration: duration,
          ),
        ),
        IconButton(
          icon: Image.asset(
            IconImages.sendImagePath,
            width: 25,
          ),
          onPressed: () async{
            final _voiceRecordPath = await Provider.of<SoundRecorderProvider>(context, listen: false).stopRecording();
            print("Voice Record Path: $_voiceRecordPath");

            Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                .setSingleNewMessage({
              DateTime.now().toString(): {
                "type": ChatMessageType.audio.toString(),
                "holder":
                Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                    .getMessageHolderType()
                    .toString(),
                "message": _voiceRecordPath,
                "time": "20:40"
              }
            });
          },
        )
      ],
    );
  }

  _emojiSection() => IconButton(
      onPressed: () {},
      color: AppColors.pureWhiteColor.withOpacity(0.9),
      icon: const Icon(Icons.emoji_emotions_outlined));

  _textMessageWritingSection() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 180,
      child: TextField(
        focusNode:
            Provider.of<ChatBoxMessagingProvider>(context).getFocusNode(),
        controller:
            Provider.of<ChatBoxMessagingProvider>(context).getTextController(),
        style: TextStyleCollection.terminalTextStyle.copyWith(fontSize: 14),
        maxLines: null,
        onChanged: (inputVal) =>
            Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                .setShowVoiceIcon(inputVal.isEmpty),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(bottom: 10),
          border: InputBorder.none,
          hintText: "Write Something Here",
          hintStyle: TextStyleCollection.searchTextStyle.copyWith(
              color: AppColors.pureWhiteColor.withOpacity(0.8), fontSize: 14),
        ),
      ),
    );
  }

  _moreMessageOptions() {
    return IconButton(
        color: AppColors.pureWhiteColor.withOpacity(0.8),
        onPressed: () {},
        icon: const Icon(Icons.attachment_outlined));
  }

  _containerToInput() {
    return Container(
      height: 40,
      width: MediaQuery.of(context).size.width - 80,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: AppColors.messageWritingSectionColor),
      child: Row(
        children: [
          _emojiSection(),
          _textMessageWritingSection(),
          _moreMessageOptions(),
        ],
      ),
    );
  }

  _messageAndVoiceSendButton() {
    final bool _showVoiceIcon =
        Provider.of<ChatBoxMessagingProvider>(context).showVoiceIcon();

    return IconButton(
      icon: !_showVoiceIcon
          ? Image.asset(
              IconImages.sendImagePath,
              width: 25,
            )
          : const Icon(
              Icons.keyboard_voice_outlined,
              color: AppColors.pureWhiteColor,
            ),
      onPressed: () async {
        if (_showVoiceIcon) {
          Provider.of<SoundRecorderProvider>(context, listen: false).startRecording();
        } else {
          final TextEditingController? _messageController =
              Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                  .getTextController();

          if (_messageController!.text.isEmpty) return;

          Provider.of<ChatBoxMessagingProvider>(context, listen: false)
              .setSingleNewMessage({
            DateTime.now().toString(): {
              "type": ChatMessageType.text.toString(),
              "holder":
                  Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                      .getMessageHolderType()
                      .toString(),
              "message": _messageController.text,
              "time": "20:40"
            }
          });
          Provider.of<ChatBoxMessagingProvider>(context, listen: false)
              .clearTextFromMessageInputSection();

          Provider.of<ChatScrollProvider>(context, listen: false)
              .animateToBottom();

          Provider.of<ChatBoxMessagingProvider>(context, listen: false)
              .setShowVoiceIcon(true);

          //Provider.of<ChatBoxMessagingProvider>(context, listen: false).unFocusNode();
        }
      },
    );
  }
}
