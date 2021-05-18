import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generation_official/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation_official/BackendAndDatabaseManager/general_services/toast_message_manage.dart';

// ignore: must_be_immutable
class PollMaker extends StatefulWidget {
  @override
  _PollMakerState createState() => _PollMakerState();
}

class _PollMakerState extends State<PollMaker> {
  int argument = 2;

  List<TextEditingController> _textEditingController = [];

  FToast _fToast = FToast();

  final GlobalKey<FormState> _pollFormKey = GlobalKey<FormState>();

  final Management _management = Management();

  @override
  void initState() {
    _textEditingController =
        List.generate(argument + 1, (index) => TextEditingController());

    _fToast.init(context);

    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.forEach((element) {
      element.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            pollingOptionsCreator(),
          ],
        ),
      ),
    );
  }

  Widget pollingOptionsCreator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: polling,
          child: Column(
            children: [
              Icon(
                Icons.poll_outlined,
                size: 50.0,
                color: Colors.lightBlue,
              ),
              Center(
                child: Text(
                  'Polling',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.lightGreen,
                    letterSpacing: 1.0,
                  ),
                ),
              )
            ],
          ),
        ),
        Column(
          children: [
            Text(
              'Total Options',
              style: TextStyle(
                color: Colors.lightBlue,
                fontSize: 20.0,
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  argument.toString(),
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(
                  width: 20.0,
                ),
                optionsMaintain(
                  iconData: Icons.add,
                  iconColor: Colors.green,
                ),
                SizedBox(
                  width: 20.0,
                ),
                optionsMaintain(
                  iconData: Entypo.minus,
                  iconColor: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget optionsMaintain(
      {@required IconData iconData, @required Color iconColor}) {
    return Center(
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor,
          ),
          child: Icon(
            iconData,
            size: 25.0,
            color: Colors.white,
          ),
        ),
        onTap: () {
          if (mounted) {
            setState(() {
              if (iconData == Icons.add)
                argument += 1;
              else if (iconData == Entypo.minus && argument > 2) {
                argument -= 1;
              } else {
                showToast(
                  'Minimum 2 Options are Compulsory',
                  _fToast,
                  toastColor: Colors.red,
                  fontSize: 16.0,
                  seconds: 3,
                );
              }

              _textEditingController = List.generate(
                  argument + 1, (index) => TextEditingController());
            });
          }
        },
      ),
    );
  }

  void polling() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              elevation: 5.0,
              backgroundColor: const Color.fromRGBO(34, 48, 60, 0.6),
              title: StatefulBuilder(builder: (context, setState) {
                return Center(
                  child: Text(
                    'Make Your Pole',
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontFamily: 'Lora',
                      letterSpacing: 1.0,
                    ),
                  ),
                );
              }),
              content: Container(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height / 2,
                child: Form(
                  key: this._pollFormKey,
                  child: SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (int i = 0; i <= argument; i++)
                          i == 0
                              ? answersSection(
                                  labelText: 'Enter Your Question',
                                  textEditingController:
                                      _textEditingController[i],
                                  index: i)
                              : answersSection(
                                  labelText: 'Option $i',
                                  textEditingController:
                                      _textEditingController[i],
                                  index: i),
                        SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _pollingAlertDialogButtons(buttonName: 'Cancel'),
                            _pollingAlertDialogButtons(buttonName: 'Save'),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }

  Widget _pollingAlertDialogButtons({@required String buttonName}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: buttonName == 'Save' ? Colors.green : Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          )),
      child: Text(
        buttonName,
        style: TextStyle(fontSize: 18.0, color: Colors.white),
      ),
      onPressed: () async {
        if (buttonName != 'Save') {
          _textEditingController.forEach((element) {
            element.clear();
          });
        } else {
          if (this._pollFormKey.currentState.validate()) {
            print('Validate');

            final Map<String, dynamic> _pollMap = Map<String, dynamic>();

            _textEditingController.forEach((pollElement) {
              if (_textEditingController.indexOf(pollElement) == 0) {
                _pollMap.addAll({
                  'question': pollElement.text,
                });
              } else {
                _pollMap.addAll({
                  '${_textEditingController.indexOf(pollElement)}+${pollElement.text}': '0',
                });
              }

              pollElement.clear();
            });

            print('PollMap is: $_pollMap');
            await _management.addPollIdInLocalAndFireStore(_pollMap);

            Navigator.pop(context);
          }
        }
      },
    );
  }

  Widget answersSection(
      {@required String labelText,
      @required TextEditingController textEditingController,
      @required index}) {
    return TextFormField(
      controller: textEditingController,
      style: TextStyle(color: Colors.white),
      validator: (inputUserName) {
        if (inputUserName.length > 0) return null;
        if (index == 0) return 'Please Add a Question';
        return "Empty Option Can't be Accepted";
      },
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white70),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlue),
        ),
      ),
    );
  }
}
