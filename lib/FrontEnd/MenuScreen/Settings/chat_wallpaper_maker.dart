import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generation/BackendAndDatabaseManager/general_services/toast_message_manage.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:photo_view/photo_view.dart';

class ChatWallPaperMaker extends StatefulWidget {
  final bool allUpdatePermission;
  final String userName;

  ChatWallPaperMaker(
      {@required this.allUpdatePermission, @required this.userName});

  @override
  _ChatWallPaperMakerState createState() => _ChatWallPaperMakerState();
}

class _ChatWallPaperMakerState extends State<ChatWallPaperMaker> {
  /// String For Store Image Path
  String _chatWallPaperPath = ''; // For New Selected Image
  String _oldWallPaperPath = ''; // For Old Selected Image
  String _appBarPickUpImagePreview = 'Select Wallpaper';

  /// Make Objects of some important class
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();
  final ImagePicker _imagePicker = ImagePicker();

  /// Toast initialization
  FToast _fToast = FToast();

  /// Controller to make easy maintain
  bool _isLoading = false; // Controlling Modal Progress HUD
  bool _wallPaperAlreadyExist = false; // Control with existing wallpaper

  /// Initially Take out Old Common Wallpaper Path
  void selectChatWallPaper() async {
    final String wallpaperTempPath =
        await _localStorageHelper.extractImportantTableData(
      userMail: widget.allUpdatePermission
          ? FirebaseAuth.instance.currentUser.email
          : '',
      userName: widget.allUpdatePermission ? '' : widget.userName,
      extraImportant: ExtraImportant.ChatWallpaper,
    );

    print('Chat Wallpaper Path: $wallpaperTempPath');

    if (mounted) {
      setState(() {
        this._chatWallPaperPath =
            wallpaperTempPath == null ? '' : wallpaperTempPath;
        if (this._chatWallPaperPath != '') {
          this._wallPaperAlreadyExist = true;
          this._oldWallPaperPath = this._chatWallPaperPath;
        }
      });
    }
  }

  @override
  void initState() {
    _fToast.init(context);
    selectChatWallPaper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Color.fromRGBO(25, 39, 52, 1),
        elevation: 10.0,
        shadowColor: Colors.white70,
        actions: [
          if (this._chatWallPaperPath != '' &&
              this._chatWallPaperPath == this._oldWallPaperPath)
            GestureDetector(
              child: Icon(
                Icons.delete_outlined,
                color: Colors.red,
              ),
              onTap: _sureDeleteCurrChatCommonWallPaper,
            ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: this._chatWallPaperPath == '' ? null : _wallpaperConfig(),
          ),
        ],
        title: Text(
          this._wallPaperAlreadyExist
              ? 'Chat Screen'
              : this._appBarPickUpImagePreview,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontFamily: 'Lora',
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Container(
          margin: EdgeInsets.only(
              top: this._chatWallPaperPath == ''
                  ? MediaQuery.of(context).size.height / 3
                  : 0),
          child: this._chatWallPaperPath != ''
              ? Stack(
                  children: [
                    PhotoView(
                      minScale: PhotoViewComputedScale.covered,
                      maxScale: PhotoViewComputedScale.covered,
                      imageProvider: FileImage(
                        File(this._chatWallPaperPath),
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
                    _messageModel(false),
                    _messageModel(true),
                    _bottomContainer(),
                  ],
                )
              : GestureDetector(
                  onTap: () async {
                    await _selectPictureFromStorage();
                  },
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.upload_rounded,
                          color: Colors.lightBlue,
                          size: 40.0,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Center(
                          child: Text(
                            'Upload Picture From Storage',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 20.0,
                            ),
                          ),
                        )
                      ],
                    ),
                  )),
        ),
      ),
    );
  }

  Widget _bottomContainer() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 70.0,
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height - 140),
      padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(25, 39, 52, 1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            Icons.emoji_emotions_rounded,
            color: Colors.amber,
          ),
          Icon(
            Entypo.link,
            color: Colors.lightBlue,
            size: 25.0,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            child: TextField(
              enabled: false,
              decoration: InputDecoration(
                  labelText: 'Type Here',
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Lora',
                    letterSpacing: 1.0,
                    fontStyle: FontStyle.italic,
                  ),
                  disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightBlue))),
            ),
          ),
          Container(
            //margin: EdgeInsets.only(left: 20.0),
            child: IconButton(
              icon: Icon(
                Icons.send_rounded,
                color: Colors.green,
                size: 30.0,
              ),
              onPressed: () async {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageModel(bool response) {
    return Container(
      alignment: response ? Alignment.topRight : Alignment.topLeft,
      margin: EdgeInsets.only(
        right: response ? 5.0 : MediaQuery.of(context).size.width / 3,
        left: response ? MediaQuery.of(context).size.width / 3 : 5.0,
        top: response ? 60.0 : 10.0,
      ),
      height: 40.0,
      decoration: BoxDecoration(
        color: response
            ? const Color.fromRGBO(102, 102, 255, 1)
            : const Color.fromRGBO(60, 80, 100, 1),
        borderRadius: BorderRadius.only(
            topRight: response ? Radius.circular(0.0) : Radius.circular(40.0),
            bottomLeft: Radius.circular(40.0),
            bottomRight: Radius.circular(40.0),
            topLeft: response ? Radius.circular(40.0) : Radius.circular(0.0)),
      ),
      child: Center(
          child: Text(
        response ? 'Your Message' : 'Incoming Message',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      )),
    );
  }

  /// For Change and Set Wallpaper
  Widget _wallpaperConfig() {
    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: Size(60, 20),
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
          side: BorderSide(
            color:
                this._wallPaperAlreadyExist ? Colors.lightBlue : Colors.green,
          ),
        ),
      ),
      child: Text(
        this._wallPaperAlreadyExist ? 'Change WallPaper' : 'Set Wallpaper',
        style: TextStyle(
          color: this._wallPaperAlreadyExist ? Colors.lightBlue : Colors.green,
          fontSize: 14.0,
        ),
      ),
      onPressed: () async {
        if (this._wallPaperAlreadyExist) {
          await _selectPictureFromStorage();
          if (mounted) {
            setState(() {
              this._wallPaperAlreadyExist = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = true;
            });
          }

          if (this._oldWallPaperPath != '') {
            try {
              print(_oldWallPaperPath);
              await File(this._oldWallPaperPath).delete(recursive: true);
              print('Old WallPaper Deleted');
            } catch (e) {
              print('Error: Old Chat Wallpaper Deletion Error');
            }
          }

          await _localStorageHelper.updateImportantTableExtraData(
              extraImportant: ExtraImportant.ChatWallpaper,
              updatedVal: this._chatWallPaperPath,
              allUpdate: widget.allUpdatePermission,
              userName: widget.userName);

          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }

          Navigator.pop(context);

          showToast(
            widget.userName == ''
                ? 'Common Chat WallPaper Activated'
                : 'This Chat Wallpaper Activated',
            _fToast,
            fontSize: 16.0,
          );
        }
      },
    );
  }

  /// Common Function to select image from storage
  Future<void> _selectPictureFromStorage() async {
    final PickedFile pickedFile =
        await _imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (mounted) {
        setState(() {
          this._chatWallPaperPath = File(pickedFile.path).path;
          if (this._appBarPickUpImagePreview == 'Select Wallpaper')
            this._appBarPickUpImagePreview = 'Chat Preview';
          print('After Added File: ${this._chatWallPaperPath}');
        });
      }
    }
  }

  void _sureDeleteCurrChatCommonWallPaper() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: const Color.fromRGBO(34, 48, 60, 0.6),
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: Text(
                'Sure To Delete Common WallPaper',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16.0,
                ),
              ),
              content: Container(
                height: 30,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _deleteDecisionButtons(false),
                    _deleteDecisionButtons(true),
                  ],
                ),
              ),
            ));
  }

  _deleteDecisionButtons(bool decision) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: decision ? Colors.green : Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
      child: Text(
        decision ? 'Sure' : 'Cancel',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      onPressed: () async {
        try {
          await File(this._chatWallPaperPath)
              .delete(recursive: true)
              .whenComplete(() async {
            await _localStorageHelper
                .deleteParticularUpdatedImportantData(
              extraImportant: ExtraImportant.ChatWallpaper,
              shouldBeDeleted: this._chatWallPaperPath,
              allUpdateStatus: widget.allUpdatePermission,
              userName: widget.userName,
            )
                .whenComplete(() {
              print('Old Chat Wallpaper Deleted');
              print('Old Image Path Already Deleted From Local Sqlite Table');
              if (mounted) {
                setState(() {
                  this._chatWallPaperPath = this._oldWallPaperPath = '';
                });
              }
            });
          });
        } catch (e) {
          print('Error: Old Chat Wallpaper Delete Error: ${e.toString()}');
        }

        Navigator.pop(context);
      },
    );
  }
}
