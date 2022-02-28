import 'package:flutter/material.dart';
import 'package:generation/providers/all_available_connections_provider.dart';
import 'package:generation/providers/connection_management_provider.dart';
import 'package:provider/provider.dart';

import '../../../config/colors_collection.dart';
import '../../../config/text_collection.dart';
import '../../../config/text_style_collection.dart';
import '../../../providers/messages_screen_controller.dart';
import '../../common/chat_connections_common_design.dart';

class ConnectionManagementScreen extends StatefulWidget {
  const ConnectionManagementScreen({Key? key}) : super(key: key);

  @override
  _ConnectionManagementScreenState createState() =>
      _ConnectionManagementScreenState();
}

class _ConnectionManagementScreenState
    extends State<ConnectionManagementScreen> {
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
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _headingSection(),
              const SizedBox(height: 15),
              _screenHeading(),
              const SizedBox(height: 15),
              _tabCollection(),
              _tabSelectionCollection(),
              const SizedBox(height: 15),
              _searchBar(),
              const SizedBox(height: 15),
              _collectionsSection(),
            ],
          ),
        ),
      ),
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

  _screenHeading() {
    return Align(
      alignment: Alignment.topCenter,
      child: Text(
        "Connection Management",
        style: TextStyleCollection.secondaryHeadingTextStyle
            .copyWith(fontSize: 16),
      ),
    );
  }

  _tabCollection() {
    final double _width = MediaQuery.of(context).size.width - 40;

    final _currentIndex =
        Provider.of<ConnectionManagementProvider>(context).getCurrentIndex();

    _particularSection(int correspondingIndex, String sectionText) {
      return GestureDetector(
        onTap: () {
          Provider.of<ConnectionManagementProvider>(context, listen: false)
              .setUpdatedIndex(correspondingIndex);
        },
        child: SizedBox(
          width: _width / 3,
          child: Text(
            sectionText,
            style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
                color: _currentIndex == correspondingIndex
                    ? AppColors.normalBlueColor
                    : AppColors.pureWhiteColor),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SizedBox(
      width: _width,
      child: Row(
        children: [
          _particularSection(0, "Available Connections"),
          _particularSection(1, "Request"),
          _particularSection(2, "Send"),
        ],
      ),
    );
  }

  _tabSelectionCollection() {
    final double _width = MediaQuery.of(context).size.width - 40;

    final _currentIndex =
        Provider.of<ConnectionManagementProvider>(context).getCurrentIndex();

    _particularUnderlineSection(int particularIndex) {
      return GestureDetector(
        onTap: () {
          Provider.of<ConnectionManagementProvider>(context, listen: false)
              .setUpdatedIndex(particularIndex);
        },
        child: Container(
          width: _width / 3,
          height: 4,
          decoration: BoxDecoration(
              color: _currentIndex == particularIndex
                  ? AppColors.normalBlueColor
                  : AppColors.transparentColor,
              borderRadius: BorderRadius.circular(100)),
        ),
      );
    }

    return Container(
      width: _width,
      margin: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          _particularUnderlineSection(0),
          _particularUnderlineSection(1),
          _particularUnderlineSection(2),
        ],
      ),
    );
  }

  _searchBar() {
    return Container(
      height: 45,
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

  _collectionsSection() {
    final _commonChatLayout = CommonChatListLayout(context: context);

    final ScrollController _scrollController =
        Provider.of<MessageScreenScrollingProvider>(context)
            .getScrollController();

    return SizedBox(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height / 1.4,
      child: ListView.builder(
        shrinkWrap: true,
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        itemCount: Provider.of<AllAvailableConnectionsProvider>(context)
            .getConnectionsLength(),
        itemBuilder: (_, availableIndex) {
          final _particularData =
              Provider.of<AllAvailableConnectionsProvider>(context)
                  .getConnections()[availableIndex];

          return _commonChatLayout.particularChatConnection(
              currentIndex: availableIndex,
              photo: _particularData["photo"],
              heading: _particularData["name"],
              subheading: _particularData["description"],
              lastMsgTime: null,
              totalPendingMessages: null);
        },
      ),
    );
  }
}
