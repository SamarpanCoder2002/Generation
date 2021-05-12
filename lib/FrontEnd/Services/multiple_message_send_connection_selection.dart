import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:generation_official/BackendAndDatabaseManager/Dataset/data_type.dart';
import 'package:generation_official/BackendAndDatabaseManager/firebase_services/firestore_management.dart';
import 'package:generation_official/BackendAndDatabaseManager/general_services/general_message_send.dart';
import 'package:generation_official/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thumbnails/thumbnails.dart';

// ignore: must_be_immutable
class SelectConnection extends StatefulWidget {
  String message;
  final MediaTypes mediaType;
  String extraText;
  File mediaFile;

  SelectConnection({
    this.message,
    @required this.mediaType,
    this.extraText = '',
    this.mediaFile,
  });

  @override
  _SelectConnectionState createState() => _SelectConnectionState();
}

class _SelectConnectionState extends State<SelectConnection> {
  List<bool> _selectedTile;
  List<Map<String, String>> allConnectionsUserNameAndProfilePicture = [];
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
    fetchAllUsersName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 48, 60, 1),
      floatingActionButton: FloatingActionButton(
        elevation: 10.0,
        backgroundColor: const Color.fromRGBO(20, 200, 50, 1),
        child: const Icon(
          Icons.send_rounded,
          color: Colors.white,
          size: 30.0,
        ),
        onPressed: () async {
          final List<String> _allConnectionsUserName = [];

          for (int currIndex = 0;
              currIndex < _selectedTile.length;
              currIndex++) {
            if (_selectedTile[currIndex])
              _allConnectionsUserName.add(this
                  .allConnectionsUserNameAndProfilePicture[currIndex]
                  .keys
                  .first);
          }

          GeneralMessage _generalMessage;

          switch (widget.mediaType) {
            case MediaTypes.Voice:
              // TODO: Handle this case.
              break;
            case MediaTypes.Image:
              final String _imageDownLoadUrl = await _management
                  .uploadMediaToStorage(widget.mediaFile, this.context);

              _generalMessage = GeneralMessage(
                  sendMessage: _imageDownLoadUrl,
                  storeMessage: widget.mediaFile.path,
                  sendTime:
                      '${DateTime.now().hour}:${DateTime.now().minute}+${widget.mediaType}+${widget.extraText}+multipleConnectionSource',
                  storeTime:
                      '${DateTime.now().hour}:${DateTime.now().minute}+${widget.extraText}',
                  mediaType: widget.mediaType,
                  selectedUsersName: _allConnectionsUserName);

              await _localStorageHelper.insertNewLinkInLinkRemainingTable(
                  link: _imageDownLoadUrl);

              break;

            case MediaTypes.Video:
              String thumbNailPicturePath, thumbNailPicturePathUrl;

              final String _videoDownLoadUrl = await _management
                  .uploadMediaToStorage(widget.mediaFile, this.context);

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
                  File(thumbNailPicturePath), context);

              _generalMessage = GeneralMessage(
                  sendMessage: '$_videoDownLoadUrl+$thumbNailPicturePathUrl',
                  storeMessage: widget.mediaFile.path,
                  sendTime:
                      '${DateTime.now().hour}:${DateTime.now().minute}+${widget.mediaType}+${widget.extraText}+multipleConnectionSource',
                  storeTime:
                      '${DateTime.now().hour}:${DateTime.now().minute}+${widget.extraText}+$thumbNailPicturePath',
                  mediaType: widget.mediaType,
                  selectedUsersName: _allConnectionsUserName);

              await _localStorageHelper.insertNewLinkInLinkRemainingTable(
                  link: _videoDownLoadUrl);
              await _localStorageHelper.insertNewLinkInLinkRemainingTable(
                  link: thumbNailPicturePathUrl);

              break;

            case MediaTypes.Text:
              break;
            case MediaTypes.Sticker:
              break;
            case MediaTypes.Location:
              // TODO: Handle this case.
              break;
            case MediaTypes.Document:
              // TODO: Handle this case.
              break;
            case MediaTypes.Indicator:
              break;
          }
          await _generalMessage.storeInFireStore();
          await _generalMessage.storeInLocalStorage();
        },
      ),
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Color.fromRGBO(25, 39, 52, 1),
        elevation: 10.0,
        shadowColor: Colors.white70,
        leading: null,
        title: Text(
          'Connections to Send',
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
      body: Container(
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
                  _selectedTile[index] = !_selectedTile[index];
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
}
