import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generation/BackendAndDatabaseManager/general_services/toast_message_manage.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:permission_handler/permission_handler.dart';

class PhoneNumberConfig extends StatefulWidget {
  const PhoneNumberConfig({Key key}) : super(key: key);

  @override
  _PhoneNumberConfigState createState() => _PhoneNumberConfigState();
}

class _PhoneNumberConfigState extends State<PhoneNumberConfig> {
  String _registeredPhoneNumber = '';
  bool _isLoading = false;

  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();
  final FToast _fToast = FToast();

  void _getRegisteredMobileNumberFromLocalDatabase() async {
    final String _savedNumber =
        await _localStorageHelper.extractImportantTableData(
            extraImportant: ExtraImportant.MobileNumber,
            userMail: FirebaseAuth.instance.currentUser.email);

    if (mounted) {
      setState(() {
        this._registeredPhoneNumber = _savedNumber;
      });
    }
  }

  @override
  void initState() {
    _fToast.init(context);
    _getRegisteredMobileNumberFromLocalDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 48, 60, 1),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Center(
          child: this._registeredPhoneNumber != ''
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Registered Number is: ',
                          style: TextStyle(
                            color: Colors.lightBlue,
                            fontSize: 18.0,
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          this._registeredPhoneNumber,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          child: Text(
                            'Add New Phone Number',
                            style: TextStyle(
                              color: Colors.green,
                            ),
                          ),
                          style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0),
                            side: BorderSide(
                              color: Colors.green,
                            ),
                          )),
                          onPressed: _mobileNumberExtractor,
                        ),
                        TextButton(
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16.0,
                            ),
                          ),
                          style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0),
                            side: BorderSide(color: Colors.red),
                          )),
                          onPressed: () async {
                            await _deleteRegisteredMobileNumber();
                          },
                        ),
                      ],
                    ),
                    _alertMessageWidget(),
                  ],
                )
              : Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 2),
                      child: TextButton(
                        child: Text(
                          'Add Phone Number',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 18.0,
                          ),
                        ),
                        style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                          side: BorderSide(color: Colors.green),
                        )),
                        onPressed: () async {
                          _mobileNumberExtractor();
                        },
                      ),
                    ),
                    _alertMessageWidget(),
                  ],
                ),
        ),
      ),
    );
  }

  void _mobileNumberExtractor() async {
    final PermissionStatus permissionStatus = await Permission.phone.request();
    if (permissionStatus.isGranted) {
      print('Phone Permission Granted');

      final List<SimCard> simCards = await MobileNumber.getSimCards;

      _selectMobileNumberToRegister(simCards);
    } else
      print('Phone Permission Denied');
  }

  void _selectMobileNumberToRegister(List<SimCard> simCards) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: const Color.fromRGBO(34, 48, 60, 0.6),
              elevation: 0.6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              title: Text(
                'Select Number to Register',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 18.0,
                ),
              ),
              content: Container(
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int i = 0; i < simCards.length; i++)
                      simCards[i].number != ''
                          ? TextButton(
                              child: Text(
                                simCards[i].number.startsWith('+')
                                    ? simCards[i].number
                                    : '+${simCards[i].number}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16.0,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40.0),
                                side: BorderSide(
                                  color: Colors.green,
                                ),
                              )),
                              onPressed: () => _proceedWithSelectedNum(
                                  simCards[i].number.startsWith('+')
                                      ? simCards[i].number
                                      : '+${simCards[i].number}'),
                            )
                          : Text(
                              "Number can't detect",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.red, fontSize: 16.0),
                            ),
                  ],
                ),
              ),
            ));
  }

  void _proceedWithSelectedNum(String selectedNum) async {
    Navigator.pop(context);

    if (this._registeredPhoneNumber != selectedNum) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      await FirebaseFirestore.instance
          .doc('generation_users/${FirebaseAuth.instance.currentUser.email}')
          .update({
        'phone_number': selectedNum,
      });

      await _localStorageHelper.updateImportantTableExtraData(
        extraImportant: ExtraImportant.MobileNumber,
        updatedVal: selectedNum,
        userMail: FirebaseAuth.instance.currentUser.email,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          this._registeredPhoneNumber = selectedNum;
        });
      }

      showToast(
        'Phone Number Registered',
        _fToast,
        fontSize: 18.0,
      );
    } else
      showToast(
        'Already Number Registered',
        _fToast,
        toastColor: Colors.red,
        fontSize: 18.0,
      );
  }

  Widget _alertMessageWidget() {
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      alignment: Alignment.bottomCenter,
      child: Text(
        'Alert: If you registered your number and if any connection will call you, your number will visible in their call Logs...',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.red, fontSize: 16.0),
      ),
    );
  }

  Future<void> _deleteRegisteredMobileNumber() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final String mobileNum =
        await _localStorageHelper.extractImportantTableData(
            extraImportant: ExtraImportant.MobileNumber,
            userMail: FirebaseAuth.instance.currentUser.email);

    if (mobileNum != null) {
      await _localStorageHelper.deleteParticularUpdatedImportantData(
          extraImportant: ExtraImportant.MobileNumber,
          shouldBeDeleted: mobileNum);

      await FirebaseFirestore.instance
          .doc('generation_users/${FirebaseAuth.instance.currentUser.email}')
          .update({
        'phone_number': '',
      });

      if (mounted) {
        setState(() {
          this._registeredPhoneNumber = '';
        });
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
