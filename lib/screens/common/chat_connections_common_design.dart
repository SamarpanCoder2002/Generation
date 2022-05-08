import 'package:flutter/material.dart';
import 'package:generation/providers/connection_collection_provider.dart';
import 'package:generation/types/types.dart';
import 'package:provider/provider.dart';
import '../../config/colors_collection.dart';
import '../../config/text_style_collection.dart';
import '../../providers/theme_provider.dart';

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
      double? middleWidth, double? bottomMargin}) {



    return Container(
      height: height,
      width: double.maxFinite,
      margin: EdgeInsets.only(bottom: bottomMargin ?? 20),
      child: Row(
        children: [
          if (commonRequirement == CommonRequirement.chatHistory || commonRequirement == CommonRequirement.forwardMsg)
            _selectionButton(isSelected, connectionData, currentIndex, commonRequirement),
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
              totalPendingMessages != null && totalPendingMessages != "0")
            _chatConnectionInformationData(lastMsgTime, totalPendingMessages.toString()),
          if (trailingWidget != null) Expanded(child: trailingWidget)
        ],
      ),
    );
  }

  _chatConnectionImage(String? photo) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
          color: _isDarkMode
              ? AppColors.searchBarBgDarkMode.withOpacity(0.5)
              : AppColors.searchBarBgLightMode.withOpacity(0.5),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: _isDarkMode?AppColors.darkBorderGreenColor:AppColors.lightBorderGreenColor, width: 3),
          image: photo == null
              ? null
              : DecorationImage(image: NetworkImage(photo), fit: BoxFit.cover)),
    );
  }

  _chatConnectionData(String heading, String? subheading, double? middleWidth) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

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
                    .copyWith(fontSize: 16,color: _isDarkMode?AppColors.pureWhiteColor:AppColors.lightChatConnectionTextColor),
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
                    color: _isDarkMode?AppColors.pureWhiteColor.withOpacity(0.8):AppColors.lightLatestMsgTextColor),
              ),
            )),
        ],
      ),
    );
  }

  _chatConnectionInformationData(
      String? lastMsgTime, String? totalPendingMessages) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (lastMsgTime != null)
            Flexible(
              child: Text(
                lastMsgTime,
                style: TextStyleCollection.activityTitleTextStyle
                    .copyWith(fontSize: 14, color: _isDarkMode?AppColors.pureWhiteColor:AppColors.lightBorderGreenColor),
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
                  color: _isDarkMode?AppColors.darkBorderGreenColor:AppColors.lightBorderGreenColor,
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
          bool _isSelected, dynamic connectionData, int currentIndex, CommonRequirement commonRequirement){
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return  IconButton(
        onPressed: () {
          if(commonRequirement == CommonRequirement.chatHistory) {
            connectionData["isSelected"] = !connectionData["isSelected"];
            Provider.of<ConnectionCollectionProvider>(context, listen: false)
                .updateParticularSelectionData(connectionData, currentIndex);
          }else{
            connectionData["isSelected"] = !connectionData["isSelected"];
            Provider.of<ConnectionCollectionProvider>(context, listen: false).selectUnselectMultipleConnection(connectionData, currentIndex);
          }
        },
        icon: _isSelected
            ? Icon(
          Icons.circle,
          color: AppColors.getIconColor(_isDarkMode),
        )
            : Icon(
          Icons.circle_outlined,
          color: AppColors.getIconColor(_isDarkMode),
        ));
  }
}
