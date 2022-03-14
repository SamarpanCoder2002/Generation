import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/providers/activity/activity_screen_provider.dart';
import 'package:generation/screens/activity/view/activity_value_screen.dart';
import 'package:generation/services/device_specific_operations.dart';
import 'package:provider/provider.dart';

import '../animation_controller.dart';

class ActivityController extends StatefulWidget {
  const ActivityController({Key? key}) : super(key: key);

  @override
  State<ActivityController> createState() => _ActivityControllerState();
}

class _ActivityControllerState extends State<ActivityController>
    with TickerProviderStateMixin {
  @override
  void initState() {
    changeSystemNavigationAndStatusBarColor(
        statusBarColor: AppColors.transparentColor,
        navigationBarColor: Colors.black12.withOpacity(0));
    Provider.of<ActivityProvider>(context, listen: false)
        .initializeAnimationController(this, context);
    super.initState();
  }

  @override
  void dispose() {
    changeOnlyNavigationBarColor(
        navigationBarColor: AppColors.backgroundDarkMode);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<ActivityProvider>(context, listen: false)
            .disposeAnimationController();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.pureWhiteColor,
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: _activityPagination(),
        ),
      ),
    );
  }

  _activityPagination() {
    return SizedBox(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height,
      child: PageView.builder(
        controller: Provider.of<ActivityProvider>(context).getPageController(),
        scrollBehavior: const ScrollBehavior(
            androidOverscrollIndicator: AndroidOverscrollIndicator.glow),
        onPageChanged: (changedPageIndex) =>
            Provider.of<ActivityProvider>(context, listen: false)
                .setUpdatedIndex(changedPageIndex),
        itemCount: Provider.of<ActivityProvider>(context)
            .getLengthOfActivityCollection(),
        itemBuilder: (_, pageViewIndex) {
          final _currentActivityData = Provider.of<ActivityProvider>(context)
              .getParticularActivity(pageViewIndex);

          return Stack(
            children: [
              ActivityViewer(activityData: _currentActivityData),
              _activityAnimation(),
              _transparentNavigatingWidget(),
            ],
          );
        },
      ),
    );
  }

  Widget _activityAnimation() {
    final _dataCollection =
        Provider.of<ActivityProvider>(context).getActivityCollection();
    return Positioned(
      top: 40.0,
      left: 5.0,
      right: 5.0,
      child: Row(
        children: [
          ..._dataCollection.map((data) => AnimatedBar(
                animController: Provider.of<ActivityProvider>(context)
                    .getAnimationController(),
                position: _dataCollection.indexOf(data),
                currentIndex:
                    Provider.of<ActivityProvider>(context).getPageIndex(),
              ))
        ],
      ),
    );
  }

  _transparentNavigatingWidget() => Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: AppColors.transparentColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                Provider.of<ActivityProvider>(context, listen: false)
                    .forwardOrBackwardActivity(false, context);
              },
              child: Container(
                width: MediaQuery.of(context).size.width / 6,
                height: MediaQuery.of(context).size.height,
                color: AppColors.transparentColor,
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTapDown: (details) {
                  Provider.of<ActivityProvider>(context, listen: false)
                      .pauseActivityAnimation();
                },
                onTapUp: (details) {
                  Provider.of<ActivityProvider>(context, listen: false)
                      .resumeActivityAnimation();
                },
                child: Container(
                  color: AppColors.transparentColor,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Provider.of<ActivityProvider>(context, listen: false)
                    .forwardOrBackwardActivity(true, context);
              },
              child: Container(
                width: MediaQuery.of(context).size.width / 6,
                height: MediaQuery.of(context).size.height,
                color: AppColors.transparentColor,
              ),
            ),
          ],
        ),
      );
}
