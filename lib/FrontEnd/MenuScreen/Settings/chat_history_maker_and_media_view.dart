import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generation/FrontEnd/MenuScreen/Settings/connection_media_view.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

import 'package:generation/BackendAndDatabaseManager/general_services/toast_message_manage.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/connection_important_data.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:generation/FrontEnd/Services/multiple_message_send_connection_selection.dart';

class ChatHistoryMakerAndMediaViewer extends StatefulWidget {
  final HistoryOrMediaChoice historyOrMediaChoice;

  ChatHistoryMakerAndMediaViewer({@required this.historyOrMediaChoice});

  @override
  _ChatHistoryMakerAndMediaViewerState createState() =>
      _ChatHistoryMakerAndMediaViewerState();
}

class _ChatHistoryMakerAndMediaViewerState
    extends State<ChatHistoryMakerAndMediaViewer> {
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();
  final FToast _fToast = FToast();

  final String _noProfileImagePath = 'assets/logo/logo.jpg';

  bool _isLoading = false;
  Map<String, dynamic> _allConnectionUserNameAndProfilePic;

  void extractUserNameAndProFilePic() async {
    this._allConnectionUserNameAndProfilePic =
        ProfileImageManagement.allConnectionsProfilePicLocalPath;

    final String _myUserName =
        await _localStorageHelper.extractImportantDataFromThatAccount(
            userMail: FirebaseAuth.instance.currentUser.email);

    this._allConnectionUserNameAndProfilePic.remove(_myUserName);
  }

  @override
  void initState() {
    _fToast.init(context);
    extractUserNameAndProFilePic();
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
        title: Text(
          'Select Connection',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(top: 20.0),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: this._allConnectionUserNameAndProfilePic.length,
            itemBuilder: (context, index) {
              return connectionTile(index);
            },
          ),
        ),
      ),
    );
  }

  Widget connectionTile(int index) {
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
            onPressed: () async {
              print('Chat Tile Pressed');

              if (widget.historyOrMediaChoice == HistoryOrMediaChoice.History)
                _historyMakerAndProceed(index);
              else
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ParticularConnectionMediaView(
                            selectedConnectionUserName: this
                                ._allConnectionUserNameAndProfilePic
                                .entries
                                .toList()[index]
                                .key
                                .toString())));
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
                    backgroundImage: this
                                ._allConnectionUserNameAndProfilePic
                                .entries
                                .toList()[index]
                                .value
                                .toString() !=
                            ''
                        ? FileImage(File(this
                            ._allConnectionUserNameAndProfilePic
                            .entries
                            .toList()[index]
                            .value
                            .toString()))
                        : ExactAssetImage(this._noProfileImagePath),
                  ),
                ),
                Expanded(
                  child: Container(
                    //color: Colors.white,
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width / 2 + 20,
                    padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                    child: Text(
                      this
                          ._allConnectionUserNameAndProfilePic
                          .entries
                          .toList()[index]
                          .key
                          .toString(),
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // if (_selectedTile[index])
                //   Icon(
                //     Icons.done_outline_rounded,
                //     color: const Color.fromRGBO(20, 200, 50, 1),
                //   )
              ],
            ),
          ),
        ));
  }

  void _differentSharingOptions(File file) {
    showToast(
      'Chat History Extracted Successfully',
      _fToast,
      fontSize: 16.0,
    );

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: const Color.fromRGBO(34, 48, 60, 0.6),
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              title: Center(
                  child: Text(
                'Select Sharing Option',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 18.0,
                ),
              )),
              content: Container(
                height: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sharingOptionsWidget(
                        mainText: 'Share With Generation Connections',
                        firstOption: true,
                        chatHistoryFile: file),
                    _sharingOptionsWidget(
                        mainText: 'Share With Other Apps',
                        firstOption: false,
                        chatHistoryFile: file),
                  ],
                ),
              ),
            ));
  }

  Widget _sharingOptionsWidget(
      {@required String mainText,
      @required bool firstOption,
      @required File chatHistoryFile}) {
    return TextButton(
      style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
        side: BorderSide(
          color: Colors.green,
        ),
      )),
      child: Text(
        mainText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.0,
        ),
      ),
      onPressed: () async {
        Navigator.pop(context);

        if (firstOption)
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => SelectConnection(
                        mediaType: MediaTypes.Document,
                        mediaFile: chatHistoryFile,
                        extra: chatHistoryFile.path.split('/').last,
                      )));
        else
          await Share.shareFiles(
            [chatHistoryFile.path],
            subject: 'Share From Generation',
          );
      },
    );
  }

  void _historyMakerAndProceed(int index) async {
    final String selectedUserName = this
        ._allConnectionUserNameAndProfilePic
        .entries
        .toList()[index]
        .key
        .toString();

    final List<Map<String, Object>> extractedHistoryData =
        await _localStorageHelper.fetchAllHistoryData(selectedUserName);

    if (extractedHistoryData.isNotEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      Directory directory = await getExternalStorageDirectory();

      directory = await Directory('${directory.path}/.chatExtractedHistory')
          .create(recursive: true);

      final File _chatHistoryFile = File(
          '${directory.path}/<ChatHistory>$selectedUserName${DateTime.now()}.txt');

      print(_chatHistoryFile.path);

      String _historyMaker = '';

      extractedHistoryData.forEach((everyChatData) {
        String _extractedThatMessage = everyChatData['Messages'].toString();

        String _extractedThatTime = everyChatData['Time'];

        if (everyChatData['Media'] == MediaTypes.Text.toString() &&
            everyChatData['Messages'].toString().contains('[[[@]]]'))
          _extractedThatMessage =
              everyChatData['Messages'].toString().split('[[[@]]]')[1];
        else if (everyChatData['Media'] == MediaTypes.Text.toString() &&
            _extractedThatMessage.contains('\n'))
          _extractedThatMessage = _extractedThatMessage.split('\n').join(' ');

        if (_extractedThatTime.contains('+'))
          _extractedThatTime = _extractedThatTime.split('+')[0];

        _historyMaker +=
            "${everyChatData['Reference'] == 1 ? selectedUserName : 'You'}: ${everyChatData['Media'] != MediaTypes.Text.toString() ? '<Non-Text-File>' : _extractedThatMessage}\nDate: ${everyChatData['Date']}   Time: $_extractedThatTime\n\n";
      });

      await _chatHistoryFile.writeAsString(_historyMaker);

      print('\n\n\n${await _chatHistoryFile.readAsString()}');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      _differentSharingOptions(_chatHistoryFile);
    }
  }
}
