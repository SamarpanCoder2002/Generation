import 'package:flutter/material.dart';
import 'package:generation/config/regex_collection.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/screens/entry_screens/information_taking.dart';
import 'package:generation/screens/entry_screens/sign_up_screen.dart';
import 'package:generation/screens/main_screens/main_screen_management.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:generation/services/navigation_management.dart';
import 'package:generation/services/toast_message_show.dart';
import 'package:generation/types/types.dart';

import '../../config/colors_collection.dart';
import '../../config/text_style_collection.dart';
import '../../operation/email_auth.dart';
import '../common/button.dart';
import '../common/common_operations.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final DBOperations _dbOperations = DBOperations();
  final LocalStorage _localStorage = LocalStorage();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashScreenColor,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                if (_isLoading)
                  const SizedBox(
                    height: 40,
                  ),
                if (_isLoading) _loadingIndicator(),
                SizedBox(
                  height: _isLoading ? 30 : 80,
                ),
                Center(
                  child: Text(
                    "Sign In",
                    style: TextStyleCollection.headingTextStyle
                        .copyWith(fontSize: 23, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                _commonTextField(
                    labelText: "Email",
                    textEditingController: _emailController),
                const SizedBox(
                  height: 15,
                ),
                _commonTextField(
                    labelText: "Password",
                    textEditingController: _pwdController),
                if (!_isLoading)
                  const SizedBox(
                    height: 40,
                  ),
                if (!_isLoading)
                  commonElevatedButton(
                      btnText: "Submit",
                      onPressed: _onSubmitInformation,
                      bgColor: AppColors.darkBorderGreenColor),
                if (!_isLoading)
                  const SizedBox(
                    height: 15,
                  ),
                if (!_isLoading) _signInSwitching(),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _commonTextField(
      {required String labelText,
      required TextEditingController textEditingController,
      bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        style: TextStyleCollection.terminalTextStyle.copyWith(fontSize: 14),
        cursorColor: AppColors.pureWhiteColor,
        controller: textEditingController,
        enabled: enabled,
        validator: (inputVal) {
          if (inputVal == null || inputVal.isEmpty) return "*Required";
          if (labelText == "Email" &&
              !RegexCollection.emailRegex.hasMatch(inputVal)) {
            return "*Please provider a valid email";
          } else if (inputVal.length < 6) {
            return "Password Must be at least 6 characters";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyleCollection.terminalTextStyle.copyWith(
              fontSize: 14, color: AppColors.pureWhiteColor.withOpacity(0.8)),
          alignLabelWithHint: true,
          errorStyle: TextStyleCollection.terminalTextStyle,
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.pureWhiteColor)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.pureWhiteColor)),
          disabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.pureWhiteColor)),
        ),
      ),
    );
  }



  _loadingIndicator() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 3,
      child: const LinearProgressIndicator(
        backgroundColor: AppColors.pureWhiteColor,
        color: AppColors.darkBorderGreenColor,
      ),
    );
  }

  _signInSwitching() {
    return TextButton(
      child: Text(
        "Sign Up",
        style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.w600,
            letterSpacing: 1),
      ),
      onPressed: () => Navigation.intent(context, const SignUpScreen()),
    );
  }

  void _onSubmitInformation() async {
    if (!_formKey.currentState!.validate()) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final EmailAuth _emailAuth =
    EmailAuth(email: _emailController.text, pwd: _pwdController.text);

    final _data = await _emailAuth.signIn();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    print("Data is: $_data");

    showToast(context,
        title: _data["message"],
        toastIconType:
        _data["success"] ? ToastIconType.success : ToastIconType.error,
        showFromTop: false,
        toastDuration: 5);

    if (!_data["success"]) return;

    final _createdBefore = await _dbOperations.isAccountCreatedBefore();

    if (!_createdBefore["success"]) {
      Navigation.intent(
          context,
          InformationTakingScreen(
            email: _emailController.text,
          ));
    } else {
      dataFetchingOperations(context, _createdBefore, _dbOperations.currUid);
    }
  }
}
