import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:generation_official/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation_official/FrontEnd/Services/auth_error_msg_toast.dart';


class PreviewImageScreen extends StatefulWidget {
  final File imageFile;
  final String purpose;
  final List<String> allConnectionUserName;

  PreviewImageScreen(
      {@required this.imageFile,
      this.purpose = 'contacts',
      this.allConnectionUserName});

  @override
  _PreviewImageScreenState createState() => _PreviewImageScreenState();
}

class _PreviewImageScreenState extends State<PreviewImageScreen> {
  bool _isLoading = false;
  FToast fToast;

  final TextEditingController manuallyTextController = TextEditingController();
  final Management management = Management();

  final GlobalKey<FormState> _imagePreviewKey = GlobalKey<FormState>();

  @override
  void initState() {
    manuallyTextController.text = '';
    _isLoading = false;
    fToast = FToast();
    fToast.init(context);
    super.initState();
  }

  @override
  void dispose() {
    manuallyTextController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(0, 0, 0, 1),
      floatingActionButton: widget.purpose == 'status' ? floatingActionButtonCall() : null,
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        color: const Color.fromRGBO(50, 20, 40, 0.8),
        progressIndicator: const CircularProgressIndicator(
          backgroundColor: Colors.black87,
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Image.file(
            File(widget.imageFile.path),
          ),
        ),
      ),
    );
  }

  floatingActionButtonCall() {
    return Form(
      key: _imagePreviewKey,
      child: Container(
        padding: EdgeInsets.only(
          bottom: 5.0,
          left: 15.0,
        ),
        child: Row(
          children: [
            Container(
              height: 60.0,
              child: IconButton(
                icon: const Icon(
                  Icons.emoji_emotions_rounded,
                  color: Colors.orangeAccent,
                  size: 30.0,
                ),
                onPressed: () {
                  //Close the keyboard
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                },
              ),
            ),
            Expanded(
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  constraints: BoxConstraints.loose(
                      Size(MediaQuery.of(context).size.width * 0.7, 100.0)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Scrollbar(
                    showTrackOnHover: true,
                    thickness: 10.0,
                    radius: Radius.circular(30.0),
                    child: TextFormField(
                      validator: (inputValue) {
                        if (inputValue.contains('++++++')) {
                          return "'++++++' pattern not supported";
                        }
                        return null;
                      },
                      controller: manuallyTextController,
                      cursorColor: Colors.white,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                      onTap: () {},
                      maxLines: null,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          borderSide:
                              BorderSide(color: Colors.black54, width: 2.0),
                        ),
                        hintText: 'Type Here',
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.lightBlue)),
                      ),
                    ),
                  )),
            ),
            Container(
              //color: Theme.of(context).primaryColor,
              padding: EdgeInsets.only(left: 20.0),
              child: FloatingActionButton(
                backgroundColor: Colors.green,
                onPressed: () async {
                  if (_imagePreviewKey.currentState.validate()) {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');

                    if (mounted) {
                      setState(() {
                        _isLoading = true;
                      });
                      showToast(
                        "Image Uploading....\nPlease Wait",
                        fToast,
                        toastColor: Colors.red,
                        toastGravity: ToastGravity.TOP,
                      );
                    }

                    if (widget.purpose == 'status') {
                      bool response =
                          await management.mediaActivityToStorageAndFireStore(
                              widget.imageFile,
                              manuallyTextController.text,
                              widget.allConnectionUserName,
                              context);

                      if (response) {
                        if (mounted) {
                          setState(() {
                            fToast.removeCustomToast();
                            _isLoading = false;
                          });
                        }
                        Navigator.of(context,rootNavigator: true).pop();
                      }

                      showToast("Activity Added", fToast);
                    }
                  }
                },
                child: Icon(
                  Icons.send_rounded,
                  size: 30.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
