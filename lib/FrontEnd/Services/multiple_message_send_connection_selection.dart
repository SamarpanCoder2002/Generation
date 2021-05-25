import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thumbnails/thumbnails.dart';

import 'package:generation/BackendAndDatabaseManager/general_services/toast_message_manage.dart';
import 'package:generation/BackendAndDatabaseManager/Dataset/data_type.dart';
import 'package:generation/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation/BackendAndDatabaseManager/general_services/general_message_send.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';

// ignore: must_be_immutable
class SelectConnection extends StatefulWidget {
  String extra;
  final MediaTypes mediaType;
  String textContent;
  File mediaFile;

  SelectConnection({
    this.extra = '',
    @required this.mediaType,
    this.textContent = '',
    this.mediaFile,
  });

  @override
  _SelectConnectionState createState() => _SelectConnectionState();
}

class _SelectConnectionState extends State<SelectConnection> {
  bool _isLoading = false;
  bool _floatingActionButtonVisible = true;
  int _totalSelected = 0;
  final FToast _fToast = FToast();

  List<bool> _selectedTile;

  final List<Map<String, String>> allConnectionsUserNameAndProfilePicture = [];
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();
  final Management _management = Management();

  void fetchAllUsersName() async {
    final List<Map<String, Object>> userNameList =
        await _localStorageHelper.extractAllUsersName();

    if (mounted) {
      setState(() {
        userNameList.forEach((userNameMap) {
          allConnectionsUserNameAndProfilePicture.add({
            userNameMap.values.first: 'assets/logo/logo.jpg',
          });
        });

        _selectedTile =
            List<bool>.generate(userNameList.length, (index) => false);
      });
    }
  }

  @override
  void initState() {
    _fToast.init(context);
    fetchAllUsersName();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 48, 60, 1),
      floatingActionButton: _floatingActionButtonVisible
          ? FloatingActionButton(
              elevation: 10.0,
              backgroundColor: const Color.fromRGBO(20, 200, 50, 1),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 30.0,
              ),
              onPressed: _sendMessage,
            )
          : null,
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Color.fromRGBO(25, 39, 52, 1),
        elevation: 10.0,
        shadowColor: Colors.white70,
        leading: null,
        title: Text(
          'Select Connections to Send',
          style: TextStyle(
            fontFamily: 'Lora',
            letterSpacing: 1.0,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40.0),
            bottomRight: Radius.circular(40.0),
          ),
          side: BorderSide(width: 0.7),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        color: const Color.fromRGBO(0, 0, 0, 0.5),
        progressIndicator: const CircularProgressIndicator(
          backgroundColor: Colors.black87,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(
            top: 10.0,
            bottom: 50.0,
          ),
          child: ListView.builder(
            itemCount: allConnectionsUserNameAndProfilePicture.length,
            itemBuilder: (context, index) {
              return connectionTile(index, 'Samarapan');
            },
          ),
        ),
      ),
    );
  }

  Widget connectionTile(int index, String userName) {
    return Card(
        elevation: 0.0,
        color: const Color.fromRGBO(34, 48, 60, 1),
        child: Container(
          padding: EdgeInsets.only(left: 1.0, right: 1.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0.0,
              primary: const Color.fromRGBO(34, 48, 60, 1),
              onPrimary: Colors.lightBlueAccent,
            ),
            onPressed: () {
              if (mounted) {
                setState(() {
                  if (_totalSelected == 10 && !_selectedTile[index]) {
                    showToast(
                      'Maximum Limits 10 Connections',
                      _fToast,
                      toastGravity: ToastGravity.CENTER,
                      fontSize: 16.0,
                      toastColor: Colors.lightGreenAccent,
                      bgColor: Colors.black87,
                    );
                  } else {
                    _selectedTile[index] = !_selectedTile[index];
                    _selectedTile[index]
                        ? _totalSelected += 1
                        : _totalSelected -= 1;
                  }
                });
              }
            },
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: 5.0,
                    bottom: 5.0,
                  ),
                  child: CircleAvatar(
                    radius: 30.0,
                    backgroundImage: ExactAssetImage(
                        allConnectionsUserNameAndProfilePicture[index]
                            .values
                            .first),
                  ),
                ),
                Expanded(
                  child: Container(
                    //color: Colors.white,
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width / 2 + 20,
                    padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                    child: Text(
                      allConnectionsUserNameAndProfilePicture[index].keys.first,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (_selectedTile[index])
                  Icon(
                    Icons.done_outline_rounded,
                    color: const Color.fromRGBO(20, 200, 50, 1),
                  )
              ],
            ),
          ),
        ));
  }

  void _sendMessage() async {
    if (mounted) {
      setState(() {
        _floatingActionButtonVisible = false;
        _isLoading = true;
      });
    }

    final List<String> _allConnectionsUserName = [];

    for (int currIndex = 0; currIndex < _selectedTile.length; currIndex++) {
      if (_selectedTile[currIndex])
        _allConnectionsUserName.add(
            this.allConnectionsUserNameAndProfilePicture[currIndex].keys.first);
    }

    GeneralMessage _generalMessage;

    switch (widget.mediaType) {
      case MediaTypes.Voice:
        final String _voiceDownloadUrl = await _management.uploadMediaToStorage(
            widget.mediaFile, context,
            reference: 'multipleConnectionSendVoice/');

        _generalMessage = GeneralMessage(
          sendMessage: _voiceDownloadUrl,
          storeMessage: widget.mediaFile.path,
          sendTime:
              '${DateTime.now().hour}:${DateTime.now().minute}+${widget.mediaType}+${widget.extra}+multipleConnectionSource',
          storeTime: '${DateTime.now().hour}:${DateTime.now().minute}',
          mediaType: widget.mediaType,
          selectedUsersName: _allConnectionsUserName,
        );

        await _localStorageHelper.insertNewLinkInLinkRemainingTable(
            link: _voiceDownloadUrl);

        break;

      case MediaTypes.Image:
        final String _imageDownLoadUrl = await _management.uploadMediaToStorage(
            widget.mediaFile, this.context,
            reference: 'MultipleConnectionImage/');

        _generalMessage = GeneralMessage(
            sendMessage: _imageDownLoadUrl,
            storeMessage: widget.mediaFile.path,
            sendTime:
                '${DateTime.now().hour}:${DateTime.now().minute}+${widget.mediaType}+${widget.textContent}+multipleConnectionSource',
            storeTime:
                '${DateTime.now().hour}:${DateTime.now().minute}+${widget.textContent}',
            mediaType: widget.mediaType,
            selectedUsersName: _allConnectionsUserName);

        await _localStorageHelper.insertNewLinkInLinkRemainingTable(
            link: _imageDownLoadUrl);

        break;

      case MediaTypes.Video:
        String thumbNailPicturePath, thumbNailPicturePathUrl;

        final String _videoDownLoadUrl = await _management.uploadMediaToStorage(
            widget.mediaFile, this.context,
            reference: 'MultipleConnectionVideo/');

        final Directory directory = await getExternalStorageDirectory();

        final Directory _newDirectory =
            await Directory('${directory.path}/.ThumbNails/')
                .create(); // Create New Folder about the desire location;

        thumbNailPicturePath = await Thumbnails.getThumbnail(
            thumbnailFolder: _newDirectory.path,
            videoFile: widget.mediaFile.path,
            imageType: ThumbFormat.JPEG,
            quality: 20);

        thumbNailPicturePathUrl = await _management.uploadMediaToStorage(
            File(thumbNailPicturePath), context,
            reference: 'MultipleConnectionThumbnail/');

        _generalMessage = GeneralMessage(
            sendMessage: '$_videoDownLoadUrl+$thumbNailPicturePathUrl',
            storeMessage: widget.mediaFile.path,
            sendTime:
                '${DateTime.now().hour}:${DateTime.now().minute}+${widget.mediaType}+${widget.textContent}+multipleConnectionSource',
            storeTime:
                '${DateTime.now().hour}:${DateTime.now().minute}+${widget.textContent}+$thumbNailPicturePath',
            mediaType: widget.mediaType,
            selectedUsersName: _allConnectionsUserName);

        await _localStorageHelper.insertNewLinkInLinkRemainingTable(
            link: _videoDownLoadUrl);
        await _localStorageHelper.insertNewLinkInLinkRemainingTable(
            link: thumbNailPicturePathUrl);

        break;

      case MediaTypes.Text:
        _generalMessage = GeneralMessage(
            sendMessage: widget.textContent,
            storeMessage: widget.textContent,
            sendTime:
                "${DateTime.now().hour}:${DateTime.now().minute}+${MediaTypes.Text}",
            storeTime: "${DateTime.now().hour}:${DateTime.now().minute}",
            mediaType: widget.mediaType,
            selectedUsersName: _allConnectionsUserName);
        break;

      case MediaTypes.Sticker:
        break;

      case MediaTypes.Location:
        _generalMessage = GeneralMessage(
            sendMessage: widget.extra,
            storeMessage: widget.extra,
            sendTime:
                '${DateTime.now().hour}:${DateTime.now().minute}+${widget.mediaType}',
            storeTime:
                '${DateTime.now().hour}:${DateTime.now().minute}+${widget.mediaType}',
            mediaType: widget.mediaType,
            selectedUsersName: _allConnectionsUserName);
        break;

      case MediaTypes.Document:
        final String _documentDownLoadUrl =
            await _management.uploadMediaToStorage(widget.mediaFile, context,
                reference: 'MultipleConnectionDocument/');

        _generalMessage = GeneralMessage(
            sendMessage: _documentDownLoadUrl,
            storeMessage: widget.mediaFile.path,
            sendTime:
                '${DateTime.now().hour}:${DateTime.now().minute}+${widget.mediaType}+${widget.textContent}+${widget.extra}+multipleConnectionSource',
            storeTime:
                '${DateTime.now().hour}:${DateTime.now().minute}+${widget.textContent}+${widget.extra}',
            mediaType: widget.mediaType,
            selectedUsersName: _allConnectionsUserName);

        await _localStorageHelper.insertNewLinkInLinkRemainingTable(
            link: _documentDownLoadUrl);

        break;
      case MediaTypes.Indicator:
        break;
    }
    await _generalMessage.storeInFireStore();
    await _generalMessage.storeInLocalStorage();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    Navigator.pop(context);
  }
}
