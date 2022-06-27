import 'dart:async';

import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/icon_collection.dart';
import 'package:generation/providers/theme_provider.dart';
import 'package:generation/screens/activity/create/make_poll.dart';
import 'package:generation/screens/activity/view/activity_controller_screen.dart';
import 'package:generation/screens/chat_screens/chat_screen.dart';
import 'package:generation/screens/chat_screens/connection_profile_screen.dart';
import 'package:generation/screens/common/button.dart';
import 'package:generation/screens/common/chat_connections_common_design.dart';
import 'package:generation/services/encryption_operations.dart';
import 'package:generation/services/input_system_services.dart';
import 'package:generation/services/local_data_management.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:generation/services/navigation_management.dart';
import 'package:generation/config/types.dart';
import 'package:provider/provider.dart';

import '../../config/text_collection.dart';
import '../../config/text_style_collection.dart';
import '../../providers/activity/activity_screen_provider.dart';
import '../../providers/connection_collection_provider.dart';
import '../../providers/main_screen_provider.dart';
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
    Provider.of<StatusCollectionProvider>(context, listen: false).initialize();
    Provider.of<ConnectionCollectionProvider>(context, listen: false)
        .initialize(context: context);
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
              const SizedBox(height: 10),
              _messagesSection(),
              const SizedBox(height: 15),
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
              cursorColor: _isDarkMode
                  ? AppColors.pureWhiteColor
                  : AppColors.lightTextColor.withOpacity(0.8),
              style: TextStyleCollection.searchTextStyle.copyWith(
                  color: _isDarkMode
                      ? AppColors.pureWhiteColor
                      : AppColors.lightTextColor.withOpacity(0.8)),
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
    final _currentActivityData =
        Provider.of<StatusCollectionProvider>(context).getCurrentAccData();

    if (_currentActivityData.isEmpty) {
      return const Center();
    }

    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return SizedBox(
      height: 150,
      child: SingleChildScrollView(
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
            const SizedBox(
              height: 10,
            ),
            _horizontalActivitySection()
          ],
        ),
      ),
    );
  }

  _horizontalActivitySection() {
    final _activityHolderCollection =
        Provider.of<ConnectionCollectionProvider>(context)
            .getActivityConnectionData();

    return SizedBox(
      width: MediaQuery.of(context).size.width - 40,
      height: 140,
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
    final _connId = Provider.of<ConnectionCollectionProvider>(context)
        .getActivityConnectionData()[index];
    final _currentActivityData =
        Provider.of<ConnectionCollectionProvider>(context).getUsersMap(_connId);

    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
    final _connName = Secure.decode(_currentActivityData["name"]);

    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () => _switchToActivity(
            tableName: DataManagement.generateTableNameForNewConnectionActivity(
                _connId),
            isDarkMode: _isDarkMode,
            connId: _connId),
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
                    image: NetworkImage(
                        Secure.decode(_currentActivityData["profilePic"])),
                    fit: BoxFit.cover),
                border: Border.all(
                    color: _isDarkMode
                        ? AppColors.darkBorderGreenColor
                        : AppColors.lightBorderGreenColor,
                    width: 3),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: Text(
                _connName.length > 8
                    ? '${_connName.substring(0, 9)}...'
                    : _connName,
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
    if (Provider.of<ConnectionCollectionProvider>(context)
            .getConnectionsDataLength ==
        0) {
      return _noConnectionSection();
    }

    if (Provider.of<ConnectionCollectionProvider>(context).getDataLength() ==
        0) {
      return _noConnectionSection(navigateButton: false);
    }

    final ScrollController _messageScreenScrollController =
        Provider.of<MainScrollingProvider>(context).getScrollController();

    final _commonChatLayout = CommonChatListLayout(context: context);
    final _totalMessages =
        Provider.of<ConnectionCollectionProvider>(context).getDataLength();

    return Container(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height / 1.8,
      margin: const EdgeInsets.only(top: 20),
      child: ListView.builder(
          controller: _messageScreenScrollController,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: _totalMessages,
          itemBuilder: (_, connectionIndex) {
            final _rawData = Provider.of<ConnectionCollectionProvider>(context)
                .getData()[connectionIndex];

            final _connectionData =
                Provider.of<ConnectionCollectionProvider>(context)
                    .getUsersMap(_rawData["id"]);

            final _lastMsgData = _connectionData["chatLastMsg"] == null
                ? null
                : DataManagement.fromJsonString(_connectionData["chatLastMsg"]);

            return InkWell(
                onTap: () => _onChatClicked(_connectionData),
                onLongPress: () =>
                    _onChatLongPressed(_connectionData, connectionIndex),
                child: _commonChatLayout.particularChatConnection(
                    photo: Secure.decode(_connectionData["profilePic"]),
                    heading: Secure.decode(_connectionData["name"]),
                    subheading: _getSubHeading(
                        _lastMsgData,
                        Secure.decode(_connectionData["name"])
                            .toString()
                            .split(' ')
                            .first),
                    lastMsgTime: Secure.decode(_lastMsgData?["time"]),
                    currentIndex: connectionIndex,
                    totalPendingMessages: _connectionData["notSeenMsgCount"],
                    bottomMargin:
                        connectionIndex == _totalMessages - 1 ? 40 : null));
          }),
    );
  }

  _noConnectionSection({bool navigateButton = true}) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height / 1.8,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!navigateButton)
              Text(
                "No Connection Found",
                style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
                    fontSize: 16,
                    color: AppColors.getModalTextColor(_isDarkMode)),
              ),
            if (navigateButton)
              commonElevatedButton(
                  btnText: "Let's Connect",
                  bgColor: AppColors.getTextButtonColor(_isDarkMode, true),
                  onPressed: () => Provider.of<MainScreenNavigationProvider>(
                          context,
                          listen: false)
                      .setUpdatedIndex(1)),
            const SizedBox(height: 40,),
          ],
        ));
  }

  _onChatClicked(_connectionData) {
    final _isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();

    Provider.of<ConnectionCollectionProvider>(context, listen: false)
        .pauseParticularConnSubscription(_connectionData["id"]);

    _afterChatClosed() {
      changeContextTheme(_isDarkMode);
      Provider.of<ConnectionCollectionProvider>(context, listen: false)
          .getAndInsertLastMessage(_connectionData["id"]);
      Provider.of<ConnectionCollectionProvider>(context, listen: false)
          .resumeParticularConnSubscription(_connectionData["id"]);
    }

    Navigation.intent(
        context,
        ChatScreen(
          connectionData: _connectionData,
        ),
        afterWork: _afterChatClosed);
  }

  _myActivity() {
    final _currentActivityData =
        Provider.of<StatusCollectionProvider>(context).getCurrentAccData();
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();
    final _connName = Secure.decode(_currentActivityData["name"]);

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
      child: InkWell(
        onTap: () => _switchToActivity(
            tableName: DbData.myActivityTable,
            isDarkMode: _isDarkMode,
            connId: _currentActivityData['id']),
        child: Column(
          children: [
            Container(
                width: 80,
                height: 80,
                alignment: Alignment.bottomRight,
                decoration: BoxDecoration(
                    color: _isDarkMode
                        ? AppColors.searchBarBgDarkMode.withOpacity(0.5)
                        : AppColors.searchBarBgLightMode.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                        color: _isDarkMode
                            ? AppColors.darkBorderGreenColor
                            : AppColors.lightBorderGreenColor,
                        width: 3),
                    image: DecorationImage(
                        image: NetworkImage(
                            Secure.decode(_currentActivityData["profilePic"])),
                        fit: BoxFit.cover)),
                child: _addActivityIcon()),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: Text(
                _connName.length > 8
                    ? '${_connName.substring(0, 9)}...'
                    : _connName,
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

  _showActivityCategoryOptions() {
    final _isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();

    showModalBottomSheet(
        context: context,
        builder: (_) => Container(
            height: 300,
            color: AppColors.getModalColor(_isDarkMode),
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
          _inputOption.makeVideoActivity(_isDarkMode);
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
                  color: AppColors.getModalTextColor(_isDarkMode)),
            ),
          )
        ],
      ),
    );
  }

  _onChatLongPressed(_connectionData, connectionIndex) {
    final _isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();

    showModalBottomSheet(
        context: context,
        builder: (_) => Container(
            height: 130,
            color: AppColors.getModalColor(_isDarkMode),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 6,
              children: List.generate(
                  ConnectionActionOptions.iconsCollection.length,
                  (index) => _particularConnectionOption(
                      index, _connectionData, connectionIndex)),
            )));
  }

  _particularConnectionOption(index, _connectionData, connectionIndex) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return InkWell(
      onTap: () async {
        // if (index == 0) {
        //   _inputOption.removeConnectedUser(
        //       _connectionData["id"], _isDarkMode, connectionIndex);
        // } else
        //
        if (index == 0) {
          _inputOption.clearChatData(_connectionData, _isDarkMode);
        } else if (index == 1) {
          Navigation.intent(
              context, ConnectionProfileScreen(connData: _connectionData));
        }
      },
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: ConnectionActionOptions.iconsCollection[index][2]),
            child: ConnectionActionOptions.iconsCollection[index][0],
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              ConnectionActionOptions.iconsCollection[index][1],
              textAlign: TextAlign.center,
              style: TextStyleCollection.terminalTextStyle.copyWith(
                  color: AppColors.getModalTextColor(_isDarkMode),
                  letterSpacing: 1.0),
            ),
          )
        ],
      ),
    );
  }

  String _getSubHeading(_lastMsgData, String connFirstName) {
    final _msgData = Secure.decode(_lastMsgData?["message"]);
    var _msgHolder = Secure.decode(_lastMsgData?['holder']);
    _msgHolder =
        _msgHolder == MessageHolderType.other.toString() ? connFirstName : 'Me';

    if (_msgData == '') return '';

    if (Secure.decode(_lastMsgData["type"]) ==
        ChatMessageType.image.toString()) {
      return '$_msgHolder:  📷 Image';
    }
    if (Secure.decode(_lastMsgData["type"]) ==
        ChatMessageType.video.toString()) {
      return '$_msgHolder:  📽️ Video';
    }
    if (Secure.decode(_lastMsgData["type"]) ==
        ChatMessageType.location.toString()) {
      return '$_msgHolder:  🗺️ Location';
    }
    if (Secure.decode(_lastMsgData["type"]) ==
        ChatMessageType.audio.toString()) {
      return '$_msgHolder:  🎵 Audio';
    }
    if (Secure.decode(_lastMsgData["type"]) ==
        ChatMessageType.document.toString()) {
      return '$_msgHolder:  📃 Document';
    }
    if (Secure.decode(_lastMsgData["type"]) ==
        ChatMessageType.contact.toString()) {
      return '$_msgHolder:  💁 Contact';
    }

    return '$_msgHolder:  $_msgData';
  }

  _switchToActivity(
      {required String tableName,
      required bool isDarkMode,
      required String connId}) async {
    final LocalStorage _localStorage = LocalStorage();

    final _activityData =
        await _localStorage.getAllActivity(tableName: tableName);
    Provider.of<ActivityProvider>(context, listen: false)
        .setActivityCollection(_activityData);

    final _visitedData =
        await _localStorage.getAllSeenUnseenActivity(tableName: tableName);

    Provider.of<ActivityProvider>(context, listen: false).startFrom(
        _visitedData.length == _activityData.length ? 0 : _visitedData.length);

    Timer(const Duration(milliseconds: 500), () {
      Navigation.intent(
          context,
          ActivityController(
            tableName: tableName,
            startingIndex: _visitedData.length == _activityData.length
                ? 0
                : _visitedData.length,
            activityHolderId: connId,
          ),
          afterWork: () => changeContextTheme(isDarkMode));
    });
  }
}
