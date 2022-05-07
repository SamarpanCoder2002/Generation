import 'package:flutter/material.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/services/device_specific_operations.dart';
import 'package:generation/services/local_database_services.dart';

import '../../services/navigation_management.dart';
import '../../services/toast_message_show.dart';
import '../../types/types.dart';
import '../main_screens/main_screen_management.dart';

storagePermissionForStoreCurrAccData(
    BuildContext context, VoidCallback rightBtnOnTap) {
  showPopUpDialog(
      context,
      "Require Storage Permission",
      "Generation will store your some frequent used data with encrypted form in your local system",
      rightBtnOnTap,
      rightBtnText: "Give Permission",
      barrierDismissible: false,
      showCancelBtn: true,
      leftOnPressed: () => closeYourApp());
}

dataFetchingOperations(BuildContext context, _createdBefore, currUserId) {
  final LocalStorage _localStorage = LocalStorage();
  final DBOperations _dbOperations = DBOperations();

  showToast(context,
      title: "Account Created Before",
      toastIconType: ToastIconType.success,
      showFromTop: false,
      toastDuration: 1);
  storagePermissionForStoreCurrAccData(context, () async {
    await _localStorage.storeDataForCurrAccount(
        _createdBefore["data"], currUserId);

    await _dbOperations.updateCurrentAccount(_createdBefore["data"]);

    showToast(context,
        title: "Data Fetched Successfully",
        toastIconType: ToastIconType.success,
        showFromTop: false,
        toastDuration: 3);
    Navigation.intentStraight(context, const MainScreen());
  });
}
