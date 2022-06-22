import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';

class TextStyleCollection{

  static const TextStyle headingTextStyle = TextStyle(
    fontSize: 25,
    color: AppColors.pureWhiteColor
  );

  static const TextStyle searchTextStyle = TextStyle(
    fontSize: 16,
    color: AppColors.pureWhiteColor
  );

  static const TextStyle secondaryHeadingTextStyle = TextStyle(
    fontSize: 14,
    color: AppColors.pureWhiteColor,
    fontWeight: FontWeight.w600
  );

  static const TextStyle activityTitleTextStyle = TextStyle(
    fontSize: 14,
    color: AppColors.pureWhiteColor,
    fontWeight: FontWeight.w600
  );

  static const TextStyle terminalTextStyle = TextStyle(
      fontSize: 12,
      color: AppColors.pureWhiteColor,
      fontWeight: FontWeight.w600
  );
}