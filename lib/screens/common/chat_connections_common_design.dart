import 'package:flutter/material.dart';
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
      required String? totalPendingMessages}) {
    return Container(
      height: 60,
      width: double.maxFinite,
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          _chatConnectionImage(photo),
          const SizedBox(
            width: 15,
          ),
          _chatConnectionData(heading, subheading),
          if (lastMsgTime != null && totalPendingMessages != null)
            const SizedBox(
              width: 10,
            ),
          if (lastMsgTime != null && totalPendingMessages != null)
            _chatConnectionInformationData(lastMsgTime, totalPendingMessages),
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

  _chatConnectionData(String heading, String? subheading) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 200,
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
}
