import 'dart:io';

import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/images_path_collection.dart';
import 'package:generation/providers/incoming_data_provider.dart';
import 'package:generation/screens/main_screens/main_screen_management.dart';
import 'package:generation/screens/settings/storage/storage_screen.dart';
import 'package:generation/services/directory_management.dart';
import 'package:generation/services/local_data_management.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:generation/services/navigation_management.dart';
import 'package:generation/types/types.dart';
import 'package:provider/provider.dart';

import '../../config/text_collection.dart';
import '../../config/text_style_collection.dart';
import '../../providers/chat/messaging_provider.dart';
import '../../providers/connection_collection_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/device_specific_operations.dart';
import '../../services/native_operations.dart';
import 'chat_connections_common_design.dart';

class CommonSelectionScreen extends StatefulWidget {
  final CommonRequirement commonRequirement;

  const CommonSelectionScreen({Key? key, required this.commonRequirement})
      : super(key: key);

  @override
  State<CommonSelectionScreen> createState() => _CommonSelectionScreenState();
}

class _CommonSelectionScreenState extends State<CommonSelectionScreen> {
  final LocalStorage _localStorage = LocalStorage();

  @override
  void initState() {
    // Provider.of<ConnectionCollectionProvider>(context, listen: false)
    //     .setForSelection();
    final _isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();

    changeContextTheme(_isDarkMode);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return WillPopScope(
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
    final _commonChatLayout = CommonChatListLayout(context: context);

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: Provider.of<ConnectionCollectionProvider>(context).getDataLength(),
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
              photo: _connectionData["profilePic"],
              heading: _connectionData["name"],
              subheading: '',
              lastMsgTime: '',
              currentIndex: connectionIndex,
              totalPendingMessages: ''),
        );
      },
    );
  }

  _navigateToLocalStorageSection(connectionData) {
    //Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalStorageScreen()));
    Navigation.intent(context, const LocalStorageScreen());
  }

  _getPerfectMethod(_connectionData) {
    if (widget.commonRequirement == CommonRequirement.chatHistory) {
      return _extractChatHistory(_connectionData);
    }
    if (widget.commonRequirement == CommonRequirement.forwardMsg) {
      Provider.of<ConnectionCollectionProvider>(context, listen: false)
          .onConnectionClick(_connectionData["id"]);
      return;
    }
    return _navigateToLocalStorageSection(_connectionData);
  }

  _sendBtn() {
    if(widget.commonRequirement != CommonRequirement.forwardMsg) return;

    final _isAnyConnectionSelected = Provider.of<ConnectionCollectionProvider>(context).isAnyConnectionSelected();
    if(!_isAnyConnectionSelected) return const Center();

    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
    // final _incomingData =
    //     Provider.of<IncomingDataProvider>(context).getIncomingData();



    return FloatingActionButton(
      onPressed: () async {
        if(widget.commonRequirement == CommonRequirement.forwardMsg){
          await _sendSelectedMessagesToSelectedConnections();
        }
      },
      backgroundColor: AppColors.getElevatedBtnColor(_isDarkMode),
      child: Image.asset(
        IconImages.sendImagePath,
        width: 35,
        color: AppColors.getIconColor(_isDarkMode),
      ),
    );
  }

  _getProperType(element) {
    if (element["type"] == IncomingMediaType.image.toString()) {
      return ChatMessageType.image.toString();
    }
    if (element["type"] == IncomingMediaType.video.toString()) {
      return ChatMessageType.video.toString();
    }
    if (element["type"] == IncomingMediaType.file.toString()) {
      return ChatMessageType.document.toString();
    }
  }

  _getThumbnail(element) async {
    if (element["type"] == IncomingMediaType.video.toString()) {
      return await NativeCallback()
          .getTheVideoThumbnail(videoPath: File(element["path"]).path);
    }

    return "";
  }

  _extractChatHistory(connectionData) async {
    print("At Extract Chat History");

    final _chatHistoryData =
        await Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .getChatHistory(connectionData["id"], connectionData["name"]);

    final _chatHistoryStoreDir = await createChatHistoryStoreDir();
    final _chatHistoryStoreFile = File(createChatHistoryFile(
        dirPath: _chatHistoryStoreDir,
        connName: connectionData["name"],
        connId: connectionData["id"]));

    String _historyTextData = """""";

    for (final particularText in _chatHistoryData[ChatMessageType.text]) {
      _historyTextData += particularText;
    }

    await _chatHistoryStoreFile.writeAsString(_historyTextData);

    print(await _chatHistoryStoreFile.readAsString());
  }

  _sendSelectedMessagesToSelectedConnections() async{
    final _selectedMessages = Provider.of<ChatBoxMessagingProvider>(context, listen: false).getSelectedMessage();
    final _messagesCollection = _selectedMessages.values.toList();

    for(final message in _messagesCollection){
      var _modifiedMessage = message.message;
      var _additionalData = message.additionalData;

      if(message.type == ChatMessageType.contact.toString() ||
          message.type == ChatMessageType.location.toString()){
        _modifiedMessage = DataManagement.fromJsonString(message.message);
      }

      if(_additionalData != null){
        _additionalData = DataManagement.fromJsonString(_additionalData);
      }

      await Provider.of<ChatBoxMessagingProvider>(context, listen: false)
          .sendMsgManagement(
          msgType: message.type,
          message: _modifiedMessage,
          additionalData: _additionalData);
    }

    Provider.of<ChatBoxMessagingProvider>(context, listen: false).clearSelectedMsgCollection();
    Provider.of<ConnectionCollectionProvider>(context, listen: false).resetSelectionData();
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
