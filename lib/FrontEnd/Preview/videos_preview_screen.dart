import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generation_official/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation_official/FrontEnd/Services/auth_error_msg_toast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

// ignore: must_be_immutable
class VideoPreview extends StatefulWidget {
  final File fileUrl;
  final String purpose;
  final List<String> allConnectionUserName;

  VideoPreview(this.fileUrl,
      {this.purpose = 'contacts', @required this.allConnectionUserName});

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  FToast fToast;
  bool _isLoading = false;

  final GlobalKey<FormState> _videoPreviewKey = GlobalKey<FormState>();

  final TextEditingController manuallyTextController = TextEditingController();
  final Management management = Management();

  @override
  void initState() {
    fToast = FToast();
    fToast.init(context);

    manuallyTextController.text = '';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: floatingActionButtonCall(),
        backgroundColor: Color.fromRGBO(34, 48, 60, 1),
        body: ModalProgressHUD(
          inAsyncCall: _isLoading,
          child: Center(
              child: AspectRatio(
            aspectRatio: 16 / 9,
            child: BetterPlayer.file(
              widget.fileUrl.path,
              betterPlayerConfiguration: BetterPlayerConfiguration(
                aspectRatio: 16 / 9,
              ),
            ),
          )),
        ));
  }

  floatingActionButtonCall() {
    return Form(
      key: _videoPreviewKey,
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
                      validator: (inputValue){
                        if(inputValue.contains('++++++')){
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
                  if(_videoPreviewKey.currentState.validate()){

                  }
                  SystemChannels.textInput.invokeMethod('TextInput.hide');

                  if (mounted) {
                    setState(() {
                      _isLoading = true;
                    });
                    showToast(
                      "Video Uploading....\nPlease Wait",
                      fToast,
                      toastColor: Colors.red,
                      toastGravity: ToastGravity.TOP,
                    );
                  }

                  if (widget.purpose == 'status') {
                    bool response = await management
                        .mediaActivityToStorageAndFireStore(
                        widget.fileUrl,
                        manuallyTextController.text,
                        widget.allConnectionUserName,
                        context,
                        mediaType: 'video');

                    if (response) {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                      Navigator.pop(context);
                    }

                    showToast("Activity Added", fToast);
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
