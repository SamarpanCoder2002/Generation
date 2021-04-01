import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:camera/camera.dart';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:generation/FrontEnd/Store/images_preview_screen.dart';

class PhotoCapture extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<PhotoCapture> {
  CameraController controller;
  List cameras;
  int selectedCameraIdx;
  bool cameraMode;
  Icon videoControlIcon;
  bool isVideoRecording;

  @override
  void initState() {
    super.initState();
    cameraMode = true;
    videoControlIcon = Icon(Icons.radio_button_checked_rounded);
    isVideoRecording = false;

    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras.length > 0) {
        setState(() {
          selectedCameraIdx = 0;
        });

        _initCameraController(cameras[selectedCameraIdx]).then((void v) {});
      } else {
        print("No camera available");
      }
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }

    controller =
        CameraController(cameraDescription, ResolutionPreset.ultraHigh);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      print('Error: ${e.code}\n${e.description}');
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Expanded>[
          Expanded(
            child: FloatingActionButton(
              heroTag: '1',
              backgroundColor: Colors.lightBlueAccent,
              onPressed: _onSwitchCamera,
              child: const Icon(Icons.flip_camera_android_rounded),
            ),
          ),
          Expanded(
            child: FloatingActionButton(
                heroTag: '2',
                child: cameraMode
                    ? Icon(
                        Icons.camera,
                        size: 25.0,
                      )
                    : videoControlIcon,
                backgroundColor: Colors.deepOrange,
                onPressed: () {
                  if (cameraMode)
                    _onCapturePressed(context);
                  else {
                    print(isVideoRecording);
                    _videoRecordController();
                  }
                }),
          ),
          Expanded(
            child: FloatingActionButton(
                heroTag: '3',
                child: cameraMode
                    ? Icon(
                        Icons.videocam_rounded,
                        size: 25.0,
                      )
                    : Icon(Icons.camera_alt_rounded),
                backgroundColor: Colors.lightGreen,
                onPressed: () {
                  if (cameraMode) {
                    setState(() {
                      cameraMode = false;
                      isVideoRecording = false;
                    });
                  } else {
                    setState(() {
                      cameraMode = true;
                    });
                  }
                }),
          ),
        ],
      ),
      body: Container(
        child: _cameraPreviewWidget(context),
      ),
    );
  }

  /// Display Camera preview.
  Widget _cameraPreviewWidget(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Loading....',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    return ClipRect(
        child: OverflowBox(
            child: SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Align(
          alignment: Alignment.center,
          child: AspectRatio(
            aspectRatio: MediaQuery.of(context).size.width /
                MediaQuery.of(context).size.height,
            child: CameraPreview(controller),
          )),
    )));
  }

  void _onSwitchCamera() {
    selectedCameraIdx =
        selectedCameraIdx < cameras.length - 1 ? selectedCameraIdx + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    _initCameraController(selectedCamera);
  }

  void _onCapturePressed(context) async {
    // Take the Picture in a try / catch block. If anything goes wrong,
    // catch the error.
    try {
      // Attempt to take a picture and log where it's been saved
      Directory directory = await getExternalStorageDirectory();
      print(directory.path);
      final path = join(
        // In this example, store the picture in the temp directory. Find
        // the temp directory using the `path_provider` plugin.
        directory.path,
        '${DateTime.now()}.png',
      );
      print(path);
      await controller.takePicture(path);

      setState(() {
        controller.dispose();

        GallerySaver.saveImage(
          path,
        ).then((bool success) {
          setState(() {
            print(path);
          });
        });
      });

      // If the picture was taken, display it on a new screen
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewImageScreen(imagePath: path),
        ),
      );
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                backgroundColor: Colors.black54,
                title: Text(
                  "Path is",
                  style: TextStyle(color: Colors.white),
                ),
                content: Text(
                  path.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ));
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }

  _videoRecordController() async {
    if (!isVideoRecording) {
      try {
        Directory directory = await getExternalStorageDirectory();
        print(directory.path);
        final path = join(
          // In this example, store the picture in the temp directory. Find
          // the temp directory using the `path_provider` plugin.
          directory.path,
          '${DateTime.now()}.mp4',
        );
        print(path);
        await controller.startVideoRecording(path);

        setState(() {
          controller.dispose();
          isVideoRecording = true;
          videoControlIcon = Icon(
            Icons.stop_rounded,
            size: 40.0,
          );
        });
        print("Start Video Recording");
      } catch (e) {
        print("Start Error is: ${e.toString()}");
      }
    } else {
      try {
        await controller.stopVideoRecording();
        setState(() {
          isVideoRecording = false;
          videoControlIcon = Icon(
            Icons.radio_button_checked_rounded,
            size: 25.0,
          );
        });
        print("Stop Video Recording");
      } catch (e) {
        print("Stop Video Error: ${e.toString()}");
      }
    }
  }
}
