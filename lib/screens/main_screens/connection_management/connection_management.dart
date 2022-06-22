import 'package:flutter/material.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/providers/connection_management_provider_collection/all_available_connections_provider.dart';
import 'package:generation/providers/connection_management_provider.dart';
import 'package:generation/providers/connection_management_provider_collection/incoming_request_provider.dart';
import 'package:generation/providers/connection_management_provider_collection/sent_request_provider.dart';
import 'package:generation/screens/main_screens/connection_management/common_show_screen.dart';
import 'package:provider/provider.dart';

import '../../../config/colors_collection.dart';
import '../../../config/text_collection.dart';
import '../../../config/text_style_collection.dart';
import '../../../providers/main_scrolling_provider.dart';
import '../../../providers/network_management_provider.dart';
import '../../../providers/theme_provider.dart';

class ConnectionManagementScreen extends StatefulWidget {
  const ConnectionManagementScreen({Key? key}) : super(key: key);

  @override
  _ConnectionManagementScreenState createState() =>
      _ConnectionManagementScreenState();
}

class _ConnectionManagementScreenState extends State<ConnectionManagementScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final DBOperations _dbOperations = DBOperations();

  _checkForNetwork() async {
    if (!(await Provider.of<NetworkManagementProvider>(context, listen: false)
        .isNetworkActive)) {
      Provider.of<NetworkManagementProvider>(context, listen: false)
          .noNetworkMsg(context, showCenterToast: true);
      return;
    }
  }

  @override
  void initState() {
    _dbOperations.getAvailableUsersData(context);
    final _tabLength =
        Provider.of<ConnectionManagementProvider>(context, listen: false)
            .getTabsCollectionLength();
    _tabController =
        TabController(length: _tabLength, vsync: this, initialIndex: 0);
    _tabController?.addListener(_tabMovementListener);
    Provider.of<AllAvailableConnectionsProvider>(context, listen: false)
        .initialize();
    Provider.of<RequestConnectionsProvider>(context, listen: false)
        .initialize();
    Provider.of<SentConnectionsProvider>(context, listen: false).initialize();
    Provider.of<MainScrollingProvider>(context, listen: false).startListening();
    _checkForNetwork();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Scaffold(
      backgroundColor: AppColors.getBgColor(_isDarkMode),
      appBar: _appBar(),
      body: _tabBarView(),
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
    final bool _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    final List<String> _tabsCollection =
        Provider.of<ConnectionManagementProvider>(context).getTabsCollection();

    return SizedBox(
      width: _width,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.normalBlueColor,
        indicatorPadding: const EdgeInsets.only(left: 20.0, right: 20.0),
        unselectedLabelColor: _isDarkMode
            ? AppColors.pureWhiteColor
            : AppColors.lightChatConnectionTextColor,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(width: 2.0, color: AppColors.normalBlueColor),
        ),
        automaticIndicatorColorAdjustment: true,
        labelStyle: TextStyleCollection.secondaryHeadingTextStyle
            .copyWith(fontSize: 16),
        tabs: [
          ..._tabsCollection.map((particularTab) => Tab(
                child: Text(particularTab, textAlign: TextAlign.center),
              ))
        ],
      ),
    );
  }

  _appBar() => PreferredSize(
      child: Column(
        children: [
          const SizedBox(height: 30),
          _headingSection(),
          const SizedBox(height: 10),
          _screenHeading(),
          const SizedBox(height: 15),
          _tabCollection()
        ],
      ),
      preferredSize: Size(MediaQuery.of(context).size.width, 140));

  _tabBarView() {
    return TabBarView(controller: _tabController, children: const [
      CommonUsersShowScreen(currIndex: 0),
      CommonUsersShowScreen(currIndex: 1),
      CommonUsersShowScreen(currIndex: 2),
    ]);
  }

  void _tabMovementListener() {
    if (!_tabController!.indexIsChanging) return;

    if (_tabController?.index == 0) {
      _dbOperations.getAvailableUsersData(context);
    } else if (_tabController?.index == 1) {
      _dbOperations.getReceivedRequestUsersData(context);
    } else {
      _dbOperations.getSentRequestUsersData(context);
    }
  }
}
