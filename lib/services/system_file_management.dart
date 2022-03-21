import 'package:open_file/open_file.dart';

class SystemFileManagement{
  static Future<void> openFile(String filePath)async{
    await OpenFile.open(filePath);
  }
}