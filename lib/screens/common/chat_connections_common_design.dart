import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generation/providers/connection_collection_provider.dart';
import 'package:generation/screens/common/image_showing_screen.dart';
import 'package:generation/services/navigation_management.dart';
import 'package:generation/services/toast_message_show.dart';
import 'package:generation/config/types.dart';
import 'package:provider/provider.dart';
import '../../config/colors_collection.dart';
import '../../config/countable_data_collection.dart';
import '../../config/text_style_collection.dart';
import '../../providers/theme_provider.dart';
import '../../services/device_specific_operations.dart';

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
      double height = 60.0,
      double? middleWidth,
      double? bottomMargin}) {
    return Container(
      height: height,
      width: double.maxFinite,
      margin: EdgeInsets.only(bottom: bottomMargin ?? 20),
      child: Row(
        children: [
          if (commonRequirement == CommonRequirement.forwardMsg || commonRequirement == CommonRequirement.incomingData)
            _selectionButton(connectionData, currentIndex, commonRequirement),
          if (commonRequirement != CommonRequirement.normal)
            const SizedBox(width: 20),
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
              totalPendingMessages != null &&
              totalPendingMessages != "0")
            _chatConnectionInformationData(
                lastMsgTime, totalPendingMessages.toString()),
          if (trailingWidget != null) Expanded(child: trailingWidget)
        ],
      ),
    );
  }

  _chatConnectionImage(String? photo) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return InkWell(
      onTap: () => _onImageClicked(photo),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
            color: _isDarkMode
                ? AppColors.searchBarBgDarkMode.withOpacity(0.5)
                : AppColors.searchBarBgLightMode.withOpacity(0.5),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
                color: _isDarkMode
                    ? AppColors.darkBorderGreenColor
                    : AppColors.lightBorderGreenColor,
                width: 3),
            image: photo == null
                ? null
                : DecorationImage(
                    image: NetworkImage(photo), fit: BoxFit.cover)),
      ),
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
                style: TextStyleCollection.activityTitleTextStyle.copyWith(
                    fontSize: 16,
                    color: _isDarkMode
                        ? AppColors.pureWhiteColor
                        : AppColors.lightChatConnectionTextColor),
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
                    color: _isDarkMode
                        ? AppColors.pureWhiteColor.withOpacity(0.8)
                        : AppColors.lightLatestMsgTextColor),
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
                style: TextStyleCollection.activityTitleTextStyle.copyWith(
                    fontSize: 14,
                    color: _isDarkMode
                        ? AppColors.pureWhiteColor
                        : AppColors.lightBorderGreenColor),
              ),
            ),
          const SizedBox(
            height: 10,
          ),
          if (totalPendingMessages != '')
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                  color: _isDarkMode
                      ? AppColors.darkBorderGreenColor
                      : AppColors.lightBorderGreenColor,
                  borderRadius: BorderRadius.circular(100)),
              child: Center(
                  child: Text(
                totalPendingMessages ?? '',
                style: TextStyleCollection.terminalTextStyle,
              )),
            ),
        ],
      ),
    );
  }

  _selectionButton(dynamic connectionData, int currentIndex,
      CommonRequirement commonRequirement) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
    final _isSelected = Provider.of<ConnectionCollectionProvider>(context)
        .isConnectionSelected(connectionData["id"]);

    return IconButton(
        onPressed: () {
          final _response = Provider.of<ConnectionCollectionProvider>(context, listen: false)
              .onConnectionClick(connectionData["id"]);

          if(!_response){
            ToastMsg.showInfoToast( 'You Can Select Maximum ${SizeCollection.maxConnSelected} Connections', context: context);
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

  _onImageClicked(String? photo) {
    if (photo == null) {
      ToastMsg.showInfoToast(
          "Image Not Found", context: context);
      return;
    }

    final _isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();

    Navigation.intent(
        context,
        ImageShowingScreen(
            imgPath: photo,
            imageType: _getPerfectImageType(photo)), afterWork: () {
      showStatusAndNavigationBar();
      changeOnlyNavigationBarColor(
          navigationBarColor: AppColors.getBgColor(_isDarkMode));
    });
  }

  _getPerfectImageType(String imagePath) {
    if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
      return ImageType.network;
    }
    return ImageType.file;
  }
}
