import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/images_path_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/screens/common/scroll_to_hide_widget.dart';
import 'package:provider/provider.dart';
import '../../config/text_collection.dart';
import '../../providers/messages_screen_controller.dart';
import '../../services/device_specific_operations.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  var activeSlideIndex = 0;

  @override
  void initState() {
    showStatusAndNavigationBar();
    makeStatusBarTransparent();
    changeOnlyNavigationBarColor(
        navigationBarColor: AppColors.backgroundDarkMode);

    Provider.of<MessageScreenScrollingProvider>(context, listen: false)
        .startListening();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundDarkMode,
        bottomSheet: _bottomSheet(),
        body: Container(
            margin: const EdgeInsets.only(top: 2, left: 20, right: 20),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: ListView(
              shrinkWrap: true,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                _headingSection(),
                const SizedBox(height: 15),
                _searchBar(),
                const SizedBox(height: 25),
                _activitiesSection(),
                const SizedBox(height: 20),
                _messagesSection(),
              ],
            )));
  }

  _headingSection() {
    return Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(left: 23),
        child: Text(
          AppText.appName,
          style: TextStyleCollection.headingTextStyle.copyWith(fontSize: 20),
        ));
  }

  _searchBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.searchBarBgDarkMode,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              Icons.search_outlined,
              color: AppColors.pureWhiteColor,
            ),
          ),
          Expanded(
            child: TextField(
              cursorColor: AppColors.pureWhiteColor,
              style: TextStyleCollection.searchTextStyle,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Search",
                hintStyle: TextStyleCollection.searchTextStyle
                    .copyWith(color: AppColors.pureWhiteColor.withOpacity(0.8)),
              ),
            ),
          )
        ],
      ),
    );
  }

  _activitiesSection() {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 5.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppText.activityHeading,
              style: TextStyleCollection.secondaryHeadingTextStyle,
            ),
          ),
          _horizontalActivitySection(),
        ],
      ),
    );
  }

  _horizontalActivitySection() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 40,
      height: 115,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (_, activityIndex) => Container(
          margin: const EdgeInsets.only(right: 15),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    color: AppColors.searchBarBgDarkMode.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                        color: AppColors.darkBorderGreenColor, width: 3),
                    image: const DecorationImage(
                        image: NetworkImage(
                            "https://media.self.com/photos/618eb45bc4880cebf08c1a5b/4:3/w_2560%2Cc_limit/1236337133"),
                        fit: BoxFit.cover)),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: const Text(
                  "Samarpan",
                  style: TextStyleCollection.activityTitleTextStyle,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _messagesSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            AppText.messagesHeading,
            style: TextStyleCollection.secondaryHeadingTextStyle,
          ),
        ),
        _messagesCollectionSection(),
      ],
    );
  }

  _messagesCollectionSection() {
    final ScrollController _messageScreenScrollController =
        Provider.of<MessageScreenScrollingProvider>(context)
            .getScrollController();

    final bool _isMainAppBarVisible =
        Provider.of<MessageScreenScrollingProvider>(context)
            .isMainAppBarVisible();

    return Container(
      width: double.maxFinite,
      height: _isMainAppBarVisible
          ? MediaQuery.of(context).size.height / 1.5
          : MediaQuery.of(context).size.height - 100,
      margin: const EdgeInsets.only(top: 20),
      child: ListView.builder(
        controller: _messageScreenScrollController,
        shrinkWrap: true,
        itemCount: 20,
        itemBuilder: (_, connectionIndex) =>
            _particularChatConnection(connectionIndex),
      ),
    );
  }

  _bottomSheet() {
    final ScrollController _messageScreenScrollController =
        Provider.of<MessageScreenScrollingProvider>(context)
            .getScrollController();

    return ScrollToHideWidget(
      scrollController: _messageScreenScrollController,
      child: Container(
        height: 60,
        color: AppColors.backgroundDarkMode,
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              color: AppColors.darkBorderGreenColor,
              icon: Image.asset(IconImages.messageImagePath,
                  height: 25, width: 25, color: AppColors.darkBorderGreenColor),
              onPressed: () {},
            ),
            IconButton(
              color: AppColors.darkInactiveIconColor,
              icon: Image.asset(IconImages.callImagePath,
                  height: 25,
                  width: 25,
                  color: AppColors.darkInactiveIconColor),
              onPressed: () {},
            ),
            IconButton(
              color: AppColors.darkInactiveIconColor,
              icon: Image.asset(IconImages.cameraImagePath,
                  height: 25,
                  width: 25,
                  color: AppColors.darkInactiveIconColor),
              onPressed: () {},
            ),
            IconButton(
              color: AppColors.darkInactiveIconColor,
              icon: Image.asset(IconImages.settingsImagePath,
                  height: 25,
                  width: 25,
                  color: AppColors.darkInactiveIconColor),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  _particularChatConnection(int connectionIndex) {
    return Container(
      height: 60,
      width: double.maxFinite,
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          _chatConnectionImage(connectionIndex),
          const SizedBox(
            width: 20,
          ),
          _chatConnectionData(connectionIndex),
          const SizedBox(
            width: 10,
          ),
          _chatConnectionInformationData(connectionIndex),
        ],
      ),
    );
  }

  _chatConnectionImage(int connectionIndex) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
          color: AppColors.searchBarBgDarkMode.withOpacity(0.5),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.darkBorderGreenColor, width: 3),
          image: const DecorationImage(
              image: NetworkImage(
                  "https://media.self.com/photos/618eb45bc4880cebf08c1a5b/4:3/w_2560%2Cc_limit/1236337133"),
              fit: BoxFit.cover)),
    );
  }

  _chatConnectionData(int connectionIndex) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Samarpan",
                style: TextStyleCollection.activityTitleTextStyle
                    .copyWith(fontSize: 16),
              )),
          Flexible(
              child: Text(
            "A Private, Secure, End-to-End Encrypted Messaging app made in Flutter(With Firebase and SQLite) that helps you to connect with your connections without any Ads, promotion. No other third-party person, organization, or even Generation Team can't read your messages.",
            style: TextStyleCollection.activityTitleTextStyle
                .copyWith(fontSize: 12, color: AppColors.pureWhiteColor.withOpacity(0.8)),
          )),
        ],
      ),
    );
  }

  _chatConnectionInformationData(int connectionIndex) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              connectionIndex == 1 ? "01/12/2021" : "26 July",
              style: TextStyleCollection.activityTitleTextStyle
                  .copyWith(fontSize: 14),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
                color: AppColors.darkBorderGreenColor,
                borderRadius: BorderRadius.circular(100)),
            child: const Center(
                child: Text(
              "5",
              style: TextStyleCollection.terminalTextStyle,
            )),
          ),
        ],
      ),
    );
  }
}
