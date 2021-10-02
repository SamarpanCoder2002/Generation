import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:generation/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation/BackendAndDatabaseManager/native_internal_call/native_call.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class CallManagement {
  final NativeCallback _nativeCallback = NativeCallback();
  final Management _management = Management(takeTotalUserName: false);
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();

  final BuildContext context;
  final String userName;

  CallManagement(this.context, this.userName);

  Future<void> makeGenerationPhoneCall() async {
    if (!await _nativeCallback.callToCheckNetworkConnectivity())
      _showDiaLog(titleText: 'No Internet Connection');
    else {
      String? phoneNumber =
          await _management.phoneNumberExtractor(this.userName);

      if (phoneNumber != null && phoneNumber != '') {
        phoneNumber =
            !phoneNumber.contains('+') ? '+$phoneNumber' : phoneNumber;

        print('Phone number is: $phoneNumber');

        // final bool? callResponse =
        // await FlutterPhoneDirectCaller.callNumber(phoneNumber);

        try {
          await launch("tel://$phoneNumber");

          await _localStorageHelper.insertDataForCallLog(this.userName,
              callDate: DateTime.now().toString().split(' ')[0],
              callTime: DateTime.now().toString().split(' ')[1]);
        } catch (e) {
          print('Exception in phone call: ${e.toString}');
          print('Connected User Phone Number not found');
          _showDiaLog(
              titleText: 'Not Found',
              contentText: 'Connected user not registered phone number');
        }

        //   if (callResponse!)
        //     await _localStorageHelper.insertDataForCallLog(this.userName,
        //         callDate: DateTime.now().toString().split(' ')[0],
        //         callTime: DateTime.now().toString().split(' ')[1]);
        // } else {
        //   print('Connected User Phone Number not found');
        //   _showDiaLog(
        //       titleText: 'Not Found',
        //       contentText: 'Connected user not registered phone number');
        // }
      }
    }
  }

  void _showDiaLog({required String titleText, String contentText = ''}) {
    showDialog(
        context: this.context,
        builder: (_) => AlertDialog(
              elevation: 5.0,
              backgroundColor: Color.fromRGBO(34, 48, 60, 0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              title: Center(
                  child: Text(
                titleText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18.0,
                ),
              )),
              content: contentText == ''
                  ? null
                  : Container(
                      height: 100,
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Center(
                            child: Text(
                              contentText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ));
  }
}
