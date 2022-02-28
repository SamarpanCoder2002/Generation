import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/colors_collection.dart';
import '../../config/text_style_collection.dart';
import '../../providers/connection_collection_provider.dart';
import '../../types/types.dart';

class CommonChatListLayout{
  final ProviderType providerType;
  final BuildContext context;

  CommonChatListLayout({required this.providerType, required this.context});

  particularChatConnection(int connectionIndex) {
    return Container(
      height: 60,
      width: double.maxFinite,
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          _chatConnectionImage(connectionIndex),
          const SizedBox(
            width: 15,
          ),
          _chatConnectionData(connectionIndex),
          const SizedBox(
            width: 10,
          ),
          _chatConnectionInformationData(connectionIndex),
        ],
      ),
    );
  }

  _chatConnectionImage(int connectionIndex) {
    final _connectionData = Provider.of<ConnectionCollectionProvider>(context)
        .getData()[connectionIndex];

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
          color: AppColors.searchBarBgDarkMode.withOpacity(0.5),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.darkBorderGreenColor, width: 3),
          image: DecorationImage(
              image: NetworkImage(_connectionData["profilePic"]),
              fit: BoxFit.cover)),
    );
  }

  _chatConnectionData(int connectionIndex) {
    final _connectionData = Provider.of<ConnectionCollectionProvider>(context)
        .getData()[connectionIndex];

    return SizedBox(
      width: MediaQuery.of(context).size.width - 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _connectionData["connectionName"],
                style: TextStyleCollection.activityTitleTextStyle
                    .copyWith(fontSize: 16),
              )),
          if (_connectionData["latestMessage"] != null &&
              _connectionData["latestMessage"].isNotEmpty)
            Flexible(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _connectionData["latestMessage"]["message"],
                    style: TextStyleCollection.activityTitleTextStyle.copyWith(
                        fontSize: 12,
                        color: AppColors.pureWhiteColor.withOpacity(0.8)),
                  ),
                )),
        ],
      ),
    );
  }

  _chatConnectionInformationData(int connectionIndex) {
    final _connectionData = Provider.of<ConnectionCollectionProvider>(context)
        .getData()[connectionIndex];

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              _connectionData["lastMessageDate"],
              style: TextStyleCollection.activityTitleTextStyle
                  .copyWith(fontSize: 14),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
                color: AppColors.darkBorderGreenColor,
                borderRadius: BorderRadius.circular(100)),
            child: Center(
                child: Text(
                  "${_connectionData["notSeenMsgCount"]}",
                  style: TextStyleCollection.terminalTextStyle,
                )),
          ),
        ],
      ),
    );
  }
}