import 'dart:io';

import '../config/size_collection.dart';

class DBHelper{
  static profileImgPath(uid) => '$uid-profile-pic.png';
  static activityPath(uid, String fileName) => '${uid}_${DateTime.now()}_$fileName';
}

class StorageHelper{
  static const profilePicRef = "media/profile-picture/";

  static chatAudioRef(String currId, String partnerId) => "chat/$currId-$partnerId/audio/";
  static chatImageRef(String currId, String partnerId) => "chat/$currId-$partnerId/images/";
  static chatVideoRef(String currId, String partnerId) => "chat/$currId-$partnerId/videos/";
  static chatDocRef(String currId, String partnerId) => "chat/$currId-$partnerId/documents/";
  static chatVideoThumbnailRef(String currId, String partnerId) => "chat/$currId-$partnerId/thumbnails/";
  static activityRef(String currId) => "activity/$currId/media/";

  static const otherRef = "media/other";
}

class Validator{
  static bool profilePic(File file){
    final double _sizeInMb = SizeCollection.getFileSize(file);
    print("Profile Picture Size: $_sizeInMb");

    return _sizeInMb <= 4;
  }
}

class DBStatement{
  static const profilePicRestriction = "Profile picture size should be within 4 mb";
  static const profileCompleted = "Profile Completed Successfully";
  static const profileUpdated = "Profile Updated Successfully";
}