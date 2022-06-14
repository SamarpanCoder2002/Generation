import 'dart:io';

import 'package:open_file/open_file.dart';

class SystemFileManagement {
  static Future<void> openFile(String filePath) async {
    await OpenFile.open(filePath);
  }

  static deleteFile(String filePath) async {
    try {
      print('Attempting Deleting media file from local storage $filePath');
      await File(filePath).delete(recursive: true);
      print('Local File $filePath deleted');
    } catch (e) {
      print('Error in Delete File: $e');
    }
  }
}
