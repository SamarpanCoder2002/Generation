import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../config/colors_collection.dart';
import '../../config/text_style_collection.dart';

class MessageCreationSection extends StatelessWidget {
  final BuildContext context;
  const MessageCreationSection({Key? key, required this.context}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(width: 0, color: AppColors.chatDarkBackgroundColor,)
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
          color: AppColors.messageWritingSectionColor
        ),
        child: TextField(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(bottom: 10),
            border: InputBorder.none,
            hintText: "Write Something Here",
            hintStyle: TextStyleCollection.searchTextStyle
                .copyWith(color: AppColors.pureWhiteColor.withOpacity(0.8), fontSize: 14),
          ),
        ),
      ),
    );
  }
}
