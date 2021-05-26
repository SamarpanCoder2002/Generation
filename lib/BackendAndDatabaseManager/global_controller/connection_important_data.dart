import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';

class ProfileImageManagement {
  static Map<String, dynamic> allConnectionsProfilePicLocalPath =
      Map<String, dynamic>();

  static Future<void> userProfileNameAndImageExtractor() async {
    allConnectionsProfilePicLocalPath =
        await LocalStorageHelper().extractUserNameAndProfilePicFromImportant();
  }
}
