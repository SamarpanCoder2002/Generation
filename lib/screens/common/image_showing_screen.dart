import 'dart:io';

import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/services/device_specific_operations.dart';
import 'package:generation/types/types.dart';
import 'package:photo_view/photo_view.dart';

class ImageShowingScreen extends StatefulWidget {
  final String imgPath;
  final ImageType imageType;
  const ImageShowingScreen({Key? key, required this.imgPath, required this.imageType}) : super(key: key);

  @override
  State<ImageShowingScreen> createState() => _ImageShowingScreenState();
}

class _ImageShowingScreenState extends State<ImageShowingScreen> {

  @override
  void initState() {
    changeOnlyNavigationBarColor(navigationBarColor: AppColors.pureBlackColor);
    super.initState();
  }

  @override
  void dispose() {
    changeOnlyNavigationBarColor(navigationBarColor: AppColors.backgroundDarkMode);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureBlackColor,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: PhotoView(
          imageProvider: _getPerfectImage(),
          enableRotation: false,
          loadingBuilder: (_,__) => Center(child: Text("Loading...", style: TextStyleCollection.terminalTextStyle.copyWith(fontSize: 18),),),
          errorBuilder: (_,__,___) => Center(child: Text("Error...", style: TextStyleCollection.terminalTextStyle.copyWith(fontSize: 18),),),
        ),
      ),
    );
  }

  _getPerfectImage() {
    switch(widget.imageType){
      case ImageType.file:
        return FileImage(File(widget.imgPath));
      case ImageType.network:
        return NetworkImage(widget.imgPath);
      case ImageType.asset:
        return ExactAssetImage(widget.imgPath);
    }
  }
}
