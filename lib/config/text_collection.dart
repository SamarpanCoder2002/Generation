import 'package:generation/config/time_collection.dart';

class AppText {
  static const String appName = "Generation";
  static const String activityHeading = "Activities";
  static const String messagesHeading = "Messages";
  static const String fontFamily = 'Poppins';
}

class DirectoryName {
  static const String voiceRecordDir = "recordings";
  static const String imageDir = "images";
  static const String videoDir = "videos";
  static const String docDir = "documents";
  static const String thumbnailDir = "thumbnails";
  static const String wallpaperDir = "wallpaperDir";
  static const String chatHistoryDir = 'chatHistoryDir';
}

class MessageData {
  static const String type = "type";
  static const String holder = "holder";
  static const String message = "message";
  static const String date = "date";
  static const String time = "time";
  static const String additionalData = "additionalData";
}

class PhoneNumberData {
  static const String number = "number";
  static const String name = "name";
  static const String numberLabel = "label";
}

class EnvFileKey{
  static const supportMail = "SUPPORT_MAIL";
  static const rzpAPIKEY = "RZP_API_KEY";
  static const dbName = "DATABASE_NAME";
  static const baseUrl = "BASE_URL";
}

class DbData{
  static const currUserTable = "__currentUserEncryptedData__";
  static const connectionsTable = "__connectionsEncryptedData__";
  static const chatTable = "__chatEncryptedData__";
  static const myActivityTable = "__myActivityEncryptedData__";
}

class FolderData{
  static const dbFolder = ".Databases";
}

class TextCollection{
  /// Terminal Link Should be Replaced by this app link after published to the playstore
  static const String appShareData = "Enjoy Private Chat Message Experience with Modern UI with Free Video Call In Generation\nhttps://generation-launch-page.netlify.app/";
  static const String videoDurationAlert = "Video duration should be within ${Timings.videoDurationInSec} seconds";
  static const String myWebsite = 'https://samarpandasgupta.com/';
}
