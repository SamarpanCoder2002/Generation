import 'package:flutter/material.dart';
import 'package:generation/providers/connection_management_provider_collection/all_available_connections_provider.dart';
import 'package:generation/providers/connection_management_provider.dart';
import 'package:generation/providers/connection_management_provider_collection/incoming_request_provider.dart';
import 'package:generation/providers/connection_management_provider_collection/sent_request_provider.dart';
import 'package:provider/provider.dart';

import '../../../config/colors_collection.dart';
import '../../../config/text_collection.dart';
import '../../../config/text_style_collection.dart';
import '../../../providers/main_scrolling_provider.dart';
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
    Provider.of<AllAvailableConnectionsProvider>(context, listen: false)
        .initialize();
    Provider.of<RequestConnectionsProvider>(context, listen: false)
        .initialize();
    Provider.of<SentConnectionsProvider>(context, listen: false).initialize();
    Provider.of<MainScrollingProvider>(context, listen: false).startListening();
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
    final List<String> _tabsCollection =
        Provider.of<ConnectionManagementProvider>(context).getTabsCollection();

    _particularSection(int correspondingIndex, String sectionText) {
      return GestureDetector(
        onTap: () {
          Provider.of<ConnectionManagementProvider>(context, listen: false)
              .setUpdatedIndex(correspondingIndex, context, movePageView: true);
        },
        child: SizedBox(
          width: _width /
              Provider.of<ConnectionManagementProvider>(context)
                  .getTabsCollectionLength(),
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
          ..._tabsCollection.map((particularTab) => _particularSection(
              _tabsCollection.indexOf(particularTab), particularTab)),
        ],
      ),
    );
  }

  _tabSelectionCollection() {
    final double _width = MediaQuery.of(context).size.width - 40;

    final _currentIndex =
        Provider.of<ConnectionManagementProvider>(context).getCurrentIndex();
    final List<String> _tabsCollection =
        Provider.of<ConnectionManagementProvider>(context).getTabsCollection();

    _particularUnderlineSection(int particularIndex) {
      return GestureDetector(
        onTap: () {
          Provider.of<ConnectionManagementProvider>(context, listen: false)
              .setUpdatedIndex(particularIndex, context, movePageView: true);
        },
        child: Container(
          width: _width /
              Provider.of<ConnectionManagementProvider>(context)
                  .getTabsCollectionLength(),
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
          ..._tabsCollection.map((particularTab) => _particularUnderlineSection(
              _tabsCollection.indexOf(particularTab))),
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
              onChanged: _onSearch,
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
    if (Provider.of<AllAvailableConnectionsProvider>(context)
                .getConnectionsLength() ==
            0 ||
        Provider.of<RequestConnectionsProvider>(context)
                .getConnectionsLength() ==
            0 ||
        Provider.of<SentConnectionsProvider>(context).getConnectionsLength() ==
            0) {
      return Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height / 1.8,
          alignment: Alignment.center,
          child: Text(
            "Not Found",
            style: TextStyleCollection.secondaryHeadingTextStyle
                .copyWith(fontSize: 16),
          ));
    }

    final ScrollController _scrollController =
        Provider.of<MainScrollingProvider>(context).getScrollController();

    return SizedBox(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height / 1.4,
      child: PageView.builder(
        controller: Provider.of<ConnectionManagementProvider>(context)
            .getPageController(),
        scrollBehavior: const ScrollBehavior(
            androidOverscrollIndicator: AndroidOverscrollIndicator.glow),
        onPageChanged: (changedPageIndex) =>
            Provider.of<ConnectionManagementProvider>(context, listen: false)
                .setUpdatedIndex(changedPageIndex, context),
        itemCount: Provider.of<ConnectionManagementProvider>(context)
            .getTabsCollectionLength(),
        itemBuilder: (_, pageViewIndex) => ListView.builder(
          shrinkWrap: true,
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          itemCount: _getItemCount(),
          itemBuilder: (_, availableIndex) =>
              _getConnectionsList(availableIndex),
        ),
      ),
    );
  }

  _getConnectionsList(availableIndex) {
    final _commonChatLayout = CommonChatListLayout(context: context);
    final int _currentIndex =
        Provider.of<ConnectionManagementProvider>(context).getCurrentIndex();

    if (_currentIndex == 0) {
      final _particularData =
          Provider.of<AllAvailableConnectionsProvider>(context)
              .getConnections()[availableIndex];

      return _commonChatLayout.particularChatConnection(
        currentIndex: availableIndex,
        photo: _particularData["photo"],
        heading: _particularData["name"],
        subheading: _particularData["description"],
        lastMsgTime: null,
        totalPendingMessages: null,
        trailingWidget: connectButton(),
      );
    } else if (_currentIndex == 1) {
      final _particularData = Provider.of<RequestConnectionsProvider>(context)
          .getConnections()[availableIndex];

      return _commonChatLayout.particularChatConnection(
          currentIndex: availableIndex,
          photo: _particularData["photo"],
          heading: _particularData["name"],
          subheading: _particularData["description"],
          lastMsgTime: null,
          totalPendingMessages: null,
          middleWidth: MediaQuery.of(context).size.width - 240,
          trailingWidget: incomingRequestButtonCollection());
    } else if (_currentIndex == 2) {
      final _particularData = Provider.of<SentConnectionsProvider>(context)
          .getConnections()[availableIndex];

      return _commonChatLayout.particularChatConnection(
          currentIndex: availableIndex,
          photo: _particularData["photo"],
          heading: _particularData["name"],
          subheading: _particularData["description"],
          lastMsgTime: null,
          totalPendingMessages: null,
          trailingWidget: withdrawButton());
    }

    return const Center(child: Text("Not Implemented till now"));
  }

  _getItemCount() {
    final _currentIndex =
        Provider.of<ConnectionManagementProvider>(context, listen: false)
            .getCurrentIndex();

    if (_currentIndex == 0) {
      return Provider.of<AllAvailableConnectionsProvider>(context)
          .getConnectionsLength();
    } else if (_currentIndex == 1) {
      return Provider.of<RequestConnectionsProvider>(context)
          .getConnectionsLength();
    } else if (_currentIndex == 2) {
      return Provider.of<SentConnectionsProvider>(context)
          .getConnectionsLength();
    }
  }

  void _onSearch(String inputVal) {
    final _currentIndex =
        Provider.of<ConnectionManagementProvider>(context, listen: false)
            .getCurrentIndex();

    if (_currentIndex == 0) {
      Provider.of<AllAvailableConnectionsProvider>(context, listen: false)
          .operateOnSearch(inputVal);
    } else if (_currentIndex == 1) {
      Provider.of<RequestConnectionsProvider>(context, listen: false)
          .operateOnSearch(inputVal);
    } else if (_currentIndex == 2) {
      Provider.of<SentConnectionsProvider>(context, listen: false)
          .operateOnSearch(inputVal);
    }
  }

  connectButton() {
    return TextButton(
      child: Text(
        "Connect",
        style: TextStyleCollection.terminalTextStyle
            .copyWith(color: AppColors.normalBlueColor, fontSize: 14),
      ),
      onPressed: () {
        /// Write Logic for Connect To A User
      },
    );
  }

  withdrawButton() {
    return TextButton(
      child: Text(
        "Withdraw",
        style: TextStyleCollection.terminalTextStyle.copyWith(
            color: AppColors.lightRedColor,
            fontSize: 14,
            fontWeight: FontWeight.normal),
      ),
      onPressed: () {
        /// Write Logic for Connect To A User
      },
    );
  }

  incomingRequestButtonCollection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          child: Text(
            "Accept",
            style: TextStyleCollection.terminalTextStyle.copyWith(
                color: AppColors.normalBlueColor,
                fontSize: 14,
                fontWeight: FontWeight.normal),
          ),
          onPressed: () {
            /// Write Logic for Connect To A User
          },
        ),
        Expanded(
          child: TextButton(
            child: Text(
              "Reject",
              style: TextStyleCollection.terminalTextStyle.copyWith(
                  color: AppColors.lightRedColor,
                  fontSize: 14,
                  fontWeight: FontWeight.normal),
            ),
            onPressed: () {
              /// Write Logic for Connect To A User
            },
          ),
        )
      ],
    );
  }
}
