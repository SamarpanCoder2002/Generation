import 'dart:io';

class SizeCollection {
  static const double activityBottomTextHeight = 150;
  static const int chatMessagePaginatedLimit = 10;

  static double getFileSize(File file){
    final sizeInBytes = file.lengthSync();/// Size in Bytes
    return sizeInBytes / (1024 * 1024);
  }
}
