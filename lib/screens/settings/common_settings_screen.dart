import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/screens/settings/storage/storage_screen.dart';
import 'package:generation/types/types.dart';
import 'package:provider/provider.dart';

import '../../config/text_style_collection.dart';
import '../../providers/connection_collection_provider.dart';
import '../common/chat_connections_common_design.dart';

class CommonSettingScreen extends StatefulWidget {
  final CommonRequirement commonRequirement;

  const CommonSettingScreen(
      {Key? key, required this.commonRequirement})
      : super(key: key);

  @override
  State<CommonSettingScreen> createState() => _CommonSettingScreenState();
}

class _CommonSettingScreenState extends State<CommonSettingScreen> {
  @override
  void initState() {
    Provider.of<ConnectionCollectionProvider>(context, listen: false)
        .setForSelection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<ConnectionCollectionProvider>(context, listen: false)
            .resetSelectionData();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDarkMode,
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

  _headerSection() => AppBar(
        elevation: 0,
        backgroundColor: AppColors.chatDarkBackgroundColor,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_outlined)),
            Text(
              "Select Any Connection",
              style:
                  TextStyleCollection.terminalTextStyle.copyWith(fontSize: 16),
            ),
          ],
        ),
      );

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
          onTap: widget.commonRequirement == CommonRequirement.chatHistory?null: () => _onClicked(_connectionData),
          child: _commonChatLayout.particularChatConnection(
              commonRequirement: widget.commonRequirement,
              connectionData: _connectionData,
              isSelected: _connectionData["isSelected"],
              photo: _connectionData["profilePic"],
              heading: _connectionData["connectionName"],
              subheading: _connectionData["latestMessage"]["message"],
              lastMsgTime: _connectionData["latestMessage"]["time"],
              currentIndex: connectionIndex,
              totalPendingMessages:
                  _connectionData["notSeenMsgCount"].toString()),
        );
      },
    );
  }

  _onClicked(connectionData) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalStorageScreen()));
  }
}
