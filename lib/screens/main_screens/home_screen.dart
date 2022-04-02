import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/icon_collection.dart';
import 'package:generation/providers/theme_provider.dart';
import 'package:generation/screens/activity/create/make_poll.dart';
import 'package:generation/screens/activity/view/activity_controller_screen.dart';
import 'package:generation/screens/chat_screens/chat_screen.dart';
import 'package:generation/screens/common/chat_connections_common_design.dart';
import 'package:generation/services/input_system_services.dart';
import 'package:generation/services/navigation_management.dart';
import 'package:generation/types/types.dart';
import 'package:provider/provider.dart';

import '../../config/text_collection.dart';
import '../../config/text_style_collection.dart';
import '../../providers/connection_collection_provider.dart';
import '../../providers/main_scrolling_provider.dart';
import '../../providers/status_collection_provider.dart';
import '../../services/device_specific_operations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late InputOption _inputOption;

  @override
  void initState() {
    Provider.of<ConnectionCollectionProvider>(context, listen: false)
        .initialize();
    Provider.of<MainScrollingProvider>(context, listen: false).startListening();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _inputOption = InputOption(context);
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Scaffold(
      backgroundColor: AppColors.getBgColor(_isDarkMode),
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
          )),
    );
  }

  _headingSection() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(left: 23),
        child: Text(
          AppText.appName,
          style: TextStyleCollection.headingTextStyle.copyWith(
              fontSize: 20,
              color: _isDarkMode
                  ? AppColors.pureWhiteColor
                  : AppColors.lightTextColor),
        ));
  }

  _searchBar() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: _isDarkMode
            ? AppColors.searchBarBgDarkMode
            : AppColors.searchBarBgLightMode,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(
              Icons.search_outlined,
              color: _isDarkMode
                  ? AppColors.pureWhiteColor
                  : AppColors.lightTextColor.withOpacity(0.8),
            ),
          ),
          Expanded(
            child: TextField(
              cursorColor: AppColors.pureWhiteColor,
              style: TextStyleCollection.searchTextStyle,
              onChanged: (inputVal) =>
                  Provider.of<ConnectionCollectionProvider>(context,
                          listen: false)
                      .operateOnSearch(inputVal),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Search",
                hintStyle: TextStyleCollection.searchTextStyle.copyWith(
                    color: _isDarkMode
                        ? AppColors.pureWhiteColor.withOpacity(0.8)
                        : AppColors.lightTextColor.withOpacity(0.8)),
              ),
            ),
          )
        ],
      ),
    );
  }

  _activitiesSection() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return SizedBox(
      height: MediaQuery.of(context).size.height / 5.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppText.activityHeading,
              style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
                  color: _isDarkMode
                      ? AppColors.pureWhiteColor
                      : AppColors.lightTextColor),
            ),
          ),
          _horizontalActivitySection()
        ],
      ),
    );
  }

  _horizontalActivitySection() {
    final _activityHolderCollection =
        Provider.of<StatusCollectionProvider>(context).getData();

    return SizedBox(
      width: MediaQuery.of(context).size.width - 40,
      height: 115,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: [
          _myActivity(),
          ..._activityHolderCollection.map((activityHolder) =>
              _activityParticularData(
                  _activityHolderCollection.indexOf(activityHolder))),
        ],
        // itemCount:
        //     Provider.of<StatusCollectionProvider>(context).getDataLength(),
        // itemBuilder: (_, index) => _activityParticularData(index),
      ),
    );
  }

  _activityParticularData(int index) {
    final _currentActivityData =
        Provider.of<StatusCollectionProvider>(context).getData()[index];

    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return OpenContainer(
      closedElevation: 0.0,
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 500),
      closedColor: AppColors.getBgColor(_isDarkMode),
      middleColor: AppColors.getBgColor(_isDarkMode),
      openColor: AppColors.getBgColor(_isDarkMode),
      onClosed: (_) => changeOnlyNavigationBarColor(
          navigationBarColor: AppColors.getBgColor(_isDarkMode)),
      openBuilder: (_, __) => const ActivityController(),
      closedBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _isDarkMode
                    ? AppColors.searchBarBgDarkMode.withOpacity(0.5)
                    : AppColors.searchBarBgLightMode.withOpacity(0.5),
                borderRadius: BorderRadius.circular(100),
                image: DecorationImage(
                    image: NetworkImage(_currentActivityData["profilePic"]),
                    fit: BoxFit.cover),
                border: Border.all(
                    color: _currentActivityData["isActive"]
                        ? _isDarkMode
                            ? AppColors.darkBorderGreenColor
                            : AppColors.lightBorderGreenColor
                        : AppColors.imageDarkBgColor,
                    width: 3),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: Text(
                _currentActivityData["connectionName"],
                overflow: TextOverflow.ellipsis,
                style: TextStyleCollection.activityTitleTextStyle.copyWith(
                    color: _isDarkMode
                        ? AppColors.pureWhiteColor
                        : AppColors.lightActivityTextColor),
              ),
            )
          ],
        ),
      ),
    );
  }

  _messagesSection() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            AppText.messagesHeading,
            style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
                color: _isDarkMode
                    ? AppColors.pureWhiteColor
                    : AppColors.lightTextColor),
          ),
        ),
        _messagesCollectionSection(),
      ],
    );
  }

  _messagesCollectionSection() {
    if (Provider.of<ConnectionCollectionProvider>(context).getDataLength() ==
        0) {
      return Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height / 1.8,
          alignment: Alignment.center,
          child: Text(
            "No Connection Found",
            style: TextStyleCollection.secondaryHeadingTextStyle
                .copyWith(fontSize: 16),
          ));
    }

    final ScrollController _messageScreenScrollController =
        Provider.of<MainScrollingProvider>(context).getScrollController();

    final _commonChatLayout = CommonChatListLayout(context: context);

    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height / 1.8,
      margin: const EdgeInsets.only(top: 20),
      child: ListView.builder(
          controller: _messageScreenScrollController,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: Provider.of<ConnectionCollectionProvider>(context)
              .getDataLength(),
          itemBuilder: (_, connectionIndex) {
            final _connectionData =
                Provider.of<ConnectionCollectionProvider>(context)
                    .getData()[connectionIndex];

            return OpenContainer(
                closedElevation: 0.0,
                transitionType: ContainerTransitionType.fadeThrough,
                transitionDuration: const Duration(milliseconds: 500),
                closedColor: AppColors.getBgColor(_isDarkMode),
                middleColor: AppColors.getBgColor(_isDarkMode),
                openColor: AppColors.getBgColor(_isDarkMode),
                onClosed: (_) => changeContextTheme(_isDarkMode),
                openBuilder: (_, __) => ChatScreen(
                      connectionData: _connectionData,
                    ),
                closedBuilder: (_, __) =>
                    _commonChatLayout.particularChatConnection(
                        photo: _connectionData["profilePic"],
                        heading: _connectionData["connectionName"],
                        subheading: _connectionData["latestMessage"]["message"],
                        lastMsgTime: _connectionData["latestMessage"]["time"],
                        currentIndex: connectionIndex,
                        totalPendingMessages:
                            _connectionData["notSeenMsgCount"].toString()));
          }),
    );
  }

  _myActivity() {
    final _currentActivityData =
        Provider.of<StatusCollectionProvider>(context).getData()[3];

    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    _addActivityIcon() {
      return InkWell(
        onTap: () {
          // Navigation.intent(context, const CreateActivity());
          _showActivityCategoryOptions();
        },
        child: Container(
          width: 25,
          height: 25,
          child: const Icon(
            Icons.add_outlined,
            color: AppColors.pureWhiteColor,
          ),
          decoration: BoxDecoration(
              color: _isDarkMode
                  ? AppColors.darkBorderGreenColor
                  : AppColors.lightBorderGreenColor,
              borderRadius: BorderRadius.circular(100)),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          OpenContainer(
            closedElevation: 0.0,
            transitionType: ContainerTransitionType.fadeThrough,
            transitionDuration: const Duration(milliseconds: 500),
            closedColor: AppColors.getBgColor(_isDarkMode),
            middleColor: AppColors.getBgColor(_isDarkMode),
            openColor: AppColors.getBgColor(_isDarkMode),
            onClosed: (_) => changeOnlyNavigationBarColor(
                navigationBarColor: AppColors.getBgColor(_isDarkMode)),
            openBuilder: (_, __) => const ActivityController(),
            closedBuilder: (_, __) => Container(
                width: 80,
                height: 80,
                alignment: Alignment.bottomRight,
                decoration: BoxDecoration(
                    color: _isDarkMode
                        ? AppColors.searchBarBgDarkMode.withOpacity(0.5)
                        : AppColors.searchBarBgLightMode.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                        color: _currentActivityData["isActive"]
                            ? _isDarkMode
                                ? AppColors.darkBorderGreenColor
                                : AppColors.lightBorderGreenColor
                            : AppColors.imageDarkBgColor,
                        width: 3),
                    image: DecorationImage(
                        image: NetworkImage(_currentActivityData["profilePic"]),
                        fit: BoxFit.cover)),
                child: _addActivityIcon()),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: Text(
              "Daefon",
              overflow: TextOverflow.ellipsis,
              style: TextStyleCollection.activityTitleTextStyle.copyWith(
                  color: _isDarkMode
                      ? AppColors.pureWhiteColor
                      : AppColors.lightActivityTextColor),
            ),
          )
        ],
      ),
    );
  }

  _showActivityCategoryOptions() {
    final _isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();

    showModalBottomSheet(
        context: context,
        builder: (_) => Container(
            height: 300,
            color: _isDarkMode
                ? AppColors.oppositeMsgDarkModeColor
                : AppColors.chatLightBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 6,
              children: List.generate(
                  ActivityIconCollection.iconsCollection.length,
                  (index) => _particularOption(index)),
            )));
  }

  _particularOption(index) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return InkWell(
      onTap: () async {
        if (index == 0) {
          _inputOption.commonCreateActivityNavigation(ActivityContentType.text,
              data: {});
        } else if (index == 1) {
          _inputOption.activityImageFromCamera();
        } else if (index == 2) {
          _inputOption.activityImageFromGallery();
        } else if (index == 3) {
          _inputOption.makeVideoActivity();
        } else if (index == 4) {
          _inputOption.makeAudioActivity();
        } else if (index == 5) {
          Navigation.intent(context, const PollCreatorScreen());
        } else if (index == 6) {
          //await _inputOption.getContacts();
        }
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: ActivityIconCollection.iconsCollection[index][2]),
            child: ActivityIconCollection.iconsCollection[index][0],
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              ActivityIconCollection.iconsCollection[index][1],
              style: TextStyleCollection.terminalTextStyle.copyWith(
                  fontSize: 14,
                  color: _isDarkMode
                      ? AppColors.pureWhiteColor
                      : AppColors.lightChatConnectionTextColor),
            ),
          )
        ],
      ),
    );
  }
}
