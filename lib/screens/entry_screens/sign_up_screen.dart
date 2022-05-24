import 'package:flutter/material.dart';
import 'package:generation/config/regex_collection.dart';
import 'package:generation/operation/email_auth.dart';
import 'package:generation/screens/entry_screens/sign_in_screen.dart';
import 'package:generation/services/toast_message_show.dart';
import 'package:generation/config/types.dart';

import '../../config/colors_collection.dart';
import '../../config/text_style_collection.dart';
import '../../services/navigation_management.dart';
import '../common/button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _confirmPwdController = TextEditingController();

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
                    "Sign Up",
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
                  height: 30,
                ),
                _commonTextField(
                    labelText: "Password",
                    textEditingController: _pwdController),
                const SizedBox(
                  height: 30,
                ),
                _commonTextField(
                    labelText: "Confirm Password",
                    textEditingController: _confirmPwdController),
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
          }else if(inputVal.length < 6){
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

  void _onSubmitInformation() async{
    if (!_formKey.currentState!.validate()) return;
    if(_pwdController.text != _confirmPwdController.text) {
      showToast(context, title: "Password and Confirm Password are not same", toastIconType: ToastIconType.error, showFromTop: false);
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    
    final EmailAuth _emailAuth = EmailAuth(email: _emailController.text, pwd: _pwdController.text);

    final _response = await _emailAuth.signUp();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }


    if(_response){
      showPopUpDialog(context, "Sign Up Successful", "A verification email is sent to your email. Please verify your email at first", (){
        Navigator.pop(context);
        Navigator.pop(context);
      });
    }else{
      showToast(context, title: "Email Already Exist Before", toastIconType: ToastIconType.error, showFromTop: false);
    }








    // Timer(const Duration(seconds: 10), () {
    //   if (mounted) {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   }
    // });
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
        "Sign In",
        style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
            decoration: TextDecoration.underline, fontWeight: FontWeight.w600, letterSpacing: 1),
      ),
      onPressed: () => Navigator.pop(context),
    );
  }
}
