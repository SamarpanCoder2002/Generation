import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/screens/common/button.dart';
import 'package:generation/services/input_system_services.dart';

import '../../../config/text_style_collection.dart';

class SendEmailToSupport extends StatelessWidget {
  final String headingTerminal;
  SendEmailToSupport({Key? key, this.headingTerminal = "Problem"}) : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _headerSection(context),
      backgroundColor: AppColors.backgroundDarkMode,
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

  _headerSection(BuildContext context) => AppBar(
        elevation: 0,
        backgroundColor: AppColors.chatDarkBackgroundColor,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_outlined)),
            Text(
              "Submit Your $headingTerminal",
              style:
                  TextStyleCollection.terminalTextStyle.copyWith(fontSize: 16),
            ),
          ],
        ),
      );

  _problemHeading(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: _subjectController,
        style: TextStyleCollection.terminalTextStyle
            .copyWith(fontSize: 14, color: AppColors.pureWhiteColor),
        cursorColor: AppColors.pureWhiteColor,
        validator: (inputVal){
          if(inputVal == null || inputVal.isEmpty) return "* Required";
          return null;
        },
        decoration: InputDecoration(
          alignLabelWithHint: true,
          labelText: "$headingTerminal Statement",
          labelStyle: TextStyleCollection.terminalTextStyle.copyWith(
              fontSize: 14, color: AppColors.pureWhiteColor.withOpacity(0.6)),
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.pureWhiteColor)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.pureWhiteColor)),
        ),
      ),
    );
  }

  _problemDescription(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: TextFormField(
        controller: _bodyController,
        style: TextStyleCollection.terminalTextStyle
            .copyWith(fontSize: 14, color: AppColors.pureWhiteColor),
        cursorColor: AppColors.pureWhiteColor,
        maxLines: null,
        validator: (inputVal){
          if(inputVal == null || inputVal.isEmpty) return "* Required";
          return null;
        },
        decoration: InputDecoration(
          alignLabelWithHint: true,
          labelText: "$headingTerminal Description",
          labelStyle: TextStyleCollection.terminalTextStyle.copyWith(
              fontSize: 14, color: AppColors.pureWhiteColor.withOpacity(0.6)),
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.pureWhiteColor)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.pureWhiteColor)),
        ),
      ),
    );
  }

  _submitProblem(BuildContext context) {
    final InputOption _inputOption = InputOption(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: commonElevatedButton(btnText: "Submit", onPressed: ()async{
        if(!_formKey.currentState!.validate()) return;

        await _inputOption.sendSupportMail(_subjectController.text, _bodyController.text);
      }),
    );
  }
}
