import 'dart:io';
import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/services/input_system_services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../config/images_path_collection.dart';
import '../../../services/show_google_map.dart';

class ShowMapInLargeForm extends StatefulWidget {
  final Map<String, dynamic> locationData;

  const ShowMapInLargeForm({Key? key, required this.locationData})
      : super(key: key);

  @override
  State<ShowMapInLargeForm> createState() => _ShowMapInLargeFormState();
}

class _ShowMapInLargeFormState extends State<ShowMapInLargeForm> {
  double? _latitude;
  double? _longitude;

  _dataInitialize() {
    if (mounted) {
      _latitude = widget.locationData["latitude"];
      _longitude = widget.locationData["longitude"];
    }
  }

  @override
  void initState() {
    if (Platform.isAndroid) {
      AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
    }

    _dataInitialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _latitude != null && _longitude != null
          ? _locationSendButton()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: _mapShowingAppBar(),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: showMapSection(
            latitude: _latitude ?? widget.locationData["latitude"],
            longitude: _longitude ?? widget.locationData["longitude"],
            onDragStopped: (changedLocationData) {
              print("Changed Location Data: $changedLocationData");
              if (mounted) {
                setState(() {
                  _latitude = changedLocationData.latitude;
                  _longitude = changedLocationData.longitude;
                });
              }
            }),
      ),
    );
  }

  _locationSendButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: FloatingActionButton.extended(
        backgroundColor: AppColors.darkBorderGreenColor,
        icon: Image.asset(
          IconImages.sendImagePath,
          width: 25,
        ),
        label: const Text(
          "Send Location",
          style: TextStyleCollection.secondaryHeadingTextStyle,
        ),
        onPressed: () {
          final InputOption _inputOption = InputOption(context);
          _inputOption.sendLocationService(_latitude!, _longitude!);
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  _mapShowingAppBar() {
    return AppBar(
      backgroundColor: AppColors.oppositeMsgDarkModeColor,
      title: const Text("Share Location"),
    );
  }
}
