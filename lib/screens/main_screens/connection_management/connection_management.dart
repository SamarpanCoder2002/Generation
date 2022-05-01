import 'package:flutter/material.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/providers/connection_management_provider_collection/all_available_connections_provider.dart';
import 'package:generation/providers/connection_management_provider.dart';
import 'package:generation/providers/connection_management_provider_collection/incoming_request_provider.dart';
import 'package:generation/providers/connection_management_provider_collection/sent_request_provider.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:generation/services/toast_message_show.dart';
import 'package:generation/types/types.dart';
import 'package:provider/provider.dart';

import '../../../config/colors_collection.dart';
import '../../../config/text_collection.dart';
import '../../../config/text_style_collection.dart';
import '../../../providers/main_scrolling_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../common/chat_connections_common_design.dart';

class ConnectionManagementScreen extends StatefulWidget {
  const ConnectionManagementScreen({Key? key}) : super(key: key);

  @override
  _ConnectionManagementScreenState createState() =>
      _ConnectionManagementScreenState();
}

class _ConnectionManagementScreenState
    extends State<ConnectionManagementScreen> {
  final LocalStorage _localStorage = LocalStorage();
  final DBOperations _dbOperations = DBOperations();

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
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Scaffold(
      backgroundColor: AppColors.getBgColor(_isDarkMode),
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
                  : AppColors.lightChatConnectionTextColor),
        ));
  }

  _screenHeading() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Align(
      alignment: Alignment.topCenter,
      child: Text(
        "Connection Management",
        style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
            fontSize: 16,
            color: _isDarkMode
                ? AppColors.pureWhiteColor
                : AppColors.lightChatConnectionTextColor),
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
      final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

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
                    : _isDarkMode
                        ? AppColors.pureWhiteColor
                        : AppColors.lightChatConnectionTextColor),
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
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
      height: 45,
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
                  : AppColors.lightChatConnectionTextColor,
              style: TextStyleCollection.searchTextStyle.copyWith(
                  color: _isDarkMode
                      ? AppColors.pureWhiteColor
                      : AppColors.lightChatConnectionTextColor),
              onChanged: _onSearch,
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

  _collectionsSection() {
    if (_getItemCount() == 0) {
      print("Here");
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
          itemCount: _getItemCount() + 1,
          itemBuilder: (_, availableIndex) =>
              availableIndex <= _getItemCount() - 1
                  ? _getConnectionsList(availableIndex)
                  : const SizedBox(
                      height: 100,
                    ),
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
        photo: _particularData["profilePic"],
        heading: _particularData["name"],
        subheading: _particularData["about"],
        lastMsgTime: null,
        totalPendingMessages: null,
        trailingWidget: connectButton(_particularData, availableIndex),
      );
    } else if (_currentIndex == 1) {
      final _particularData = Provider.of<RequestConnectionsProvider>(context)
          .getConnections()[availableIndex]
          .data();

      return _commonChatLayout.particularChatConnection(
          currentIndex: availableIndex,
          photo: _particularData["profilePic"],
          heading: _particularData["name"],
          subheading: _particularData["about"],
          lastMsgTime: null,
          totalPendingMessages: null,
          middleWidth: MediaQuery.of(context).size.width - 240,
          trailingWidget:
              incomingRequestButtonCollection(_particularData, availableIndex));
    } else if (_currentIndex == 2) {
      final _particularData = Provider.of<SentConnectionsProvider>(context)
          .getConnections()[availableIndex]
          .data();

      return _commonChatLayout.particularChatConnection(
          currentIndex: availableIndex,
          photo: _particularData["profilePic"],
          heading: _particularData["name"],
          subheading: _particularData["about"],
          lastMsgTime: null,
          totalPendingMessages: null,
          trailingWidget: withdrawButton(_particularData, availableIndex));
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

  connectButton(otherUserData, int index) {
    return TextButton(
      child: Text(
        "Connect",
        style: TextStyleCollection.terminalTextStyle
            .copyWith(color: AppColors.normalBlueColor, fontSize: 14),
      ),
      onPressed: () => _sendConnectionRequest(otherUserData, index),
    );
  }

  withdrawButton(otherData, int index) {
    return TextButton(
      child: Text(
        "Withdraw",
        style: TextStyleCollection.terminalTextStyle.copyWith(
            color: AppColors.lightRedColor,
            fontSize: 14,
            fontWeight: FontWeight.normal),
      ),
      onPressed: () => _withdrawRequest(otherData, index),
    );
  }

  incomingRequestButtonCollection(otherData, int index) {
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
          onPressed: () => _acceptConnectionRequest(otherData, index),
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
            onPressed: () => _rejectConnectionRequest(otherData, index),
          ),
        )
      ],
    );
  }

  _sendConnectionRequest(otherUserData, int index) async {
    final _currAccData = await _localStorage.getDataForCurrAccount();
    print("Current Account Data: $_currAccData");

    if (_currAccData == null) return;

    final _response = await _dbOperations.sendConnectionRequest(
        currUserData: _currAccData,
        otherUserId: otherUserData["id"],
        otherUserData: otherUserData);
    if (_response) {
      await _dbOperations.getAvailableUsersData(context);
      Provider.of<AllAvailableConnectionsProvider>(context, listen: false)
          .removeIndexFromSearch(index);
      Provider.of<SentConnectionsProvider>(context, listen: false)
          .initialize(update: true);
      showToast(context,
          title: "Connection Request Sent",
          toastIconType: ToastIconType.success,
          showFromTop: false);
    } else {
      showToast(context,
          title: "Failed to sent request",
          toastIconType: ToastIconType.error,
          showFromTop: false);
    }
  }

  _withdrawRequest(otherUserData, index) async {
    final _currAccData = await _localStorage.getDataForCurrAccount();

    if (_currAccData == null) return;

    final _response = await _dbOperations.withdrawConnectionRequest(
        currUserData: _currAccData,
        otherUserId: otherUserData["id"],
        otherUserData: otherUserData);
    if (_response) {
      await _dbOperations.getAvailableUsersData(context);
      Provider.of<SentConnectionsProvider>(context, listen: false)
          .removeIndexFromSearch(index);
      Provider.of<AllAvailableConnectionsProvider>(context, listen: false)
          .initialize(update: true);
      showToast(context,
          title: "Request withdrawn",
          toastIconType: ToastIconType.success,
          showFromTop: false);
    } else {
      showToast(context,
          title: "Failed to withdraw request",
          toastIconType: ToastIconType.error,
          showFromTop: false);
    }
  }

  _acceptConnectionRequest(otherUserData, int index) async {
    final _currAccData = await _localStorage.getDataForCurrAccount();

    if (_currAccData == null) return;

    final _response = await _dbOperations.acceptConnectionRequest(
        currUserData: _currAccData,
        otherUserId: otherUserData["id"],
        otherUserData: otherUserData);
    if (_response) {
      await _dbOperations.getAvailableUsersData(context);
      Provider.of<RequestConnectionsProvider>(context, listen: false)
          .removeFromSearch(index);
      Provider.of<AllAvailableConnectionsProvider>(context, listen: false)
          .initialize(update: true);
      showToast(context,
          title: "Request Accepted",
          toastIconType: ToastIconType.success,
          showFromTop: false);
    } else {
      showToast(context,
          title: "Failed to accept request",
          toastIconType: ToastIconType.error,
          showFromTop: false);
    }
  }

  _rejectConnectionRequest(otherUserData, int index) async {
    final _currAccData = await _localStorage.getDataForCurrAccount();

    if (_currAccData == null) return;

    final _response = await _dbOperations.rejectIncomingRequest(
        otherUserId: otherUserData["id"]);
    if (_response) {
      await _dbOperations.getAvailableUsersData(context);
      Provider.of<RequestConnectionsProvider>(context, listen: false)
          .removeFromSearch(index);
      Provider.of<AllAvailableConnectionsProvider>(context, listen: false)
          .initialize(update: true);
      showToast(context,
          title: "Incoming Request Rejected",
          toastIconType: ToastIconType.success,
          showFromTop: false);
    } else {
      showToast(context,
          title: "Failed to reject request",
          toastIconType: ToastIconType.error,
          showFromTop: false);
    }
  }
}
