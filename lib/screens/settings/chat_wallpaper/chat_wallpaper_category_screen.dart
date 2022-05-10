import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/db_operations/types.dart';
import 'package:generation/screens/settings/chat_wallpaper/chat_wallpaper_preview.dart';
import 'package:generation/services/input_system_services.dart';
import 'package:generation/types/types.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';
import '../../../providers/wallpaper/wallpaper_provider.dart';
import '../../../services/device_specific_operations.dart';

class ChatWallpaperScreen extends StatefulWidget {
  const ChatWallpaperScreen({Key? key}) : super(key: key);

  @override
  State<ChatWallpaperScreen> createState() => _ChatWallpaperScreenState();
}

class _ChatWallpaperScreenState extends State<ChatWallpaperScreen> {
  final DBOperations _dbOperations = DBOperations();
  bool _isLoading = true;

  _initialize()async{
    final _wallpaperCollection = await _dbOperations.getWallpaperData();
    for (final wallpaperCategory in _wallpaperCollection.docs) {
      if(wallpaperCategory.id == DBPath.brightWallPaper){
        Provider.of<WallpaperProvider>(context, listen: false).setBrightImagesCollection(wallpaperCategory.data()[DBPath.wallpaperPictureCollection]);
      }else if(wallpaperCategory.id == DBPath.darkWallPaper){
        Provider.of<WallpaperProvider>(context, listen: false).setDarkImagesCollection(wallpaperCategory.data()[DBPath.wallpaperPictureCollection]);
      }else if(wallpaperCategory.id == DBPath.solidColorWallpaper){
        Provider.of<WallpaperProvider>(context, listen: false).setSolidImagesCollection(wallpaperCategory.data()[DBPath.wallpaperPictureCollection]);
      }
    }

    if(mounted){
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _initialize();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Scaffold(
      backgroundColor: AppColors.getBgColor(_isDarkMode),
      appBar: _headerSection(),
      body: _isLoading?const Center():Container(
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
                                    .copyWith(fontSize: 16, color: _isDarkMode
                                ? AppColors.pureWhiteColor
                                    : AppColors.lightChatConnectionTextColor,),
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

  _headerSection(){
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.getBgColor(_isDarkMode),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon:Icon(Icons.arrow_back_outlined, color: _isDarkMode
              ? AppColors.pureWhiteColor
                  : AppColors.lightChatConnectionTextColor,)),
          Text(
            "Wallpaper Management",
            style:
            TextStyleCollection.terminalTextStyle.copyWith(fontSize: 16,color: _isDarkMode?AppColors.pureWhiteColor:AppColors.lightChatConnectionTextColor),
          ),
        ],
      ),
    );
  }

  _imageCategoryTapAction(wallpaperData) async {
    final _isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();

    changeOnlyContextChatColor(_isDarkMode);


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
                  imgPath: _singleImagePath))).then((value){
        print("nOw");
        changeContextTheme(_isDarkMode);
      });
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(

              builder: (_) =>
                  ChatWallpaperPreview(wallpaperType: wallpaperData["type"]))).then((value){
                    print("nOw");
        changeContextTheme(_isDarkMode);
      });
    }
  }
}
