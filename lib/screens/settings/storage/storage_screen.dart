import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/screens/settings/storage/storage_audio_document_collection.dart';
import 'package:generation/screens/settings/storage/storage_image_video_collection.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';

class LocalStorageScreen extends StatefulWidget {
  const LocalStorageScreen({Key? key}) : super(key: key);

  @override
  State<LocalStorageScreen> createState() => _LocalStorageScreenState();
}

class _LocalStorageScreenState extends State<LocalStorageScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_tabController?.index != 0) {
          _tabController?.index = 0;
          return false;
        }

        return true;
      },
      child: DefaultTabController(
        length: 4,
        initialIndex: 0,
        child: Scaffold(
          backgroundColor: AppColors.backgroundDarkMode,
          appBar: _appBarSection(),
          body: _tabBarViewCollection(),
        ),
      ),
    );
  }

  _appBarSection() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return AppBar(
      titleSpacing: 0,
      backgroundColor: AppColors.getBgColor(_isDarkMode),
      automaticallyImplyLeading: false,
      toolbarHeight: 40,
      elevation: 0,
      title: _headerTitleSection(),
      bottom: _tabCollection(),
    );
  }

  _headerTitleSection() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
      margin: const EdgeInsets.only(left: 10),
      child: Row(
        children: [
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_outlined,
                  size: 20,
                  color: _isDarkMode
                      ? AppColors.pureWhiteColor
                      : AppColors.lightChatConnectionTextColor)),
          Text(
            "Storage",
            style: TextStyleCollection.terminalTextStyle.copyWith(
                fontSize: 16,
                color: _isDarkMode
                    ? AppColors.pureWhiteColor
                    : AppColors.lightChatConnectionTextColor),
          ),
        ],
      ),
    );
  }

  _tabCollection() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    _tabDesign(String tabText) {
      return Tab(
        child: Text(
          tabText,
          style: TextStyleCollection.terminalTextStyle.copyWith(
              fontSize: 12,
              color: _isDarkMode
                  ? AppColors.pureWhiteColor
                  : AppColors.lightChatConnectionTextColor),
        ),
      );
    }

    return TabBar(
      controller: _tabController,
      indicatorPadding: const EdgeInsets.symmetric(horizontal: 5),
      labelColor: AppColors.pureWhiteColor,
      unselectedLabelColor: AppColors.pureWhiteColor.withOpacity(0.6),
      indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(width: 2.0, color: AppColors.normalBlueColor),
          insets: EdgeInsets.symmetric(horizontal: 5.0)),
      automaticIndicatorColorAdjustment: true,
      labelStyle:
          TextStyleCollection.secondaryHeadingTextStyle.copyWith(fontSize: 12),
      tabs: [
        _tabDesign("Image"),
        _tabDesign("Video"),
        _tabDesign("Audio"),
        _tabDesign("Document"),
      ],
    );
  }

  _tabBarViewCollection() =>
      TabBarView(controller: _tabController, children: const [
        StorageImageAndVideoCollection(),
        StorageImageAndVideoCollection(
          showVideoPlayIcon: true,
        ),
        StorageAudioAndDocumentCollectionScreen(),
        StorageAudioAndDocumentCollectionScreen(isAudio: false),
      ]);
}
