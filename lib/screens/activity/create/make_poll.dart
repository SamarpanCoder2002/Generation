import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/config/time_collection.dart';
import 'package:generation/providers/activity/poll_creator_provider.dart';
import 'package:generation/screens/common/button.dart';
import 'package:generation/services/input_system_services.dart';
import 'package:generation/types/types.dart';
import 'package:provider/provider.dart';

class PollCreatorScreen extends StatefulWidget {
  const PollCreatorScreen({Key? key}) : super(key: key);

  @override
  State<PollCreatorScreen> createState() => _PollCreatorScreenState();
}

class _PollCreatorScreenState extends State<PollCreatorScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late InputOption _inputOption;

  @override
  Widget build(BuildContext context) {
    final _pollProvider = Provider.of<PollCreatorProvider>(context);
    final _allAnswerController = _pollProvider.getAllAnswerController();
    _inputOption = InputOption(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDarkMode,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        alignment: Alignment.center,
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            children: [
              _heading(),
              _commonTextField(
                  labelText: "Enter Your Question",
                  controller: _pollProvider.getQuestionController()),
              ..._allAnswerController.map((ansCtl) => _commonTextField(
                  labelText:
                      "Answer ${_allAnswerController.indexOf(ansCtl) + 1}",
                  controller: ansCtl)),
              const SizedBox(
                height: 20,
              ),
              _addRemoveAnswerBtn(),
              const SizedBox(
                height: 20,
              ),
              _makePollBtn(),
            ],
          ),
        ),
      ),
    );
  }

  _heading() => Center(
        child: Text(
          "Make Your Poll",
          style: TextStyleCollection.secondaryHeadingTextStyle
              .copyWith(fontSize: 18, letterSpacing: 1.0),
        ),
      );

  _commonTextField(
      {required String labelText, required TextEditingController controller}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: TextFormField(
        cursorColor: AppColors.pureWhiteColor,
        style: TextStyleCollection.activityTitleTextStyle,
        controller: controller,
        validator: (inputVal) {
          if (inputVal == null || inputVal.isEmpty) return "*Required";
          return null;
        },
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyleCollection.activityTitleTextStyle
              .copyWith(color: AppColors.pureWhiteColor.withOpacity(0.6)),
          alignLabelWithHint: true,
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.pureWhiteColor)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.pureWhiteColor)),
        ),
      ),
    );
  }

  _makePollBtn() {
    final _pollProvider = Provider.of<PollCreatorProvider>(context);
    return Center(
      child: commonElevatedButton(
          btnText: "Create Poll",
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            _inputOption.commonCreateActivityNavigation(
                ActivityContentType.poll,
                data: {
                  "question": _pollProvider.getQuestionController().text,
                  "answer": [
                    ..._pollProvider
                        .getAllAnswerController()
                        .map((ctl) => {ctl.text: "0"})
                  ],
                  "duration": _getPollShowingDuration().toString(),
                });
          }),
    );
  }

  _addRemoveAnswerBtn() {
    final _pollProvider = Provider.of<PollCreatorProvider>(context);
    final _allAnswerController = _pollProvider.getAllAnswerController();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (_allAnswerController.length > 2)
          commonTextButton(
              btnText: "Remove Last Answer",
              onPressed: () =>
                  _pollProvider.deleteLastAnswerController(context),
              borderColor: AppColors.lightRedColor.withOpacity(0.8),
              textColor: AppColors.lightRedColor.withOpacity(0.8)),
        if (_allAnswerController.length < 6)
          commonElevatedButton(
              btnText: "Add New Answer",
              onPressed: () => _pollProvider.addNewAnswerController(),
              fontSize: 14,
              bgColor: AppColors.darkBorderGreenColor),
      ],
    );
  }

  int _getPollShowingDuration() {
    final _pollProvider = Provider.of<PollCreatorProvider>(context, listen: false);
    final int _totalAnswersOption =
        _pollProvider.getAllAnswerController().length;

    if (_totalAnswersOption == 6) return Timings.pollDurationInSec + 2;
    if (_totalAnswersOption >= 4) return Timings.pollDurationInSec + 1;
    return Timings.pollDurationInSec;
  }
}
