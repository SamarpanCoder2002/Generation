import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/images_path_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/model/activity_model.dart';
import 'package:generation/providers/activity/activity_screen_provider.dart';
import 'package:generation/providers/activity/poll_show_provider.dart';
import 'package:generation/screens/activity/view/activity_value_screen.dart';
import 'package:generation/services/device_specific_operations.dart';
import 'package:generation/types/types.dart';
import 'package:provider/provider.dart';
import '../../../config/size_collection.dart';
import '../../../providers/sound_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/video_management/video_show_provider.dart';
import '../animation_controller.dart';

class ActivityController extends StatefulWidget {
  const ActivityController({Key? key}) : super(key: key);

  @override
  State<ActivityController> createState() => _ActivityControllerState();
}

class _ActivityControllerState extends State<ActivityController>
    with TickerProviderStateMixin {
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    changeSystemNavigationAndStatusBarColor(
        statusBarColor: AppColors.transparentColor,
        navigationBarColor: Colors.black12.withOpacity(0));
    Provider.of<ActivityProvider>(context, listen: false)
        .initializeAnimationController(this, context);

    changeOnlyNavigationBarColor(
        navigationBarColor: AppColors.pureBlackColor.withOpacity(0.1));

    super.initState();
  }

  // @override
  // void dispose() {
  //   changeOnlyNavigationBarColor(
  //       navigationBarColor: AppColors.getBgColor(_isDarkMode));
  //
  //   super.dispose();
  // }

  _onReplySectionRemovedAction() {
    final _activityProvider =
        Provider.of<ActivityProvider>(context, listen: false);

    final _currentActivityData = _activityProvider
        .getParticularActivity(_activityProvider.getPageIndex());

    Provider.of<ActivityProvider>(context, listen: false)
        .updateReplyBtnClicked(false);

    Provider.of<ActivityProvider>(context, listen: false)
        .resumeActivityAnimation();

    if (_currentActivityData!.type == ActivityContentType.video.toString()) {
      Provider.of<VideoShowProvider>(context, listen: false).playVideo();
    }

    if (_currentActivityData.type == ActivityContentType.audio.toString()) {
      Provider.of<SongManagementProvider>(context, listen: false).playSong();
    }
  }

  @override
  Widget build(BuildContext context) {
    final _activityProvider = Provider.of<ActivityProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        if (_activityProvider.isReplyBtnClicked()) {
          _onReplySectionRemovedAction();
          return false;
        }

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
    final _activityProvider = Provider.of<ActivityProvider>(context);
    final int _totalActivityData =
        _activityProvider.getLengthOfActivityCollection();

    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    if (_totalActivityData == 0) {
      changeOnlyNavigationBarColor(
          navigationBarColor: AppColors.getBgColor(_isDarkMode));
      return Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height,
        color: AppColors.getBgColor(_isDarkMode),
        alignment: Alignment.center,
        child: Text(
          "No Activity Found",
          style: TextStyleCollection.terminalTextStyle
              .copyWith(fontSize: 20, color: AppColors.lightRedColor),
        ),
      );
    }

    return SizedBox(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height,
      child: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
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

          if (_currentActivityData == null) return const Center();

          if (_currentActivityData.type ==
              ActivityContentType.poll.toString()) {
            Provider.of<PollShowProvider>(context, listen: false)
                .setPollData(_currentActivityData.message, update: false);
          }

          return Stack(
            clipBehavior: Clip.none,
            children: [
              ActivityViewer(activityData: _currentActivityData),
              _activityAnimation(),
              _forNavigation(_currentActivityData),
              if (!_activityProvider.isReplyBtnClicked())
                _replyButton(_currentActivityData),
              if (_activityProvider.isReplyBtnClicked()) _replySection(),
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
      top: 30.0,
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

  _transparentNavigatingWidget(activityModel) => Container(
        width: MediaQuery.of(context).size.width,
        height: activityModel.type != ActivityContentType.text.toString()
            ? MediaQuery.of(context).size.height -
                SizeCollection.activityBottomTextHeight -
                50
            : MediaQuery.of(context).size.height,
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

                  if (activityModel.type ==
                      ActivityContentType.video.toString()) {
                    Provider.of<VideoShowProvider>(context, listen: false)
                        .pauseVideo();
                  }

                  if (activityModel.type ==
                      ActivityContentType.audio.toString()) {
                    Provider.of<SongManagementProvider>(context, listen: false)
                        .pauseSong();
                  }
                },
                onTapUp: (details) {
                  Provider.of<ActivityProvider>(context, listen: false)
                      .resumeActivityAnimation();

                  if (activityModel.type ==
                      ActivityContentType.video.toString()) {
                    Provider.of<VideoShowProvider>(context, listen: false)
                        .playVideo();
                  }

                  if (activityModel.type ==
                      ActivityContentType.audio.toString()) {
                    Provider.of<SongManagementProvider>(context, listen: false)
                        .playSong();
                  }
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

  _replyButton(_currentActivityData) {
    _getBgColor() {
      return _currentActivityData.additionalThings["text"] == null ||
              _currentActivityData.additionalThings["text"] == ""
          ? AppColors.transparentColor
          : AppColors.pureBlackColor.withOpacity(0.2);
    }

    _onTap() {
      Provider.of<ActivityProvider>(context, listen: false)
          .pauseActivityAnimation();

      Provider.of<ActivityProvider>(context, listen: false)
          .updateReplyBtnClicked(true);

      if (_currentActivityData.type == ActivityContentType.video.toString()) {
        Provider.of<VideoShowProvider>(context, listen: false).pauseVideo();
      }

      if (_currentActivityData.type == ActivityContentType.audio.toString()) {
        Provider.of<SongManagementProvider>(context, listen: false).pauseSong();
      }
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: InkWell(
        onTap: _onTap,
        child: Container(
          width: double.maxFinite,
          height: 50,
          color: _getBgColor(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.keyboard_arrow_up_outlined,
                color: AppColors.pureWhiteColor,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                "Reply",
                style: TextStyleCollection.secondaryHeadingTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _replySection() => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: const BoxDecoration(
              color: AppColors.transparentColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0))),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _replyContainerToInput(),
              ],
            ),
          ),
        ),
      );

  _replyContainerToInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _containerToInput(),
          _sendButton(bgColor: AppColors.messageWritingSectionColor)
        ],
      ),
    );
  }

  _containerToInput() {
    return Container(
      height: 40,
      width: MediaQuery.of(context).size.width - 80,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: AppColors.messageWritingSectionColor),
      child: _textMessageWritingSection(),
    );
  }

  _textMessageWritingSection() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 180,
      child: TextField(
        autofocus: true,
        controller: textEditingController,
        style: TextStyleCollection.terminalTextStyle.copyWith(fontSize: 14),
        maxLines: null,
        cursorColor: AppColors.pureWhiteColor,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(bottom: 10, left: 20),
          border: InputBorder.none,
          hintText: "Write Something Here",
          hintStyle: TextStyleCollection.searchTextStyle.copyWith(
              color: AppColors.pureWhiteColor.withOpacity(0.8), fontSize: 14),
        ),
      ),
    );
  }

  _sendButton({Color bgColor = AppColors.darkBorderGreenColor}) {
    return InkWell(
      onTap: () {
        textEditingController.clear();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Container(
          width: 45,
          height: 45,
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
              color: bgColor, borderRadius: BorderRadius.circular(100)),
          child: Image.asset(
            IconImages.sendImagePath,
          ),
        ),
      ),
    );
  }

  _forNavigation(ActivityModel _currentActivityData) {
    final _activityProvider = Provider.of<ActivityProvider>(context);

    if (_currentActivityData.type != ActivityContentType.poll.toString() &&
        !_activityProvider.isReplyBtnClicked()) {
      return _transparentNavigatingWidget(_currentActivityData);
    }

    return const Center();
  }
}
