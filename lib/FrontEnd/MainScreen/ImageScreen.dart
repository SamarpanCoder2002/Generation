import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageTake extends StatefulWidget {
  @override
  _ImageTakeState createState() => _ImageTakeState();
}

class _ImageTakeState extends State<ImageTake> {
  File _image;

  Future getImage() async {
    final image = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      _image = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          getImage();
        },
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child:
              _image == null ? Text("No Image Captured") : Image.file(_image, width: MediaQuery.of(context).size.width-20, height: MediaQuery.of(context).size.height-20,),
        ),
      ),
    );
  }
}
