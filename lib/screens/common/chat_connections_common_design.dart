import 'package:flutter/material.dart';
import 'package:generation/providers/connection_collection_provider.dart';
import 'package:generation/types/types.dart';
import 'package:provider/provider.dart';
import '../../config/colors_collection.dart';
import '../../config/text_style_collection.dart';

class CommonChatListLayout {
  final BuildContext context;

  CommonChatListLayout({required this.context});

  particularChatConnection(
      {required int currentIndex,
      required String? photo,
      required String heading,
      required String? subheading,
      required String? lastMsgTime,
      required String? totalPendingMessages,
      CommonRequirement commonRequirement = CommonRequirement.normal,
      dynamic connectionData,
      Widget? trailingWidget,
      bool isSelected = false,
      double height = 60.0,
      double? middleWidth}) {
    return Container(
      height: height,
      width: double.maxFinite,
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          if (commonRequirement == CommonRequirement.chatHistory)
            _selectionButton(isSelected, connectionData, currentIndex),
          if (commonRequirement != CommonRequirement.normal) const SizedBox(width: 20),
          _chatConnectionImage(photo),
          const SizedBox(
            width: 15,
          ),
          _chatConnectionData(heading, subheading, middleWidth),
          if (commonRequirement == CommonRequirement.normal &&
              lastMsgTime != null &&
              totalPendingMessages != null)
            const SizedBox(
              width: 10,
            ),
          if (commonRequirement == CommonRequirement.normal &&
              trailingWidget == null &&
              lastMsgTime != null &&
              totalPendingMessages != null)
            _chatConnectionInformationData(lastMsgTime, totalPendingMessages),
          if (trailingWidget != null) Expanded(child: trailingWidget)
        ],
      ),
    );
  }

  _chatConnectionImage(String? photo) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
          color: AppColors.searchBarBgDarkMode.withOpacity(0.5),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.darkBorderGreenColor, width: 3),
          image: photo == null
              ? null
              : DecorationImage(image: NetworkImage(photo), fit: BoxFit.cover)),
    );
  }

  _chatConnectionData(String heading, String? subheading, double? middleWidth) {
    return SizedBox(
      width: middleWidth ?? MediaQuery.of(context).size.width - 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                heading,
                style: TextStyleCollection.activityTitleTextStyle
                    .copyWith(fontSize: 16),
              )),
          if (subheading != null && subheading.isNotEmpty)
            Flexible(
                child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                subheading,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyleCollection.activityTitleTextStyle.copyWith(
                    fontSize: 12,
                    color: AppColors.pureWhiteColor.withOpacity(0.8)),
              ),
            )),
        ],
      ),
    );
  }

  _chatConnectionInformationData(
      String? lastMsgTime, String? totalPendingMessages) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (lastMsgTime != null)
            Flexible(
              child: Text(
                lastMsgTime,
                style: TextStyleCollection.activityTitleTextStyle
                    .copyWith(fontSize: 14),
              ),
            ),
          const SizedBox(
            height: 10,
          ),
          if (totalPendingMessages != null)
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                  color: AppColors.darkBorderGreenColor,
                  borderRadius: BorderRadius.circular(100)),
              child: Center(
                  child: Text(
                totalPendingMessages,
                style: TextStyleCollection.terminalTextStyle,
              )),
            ),
        ],
      ),
    );
  }

  _selectionButton(
          bool _isSelected, dynamic connectionData, int currentIndex) =>
      IconButton(
          onPressed: () {
            connectionData["isSelected"] = !connectionData["isSelected"];
            Provider.of<ConnectionCollectionProvider>(context, listen: false)
                .updateParticularSelectionData(connectionData, currentIndex);
          },
          icon: _isSelected
              ? const Icon(
                  Icons.circle,
                  color: AppColors.pureWhiteColor,
                )
              : const Icon(
                  Icons.circle_outlined,
                  color: AppColors.pureWhiteColor,
                ));
}
