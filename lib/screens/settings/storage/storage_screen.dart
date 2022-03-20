import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';

class LocalStorageScreen extends StatefulWidget {
  const LocalStorageScreen({Key? key}) : super(key: key);

  @override
  State<LocalStorageScreen> createState() => _LocalStorageScreenState();
}

class _LocalStorageScreenState extends State<LocalStorageScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDarkMode,
        appBar: AppBar(
          title:  SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Container(
              color: AppColors.pureWhiteColor,
              height: 40,
              width: MediaQuery.of(context).size.width,
              child: _tabCollection(),
            ),
          ),
        ),
      ),
    );
  }
  _tabCollection() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 110,
      child: TabBar(
        isScrollable: true,
        labelColor: AppColors.pureBlackColor,
        unselectedLabelColor: AppColors.pureBlackColor,
        indicator: UnderlineTabIndicator(
          borderSide:
          BorderSide(width: 3.0, color: AppColors.lightRedColor),
        ),
        automaticIndicatorColorAdjustment: true,
        tabs: [
          Tab(

          ),
        ],
      ),
    );
  }

}
