import 'dart:io';

class SizeCollection {
  static const double activityBottomTextHeight = 150;
  static const int chatMessagePaginatedLimit = 50;
  static const int activitySustainTimeInHour = 24;

  static double getFileSize(File file) {
    final sizeInBytes = file.lengthSync();

    /// Size in Bytes
    return sizeInBytes / (1024 * 1024);
  }

  static const maxConnSelected = 3;
}
