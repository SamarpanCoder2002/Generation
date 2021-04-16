import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class StatusTextContainer extends StatefulWidget {
  @override
  _StatusTextContainerState createState() => _StatusTextContainerState();
}

class _StatusTextContainerState extends State<StatusTextContainer> {
  Color pickColor = Colors.lightBlue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        elevation: 5.0,
        backgroundColor: const Color.fromRGBO(66, 133, 255, 1),
        child: const Icon(
          Icons.send_rounded,
        ),
        onPressed: () {},
      ),
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        color: pickColor,
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              constraints: BoxConstraints.loose(Size(double.maxFinite, 500.0)),
              padding:
                  const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
              child: const Center(
                child: const Scrollbar(
                  showTrackOnHover: true,
                  thickness: 10.0,
                  radius: const Radius.circular(30.0),
                  child: const TextField(
                    textAlign: TextAlign.center,
                    cursorColor: Colors.white,
                    style: const TextStyle(
                      fontSize: 30.0,
                      color: Colors.white,
                      fontFamily: 'Lora',
                      letterSpacing: 1.0,
                    ),
                    autofocus: true,
                    maxLines: 10,
                    minLines: 1,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type Here",
                        hintStyle: const TextStyle(
                          color: Colors.white54,
                          fontFamily: 'Lora',
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1.0,
                        )),
                  ),
                ),
              ),
            ),
            Container(
              //color: Colors.black,
              //alignment: Alignment.topCenter,
              width: double.maxFinite,
              child: Center(
                child: ColorPicker(
                  showLabel: false,
                  pickerAreaHeightPercent: 0.05,
                  displayThumbColor: false,
                  pickerColor: pickColor,
                  paletteType: PaletteType.rgb,
                  onColorChanged: (Color color) {
                    if (mounted) {
                      setState(() {
                        pickColor = color;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
