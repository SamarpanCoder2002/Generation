import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:circle_list/circle_list.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:generation_official/BackendAndDatabaseManager/Dataset/data_type.dart';
import 'package:generation_official/FrontEnd/Services/multiple_message_send_connection_selection.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:image_picker/image_picker.dart';

class ApplicationList extends StatefulWidget {
  @override
  _ApplicationListState createState() => _ApplicationListState();
}

class _ApplicationListState extends State<ApplicationList> {
  final ImagePicker picker = ImagePicker();
  final TextEditingController _mediaController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(34, 48, 60, 1),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Center(
            child: CircleList(
          initialAngle: 55,
          outerRadius: MediaQuery.of(context).size.width / 2.2,
          innerRadius: MediaQuery.of(context).size.width / 4,
          showInitialAnimation: true,
          innerCircleColor: Color.fromRGBO(34, 48, 60, 1),
          outerCircleColor: Color.fromRGBO(0, 0, 0, 0.1),
          origin: Offset(0, 0),
          rotateMode: RotateMode.allRotate,
          centerWidget: Center(
            child: Text(
              "G",
              style: TextStyle(
                color: Colors.lightBlue,
                fontSize: 65.0,
                fontFamily: 'Lora',
              ),
            ),
          ),
          children: <Widget>[
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.blue,
                    width: 3,
                  )),
              child: GestureDetector(
                onTap: () async {
                  _imageOrVideoSend(imageSource: ImageSource.camera);
                },
                onLongPress: () async {
                  _imageOrVideoSend(imageSource: ImageSource.gallery);
                },
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.lightGreen,
                  size: 30.0,
                ),
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.blue,
                    width: 3,
                  )),
              child: GestureDetector(
                onTap: () async {
                  _imageOrVideoSend(
                      imageSource: ImageSource.camera, type: 'video');
                },
                onLongPress: () async {
                  _imageOrVideoSend(
                      imageSource: ImageSource.gallery, type: 'video');
                },
                child: Icon(
                  Icons.video_collection,
                  color: Colors.lightGreen,
                  size: 30.0,
                ),
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.blue,
                    width: 3,
                  )),
              child: GestureDetector(
                onTap: () async {
                  _extraTextManagement(MediaTypes.Text);
                },
                child: Icon(
                  Icons.text_fields_rounded,
                  color: Colors.lightGreen,
                  size: 30.0,
                ),
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.blue,
                    width: 3,
                  )),
              child: GestureDetector(
                onTap: () async {
                  await _documentSend();
                },
                child: Icon(
                  Entypo.documents,
                  color: Colors.lightGreen,
                  size: 30.0,
                ),
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.blue,
                    width: 3,
                  )),
              child: GestureDetector(
                onTap: () async {
                  await _locationSend();
                },
                child: Icon(
                  Icons.location_on_rounded,
                  color: Colors.lightGreen,
                  size: 30.0,
                ),
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.blue,
                    width: 3,
                  )),
              child: GestureDetector(
                child: Icon(
                  Icons.music_note_rounded,
                  color: Colors.lightGreen,
                  size: 30.0,
                ),
                onTap: () async {
                  await _voiceSend();
                },
              ),
            ),
          ],
        )),
      ),
    );
  }

  void _imageOrVideoSend(
      {@required ImageSource imageSource, String type = 'image'}) async {
    PickedFile pickedFile;
    type == 'image'
        ? pickedFile =
            await picker.getImage(source: imageSource, imageQuality: 50)
        : pickedFile = await picker.getVideo(
            source: imageSource, maxDuration: Duration(seconds: 15));

    if (pickedFile != null)
      _extraTextManagement(
        type == 'image' ? MediaTypes.Image : MediaTypes.Video,
        file: File(pickedFile.path),
      );
  }

  Future<void> _documentSend() async {
    List<String> _allowedExtensions = [
      'pdf',
      'doc',
      'docx',
      'ppt',
      'pptx',
      'c',
      'cpp',
      'py',
      'text'
    ];

    try {
      final FilePickerResult filePickerResult =
          await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
      );

      if (filePickerResult != null && filePickerResult.files.length > 0) {
        filePickerResult.files.forEach((file) async {
          print(file.path);
          if (_allowedExtensions.contains(file.extension))
            _extraTextManagement(
              MediaTypes.Document,
              extension: '.${file.extension}',
              file: File(file.path),
            );
          else {
            _showDiaLog(
              titleText: 'Not Supporting Document Format',
            );
          }
        });
      }
    } catch (e) {
      _showDiaLog(
          titleText: 'Some Error Occurred',
          contentText: 'Please close and reopen this chat');
    }
  }

  _locationSend() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);

      final Marker marker = Marker(
          markerId: MarkerId('locate'),
          zIndex: 1.0,
          draggable: true,
          position: LatLng(position.latitude, position.longitude));

      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                backgroundColor: Colors.black26,
                actions: [
                  FloatingActionButton(
                    child: Icon(Icons.send),
                    onPressed: () {
                      Navigator.pop(context);

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => SelectConnection(
                                    mediaType: MediaTypes.Location,
                                    extra:
                                        '${position.latitude}+${position.longitude}',
                                  )));
                    },
                  ),
                ],
                content: FittedBox(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                    ),
                    child: GoogleMap(
                      mapType: MapType.hybrid,
                      markers: Set.of([marker]),
                      initialCameraPosition: CameraPosition(
                        target: LatLng(position.latitude, position.longitude),
                        zoom: 18.4746,
                      ),
                    ),
                  ),
                ),
              ));
    } catch (e) {
      print('Map Show Error: ${e.toString()}');
      _showDiaLog(titleText: 'Map Show Error', contentText: e.toString());
    }
  }

  Future<void> _voiceSend() async {
    final List<String> _allowedExtensions = const [
      'mp3',
      'm4a',
      'wav',
      'ogg',
    ];

    final FilePickerResult _audioFilePickerResult =
        await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (_audioFilePickerResult != null) {
      _audioFilePickerResult.files.forEach((element) async {
        print('Name: ${element.path}');
        print('Extension: ${element.extension}');

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => SelectConnection(
                      mediaType: MediaTypes.Voice,
                      mediaFile: File(element.path),
                      extra: _allowedExtensions.contains(element.extension)
                          ? '.${element.extension}'
                          : '.mp3',
                    )));
      });
    }
  }

  void _extraTextManagement(MediaTypes mediaTypes,
      {String extension = '', File file}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        elevation: 5.0,
        backgroundColor: Color.fromRGBO(34, 48, 60, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(
            40.0,
          )),
        ),
        title: Center(
          child: Text(
            'Something About That',
            style: TextStyle(
              color: Colors.lightBlue,
              fontSize: 14.0,
              fontFamily: 'Lora',
              fontStyle: FontStyle.italic,
              letterSpacing: 1.0,
            ),
          ),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: TextField(
                controller: _mediaController,
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                    labelText: 'Type Here',
                    labelStyle: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Lora',
                      letterSpacing: 1.0,
                      fontStyle: FontStyle.italic,
                    ),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.lightBlue))),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: IconButton(
                icon: Icon(
                  Icons.send_rounded,
                  color: Colors.green,
                  size: 30.0,
                ),
                onPressed: () async {
                  Navigator.pop(context);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => SelectConnection(
                                mediaType: mediaTypes,
                                mediaFile: file,
                                textContent: _mediaController.text,
                                extra: extension,
                              )));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDiaLog({@required String titleText, String contentText = ''}) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              elevation: 5.0,
              backgroundColor: Color.fromRGBO(34, 48, 60, 0.6),
              title: Center(
                  child: Text(
                titleText,
                style: TextStyle(
                  fontFamily: 'Lora',
                  color: Colors.red,
                  letterSpacing: 1.0,
                  fontSize: 16.0,
                ),
              )),
              content: contentText == ''
                  ? null
                  : Text(
                      contentText,
                      style: TextStyle(
                        fontFamily: 'Lora',
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
            ));
  }
}
