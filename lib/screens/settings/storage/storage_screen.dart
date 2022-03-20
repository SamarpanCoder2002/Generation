import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/screens/settings/storage/storage_image_video_collection.dart';

class LocalStorageScreen extends StatefulWidget {
  const LocalStorageScreen({Key? key}) : super(key: key);

  @override
  State<LocalStorageScreen> createState() => _LocalStorageScreenState();
}

class _LocalStorageScreenState extends State<LocalStorageScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDarkMode,
        appBar: _appBarSection(),
        body: _tabBarViewCollection(),
      ),
    );
  }

  _appBarSection() => AppBar(
        titleSpacing: 0,
        backgroundColor: AppColors.backgroundDarkMode,
        automaticallyImplyLeading: false,
        toolbarHeight: 40,
        elevation: 0,
        title: _headerTitleSection(),
        bottom: _tabCollection(),
      );

  _headerTitleSection() {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      child: Row(
        children: [
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_outlined,
                size: 20,
              )),
          Text(
            "Storage",
            style: TextStyleCollection.terminalTextStyle.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }

  _tabCollection() {
    _tabDesign(String tabText) {
      return Tab(
        child: Text(
          tabText,
        ),
      );
    }

    return TabBar(
      indicatorPadding: const EdgeInsets.symmetric(horizontal: 5),
      labelColor: AppColors.pureWhiteColor,
      unselectedLabelColor: AppColors.pureWhiteColor.withOpacity(0.6),
      indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(width: 2.0, color: AppColors.normalBlueColor),
          insets: EdgeInsets.symmetric(horizontal: 5.0)),
      automaticIndicatorColorAdjustment: true,
      labelStyle:
          TextStyleCollection.secondaryHeadingTextStyle.copyWith(fontSize: 15),
      tabs: [
        _tabDesign("Image"),
        _tabDesign("Video"),
        _tabDesign("Audio"),
        _tabDesign("Document"),
      ],
    );
  }

  _tabBarViewCollection() => const TabBarView(children: [
        StorageImageAndVideoCollection(),
        StorageImageAndVideoCollection(
          showVideoPlayIcon: true,
        ),
        Center(
          child: Text(
            "Audio",
            style: TextStyleCollection.terminalTextStyle,
          ),
        ),
        Center(
          child: Text(
            "Document",
            style: TextStyleCollection.terminalTextStyle,
          ),
        ),
      ]);
}
