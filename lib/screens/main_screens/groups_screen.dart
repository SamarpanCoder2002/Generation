import 'package:flutter/material.dart';
import 'package:generation/providers/group_collection_provider.dart';
import 'package:provider/provider.dart';

import '../../config/colors_collection.dart';
import '../../config/text_collection.dart';
import '../../config/text_style_collection.dart';
import '../../providers/main_scrolling_provider.dart';
import '../common/chat_connections_common_design.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  _GroupsScreenState createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  void initState() {
    Provider.of<GroupCollectionProvider>(context, listen: false).initialize();
    Provider.of<MainScrollingProvider>(context, listen: false)
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
              _searchBar(),
              const SizedBox(height: 25),
              _screenHeading(),
              _groupCollection(),
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
              onChanged: (inputVal) =>
                  Provider.of<GroupCollectionProvider>(context, listen: false)
                      .operateOnSearch(inputVal),
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

  _screenHeading() {
    return const Align(
      alignment: Alignment.topLeft,
      child: Text(
        "Groups",
        style: TextStyleCollection.secondaryHeadingTextStyle,
      ),
    );
  }

  _groupCollection() {
    if (Provider.of<GroupCollectionProvider>(context).getDataLength() == 0) {
      return Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height / 1.8,
          alignment: Alignment.center,
          child: Text(
            "No Groups Found",
            style: TextStyleCollection.secondaryHeadingTextStyle
                .copyWith(fontSize: 16),
          ));
    }

    final ScrollController _groupScreenController =
        Provider.of<MainScrollingProvider>(context)
            .getScrollController();

    final _commonChatLayout = CommonChatListLayout(context: context);

    return Container(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height / 1.3,
      margin: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        shrinkWrap: true,
        controller: _groupScreenController,
        physics: const BouncingScrollPhysics(),
        itemCount:
            Provider.of<GroupCollectionProvider>(context).getDataLength(),
        itemBuilder: (_, groupIndex) {
          final _groupData = Provider.of<GroupCollectionProvider>(context)
              .getData()[groupIndex];

          return _commonChatLayout.particularChatConnection(
              photo: _groupData["profilePic"],
              heading: _groupData["groupName"],
              subheading:
                  "${_groupData["latestMessage"]["holderName"]}: ${_groupData["latestMessage"]["message"]}",
              lastMsgTime: _groupData["latestMessage"]["time"],
              currentIndex: groupIndex,
              totalPendingMessages: _groupData["notSeenMsgCount"].toString());
        },
      ),
    );
  }
}
