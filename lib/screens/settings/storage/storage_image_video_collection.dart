import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/providers/storage/storage_provider.dart';
import 'package:generation/screens/common/image_showing_screen.dart';
import 'package:generation/services/encryption_operations.dart';
import 'package:generation/services/local_data_management.dart';
import 'package:generation/config/types.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';
import '../../../services/device_specific_operations.dart';

class StorageImageAndVideoCollection extends StatelessWidget {
  final bool showVideoPlayIcon;

  const StorageImageAndVideoCollection(
      {Key? key, this.showVideoPlayIcon = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Scaffold(
      backgroundColor: AppColors.getBgColor(_isDarkMode),
      body: _getBody(context),
    );
  }

  _getBody(BuildContext context) {
    if (showVideoPlayIcon &&
        Provider.of<StorageProvider>(context).getVideosCollection().isEmpty) {
      return _emptyMedia('No Videos Found', context);
    }

    if (!showVideoPlayIcon &&
        Provider.of<StorageProvider>(context).getImagesCollection().isEmpty) {
      return _emptyMedia('No Images Found', context);
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 20, crossAxisSpacing: 20),
        itemCount: showVideoPlayIcon
            ? Provider.of<StorageProvider>(context).getVideosCollection().length
            : Provider.of<StorageProvider>(context)
                .getImagesCollection()
                .length,
        itemBuilder: (_, index) => _particularData(index, context),
      ),
    );
  }

  _emptyMedia(String title, BuildContext context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
    return Center(
        child: Text(title,
            style: TextStyleCollection.terminalTextStyle.copyWith(
                fontSize: 16,
                color: AppColors.getModalTextColor(_isDarkMode))));
  }

  _particularData(int index, BuildContext context) {
    final _extractedData = showVideoPlayIcon
        ? Provider.of<StorageProvider>(context).getVideosCollection()[index]
        : Provider.of<StorageProvider>(context).getImagesCollection()[index];

    _onTapped() async {
      if (showVideoPlayIcon) {
        await OpenFile.open(Secure.decode(_extractedData['message']));
      } else {
        makeStatusBarTransparent();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ImageShowingScreen(
                      imgPath: Secure.decode(_extractedData['message']),
                      imageType: ImageType.file,
                    ))).then((value) => showStatusAndNavigationBar());
      }
    }

    return InkWell(
      onTap: _onTapped,
      child: Stack(
        children: [
          _onlyImageSection(showVideoPlayIcon
              ? DataManagement.fromJsonString(
                  Secure.decode(_extractedData['additionalData']))['thumbnail']
              : Secure.decode(_extractedData['message'])),
          if (showVideoPlayIcon)
            _forShowingVideoFile(_extractedData['message']),
        ],
      ),
    );
  }

  _onlyImageSection(_extractedData) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
                fit: BoxFit.cover, image: _getPerfectImage(_extractedData))));
  }

  _forShowingVideoFile(extractedData) {
    return Container(
      alignment: Alignment.center,
      color: AppColors.pureBlackColor.withOpacity(0.4),
      padding: const EdgeInsets.only(right: 10, bottom: 10),
      child: IconButton(
        icon: const Icon(
          Icons.play_circle_outline,
          size: 40,
          color: AppColors.darkBorderGreenColor,
        ),
        onPressed: () async {
          /// When Integrate Functions later, Open Video from phone app write here
          await OpenFile.open(Secure.decode(extractedData));
        },
      ),
    );
  }

  _getPerfectImage(String imagePath) {
    if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
      return CachedNetworkImageProvider(imagePath);
    }
    return FileImage(File(imagePath));
  }
}
