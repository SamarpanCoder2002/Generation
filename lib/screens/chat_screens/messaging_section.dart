import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/model/chat_message_model.dart';
import 'package:generation/providers/chat/chat_creation_section_provider.dart';
import 'package:generation/providers/chat/chat_scroll_provider.dart';
import 'package:generation/providers/chat/messaging_provider.dart';
import 'package:generation/screens/common/button.dart';
import 'package:generation/services/input_system_services.dart';
import 'package:generation/services/local_data_management.dart';
import 'package:generation/services/show_google_map.dart';
import 'package:generation/services/system_file_management.dart';
import 'package:generation/types/types.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:swipe_to/swipe_to.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../providers/sound_provider.dart';
import '../../providers/theme_provider.dart';

class MessagingSection extends StatefulWidget {
  final BuildContext context;

  const MessagingSection({Key? key, required this.context}) : super(key: key);

  @override
  State<MessagingSection> createState() => _MessagingSectionState();
}

class _MessagingSectionState extends State<MessagingSection> {
  // @override
  // void didChangeDependencies() {
  //   Provider.of<ChatScrollProvider>(context, listen: false)
  //       .animateToBottom(scrollDuration: 1000);
  //
  //   super.didChangeDependencies();
  // }


  @override
  Widget build(BuildContext context) {
    final int _totalChatMessages =
        Provider.of<ChatBoxMessagingProvider>(context).getTotalMessages();

    if (Provider.of<ChatScrollProvider>(context).getScrollAtFirst &&
        Provider.of<ChatScrollProvider>(context).isAttachedToScrollView) {
      Provider.of<ChatScrollProvider>(context).directBottom();
    }

    return _totalChatMessages > 0
        ? _chatBoxContainingMessages()
        : _noChatBoxMessagesSection();
  }

  _commonMessageLayout(
      {required String messageId,
      required ChatMessageModel messageData,
      required int index}) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
    final _selectedMessages =
        Provider.of<ChatBoxMessagingProvider>(context).getSelectedMessage();

    return SwipeTo(
      iconColor: AppColors.getIconColor(_isDarkMode),
      onRightSwipe: () => _rightSwipe(messageId, messageData),
      child: InkWell(
        onTap: () => onMessageTap(messageId, messageData, _selectedMessages),
        onLongPress: () =>
            onMessageLongTap(messageId, messageData, _selectedMessages),
        child: Container(
          color: AppColors.getSelectedMsgColor(
              _isDarkMode, _selectedMessages[messageId] != null),
          child: Align(
            alignment: messageData.holder == MessageHolderType.other.toString()
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(widget.context).size.width - 45,
                  minWidth: 100),
              child: Card(
                elevation: 0,
                shadowColor: AppColors.pureWhiteColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                color: AppColors.getMsgColor(_isDarkMode,
                    messageData.holder == MessageHolderType.other.toString()),
                child: Stack(
                  children: [
                    _getPerfectMessageContainer(messageData: messageData),
                    _messageTimingAndStatus(messageData: messageData),
                    if (messageData.type == ChatMessageType.audio.toString())
                      _audioPlayingLoadingTime(messageData: messageData),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _textMessageSection({required ChatMessageModel messageData}) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 15, top: 8, bottom: 28),
      child: Linkify(
        text: messageData.message,
        onOpen: (link) async {
          try {
            await launch(link.url);
          } catch (e) {
            throw 'Could not launch $link';
          }
        },
        linkStyle: const TextStyle(color: AppColors.lightBlueColor),
        style: TextStyle(
            fontSize: 14,
            color: AppColors.getMsgTextColor(
                messageData.holder == MessageHolderType.other.toString(),
                _isDarkMode)),
        options: const LinkifyOptions(humanize: false),
      ),
    );
  }

  _messageTimingAndStatus({required ChatMessageModel messageData}) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Positioned(
      bottom: 3,
      right: 10,
      child: Text(
        messageData.time,
        style: TextStyleCollection.terminalTextStyle.copyWith(
            color: AppColors.getMsgTextColor(
                    messageData.holder == MessageHolderType.other.toString(),
                    _isDarkMode)
                .withOpacity(0.8),
            fontWeight: FontWeight.normal),
      ),
    );
  }

  _getPerfectMessageContainer({required ChatMessageModel messageData}) {
    if (Provider.of<ChatScrollProvider>(context).getScrollAtFirst) {
      Provider.of<ChatScrollProvider>(context, listen: false)
          .animateToBottom(scrollDuration: 100, updateScrollAtFirstValue: true, extraScroll: 200);
    }

    if (messageData.type == ChatMessageType.text.toString()) {
      return _textMessageSection(messageData: messageData);
    } else if (messageData.type == ChatMessageType.image.toString()) {
      return _imageMessageSection(messageData: messageData);
    } else if (messageData.type == ChatMessageType.audio.toString()) {
      return _audioMessageSection(messageData: messageData);
    } else if (messageData.type == ChatMessageType.video.toString()) {
      return _videoMessageSection(messageData: messageData);
    } else if (messageData.type == ChatMessageType.document.toString()) {
      return _documentMessageSection(messageData: messageData);
    } else if (messageData.type == ChatMessageType.location.toString()) {
      return _locationMessageSection(messageData: messageData);
    } else if (messageData.type == ChatMessageType.contact.toString()) {
      return _contactMessageSection(messageData: messageData);
    }

    return const Center();
  }

  _imageMessageSection(
      {required ChatMessageModel messageData, bool fromVideo = false}) {
    final _imagePath = _getPerfectImage(fromVideo
        ? messageData.additionalData["thumbnail"] ?? ""
        : messageData.message);

    return InkWell(
      onTap: () async {
        await SystemFileManagement.openFile(messageData.message);
      },
      child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: 300,
              maxWidth: MediaQuery.of(widget.context).size.width - 110),
          child: Card(
            elevation: 2,
            shadowColor: AppColors.pureWhiteColor,
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: _imagePath != null
                ? Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                            image: _imagePath, fit: BoxFit.cover)),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          )),
    );
  }

  _audioMessageSection({required ChatMessageModel messageData}) {
    final bool isSongPlaying =
        Provider.of<SongManagementProvider>(widget.context).isSongPlaying();

    final String _getCurrentSongPath =
        Provider.of<SongManagementProvider>(widget.context).getSongPath();

    final double? _currentLoadingTime =
        Provider.of<SongManagementProvider>(widget.context)
            .getCurrentLoadingTime();

    final _isLocalFile = _isItLocalFile(messageData.message);

    _songPlayManagement() async {
      await Provider.of<SongManagementProvider>(widget.context, listen: false)
          .audioPlaying(messageData.message);
    }

    _loadingProgress() {
      final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

      return Expanded(
        child: Container(
          width: double.maxFinite,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: LinearPercentIndicator(
              percent: _getCurrentSongPath == messageData.message
                  ? _currentLoadingTime ?? 1.0
                  : 0.0,
              backgroundColor: Colors.black26,
              progressColor: AppColors.getLoadingColor(_isDarkMode,
                  messageData.holder == MessageHolderType.other.toString())),
        ),
      );
    }

    _controllingButton() {
      final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

      if (!_isLocalFile) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return IconButton(
          onPressed: _songPlayManagement,
          icon: Icon(
            isSongPlaying && _getCurrentSongPath == messageData.message
                ? Icons.pause
                : Icons.play_arrow,
            color: AppColors.getIconColor(_isDarkMode,
                isOpposite:
                    messageData.holder == MessageHolderType.other.toString()),
            size: 30,
          ));
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(widget.context).size.width - 110),
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

  _audioPlayingLoadingTime({required ChatMessageModel messageData}) {
    final _currentLoadingTime =
        Provider.of<SongManagementProvider>(widget.context).getShowingTiming();

    final String _getCurrentSongPath =
        Provider.of<SongManagementProvider>(widget.context).getSongPath();

    return Positioned(
      bottom: 6,
      right: MediaQuery.of(widget.context).size.width / 2 - 12,
      child: Text(
        _getCurrentSongPath == messageData.message
            ? _currentLoadingTime.toString()
            : "00:00",
        style: TextStyle(
            fontSize: 12, color: AppColors.pureWhiteColor.withOpacity(0.8)),
      ),
    );
  }

  _chatBoxContainingMessages() {
    final bool _isFocused =
        Provider.of<ChatBoxMessagingProvider>(widget.context)
            .hasTextFieldFocus(widget.context);
    final bool _isEmojiSectionActivated =
        Provider.of<ChatCreationSectionProvider>(widget.context)
            .getEmojiActivationState();

    return SizedBox(
        width: double.maxFinite,
        height: Provider.of<ChatBoxMessagingProvider>(widget.context)
            .getChatMessagingSectionHeight(
                _isFocused || _isEmojiSectionActivated, widget.context),
        child: ListView.separated(
          controller:
              Provider.of<ChatScrollProvider>(widget.context).getController(),
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: Provider.of<ChatBoxMessagingProvider>(widget.context)
              .getTotalMessages(),
          itemBuilder: (_, index) {
            final messageData = Provider.of<ChatBoxMessagingProvider>(
                    widget.context,
                    listen: false)
                .getParticularMessage(index);

            final realMsg = messageData.values.toList()[0];

            final chatMsgObj = ChatMessageModel.toJson(
                type: realMsg["type"],
                message: realMsg["message"],
                time: realMsg["time"],
                holder: realMsg["holder"],
                additionalData: realMsg["additionalData"] != null
                    ? DataManagement.fromJsonString(realMsg["additionalData"])
                    : null,
                date: realMsg["date"]);

            return _commonMessageLayout(
                messageId: messageData.keys.toList()[0].toString(),
                messageData: chatMsgObj,
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
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
      width: double.maxFinite,
      height: MediaQuery.of(widget.context).size.height / 2,
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: _isDarkMode
                    ? AppColors.oppositeMsgDarkModeColor
                    : AppColors.lightBorderGreenColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      offset: const Offset(0, 1),
                      blurRadius: 5,
                      color: _isDarkMode
                          ? AppColors.pureBlackColor
                          : AppColors.pureBlackColor.withOpacity(0.2))
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
              style: TextStyleCollection.headingTextStyle.copyWith(
                  fontSize: 18,
                  color: _isDarkMode
                      ? AppColors.pureWhiteColor
                      : AppColors.lightChatConnectionTextColor),
            ),
          ),
        ],
      ),
    );
  }

  _videoMessageSection({required ChatMessageModel messageData}) {
    final _isLocalFile = _isItLocalFile(messageData.message);

    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: 300,
          maxWidth: MediaQuery.of(widget.context).size.width - 110),
      child: !_isLocalFile
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                _imageMessageSection(messageData: messageData, fromVideo: true),
                InkWell(
                  onTap: () async {
                    print("Ok Video");
                    await SystemFileManagement.openFile(messageData.message);
                  },
                  child: SizedBox(
                    width: MediaQuery.of(widget.context).size.width - 110,
                    height: 300,
                    child: IconButton(
                      icon: const Icon(
                        Icons.play_circle_outline_outlined,
                        size: 60,
                        color: AppColors.darkBorderGreenColor,
                      ),
                      onPressed: () async {
                        print("Message Data: ${messageData.message}");
                        await SystemFileManagement.openFile(
                            messageData.message);
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  _documentMessageSection({required ChatMessageModel messageData}) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
    final _isLocalFile = _isItLocalFile(messageData.message);

    _pdfMaintainerWidget() => Stack(
          children: [
            PdfView(
              path: messageData.message,
            ),
            Center(
              child: GestureDetector(
                child: const Icon(
                  Icons.open_in_new_rounded,
                  size: 40.0,
                  color: Colors.blue,
                ),
                onTap: () async {
                  await SystemFileManagement.openFile(messageData.message);

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
                messageData.message.split("/").last,
                style: TextStyleCollection.terminalTextStyle
                    .copyWith(fontSize: 14),
              ),
              IconButton(
                  onPressed: () async {
                    await SystemFileManagement.openFile(messageData.message);

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
            maxHeight:
                messageData.additionalData["extension-for-document"] == 'pdf'
                    ? 300
                    : 100,
            maxWidth: MediaQuery.of(widget.context).size.width - 110),
        child: Card(
          elevation: 2,
          color: AppColors.getMsgColor(_isDarkMode,
              messageData.holder == MessageHolderType.other.toString()),
          shadowColor: AppColors.pureWhiteColor,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: !_isLocalFile
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: messageData.additionalData["extension-for-document"] ==
                          'pdf'
                      ? _pdfMaintainerWidget()
                      : _otherDocumentMaintainerWidget(),
                ),
        ));
  }

  _locationMessageSection({required ChatMessageModel messageData}) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
    final message = DataManagement.fromJsonString(messageData.message);

    return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: 300,
            maxWidth: MediaQuery.of(widget.context).size.width - 110),
        child: Card(
          elevation: 2,
          color: AppColors.getMsgColor(_isDarkMode,
              messageData.holder == MessageHolderType.other.toString()),
          shadowColor: AppColors.pureWhiteColor,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: showMapSection(
                latitude: message["latitude"], longitude: message["longitude"]),
          ),
        ));
  }

  _contactMessageSection({required ChatMessageModel messageData}) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
    final contact = DataManagement.fromJsonString(messageData.message);

    return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: 150,
            maxWidth: MediaQuery.of(widget.context).size.width - 160),
        child: Card(
          elevation: 2,
          color: AppColors.getMsgColor(_isDarkMode,
              messageData.holder == MessageHolderType.other.toString()),
          shadowColor: AppColors.pureWhiteColor,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    contact[PhoneNumberData.name],
                    style: TextStyleCollection.activityTitleTextStyle.copyWith(
                        fontSize: 16,
                        color: AppColors.getMsgTextColor(
                            messageData.holder ==
                                MessageHolderType.other.toString(),
                            _isDarkMode)),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    contact[PhoneNumberData.number],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyleCollection.terminalTextStyle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: AppColors.getMsgTextColor(
                            messageData.holder ==
                                MessageHolderType.other.toString(),
                            _isDarkMode)),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  _phoneNumberManagementSection(
                      phoneNumber: contact[PhoneNumberData.number],
                      name: contact[PhoneNumberData.name],
                      label: contact[PhoneNumberData.numberLabel],
                      messageData: messageData),
                ],
              ),
            ),
          ),
        ));
  }

  _phoneNumberManagementSection(
      {required String phoneNumber,
      String? name,
      String? label,
      required ChatMessageModel messageData}) {
    final InputOption _inputOption = InputOption(widget.context);
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    _addContactButtonPressed() {
      final TextEditingController _contactNameController =
          TextEditingController();
      _contactNameController.text = name ?? "";

      _inputOption.takeInputForContactName(
          contactNameController: _contactNameController,
          phoneNumber: phoneNumber,
          phoneNumberLabel: label ?? "mobile",
          isDarkMode: _isDarkMode);
    }

    _messageOrCallButtonPressed() =>
        _inputOption.phoneNumberOpeningOptions(widget.context,
            phoneNumber: phoneNumber, isDarkMode: _isDarkMode);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        commonTextButton(
            btnText: "Add Contact",
            onPressed: _addContactButtonPressed,
            textColor: AppColors.getTextButtonColor(_isDarkMode,
                messageData.holder == MessageHolderType.other.toString()),
            borderColor: AppColors.getTextButtonColor(_isDarkMode,
                messageData.holder == MessageHolderType.other.toString())),
        commonTextButton(
            btnText: "Message/Call",
            onPressed: _messageOrCallButtonPressed,
            textColor: AppColors.getTextButtonColor(_isDarkMode,
                messageData.holder == MessageHolderType.other.toString()),
            borderColor: AppColors.getTextButtonColor(_isDarkMode,
                messageData.holder == MessageHolderType.other.toString())),
      ],
    );
  }

  _rightSwipe(String messageId, ChatMessageModel messageData) {
    print("Reply to This Message");
  }

  onMessageTap(
      String messageId, ChatMessageModel messageData, _selectedMessages) {
    if (!_selectedMessages.containsKey(messageId)) return;

    Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .removeSingleMessageSelection(messageId);
  }

  onMessageLongTap(
      String messageId, ChatMessageModel messageData, _selectedMessages) {
    if (_selectedMessages.containsKey(messageId)) return;

    Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .setSelectedMessage(messageId, messageData);
  }

  _getPerfectImage(String imagePath) {
    if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
      return null;
    }
    return FileImage(File(imagePath));
  }

  _isItLocalFile(String message) =>
      !message.startsWith('http') && !message.startsWith('https');
}
