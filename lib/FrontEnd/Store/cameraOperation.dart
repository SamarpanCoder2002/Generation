import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:generation/FrontEnd/Store/CapturedImagePrevieeScreen.dart';

class PhotoCapture extends StatefulWidget {
  static final String route = '/photoCapture';

  PhotoCapture();

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<PhotoCapture> {
  GlobalKey _globalKey = GlobalKey();
  CameraController controller;
  List cameras;
  int selectedCameraIdx;
  String imagePath;
  String albumName = 'Media';


  @override
  void initState() {
    super.initState();
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
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: _cameraPreviewWidget(),
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _cameraTogglesRowWidget(),
                  _captureControlRowWidget(context),
                  Spacer()
                ],
              ),
              SizedBox(height: 20.0)
            ],
          ),
        ),
      ),
    );
  }

  /// Display Camera preview.
  Widget _cameraPreviewWidget() {
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

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: CameraPreview(controller),
    );
  }

  /// Display the control bar with buttons to take pictures
  Widget _captureControlRowWidget(context) {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            FloatingActionButton(
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: 25.0,
                ),
                backgroundColor: Color(0xffb72334),
                onPressed: () {
                  _onCapturePressed(context);
                })
          ],
        ),
      ),
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    if (cameras == null || cameras.isEmpty) {
      return Spacer();
    }

    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          onPressed: _onSwitchCamera,
          icon: Icon(Icons.flip_camera_android_rounded),
        ),
      ),
    );
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

        GallerySaver.saveImage(path,).then((bool success) {
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
      showDialog(context: context, builder: (context) => AlertDialog(
        backgroundColor: Colors.black54,
        title: Text("Path is", style: TextStyle(color: Colors.white),),
        content: Text(path.toString(), style: TextStyle(color: Colors.white),),
      ));
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
    print(errorText);

    print('Error: ${e.code}\n${e.description}');
  }
}
