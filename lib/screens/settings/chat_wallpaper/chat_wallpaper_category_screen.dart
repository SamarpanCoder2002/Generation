import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/screens/settings/chat_wallpaper/chat_wallpaper_preview.dart';
import 'package:generation/services/input_system_services.dart';
import 'package:generation/types/types.dart';
import 'package:provider/provider.dart';

import '../../../providers/wallpaper/wallpaper_provider.dart';

class ChatWallpaperScreen extends StatefulWidget {
  const ChatWallpaperScreen({Key? key}) : super(key: key);

  @override
  State<ChatWallpaperScreen> createState() => _ChatWallpaperScreenState();
}

class _ChatWallpaperScreenState extends State<ChatWallpaperScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkMode,
      appBar: _headerSection(),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 20),
          children: [
            ...Provider.of<WallpaperProvider>(context)
                .getWallpaperCategoryCollection()
                .map((wallpaperData) => InkWell(
                      onTap: () => _imageCategoryTapAction(wallpaperData),
                      child: SizedBox(
                        width: 300,
                        height: 400,
                        child: Stack(
                          children: [
                            Container(
                                height: 150,
                                width: 300,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                            wallpaperData["image"])))),
                            Container(
                              width: 300,
                              height: 400,
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                wallpaperData["category"],
                                style: TextStyleCollection
                                    .secondaryHeadingTextStyle
                                    .copyWith(fontSize: 16),
                              ),
                            )
                          ],
                        ),
                      ),
                    )),
          ],
        ),
      ),
    );
  }

  _headerSection() => AppBar(
        elevation: 0,
        backgroundColor: AppColors.chatDarkBackgroundColor,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_outlined)),
            Text(
              "Wallpaper Management",
              style:
                  TextStyleCollection.terminalTextStyle.copyWith(fontSize: 16),
            ),
          ],
        ),
      );

  _imageCategoryTapAction(wallpaperData) async {
    if (wallpaperData["type"] == WallpaperType.myPhotos) {
      final InputOption _inputOption = InputOption(context);
      final _singleImagePath = await _inputOption.pickSingleImageFromGallery(
          imageQuality: 100, popUpScreen: false);

      if (_singleImagePath == null) return;

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ChatWallpaperPreview(
                  wallpaperType: wallpaperData["type"],
                  imgPath: _singleImagePath)));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  ChatWallpaperPreview(wallpaperType: wallpaperData["type"])));
    }
  }
}
