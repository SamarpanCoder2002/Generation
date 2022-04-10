import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/screens/settings/storage/storage_screen.dart';
import 'package:generation/types/types.dart';
import 'package:provider/provider.dart';

import '../../config/text_style_collection.dart';
import '../../providers/connection_collection_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/device_specific_operations.dart';
import 'chat_connections_common_design.dart';

class CommonSelectionScreen extends StatefulWidget {
  final CommonRequirement commonRequirement;

  const CommonSelectionScreen(
      {Key? key, required this.commonRequirement})
      : super(key: key);

  @override
  State<CommonSelectionScreen> createState() => _CommonSelectionScreenState();
}

class _CommonSelectionScreenState extends State<CommonSelectionScreen> {
  @override
  void initState() {
    Provider.of<ConnectionCollectionProvider>(context, listen: false)
        .setForSelection();
    final _isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();

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
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: _chatConnectionCollection(),
        ),
      ),
    );
  }

  _headerSection(){
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.getBgColor(_isDarkMode),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_outlined,color: _isDarkMode?AppColors.pureWhiteColor:AppColors.lightChatConnectionTextColor)),
          Text(
            "Select Any Connection",
            style:
            TextStyleCollection.terminalTextStyle.copyWith(fontSize: 16,color: _isDarkMode?AppColors.pureWhiteColor:AppColors.lightChatConnectionTextColor),
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
      itemCount: Provider.of<ConnectionCollectionProvider>(context)
          .getWillSelectDataLength(),
      itemBuilder: (_, connectionIndex) {
        final _connectionData =
            Provider.of<ConnectionCollectionProvider>(context)
                .getWillSelectData()[connectionIndex];

        return InkWell(
          onTap: () => _getPerfectMethod(_connectionData),
          child: _commonChatLayout.particularChatConnection(
              commonRequirement: widget.commonRequirement,
              connectionData: _connectionData,
              isSelected: _connectionData["isSelected"],
              photo: _connectionData["profilePic"],
              heading: _connectionData["connectionName"],
              subheading: _connectionData["latestMessage"]["message"],
              lastMsgTime: _connectionData["latestMessage"]["time"],
              currentIndex: connectionIndex,
              totalPendingMessages:      _connectionData["notSeenMsgCount"].toString()),
        );
      },
    );
  }

  _onClicked(connectionData) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalStorageScreen()));
  }

  _getPerfectMethod(_connectionData) {
    if(widget.commonRequirement == CommonRequirement.chatHistory) return {};
    if(widget.commonRequirement == CommonRequirement.forwardMsg) return{};
    return _onClicked(_connectionData);
  }
}
