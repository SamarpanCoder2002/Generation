import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generation/BackendAndDatabaseManager/general_services/toast_message_manage.dart';
import 'package:generation/BackendAndDatabaseManager/sqlite_services/local_storage_controller.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:open_file/open_file.dart';
import 'package:photo_view/photo_view.dart';

import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';
import 'package:generation/FrontEnd/Preview/images_preview_screen.dart';
import 'package:share/share.dart';

class StorageMediaCommonView extends StatefulWidget {
  final MediaTypes mediaTypes;
  final List<Map<String, String>> mediaSources;
  final String userName;

  StorageMediaCommonView(
      {@required this.mediaTypes,
      @required this.mediaSources,
      @required this.userName});

  @override
  _StorageMediaCommonViewState createState() => _StorageMediaCommonViewState();
}

class _StorageMediaCommonViewState extends State<StorageMediaCommonView> {
  bool _isLoading = false;
  bool _selectEveryMedia = false;

  final FToast _fToast = FToast();
  final LocalStorageHelper _localStorageHelper = LocalStorageHelper();

  List<bool> _selectedCheckBox = [];

  void _getVal() {
    if (mounted) {
      setState(() {
        this._selectedCheckBox =
            List.generate(widget.mediaSources.length, (index) => false);
      });
    }
  }

  @override
  void initState() {
    _fToast.init(context);
    super.initState();

    print('Checkbox Value: ${this._selectedCheckBox}');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (this._selectEveryMedia) {
          if (mounted) {
            setState(() {
              this._selectEveryMedia = false;
            });
          }
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
        floatingActionButton:
            this._selectEveryMedia && this._selectedCheckBox.contains(true)
                ? _multipleOptions()
                : null,
        body: ModalProgressHUD(
          inAsyncCall: _isLoading,
          child: _differentProceed(),
        ),
      ),
    );
  }

  Widget _differentProceed() {
    if (widget.mediaTypes == MediaTypes.Image)
      return _forImageAndVideoProcessing();
    else if (widget.mediaTypes == MediaTypes.Video)
      return _forImageAndVideoProcessing();
    else if (widget.mediaTypes == MediaTypes.Voice)
      return _audioAndDocView();
    else
      return _audioAndDocView();
  }

  Widget _forImageAndVideoProcessing() {
    return Container(
      padding: EdgeInsets.all(
        20.0,
      ),
      child: widget.mediaSources.isNotEmpty
          ? GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                for (int i = 0; i < widget.mediaSources.length; i++)
                  _imageAndVideoView(i),
              ],
            )
          : Center(
              child: Text(
                widget.mediaTypes == MediaTypes.Image
                    ? 'No Image Found'
                    : 'No Video Found',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20.0,
                ),
              ),
            ),
    );
  }

  Widget _imageAndVideoView(int index) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: Duration(milliseconds: 500),
      middleColor: const Color.fromRGBO(34, 48, 60, 1),
      openColor: const Color.fromRGBO(34, 48, 60, 1),
      openBuilder: (_, __) => PreviewImageScreen(
        imageFile: File(widget.mediaTypes == MediaTypes.Image
            ? widget.mediaSources[index].keys.first.toString()
            : widget.mediaSources[index].keys.first.toString().split('+')[1]),
      ),
      closedBuilder: (_, __) => GestureDetector(
        onLongPress: () {
          print('It Long Pressed');
          if (mounted) {
            setState(() {
              _getVal();
              this._selectEveryMedia = true;
              this._selectedCheckBox[index] = true;
            });
          }
        },
        child: Stack(
          children: [
            PhotoView(
              imageProvider: FileImage(File(
                  widget.mediaTypes == MediaTypes.Image
                      ? widget.mediaSources[index].keys.first.toString()
                      : widget.mediaSources[index].keys.first
                          .toString()
                          .split('+')[1])),
              loadingBuilder: (context, event) => Center(
                child: CircularProgressIndicator(),
              ),
              errorBuilder: (context, obj, stackTrace) => Center(
                  child: Text(
                'Image not Found',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.red,
                  fontFamily: 'Lora',
                  letterSpacing: 1.0,
                ),
              )),
              enableRotation: true,
              minScale: PhotoViewComputedScale.covered,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: double.maxFinite,
                alignment: Alignment.bottomRight,
                color: Colors.black26,
                height: 20.0,
                child: Text(
                  widget.mediaSources[index].values.first.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            if (this._selectEveryMedia)
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  color: Colors.black38,
                  alignment: Alignment.topLeft,
                  child: this._selectedCheckBox.isNotEmpty
                      ? Transform.scale(
                          scale: 1.5,
                          child: Theme(
                            data: ThemeData(
                              unselectedWidgetColor: Colors.white,
                            ),
                            child: Checkbox(
                              shape: CircleBorder(),
                              activeColor: Colors.green,
                              value: this._selectedCheckBox[index],
                              onChanged: (changedVal) {
                                if (mounted) {
                                  setState(() {
                                    this._selectedCheckBox[index] = changedVal;
                                  });
                                }
                              },
                            ),
                          ),
                        )
                      : Center(),
                ),
              ),
            if (widget.mediaTypes == MediaTypes.Video &&
                !this._selectEveryMedia)
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 100.0,
                    color: Colors.white,
                  ),
                  onTap: () async {
                    final OpenResult openResult = await OpenFile.open(widget
                        .mediaSources[index].keys.first
                        .toString()
                        .split('+')[0]);

                    openFileResultStatus(openResult: openResult);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void openFileResultStatus({@required OpenResult openResult}) {
    if (openResult.type == ResultType.permissionDenied)
      showToast('Permission Denied to Open File', _fToast);
    else if (openResult.type == ResultType.noAppToOpen)
      showToast('No App Found to Open', _fToast);
    else if (openResult.type == ResultType.error)
      showToast('Error in Opening File', _fToast);
    else if (openResult.type == ResultType.fileNotFound)
      showToast('Sorry, File Not Found', _fToast);
  }

  Widget _audioAndDocView() {
    return widget.mediaSources.length != 0
        ? Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(
              top: 10.0,
              bottom: 10.0,
            ),
            child: ListView(
              shrinkWrap: true,
              children: widget.mediaSources
                  .asMap()
                  .map(
                      (mapIndex, e) => MapEntry(mapIndex, _everyFile(mapIndex)))
                  .values
                  .toList(),
            ),
          )
        : Center(
            child: Text(
              '${widget.mediaTypes == MediaTypes.Voice ? 'No Audio Found' : 'No Document Found'}',
              style: TextStyle(color: Colors.red, fontSize: 20.0),
            ),
          );
  }

  Widget _everyFile(int index) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 90.0,
      padding: EdgeInsets.only(
        left: 5.0,
        right: 5.0,
        top: 10.0,
        bottom: 10.0,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0.0,
          primary: const Color.fromRGBO(34, 48, 60, 1),
          onPrimary: Colors.lightBlueAccent,
        ),
        onPressed: () async {
          print(widget.mediaSources[index].keys.first.toString());
          final OpenResult openResult = await OpenFile.open(
            widget.mediaSources[index].keys.first.toString(),
          );

          openFileResultStatus(openResult: openResult);
        },
        onLongPress: () {
          print('It Long Pressed');
          if (mounted) {
            setState(() {
              _getVal();
              this._selectEveryMedia = true;
              this._selectedCheckBox[index] = true;
            });
          }
        },
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: Icon(
                    widget.mediaTypes == MediaTypes.Voice
                        ? Icons.audiotrack_rounded
                        : Entypo.documents,
                    size: 35.0,
                    color: Colors.lightBlue,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: 10.0,
                        ),
                        child: Text(
                          _compressFileName(index),
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 10.0,
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            widget.mediaSources[index].values.first.toString(),
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (this._selectEveryMedia)
              Container(
                width: double.maxFinite,
                alignment: Alignment.centerRight,
                //color: Colors.black38,
                child: Transform.scale(
                  scale: 1.2,
                  child: Theme(
                    data: ThemeData(
                      unselectedWidgetColor: Colors.white,
                    ),
                    child: Checkbox(
                      shape: CircleBorder(),
                      activeColor: Colors.green,
                      value: this._selectedCheckBox[index],
                      onChanged: (changedVal) {
                        if (mounted) {
                          setState(() {
                            this._selectedCheckBox[index] = changedVal;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _compressFileName(int index) {
    return widget.mediaSources[index].keys.first
                .toString()
                .split('/')
                .last
                .length <=
            30
        ? widget.mediaSources[index].keys.first
            .toString()
            .split('/')
            .last
            .toString()
        : '${widget.mediaSources[index].keys.first.toString().split('/').last.replaceRange(30, widget.mediaSources[index].keys.first.toString().split('/').last.length, '...')}';
  }

  Widget _multipleOptions() {
    return Container(
      padding: EdgeInsets.only(left: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton(
            heroTag: '1',
            elevation: 5.0,
            backgroundColor: Colors.lightBlue,
            child: Icon(
              Icons.share,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed:
                this._selectEveryMedia ? _shareMultipleSelectedFile : null,
          ),
          FloatingActionButton(
            heroTag: '2',
            elevation: 5.0,
            backgroundColor: Colors.red,
            child: Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () {
              print(this._selectedCheckBox);

              _showDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showDialog() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: const Color.fromRGBO(34, 48, 60, 0.6),
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              title: Center(
                child: Text(
                  'Sure to Delete?',
                  style: TextStyle(
                    color: Colors.amber,
                  ),
                ),
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _alertDialogOptionMaker(
                      buttonName: 'Cancel', rightButton: false),
                  _alertDialogOptionMaker(
                      buttonName: 'Sure', rightButton: true),
                ],
              ),
            ));
  }

  Widget _alertDialogOptionMaker(
      {@required String buttonName, @required bool rightButton}) {
    return TextButton(
      child: Text(
        buttonName,
        style: TextStyle(
          color: rightButton ? Colors.red : Colors.green,
          fontSize: 16.0,
        ),
      ),
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
          side: BorderSide(color: rightButton ? Colors.red : Colors.green),
        ),
      ),
      onPressed: () async {
        Navigator.pop(context);

        if (rightButton) {
          print('Delete Activity');

          if (mounted) {
            setState(() {
              _isLoading = true;
            });
          }

          List<Map<String, String>> take = [];

          for (int i = 0; i < this._selectedCheckBox.length; i++) {
            if (this._selectedCheckBox[i]) take.add(widget.mediaSources[i]);
          }

          if (mounted) {
            setState(() {
              this._selectEveryMedia = false;
              this._selectedCheckBox.clear();
            });
          }

          take.forEach((element) async {
            final bool responseIs = await _localStorageHelper.deleteChatMessage(
                widget.userName,
                message: element.keys.first.toString().contains('+')
                    ? element.keys.first.toString().split('+')[0]
                    : element.keys.first.toString(),
                multipleMediaDeletion: true,
                mediaType: widget.mediaTypes.toString());

            if (responseIs) {
              final String _imageFilePath =
                  element.keys.first.toString().contains('file:///')
                      ? element.keys.first.toString().split('file:///')[1]
                      : element.keys.first.toString();

              if (await File(_imageFilePath.contains('+')
                      ? _imageFilePath.split('+')[0]
                      : _imageFilePath)
                  .exists()) {
                print('File Exist at desired location');
                try {
                  await File(_imageFilePath.contains('+')
                          ? _imageFilePath.split('+')[0]
                          : _imageFilePath)
                      .delete(recursive: true)
                      .whenComplete(
                          () => print('Media File Deletion Complete'));

                  /// For Video Thumbnail Delete
                  if (_imageFilePath.contains('+'))
                    await File(_imageFilePath.split('+')[1])
                        .delete(recursive: true)
                        .whenComplete(() =>
                            print('Video Thumbnail File Deletion Complete'));
                } catch (e) {
                  print('Error: File Deletion Error: ${e.toString()}');
                }
              } else {
                print('File Not Exist at desired location');
              }
            }

            if (mounted) {
              setState(() {
                widget.mediaSources.remove(element);
              });
            } else
              print('Path Deleted Already');
          });

          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }

          try {
            showToast(
              'Please close and reopen particular\nthat chat to see changes',
              _fToast,
              toastColor: Colors.amber,
              fontSize: 16.0,
              seconds: 4,
            );
          } catch (e) {
            print('Toast Error in Storage Different Media: ${e.toString()}');
          }
        }
      },
    );
  }

  void _shareMultipleSelectedFile() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        this._selectEveryMedia = false;
      });
    }

    final List<String> _linkTobeShare = [];

    for (int i = 0; i < this._selectedCheckBox.length; i++) {
      if (this._selectedCheckBox[i]) {
        final String _tempMediaLink =
            widget.mediaSources[i].keys.first.toString();
        _linkTobeShare.add(_tempMediaLink.contains('+')
            ? _tempMediaLink.split('+')[0]
            : _tempMediaLink);
      }
    }

    if (mounted) {
      setState(() {
        this._selectedCheckBox.clear();
      });
    }

    await Share.shareFiles(_linkTobeShare);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
