import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:generation/config/icon_collection.dart';
import 'package:generation/config/images_path_collection.dart';
import 'package:generation/config/text_collection.dart';
import 'package:generation/config/time_collection.dart';
import 'package:generation/providers/chat_creation_section_provider.dart';
import 'package:generation/providers/messaging_provider.dart';
import 'package:generation/providers/sound_record_provider.dart';
import 'package:generation/services/device_specific_operations.dart';
import 'package:generation/services/input_system_services.dart';
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
      height:
          Provider.of<ChatCreationSectionProvider>(context).getSectionHeight(),
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
    final bool _isEmojiSectionShowing =
    Provider.of<ChatCreationSectionProvider>(context)
        .getEmojiActivationState();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _containerToInput(),
            _messageAndVoiceSendButton(),
          ],
        ),
        if(_isEmojiSectionShowing)
        _emojiCollectionWidget(),
      ],
    );
  }

  _recordingModeContainer() {
    _deleteRecording() => IconButton(
          icon: const Icon(
            Icons.delete_outline_outlined,
            color: AppColors.pureWhiteColor,
          ),
          onPressed: () {
            Provider.of<SoundRecorderProvider>(context, listen: false)
                .stopRecording();
            Provider.of<ChatScrollProvider>(context, listen: false)
                .animateToBottom();
          },
        );

    _recordingWaveForm() => SizedBox(
          width: MediaQuery.of(context).size.width - 120,
          child: MusicVisualizer(
            barCount: 30,
            colors: WaveForm.colors,
            duration: Timings.waveFormDuration,
          ),
        );

    _recordingVoiceSending() => IconButton(
          icon: Image.asset(
            IconImages.sendImagePath,
            width: 25,
          ),
          onPressed: () async {
            final _voiceRecordPath =
                await Provider.of<SoundRecorderProvider>(context, listen: false)
                    .stopRecording();

            Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                .setSingleNewMessage({
              DateTime.now().toString(): {
                MessageData.type: ChatMessageType.audio.toString(),
                MessageData.holder: Provider.of<ChatBoxMessagingProvider>(
                        context,
                        listen: false)
                    .getMessageHolderType()
                    .toString(),
                MessageData.message: _voiceRecordPath,
                MessageData.time: Provider.of<ChatBoxMessagingProvider>(context,
                        listen: false)
                    .getCurrentTime()
              }
            });

            Provider.of<ChatScrollProvider>(context, listen: false)
                .animateToBottom();
          },
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _deleteRecording(),
        _recordingWaveForm(),
        _recordingVoiceSending(),
      ],
    );
  }

  _emojiSection() {
    final bool _isEmojiSectionShowing =
        Provider.of<ChatCreationSectionProvider>(context)
            .getEmojiActivationState();

    return IconButton(
        onPressed: () {
          if (_isEmojiSectionShowing) {
            Provider.of<ChatCreationSectionProvider>(context, listen: false)
                .backToNormalHeight();
          } else {
            Provider.of<ChatCreationSectionProvider>(context, listen: false)
                .setSectionHeight();
          }
        },
        color: AppColors.pureWhiteColor.withOpacity(0.9),
        icon: const Icon(Icons.emoji_emotions_outlined));
  }

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
        cursorColor: AppColors.pureWhiteColor,
        onTap: (){
          Provider.of<ChatCreationSectionProvider>(context, listen: false)
              .backToNormalHeight();
        },
        onChanged: (inputVal){
          Provider.of<ChatBoxMessagingProvider>(context, listen: false)
              .setShowVoiceIcon(inputVal.isEmpty);
        },
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
    final InputOption _inputOption = InputOption(context);

    _videoTakingOption() {
      showModalBottomSheet(
          context: context,
          elevation: 5,
          builder: (_) => Container(
                color: AppColors.backgroundDarkMode,
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _inputOption.pickVideoFromCameraAndGallery();
                      },
                      child: const Text("Camera"),
                      style: ElevatedButton.styleFrom(
                          primary: AppColors.oppositeMsgDarkModeColor),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _inputOption.pickVideoFromCameraAndGallery(
                            fromCamera: false);
                      },
                      child: const Text("Gallery"),
                      style: ElevatedButton.styleFrom(
                          primary: AppColors.oppositeMsgDarkModeColor),
                    ),
                  ],
                ),
              ));
    }

    _particularOption(index) {
      return InkWell(
        onTap: () async {
          hideKeyboard();
          if (index == 0) {
            _inputOption.takeImageFromCamera();
          } else if (index == 1) {
            _inputOption.pickImageFromGallery();
          } else if (index == 2) {
            _videoTakingOption();
          } else if (index == 3) {
            _inputOption.documentPickFromDevice();
          } else if (index == 4) {
            _inputOption.audioPickFromDevice();
          } else if (index == 5) {
            await _inputOption.showCurrentLocationInGoogleMaps();
          } else if (index == 6) {
            await _inputOption.getContacts();
          }
        },
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: IconCollection.iconsCollection[index][2]),
              child: IconCollection.iconsCollection[index][0],
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Text(
                IconCollection.iconsCollection[index][1],
                style: TextStyleCollection.terminalTextStyle
                    .copyWith(fontSize: 14),
              ),
            )
          ],
        ),
      );
    }

    _showMoreOptions() {
      showModalBottomSheet(
          context: context,
          builder: (_) => Container(
              height: 450,
              color: AppColors.oppositeMsgDarkModeColor,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 6,
                children: List.generate(IconCollection.iconsCollection.length,
                    (index) => _particularOption(index)),
              )));
    }

    return IconButton(
        color: AppColors.pureWhiteColor.withOpacity(0.8),
        onPressed: _showMoreOptions,
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

    _voiceOrSendIconPressed() async {
      if (_showVoiceIcon) {
        Provider.of<SoundRecorderProvider>(context, listen: false)
            .startRecording();
      } else {
        final TextEditingController? _messageController =
            Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                .getTextController();

        if (_messageController!.text.isEmpty) return;

        Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .setSingleNewMessage({
          DateTime.now().toString(): {
            MessageData.type: ChatMessageType.text.toString(),
            MessageData.holder:
                Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                    .getMessageHolderType()
                    .toString(),
            MessageData.message: _messageController.text,
            MessageData.time:
                Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                    .getCurrentTime()
          }
        });
        Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .clearTextFromMessageInputSection();

        Provider.of<ChatScrollProvider>(context, listen: false)
            .animateToBottom();

        Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .setShowVoiceIcon(true);
      }
    }

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
      onPressed: _voiceOrSendIconPressed,
    );
  }

  Widget _emojiCollectionWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          Provider.of<ChatBoxMessagingProvider>(context, listen: false).insertEmoji(emoji.emoji);
        },
        onBackspacePressed: () {
          // Backspace-Button tapped logic
          // Remove this line to also remove the button in the UI
        },
        config: const Config(
            columns: 7,
            emojiSizeMax: 32,
            // Issue: https://github.com/flutter/flutter/issues/28894
            verticalSpacing: 0,
            horizontalSpacing: 0,
            initCategory: Category.RECENT,
            bgColor: AppColors.chatDarkBackgroundColor,
            indicatorColor: Colors.blue,
            iconColor: Colors.grey,
            iconColorSelected: Colors.blue,
            progressIndicatorColor: Colors.blue,
            backspaceColor: Colors.blue,
            skinToneDialogBgColor: Colors.white,
            skinToneIndicatorColor: Colors.grey,
            enableSkinTones: true,
            showRecentsTab: true,
            recentsLimit: 28,
            noRecentsText: "No Recents",
            noRecentsStyle: TextStyle(fontSize: 20, color: Colors.black26),
            tabIndicatorAnimDuration: kTabScrollDuration,
            categoryIcons: CategoryIcons(),
            buttonMode: ButtonMode.MATERIAL),
      ),
    );
  }
}
