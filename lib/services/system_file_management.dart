import 'dart:io';

import 'package:open_file/open_file.dart';

class SystemFileManagement {
  static Future<void> openFile(String filePath) async {
    await OpenFile.open(filePath);
  }

  static deleteFile(String filePath) async {
    try {
      debug('Attempting Deleting media file from local storage $filePath');
      await File(filePath).delete(recursive: true);
      debug('Local File $filePath deleted');
    } catch (e) {
      debug('Error in Delete File: $e');
    }
  }
}
