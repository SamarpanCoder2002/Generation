import 'package:firebase_auth/firebase_auth.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';

class ImportantThings {
  static String thisAccountProfileImagePath = '';
  static String thisAccountUserName = '';

  static void findImageUrlAndUserName() async {
    thisAccountProfileImagePath = await LocalStorageHelper()
        .extractProfileImageLocalPath(
            userMail: FirebaseAuth.instance.currentUser.email);
    thisAccountUserName = await LocalStorageHelper()
        .extractImportantDataFromThatAccount(
            userMail: FirebaseAuth.instance.currentUser.email);
  }
}
