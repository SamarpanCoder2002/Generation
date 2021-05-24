import 'package:firebase_auth/firebase_auth.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';

class ImportantThings {
  static String thisAccountImageUrl = '';
  static String thisAccountUserName = '';

  static findImageUrlAndUserName() async {
    thisAccountImageUrl = await LocalStorageHelper().extractProfileImageUrl(
        userMail: FirebaseAuth.instance.currentUser.email);
    thisAccountUserName = await LocalStorageHelper()
        .extractImportantDataFromThatAccount(
            userMail: FirebaseAuth.instance.currentUser.email);
  }

}
