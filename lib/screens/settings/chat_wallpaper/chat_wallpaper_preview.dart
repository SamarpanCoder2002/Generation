import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/providers/wallpaper/wallpaper_provider.dart';
import 'package:generation/types/types.dart';
import 'package:provider/provider.dart';

class ChatWallpaperPreview extends StatefulWidget {
  final String? imgPath;
  final WallpaperType wallpaperType;

  const ChatWallpaperPreview(
      {Key? key, this.imgPath, required this.wallpaperType})
      : super(key: key);

  @override
  State<ChatWallpaperPreview> createState() => _ChatWallpaperPreviewState();
}

class _ChatWallpaperPreviewState extends State<ChatWallpaperPreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkMode,
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: _setWallpaperButton(),
      appBar: _headerSection(),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: widget.wallpaperType == WallpaperType.myPhotos
            ? _particularImage()
            : PageView(
                physics: const PageScrollPhysics(),
                scrollBehavior: const ScrollBehavior(
                    androidOverscrollIndicator:
                        AndroidOverscrollIndicator.glow),
                children: [
                  ..._getImagesCollection()
                      .map((imageData) => _particularImage(image: imageData))
                ],
              ),
      ),
    );
  }

  _particularImage({image}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover, image: _getPerfectImage(image))),
          ),
          _commonMessageLayout(
              textMsg: "Swipe Left to Preview More Wallpapers", top: 10),
          _commonMessageLayout(
              leftAligned: false,
              textMsg: "Set Common Wallpaper For Generation",
              top: 80),
          _setWallpaperButton()
        ],
      ),
    );
  }

  _getPerfectImage(image) {
    if (widget.imgPath != null
        ? widget.imgPath!.startsWith("https")
        : image.startsWith("https")) {
      return CachedNetworkImageProvider(image ?? widget.imgPath);
    } else {
      return FileImage(File(image ?? widget.imgPath));
    }
  }

  _getImagesCollection() {
    switch (widget.wallpaperType) {
      case WallpaperType.bright:
        return Provider.of<WallpaperProvider>(context)
            .getBrightImagesCollection();
      case WallpaperType.dark:
        return Provider.of<WallpaperProvider>(context)
            .getDarkImagesCollection();
      case WallpaperType.solidColor:
        return Provider.of<WallpaperProvider>(context)
            .getSolidImagesCollection();
      case WallpaperType.myPhotos:
        // TODO: Handle this case.
        break;
    }
  }

  _commonMessageLayout(
      {bool leftAligned = true, required String textMsg, double top = 0}) {
    return Container(
      margin: EdgeInsets.only(top: top),
      child: Align(
        alignment: leftAligned ? Alignment.topLeft : Alignment.topRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 45, minWidth: 100),
          child: Card(
            elevation: 0,
            shadowColor: AppColors.pureWhiteColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: leftAligned
                ? AppColors.oppositeMsgDarkModeColor
                : AppColors.myMsgDarkModeColor,
            child: Stack(
              children: [
                _textMessageSection(text: textMsg),
                _messageTimingAndStatus(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _textMessageSection({required String text}) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 15, top: 8, bottom: 28),
      child: Text(text,
          style:
              const TextStyle(fontSize: 14, color: AppColors.pureWhiteColor)),
    );
  }

  _messageTimingAndStatus() {
    return Positioned(
      bottom: 3,
      right: 10,
      child: Row(
        children: [
          Text(
            "12:00 AM",
            style: TextStyle(
                fontSize: 12, color: AppColors.pureWhiteColor.withOpacity(0.8)),
          ),
          const SizedBox(
            width: 5,
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 3),
            child: Icon(Icons.done_outlined,
                size: 20, color: AppColors.pureWhiteColor),
          )
        ],
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
              "Preview",
              style:
                  TextStyleCollection.terminalTextStyle.copyWith(fontSize: 16),
            ),
          ],
        ),
      );

  _setWallpaperButton() {
    return Container(
        alignment: Alignment.bottomCenter,
        margin: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton.extended(
            backgroundColor: AppColors.transparentColor,
            shape: const RoundedRectangleBorder(
                side: BorderSide(width: 1, color: AppColors.pureWhiteColor)),
            elevation: 3,
            onPressed: () {},
            label: Text(
              "SET WALLPAPER",
              style: TextStyleCollection.secondaryHeadingTextStyle
                  .copyWith(fontSize: 16),
            )));
  }
}
