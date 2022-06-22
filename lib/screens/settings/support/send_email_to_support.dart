import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/screens/common/button.dart';
import 'package:generation/services/input_system_services.dart';
import 'package:provider/provider.dart';

import '../../../config/text_style_collection.dart';
import '../../../providers/theme_provider.dart';

class SendEmailToSupport extends StatelessWidget {
  final String headingTerminal;

  SendEmailToSupport({Key? key, this.headingTerminal = "Problem"})
      : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Scaffold(
      appBar: _headerSection(context),
      backgroundColor: AppColors.getBgColor(_isDarkMode),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _problemHeading(context),
                _problemDescription(context),
                _submitProblem(context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  _headerSection(BuildContext context){
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.getBgColor(_isDarkMode),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_outlined, color: _isDarkMode?AppColors.pureWhiteColor:AppColors.lightChatConnectionTextColor)),
          Text(
            "Submit Your $headingTerminal",
            style:
            TextStyleCollection.terminalTextStyle.copyWith(fontSize: 16, color: _isDarkMode?AppColors.pureWhiteColor:AppColors.lightChatConnectionTextColor),
          ),
        ],
      ),
    );
  }

  _problemHeading(BuildContext context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: _subjectController,
        style: TextStyleCollection.terminalTextStyle
            .copyWith(fontSize: 14, color: _isDarkMode?AppColors.pureWhiteColor:AppColors.lightChatConnectionTextColor),
        cursorColor: _isDarkMode?AppColors.pureWhiteColor:AppColors.lightLatestMsgTextColor,
        validator: (inputVal) {
          if (inputVal == null || inputVal.isEmpty) return "* Required";
          return null;
        },
        decoration: InputDecoration(
          alignLabelWithHint: true,
          labelText: "$headingTerminal Statement",
          labelStyle: TextStyleCollection.terminalTextStyle.copyWith(
              fontSize: 14,
              color: _isDarkMode
                  ? AppColors.pureWhiteColor.withOpacity(0.8)
                  : AppColors.lightLatestMsgTextColor),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: _isDarkMode
                      ? AppColors.pureWhiteColor
                      : AppColors.lightChatConnectionTextColor)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: _isDarkMode
                      ? AppColors.pureWhiteColor
                      : AppColors.lightChatConnectionTextColor)),
        ),
      ),
    );
  }

  _problemDescription(BuildContext context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: TextFormField(
        controller: _bodyController,
        style: TextStyleCollection.terminalTextStyle
            .copyWith(fontSize: 14, color: _isDarkMode?AppColors.pureWhiteColor:AppColors.lightChatConnectionTextColor),
        cursorColor: _isDarkMode?AppColors.pureWhiteColor:AppColors.lightLatestMsgTextColor,
        maxLines: null,
        validator: (inputVal) {
          if (inputVal == null || inputVal.isEmpty) return "* Required";
          return null;
        },
        decoration: InputDecoration(
          alignLabelWithHint: true,
          labelText: "$headingTerminal Description",
          labelStyle: TextStyleCollection.terminalTextStyle.copyWith(
              fontSize: 14,color: _isDarkMode?AppColors.pureWhiteColor.withOpacity(0.6):AppColors.lightLatestMsgTextColor),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: _isDarkMode
                      ? AppColors.pureWhiteColor
                      : AppColors.lightChatConnectionTextColor)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: _isDarkMode
                      ? AppColors.pureWhiteColor
                      : AppColors.lightChatConnectionTextColor)),
        ),
      ),
    );
  }

  _submitProblem(BuildContext context) {
    final InputOption _inputOption = InputOption(context);
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: commonElevatedButton(
          btnText: "Submit",
          bgColor: AppColors.getElevatedBtnColor(_isDarkMode),
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;

            await _inputOption.sendSupportMail(
                _subjectController.text, _bodyController.text);
          }),
    );
  }
}
