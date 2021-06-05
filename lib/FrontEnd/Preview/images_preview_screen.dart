import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:photo_view/photo_view.dart';

import 'package:generation/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation/BackendAndDatabaseManager/general_services/toast_message_manage.dart';

// ignore: must_be_immutable
class PreviewImageScreen extends StatefulWidget {
  final File imageFile;
  String purpose;
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
      backgroundColor: Colors.black12,
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: ListView(
              shrinkWrap: true,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height - 130,
                  width: MediaQuery.of(context).size.width,
                  child: PhotoView(
                    enableRotation: false,
                    imageProvider: FileImage(
                      widget.imageFile,
                    ),
                    loadingBuilder: (context, event) => Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorBuilder: (context, obj, stackTrace) => Center(
                        child: Text(
                      'Image not Found',
                      style: TextStyle(
                        fontSize: 23.0,
                        color: Colors.red,
                        fontFamily: 'Lora',
                        letterSpacing: 1.0,
                      ),
                    )),
                  ),
                ),
                _bottomContainer(),
              ],
            )),
      ),
    );
  }

  Widget _bottomContainer() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 100.0,
      padding: const EdgeInsets.only(top: 20.0),
      child: Form(
        key: this._imagePreviewKey,
        child: Row(
          children: [
            Expanded(
              child: Container(
                  padding: EdgeInsets.only(top: 10.0, left: 15.0),
                  width: MediaQuery.of(context).size.width * 0.8,
                  constraints: BoxConstraints.loose(
                      Size(MediaQuery.of(context).size.width * 0.8, 100.0)),
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
                        fontSize: 18.0,
                      ),
                      maxLines: null,
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        hintText: 'Type Here',
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                  )),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: IconButton(
                icon: Icon(Icons.send_rounded,
                    size: 30.0, color: Colors.lightGreenAccent),
                onPressed: () async {
                  if (_imagePreviewKey.currentState.validate()) {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');

                    if (mounted) {
                      setState(() {
                        widget.purpose = 'contacts';
                        _isLoading = true;
                      });
                      showToast(
                        "Image Uploading... Please Wait",
                        fToast,
                        toastColor: Colors.amber,
                        toastGravity: ToastGravity.CENTER,
                        fontSize: 18.0,
                      );
                    }

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
                      Navigator.of(context, rootNavigator: true).pop();
                    }

                    showToast("Activity Added", fToast);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
