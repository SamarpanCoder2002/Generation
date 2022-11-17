import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/images_path_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/model/activity_model.dart';
import 'package:generation/providers/activity/activity_screen_provider.dart';
import 'package:generation/providers/activity/poll_show_provider.dart';
import 'package:generation/providers/status_collection_provider.dart';
import 'package:generation/screens/activity/view/activity_value_screen.dart';
import 'package:generation/services/device_specific_operations.dart';
import 'package:generation/config/types.dart';
import 'package:generation/services/encryption_operations.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:generation/services/toast_message_show.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../../../config/countable_data_collection.dart';
import '../../../providers/chat/messaging_provider.dart';
import '../../../providers/connection_collection_provider.dart';
import '../../../providers/sound_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/video_management/video_show_provider.dart';
import '../../../services/debugging.dart';
import '../../../services/local_data_management.dart';
import '../animation_controller.dart';

class ActivityController extends StatefulWidget {
  final String tableName;
  final int startingIndex;
  final bool showReplySection;
  final String activityHolderId;

  const ActivityController(
      {Key? key,
      required this.tableName,
      required this.startingIndex,
      required this.activityHolderId,
      this.showReplySection = true})
      : super(key: key);

  @override
  State<ActivityController> createState() => _ActivityControllerState();
}

class _ActivityControllerState extends State<ActivityController>
    with TickerProviderStateMixin {
  final TextEditingController textEditingController = TextEditingController();
  final LocalStorage _localStorage = LocalStorage();
  final DBOperations _dbOperations = DBOperations();

  bool _isLoading = false;

  @override
  void initState() {
    changeSystemNavigationAndStatusBarColor(
        statusBarColor: AppColors.pureBlackColor,
        navigationBarColor: AppColors.pureBlackColor);
    Provider.of<ActivityProvider>(context, listen: false)
        .initializeAnimationController(this, context);
    Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .setContext(context);

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

    return LoadingOverlay(
      isLoading: _isLoading,
      color: AppColors.pureBlackColor.withOpacity(0.6),
      progressIndicator: const CircularProgressIndicator(
        color: AppColors.lightBorderGreenColor,
      ),
      child: WillPopScope(
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

    final _currUserId = Provider.of<StatusCollectionProvider>(context)
        .getCurrentAccData()['id'];

    final _showActivityDetails =
        Provider.of<ActivityProvider>(context).showActivityDetails;

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

          _activityVisited(_currentActivityData);

          // final _animController = Provider.of<ActivityProvider>(context, listen: false).getAnimationController();
          // _animController.forward();

          return Stack(
            clipBehavior: Clip.none,
            children: [
              ActivityViewer(activityData: _currentActivityData),
              _activityAnimation(),
              if (_showActivityDetails)
                _activityInformation(_currentActivityData),
              _forNavigation(_currentActivityData),
              if (widget.showReplySection &&
                  _currentActivityData.holderId != _currUserId &&
                  !_activityProvider.isReplyBtnClicked())
                _replyButton(_currentActivityData),
              if (widget.showReplySection &&
                  _currentActivityData.holderId != _currUserId &&
                  _activityProvider.isReplyBtnClicked())
                _replySection(_currentActivityData),
            ],
          );
        },
      ),
    );
  }

  _activityInformation(ActivityModel? _currentActivityData) {
    debugShow('Activity holder id :${widget.activityHolderId}');

    final _connectionData = widget.activityHolderId == _dbOperations.currUid
        ? Provider.of<StatusCollectionProvider>(context).getCurrentAccData()
        : Provider.of<ConnectionCollectionProvider>(context)
            .getUsersMap(widget.activityHolderId);

    final _showDateTime = Provider.of<StatusCollectionProvider>(context)
        .eligibleForShowDateTime(_currentActivityData);

    debugShow('Show Date Time in activity: $_showDateTime');

    return Positioned(
      top: 35,
      left: 1,
      right: 1,
      child: Container(
        width: double.maxFinite,
        color: AppColors.pureBlackColor.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.transparentColor,
              backgroundImage: CachedNetworkImageProvider(
                  Secure.decode(_connectionData['profilePic'])),
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 100,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      Secure.decode(_connectionData['name']),
                      style: TextStyleCollection.activityTitleTextStyle,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (_showDateTime)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "${_currentActivityData!.date} ${_currentActivityData.time}",
                        style: TextStyleCollection.activityTitleTextStyle,
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityAnimation() {
    final _dataCollection =
        Provider.of<ActivityProvider>(context).getActivityCollection();

    if (widget.startingIndex > 0 &&
        Provider.of<ActivityProvider>(context).getPageIndex() ==
            widget.startingIndex) {
      Provider.of<ActivityProvider>(context)
          .resumeAnimationForNewest(widget.startingIndex);
    }

    debugShow('Data collection: $_dataCollection');

    return Positioned(
      top: 30.0,
      left: 5.0,
      right: 5.0,
      child: Row(
        children: [
          ..._dataCollection.asMap().entries.map((dataMap) {
            debugShow('Position in activity: ${dataMap.key}');

            return AnimatedBar(
              animController: Provider.of<ActivityProvider>(context)
                  .getAnimationController(),
              position: dataMap.key,
              currentIndex:
                  Provider.of<ActivityProvider>(context).getPageIndex(),
            );
          })
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

  _replyButton(ActivityModel? _currentActivityData) {
    _getBgColor() {
      debugShow('Additional Things: ${_currentActivityData!.additionalThings}');

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

      if (_currentActivityData!.type == ActivityContentType.video.toString()) {
        Provider.of<VideoShowProvider>(context, listen: false).pauseVideo();
      }

      if (_currentActivityData.type == ActivityContentType.audio.toString()) {
        Provider.of<SongManagementProvider>(context, listen: false).pauseSong();
      }

      Provider.of<ChatBoxMessagingProvider>(context, listen: false)
          .setReplyActivity(
              _currentActivityData.id, _currentActivityData.holderId);
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

  _replySection(ActivityModel? _currentActivityData) => Align(
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
                _replyContainerToInput(_currentActivityData),
              ],
            ),
          ),
        ),
      );

  _replyContainerToInput(ActivityModel? _currentActivityData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _containerToInput(),
          _sendButton(
              bgColor: AppColors.messageWritingSectionColor,
              currentActivityData: _currentActivityData)
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

  _sendButton(
      {Color bgColor = AppColors.darkBorderGreenColor,
      ActivityModel? currentActivityData}) {
    return InkWell(
      onTap: () => _sendActivityReplyMsg(currentActivityData),
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

  void _activityVisited(ActivityModel _currentActivityData) {
    _localStorage.insertUpdateTableForActivity(
        tableName: widget.tableName,
        activityId: _currentActivityData.id,
        activityHolderId: Secure.encode(_currentActivityData.holderId) ?? '',
        activityType: Secure.encode(_currentActivityData.type) ?? '',
        date: Secure.encode(_currentActivityData.date) ?? '',
        time: Secure.encode(_currentActivityData.time) ?? '',
        msg: Secure.encode(_currentActivityData.message) ?? '',
        additionalData: Secure.encode(
            DataManagement.toJsonString(_currentActivityData.additionalThings)),
        activityVisited: true,
        dbOperation: DBOperation.update);
  }

  _sendActivityReplyMsg(ActivityModel? _currentActivityData) async {
    debugShow('At Reply Activity');

    final _replyMsg =
        Provider.of<ChatBoxMessagingProvider>(context, listen: false)
            .getReplyHolderMsg;

    if (_replyMsg.isEmpty) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    /// Message Send Management
    await Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .sendMsgManagement(
            msgType: ChatMessageType.text.toString(),
            message: textEditingController.text,
            incomingConnId: _currentActivityData!.holderId,
            storeOnMsgBox: false,
            additionalData: _replyMsg.isEmpty
                ? null
                : {'reply': DataManagement.toJsonString(_replyMsg)});

    Provider.of<ChatBoxMessagingProvider>(context, listen: false)
        .removeReplyMsg();

    if (mounted) {
      setState(() {
        textEditingController.clear();
        _isLoading = false;
        _onReplySectionRemovedAction();
      });
    }

    ToastMsg.showSuccessToast(
     'Reply Send Successfully',
        context: context);
  }
}
