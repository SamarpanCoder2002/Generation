import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'firestore_management.dart';
import 'google_auth.dart';

Future<void> deleteMyGenerationAccount() async {
  final String _userName = await LocalStorageHelper()
      .extractImportantDataFromThatAccount(
          userMail: FirebaseAuth.instance.currentUser!.email.toString());

  final String? _profilePicUrl =
      await LocalStorageHelper().extractProfilePicUrl(userName: _userName);

  if (_profilePicUrl != null && _profilePicUrl != '') {
    await Management(takeTotalUserName: false)
        .deleteFilesFromFirebaseStorage(_profilePicUrl);
  }

  await FirebaseFirestore.instance
      .doc('generation_users/${FirebaseAuth.instance.currentUser!.email.toString()}')
      .delete();

  await LocalStorageHelper().deleteTheExistingDatabase();

  print('Deleted Account');

  await GoogleAuth().logOut();

  await FirebaseAuth.instance.signOut();
  await SystemNavigator.pop(animated: true);
}
