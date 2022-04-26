import 'dart:io';

import '../config/size_collection.dart';

class DBHelper{
  static profileImgPath(uid) => '$uid-profile-pic.png';
}

class StorageHelper{
  static const profilePicRef = "media/profile-picture/";
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
}