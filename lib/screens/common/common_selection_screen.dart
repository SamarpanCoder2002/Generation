import 'dart:io';

import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/images_path_collection.dart';
import 'package:generation/config/countable_data_collection.dart';
import 'package:generation/model/chat_message_model.dart';
import 'package:generation/providers/main_screen_provider.dart';
import 'package:generation/screens/common/button.dart';
import 'package:generation/screens/settings/storage/storage_screen.dart';
import 'package:generation/services/directory_management.dart';
import 'package:generation/services/encryption_operations.dart';
import 'package:generation/services/input_system_services.dart';
import 'package:generation/services/local_data_management.dart';
import 'package:generation/services/navigation_management.dart';
import 'package:generation/services/toast_message_show.dart';
import 'package:generation/config/types.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../../config/text_style_collection.dart';
import '../../providers/chat/messaging_provider.dart';
import '../../providers/connection_collection_provider.dart';
import '../../providers/storage/storage_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/debugging.dart';
import '../../services/device_specific_operations.dart';
import 'chat_connections_common_design.dart';

class CommonSelectionScreen extends StatefulWidget {
  final CommonRequirement commonRequirement;

  const CommonSelectionScreen({Key? key, required this.commonRequirement})
      : super(key: key);

  @override
  State<CommonSelectionScreen> createState() => _CommonSelectionScreenState();
}

class _CommonSelectionScreenState extends State<CommonSelectionScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    final _isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();

    changeContextTheme(_isDarkMode);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return LoadingOverlay(
      isLoading: _isLoading,
      color: AppColors.pureBlackColor.withOpacity(0.6),
      progressIndicator: const CircularProgressIndicator(
        color: AppColors.lightBorderGreenColor,
      ),
      child: WillPopScope(
        onWillPop: () async {
          Provider.of<ConnectionCollectionProvider>(context, listen: false)
              .resetSelectionData();
          return true;
        },
        child: Scaffold(
          backgroundColor: AppColors.getBgColor(_isDarkMode),
          appBar: _headerSection(),
          floatingActionButton: _sendBtn(),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: _chatConnectionCollection(),
          ),
        ),
      ),
    );
  }

  _headerSection() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.getBgColor(_isDarkMode),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_outlined,
                  color: _isDarkMode
                      ? AppColors.pureWhiteColor
                      : AppColors.lightChatConnectionTextColor)),
          Text(
            "Select Any Connection",
            style: TextStyleCollection.terminalTextStyle.copyWith(
                fontSize: 16,
                color: _isDarkMode
                    ? AppColors.pureWhiteColor
                    : AppColors.lightChatConnectionTextColor),
          ),
        ],
      ),
    );
  }

  _chatConnectionCollection() {
    if (Provider.of<ConnectionCollectionProvider>(context)
            .getConnectionsDataLength ==
        0) {
      return _noConnectionSection();
    }

    final _commonChatLayout = CommonChatListLayout(context: context);

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount:
          Provider.of<ConnectionCollectionProvider>(context).getDataLength(),
      itemBuilder: (_, connectionIndex) {
        final _rawData = Provider.of<ConnectionCollectionProvider>(context)
            .getData()[connectionIndex];

        final _connectionData =
            Provider.of<ConnectionCollectionProvider>(context)
                .getUsersMap(_rawData["id"]);

        return InkWell(
          onTap: () => _getPerfectMethod(_connectionData),
          child: _commonChatLayout.particularChatConnection(
              commonRequirement: widget.commonRequirement,
              connectionData: _connectionData,
              photo: Secure.decode(_connectionData["profilePic"]),
              heading: Secure.decode(_connectionData["name"]),
              subheading: '',
              lastMsgTime: '',
              currentIndex: connectionIndex,
              totalPendingMessages: ''),
        );
      },
    );
  }

  _noConnectionSection({bool navigateButton = true}) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height / 1.8,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "No Connection Found",
              style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
                  fontSize: 16,
                  color: AppColors.getModalTextColor(_isDarkMode)),
            ),
            if (navigateButton) const SizedBox(height: 10),
            if (navigateButton)
              commonElevatedButton(
                  btnText: "Let's Connect",
                  bgColor: AppColors.getTextButtonColor(_isDarkMode, true),
                  onPressed: () {
                    Navigator.pop(context);
                    Provider.of<MainScreenNavigationProvider>(context,
                            listen: false)
                        .setUpdatedIndex(1);
                  })
          ],
        ));
  }

  _navigateToLocalStorageSection(connectionData) async {
    final _chatHistoryData =
        await Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .getChatHistory(connectionData["id"], connectionData["name"]);

    debugShow("Connection Data:   $_chatHistoryData");

    Provider.of<StorageProvider>(context, listen: false)
        .setImagesCollection(_chatHistoryData[ChatMessageType.image]);
    Provider.of<StorageProvider>(context, listen: false)
        .setVideosCollection(_chatHistoryData[ChatMessageType.video]);
    Provider.of<StorageProvider>(context, listen: false)
        .setDocumentCollection(_chatHistoryData[ChatMessageType.document]);
    Provider.of<StorageProvider>(context, listen: false)
        .setAudioCollection(_chatHistoryData[ChatMessageType.audio]);

    Navigation.intent(context, const LocalStorageScreen());
  }

  _getPerfectMethod(_connectionData) {
    if (widget.commonRequirement == CommonRequirement.chatHistory) {
      return _extractChatHistory(_connectionData);
    }
    if (widget.commonRequirement == CommonRequirement.forwardMsg) {
      final _response =
          Provider.of<ConnectionCollectionProvider>(context, listen: false)
              .onConnectionClick(_connectionData["id"]);

      if (!_response) {
        showToast(
            title:
                'You Can Select Maximum ${SizeCollection.maxConnSelected} Connections',
            toastIconType: ToastIconType.info,
            fontSize: 14,
            showFromTop: false);
      }
      return;
    }
    if (widget.commonRequirement == CommonRequirement.localDataStorage) {
      return _navigateToLocalStorageSection(_connectionData);
    }
    return {};
  }

  _sendBtn() {
    if (widget.commonRequirement != CommonRequirement.forwardMsg &&
        widget.commonRequirement != CommonRequirement.incomingData) return;

    final _isAnyConnectionSelected =
        Provider.of<ConnectionCollectionProvider>(context)
            .isAnyConnectionSelected();
    if (!_isAnyConnectionSelected) return const Center();

    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
    // final _incomingData =
    //     Provider.of<IncomingDataProvider>(context).getIncomingData();

    return FloatingActionButton(
      onPressed: () async {
        if (widget.commonRequirement == CommonRequirement.forwardMsg) {
          final _selectedMessages =
              Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                  .getSelectedMessage();
          final _messagesCollection = _selectedMessages.values.toList();
          await _sendMessagesToSelectedConnections(_messagesCollection);
        } else if (widget.commonRequirement == CommonRequirement.incomingData) {
          final _messagesCollection =
              Provider.of<MainScreenNavigationProvider>(context, listen: false)
                  .getIncomingData();
          await _sendMessagesToSelectedConnections(_messagesCollection);
        }
      },
      backgroundColor: AppColors.getElevatedBtnColor(_isDarkMode),
      child: Image.asset(
        IconImages.sendImagePath,
        width: 35,
        color: AppColors.pureWhiteColor,
      ),
    );
  }

  _extractChatHistory(connectionData) async {
    debugShow("At Extract Chat History");

    final _chatHistoryData =
        await Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .getChatHistory(
                connectionData["id"], Secure.decode(connectionData["name"]));

    final _chatHistoryStoreDir = await createChatHistoryStoreDir();
    final _chatHistoryStoreFile = File(createChatHistoryFile(
        dirPath: _chatHistoryStoreDir,
        connName: Secure.decode(connectionData["name"]),
        connId: connectionData["id"]));

    String _historyTextData = """""";

    for (final particularText in _chatHistoryData[ChatMessageType.text]) {
      _historyTextData += particularText;
    }

    await _chatHistoryStoreFile.writeAsString(_historyTextData);

    debugShow(await _chatHistoryStoreFile.readAsString());

    _showShareOptions(_chatHistoryStoreFile);
  }

  _sendMessagesToSelectedConnections(_messagesCollection) async {
    final _selectedConnections =
        Provider.of<ConnectionCollectionProvider>(context, listen: false)
            .getSelectedConnections();
    debugShow("Selected Connections:  $_selectedConnections");

    for (final message in _messagesCollection) {
      var _modifiedMessage = message.message;
      var _additionalData = message.additionalData;

      if (message.type == ChatMessageType.contact.toString() ||
          message.type == ChatMessageType.location.toString()) {
        _modifiedMessage = DataManagement.fromJsonString(message.message);
      }

      // if (_additionalData != null) {
      //   _additionalData = DataManagement.fromJsonString(_additionalData);
      // }

      showToast(
          title: 'Message Sending... Please Wait',
          toastIconType: ToastIconType.success,
          toastDuration: 10);

      for (final selectedConnectionsId in _selectedConnections.keys.toList()) {
        if (mounted) {
          setState(() {
            _isLoading = true;
          });
        }

        await Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .sendMsgManagement(
                msgType: message.type,
                message: _modifiedMessage,
                additionalData: _additionalData,
                incomingConnId: selectedConnectionsId,
                forSendMultiple: true);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }

    Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .clearSelectedMsgCollection();
    Provider.of<ConnectionCollectionProvider>(context, listen: false)
        .resetSelectionData();

    Navigator.pop(context);
    Navigator.pop(context);
  }

  void _showShareOptions(File chatHistoryStoreFile) {
    final InputOption _inputOption = InputOption(context);
    final _isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();

    showModalBottomSheet(
        context: context,
        builder: (_) => Container(
              width: MediaQuery.of(context).size.width,
              height: 140,
              color: AppColors.getModalColorSecondary(_isDarkMode),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        "Share Chat History With",
                        style: TextStyleCollection.secondaryHeadingTextStyle
                            .copyWith(
                                fontSize: 18,
                                color:
                                    AppColors.getModalTextColor(_isDarkMode)),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          commonElevatedButton(
                              btnText: 'Connections',
                              bgColor: AppColors.getTextButtonColor(
                                  _isDarkMode, true),
                              onPressed: () => _sendChatHistoryToConnections(
                                  chatHistoryStoreFile)),
                          commonElevatedButton(
                              btnText: 'Other Apps',
                              bgColor: AppColors.getTextButtonColor(
                                  _isDarkMode, true),
                              onPressed: () =>
                                  _inputOption.shareFile(chatHistoryStoreFile)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  _sendChatHistoryToConnections(File chatHistoryStoreFile) {
    final _date = Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .getCurrentDate();
    final _time = Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .getCurrentTime();

    Provider.of<MainScreenNavigationProvider>(context, listen: false)
        .setIncomingData([
      ChatMessageModel.toJson(
          type: ChatMessageType.document.toString(),
          message: chatHistoryStoreFile.path,
          date: _date,
          time: _time,
          holder: MessageHolderType.me.toString(),
          additionalData: {"extension-for-document": 'txt', "fileName": chatHistoryStoreFile.path})
    ]);

    Navigator.pop(context);

    Navigation.intent(
        context,
        const CommonSelectionScreen(
            commonRequirement: CommonRequirement.incomingData));
  }
}
