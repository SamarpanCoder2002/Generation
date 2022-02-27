import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:provider/provider.dart';

import '../../config/text_collection.dart';
import '../../config/text_style_collection.dart';
import '../../providers/connection_collection_provider.dart';
import '../../providers/messages_screen_controller.dart';
import '../../providers/status_collection_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    Provider.of<MessageScreenScrollingProvider>(context, listen: false)
        .startListening();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkMode,
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
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: [
          ..._activityDataCollection(),
        ],
      ),
    );
  }

  _activityDataCollection() {
    final _activityData =
        Provider.of<StatusCollectionProvider>(context).getData();

    return _activityData.map((_currentActivityData) {
      return Container(
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
                      color: _currentActivityData["isActive"]
                          ? AppColors.darkBorderGreenColor
                          : AppColors.imageDarkBgColor,
                      width: 3),
                  image: DecorationImage(
                      image: NetworkImage(_currentActivityData["profilePic"]),
                      fit: BoxFit.cover)),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: Text(
                _currentActivityData["connectionName"],
                style: TextStyleCollection.activityTitleTextStyle,
              ),
            )
          ],
        ),
      );
    });
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

    return Container(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height / 1.8,
      margin: const EdgeInsets.only(top: 20),
      child: ListView.builder(
        controller: _messageScreenScrollController,
        shrinkWrap: true,
        itemCount:
            Provider.of<ConnectionCollectionProvider>(context).getDataLength(),
        itemBuilder: (_, connectionIndex) =>
            _particularChatConnection(connectionIndex),
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
            width: 15,
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
    final _connectionData = Provider.of<ConnectionCollectionProvider>(context)
        .getData()[connectionIndex];

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
          color: AppColors.searchBarBgDarkMode.withOpacity(0.5),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.darkBorderGreenColor, width: 3),
          image: DecorationImage(
              image: NetworkImage(_connectionData["profilePic"]),
              fit: BoxFit.cover)),
    );
  }

  _chatConnectionData(int connectionIndex) {
    final _connectionData = Provider.of<ConnectionCollectionProvider>(context)
        .getData()[connectionIndex];

    return SizedBox(
      width: MediaQuery.of(context).size.width - 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _connectionData["connectionName"],
                style: TextStyleCollection.activityTitleTextStyle
                    .copyWith(fontSize: 16),
              )),
          if (_connectionData["latestMessage"] != null &&
              _connectionData["latestMessage"].isNotEmpty)
            Flexible(
                child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _connectionData["latestMessage"]["message"],
                style: TextStyleCollection.activityTitleTextStyle.copyWith(
                    fontSize: 12,
                    color: AppColors.pureWhiteColor.withOpacity(0.8)),
              ),
            )),
        ],
      ),
    );
  }

  _chatConnectionInformationData(int connectionIndex) {
    final _connectionData = Provider.of<ConnectionCollectionProvider>(context)
        .getData()[connectionIndex];

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              _connectionData["lastMessageDate"],
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
            child: Center(
                child: Text(
              "${_connectionData["notSeenMsgCount"]}",
              style: TextStyleCollection.terminalTextStyle,
            )),
          ),
        ],
      ),
    );
  }
}
