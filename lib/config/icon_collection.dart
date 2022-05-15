import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'colors_collection.dart';

class IconCollection {
  static List<dynamic> iconsCollection = [
    [
      const Icon(
        Icons.camera_alt_outlined,
        color: AppColors.pureWhiteColor,
        size: 30,
      ),
      "Camera",
      AppColors.cameraIconBgColor,
    ],
    [
      const Icon(
        Icons.photo,
        color: AppColors.pureWhiteColor,
        size: 30,
      ),
      "Gallery",
      AppColors.galleryIconBgColor,
    ],
    [
      const Icon(
        Icons.video_collection_outlined,
        color: AppColors.pureWhiteColor,
        size: 30,
      ),
      "Video",
      AppColors.videoIconBgColor
    ],
    [
      const Icon(
        Entypo.documents,
        color: AppColors.pureWhiteColor,
        size: 30,
      ),
      "Document",
      AppColors.documentIconBgColor
    ],
    [
      const Icon(
        Icons.music_note_outlined,
        color: AppColors.pureWhiteColor,
        size: 30,
      ),
      "Audio",
      AppColors.audioIconBgColor
    ],
    [
      const Icon(
        Icons.location_on_outlined,
        color: AppColors.pureWhiteColor,
        size: 30,
      ),
      "Location",
      AppColors.locationIconBgColor
    ],
    [
      const Icon(
        Icons.person_outline_outlined,
        color: AppColors.pureWhiteColor,
        size: 30,
      ),
      "Contact",
      AppColors.personIconBgColor
    ],
  ];
}

class ActivityIconCollection{
  static List<dynamic> iconsCollection = [
    [
      const Icon(
        Icons.create_rounded,
        color: AppColors.pureWhiteColor,
        size: 30,
      ),
      "Text",
      AppColors.normalBlueColor,
    ],
    [
      const Icon(
        Icons.camera_alt_outlined,
        color: AppColors.pureWhiteColor,
        size: 30,
      ),
      "Camera",
      AppColors.cameraIconBgColor,
    ],
    [
      const Icon(
        Icons.photo,
        color: AppColors.pureWhiteColor,
        size: 30,
      ),
      "Gallery",
      AppColors.galleryIconBgColor,
    ],
    [
      const Icon(
        Icons.video_collection_outlined,
        color: AppColors.pureWhiteColor,
        size: 30,
      ),
      "Video",
      AppColors.videoIconBgColor
    ],
    [
      const Icon(
        Icons.music_note_outlined,
        color: AppColors.pureWhiteColor,
        size: 30,
      ),
      "Audio",
      AppColors.audioIconBgColor
    ],
    // [
    //   const Icon(
    //     Icons.poll_outlined,
    //     color: AppColors.pureWhiteColor,
    //     size: 30,
    //   ),
    //   "Poll",
    //   AppColors.personIconBgColor
    // ],
  ];
}


class ConnectionActionOptions{
  static List<dynamic> iconsCollection = [
    [
      const Icon(
        Icons.person_add_disabled,
        color: AppColors.pureWhiteColor,
        size: 25,
      ),
      "Remove Connection",
      AppColors.normalBlueColor,
    ],
    [
      const Icon(
        Icons.delete_outline_outlined,
        color: AppColors.pureWhiteColor,
        size: 25,
      ),
      "Clear Chat",
      AppColors.cameraIconBgColor,
    ],
    [
      const Icon(
        Icons.notifications_none,
        color: AppColors.pureWhiteColor,
        size: 25,
      ),
      "Notification",
      AppColors.galleryIconBgColor,
    ],
  ];
}
