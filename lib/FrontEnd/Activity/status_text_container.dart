import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:generation_official/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation_official/BackendAndDatabaseManager/general_services/toast_message_manage.dart';

// ignore: must_be_immutable
class StatusTextContainer extends StatefulWidget {
  List<String> _allUserNameContainer;

  StatusTextContainer(this._allUserNameContainer);

  @override
  _StatusTextContainerState createState() => _StatusTextContainerState();
}

class _StatusTextContainerState extends State<StatusTextContainer> {
  Color pickColor = Color.fromRGBO(0, 150, 250, 1);
  final Management management = Management();
  TextEditingController activityText = TextEditingController();
  bool isLoading = false;
  FToast fToast;

  int _fontSizeController = 1;

  @override
  void initState() {
    isLoading = false;
    fToast = FToast();
    fToast.init(context);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    activityText.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: pickColor,
        floatingActionButton: FloatingActionButton(
          elevation: 5.0,
          backgroundColor: Color.fromRGBO(100, 200, 10, 1),
          child: const Icon(
            Icons.send_rounded,
          ),
          onPressed: () async {
            if (activityText.text.length > 0) {
              SystemChannels.textInput.invokeMethod('TextInput.hide');

              setState(() {
                isLoading = true;
              });

              bool response = await management.addTextActivityToFireStore(
                  activityText.text,
                  pickColor,
                  widget._allUserNameContainer,
                  (_fontSizeController + 20).toDouble());

              setState(() {
                isLoading = false;
              });

              Navigator.pop(context);

              if (response) showToast("Activity Added", fToast);

              print("Activity Response: $response");
            }
          },
        ),
        body: ModalProgressHUD(
          inAsyncCall: isLoading,
          color: Color.fromRGBO(0, 0, 0, 1),
          progressIndicator: CircularProgressIndicator(
            backgroundColor: Colors.black87,
          ),
          child: Container(
            width: double.maxFinite,
            height: double.maxFinite,
            color: pickColor,
            child: ListView(
              shrinkWrap: true,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 20.0),
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: Center(
                    child: Scrollbar(
                      showTrackOnHover: true,
                      thickness: 10.0,
                      radius: const Radius.circular(30.0),
                      child: TextField(
                        controller: activityText,
                        textAlign: TextAlign.center,
                        cursorColor: Colors.white,
                        style: TextStyle(
                          fontSize: (_fontSizeController + 20).toDouble(),
                          color: Colors.white,
                          fontFamily: 'Lora',
                          letterSpacing: 1.0,
                        ),
                        autofocus: true,
                        maxLines: null,
                        minLines: 1,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Type Here",
                            hintStyle: TextStyle(
                              color: Colors.white54,
                              fontSize: (_fontSizeController + 20).toDouble(),
                              fontFamily: 'Lora',
                              fontStyle: FontStyle.italic,
                              letterSpacing: 1.0,
                            )),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.maxFinite,
                  child: Center(
                    child: ColorPicker(
                      showLabel: false,
                      pickerAreaHeightPercent: 0.05,
                      displayThumbColor: false,
                      pickerColor: pickColor,
                      paletteType: PaletteType.rgb,
                      onColorChanged: (Color color) {
                        if (mounted) {
                          setState(() {
                            pickColor = color;
                          });
                        }
                      },
                    ),
                  ),
                ),
                Container(
                    height: 10,
                    margin: EdgeInsets.only(
                      left: 60.0,
                      right: 65.0,
                    ),
                    child: Slider(
                        value: _fontSizeController.toDouble(),
                        min: 1.0,
                        max: 20.0,
                        divisions: 10,
                        activeColor: Colors.amber,
                        inactiveColor: Colors.lightGreenAccent,
                        label: 'Set Font Size',
                        onChanged: (double newValue) {
                          setState(() {
                            print(newValue);
                            _fontSizeController = newValue.round();
                          });
                        },
                        semanticFormatterCallback: (double newValue) {
                          return '${newValue.round()} dollars';
                        })),
              ],
            ),
          ),
        ));
  }
}
