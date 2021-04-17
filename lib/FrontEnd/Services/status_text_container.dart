import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generation/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation/FrontEnd/Services/auth_error_msg_toast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

// ignore: must_be_immutable
class StatusTextContainer extends StatefulWidget {
  List<String> _allUserNameContainer;

  StatusTextContainer(this._allUserNameContainer);

  @override
  _StatusTextContainerState createState() => _StatusTextContainerState();
}

class _StatusTextContainerState extends State<StatusTextContainer> {
  Color pickColor = Colors.lightBlue;
  final Management management = Management();
  TextEditingController activityText = TextEditingController();
  bool isLoading = false;
  FToast fToast;

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
        backgroundColor: Theme.of(context).backgroundColor,
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

              bool response = await management.addTextActivityTextToFireStore(
                  activityText.text, pickColor, widget._allUserNameContainer);

              setState(() {
                isLoading = false;
              });

              Navigator.pop(context);

              if (response) showErrToast("Activity Added", fToast);

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
                  constraints:
                      BoxConstraints.loose(Size(double.maxFinite, 500.0)),
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                  child: Center(
                    child: Scrollbar(
                      showTrackOnHover: true,
                      thickness: 10.0,
                      radius: const Radius.circular(30.0),
                      child: TextField(
                        controller: activityText,
                        textAlign: TextAlign.center,
                        cursorColor: Colors.white,
                        style: const TextStyle(
                          fontSize: 30.0,
                          color: Colors.white,
                          fontFamily: 'Lora',
                          letterSpacing: 1.0,
                        ),
                        autofocus: true,
                        maxLines: 10,
                        minLines: 1,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Type Here",
                            hintStyle: const TextStyle(
                              color: Colors.white54,
                              fontFamily: 'Lora',
                              fontStyle: FontStyle.italic,
                              letterSpacing: 1.0,
                            )),
                      ),
                    ),
                  ),
                ),
                Container(
                  //color: Colors.black,
                  //alignment: Alignment.topCenter,
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
              ],
            ),
          ),
        ));
  }
}
