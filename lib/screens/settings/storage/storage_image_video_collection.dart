import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/screens/common/image_showing_screen.dart';
import 'package:generation/types/types.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import '../../../providers/wallpaper/wallpaper_provider.dart';

class StorageImageAndVideoCollection extends StatelessWidget {
  final bool showVideoPlayIcon;

  const StorageImageAndVideoCollection(
      {Key? key, this.showVideoPlayIcon = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkMode,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, mainAxisSpacing: 20, crossAxisSpacing: 20),
          itemCount: Provider.of<WallpaperProvider>(context)
              .getBrightImagesCollection()
              .length,
          itemBuilder: (_, index) => _particularImage(index, context),
        ),
      ),
    );
  }

  _particularImage(int index, BuildContext context) {
    final _extractedData = Provider.of<WallpaperProvider>(context)
        .getBrightImagesCollection()[index];

    _onTapped() async {
      if (showVideoPlayIcon) {
        /// When Integrate Functions later, Open Video from phone app write here
        /// await OpenFile.open("give_local_video_file_path_here");
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ImageShowingScreen(
                      imgPath: _extractedData,
                      imageType: ImageType.network,
                      isCovered: true,
                    )));
      }
    }

    return InkWell(
      onTap: _onTapped,
      child: Stack(
        children: [
          _onlyImageSection(_extractedData),
          if (showVideoPlayIcon) _forShowingVideoFile(_extractedData),
        ],
      ),
    );
  }

  _onlyImageSection(_extractedData) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(_extractedData))));
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
        onPressed: () {
          /// When Integrate Functions later, Open Video from phone app write here
          /// await OpenFile.open("give_local_video_file_path_here");
        },
      ),
    );
  }
}
