import 'dart:io';

import 'package:open_file/open_file.dart';

import 'debugging.dart';

class SystemFileManagement {
  static Future<void> openFile(String filePath) async {
    await OpenFile.open(filePath);
  }

  static deleteFile(String filePath) async {
    try {
      debugShow('Attempting Deleting media file from local storage $filePath');
      await File(filePath).delete(recursive: true);
      debugShow('Local File $filePath deleted');
    } catch (e) {
      debugShow('Error in Delete File: $e');
    }
  }
}
