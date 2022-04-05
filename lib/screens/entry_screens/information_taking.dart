import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/screens/common/button.dart';

import '../../config/colors_collection.dart';
import '../../config/icon_collection.dart';
import '../../services/device_specific_operations.dart';
import '../../services/input_system_services.dart';

class InformationTakingScreen extends StatefulWidget {
  const InformationTakingScreen({Key? key}) : super(key: key);

  @override
  State<InformationTakingScreen> createState() =>
      _InformationTakingScreenState();
}

class _InformationTakingScreenState extends State<InformationTakingScreen> {
  final Map<String, dynamic> userData = {
    "profilePic":
        "https://www.samarpandasgupta.com/static/media/samarpan_dasgupta.48a013aa.png",
    "name": "Samarpan Dasgupta",
    "email": "samarpan2dasgupta@gmail.com",
    "about": "Hey Guys, I am Using Generation"
  };

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void initState() {
    makeScreenCleanView();
    _nameController.text = userData["name"];
    _emailController.text = userData["email"];
    _aboutController.text = userData["about"];
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashScreenColor,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
                  height: _isLoading?30:40,
                ),
                Center(
                  child: Text(
                    "Complete Your Profile",
                    style: TextStyleCollection.headingTextStyle
                        .copyWith(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                _profilePictureSection(),
                const SizedBox(
                  height: 30,
                ),
                _commonTextField(
                    labelText: "Name", textEditingController: _nameController),
                const SizedBox(
                  height: 30,
                ),
                _commonTextField(
                    labelText: "Email",
                    enabled: false,
                    textEditingController: _emailController),
                const SizedBox(
                  height: 30,
                ),
                _commonTextField(
                    labelText: "About",
                    textEditingController: _aboutController),
                if (!_isLoading)
                const SizedBox(
                  height: 100,
                ),
                if (!_isLoading)
                  commonElevatedButton(
                      btnText: "Submit",
                      onPressed: _onSubmitInformation,
                      bgColor: AppColors.darkBorderGreenColor),
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

  _profilePictureSection() {
    return Center(
      child: Stack(
        children: [
          _imageSection(),
          if (!_isLoading) _imagePickingSection(),
        ],
      ),
    );
  }

  _imageSection() {
    return InkWell(
      onTap: () async {},
      child: Container(
        width: 120,
        height: 120,
        margin: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: AppColors.lightBlueColor.withOpacity(0.2),
            border: Border.all(color: AppColors.darkBorderGreenColor, width: 3),
            image: userData["profilePic"].startsWith("https")
                ? DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(userData["profilePic"]),
                  )
                : DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(File(userData["profilePic"])),
                  )),
      ),
    );
  }

  _imagePickingSection() {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(top: 20 + 80, left: 90),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: AppColors.darkBorderGreenColor,
        border: Border.all(color: AppColors.darkBorderGreenColor, width: 2),
      ),
      child: InkWell(
        onTap: _imageTakingOption,
        child: const Icon(
          Icons.camera_alt_outlined,
          color: AppColors.pureWhiteColor,
        ),
      ),
    );
  }

  _imageTakingOption() {
    showModalBottomSheet(
        context: context,
        elevation: 5,
        builder: (_) => Container(
              height: 120,
              color: AppColors.splashScreenColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _commonIconButton(0),
                  _commonIconButton(1),
                ],
              ),
            ));
  }

  _commonIconButton(int index) {
    final InputOption _inputOption = InputOption(context);

    return InkWell(
      onTap: () async {
        if (index == 0) {
          final String? imgPath =
              await _inputOption.takeImageFromCamera(forChat: false);
          if (imgPath == null) return;

          if (mounted) {
            setState(() {
              userData["profilePic"] = imgPath;
            });
          }
        } else {
          final String? imgPath =
              await _inputOption.pickSingleImageFromGallery();

          if (imgPath == null) return;

          if (mounted) {
            setState(() {
              userData["profilePic"] = imgPath;
            });
          }
        }
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: index == 0
                    ? AppColors.darkBorderGreenColor
                    : AppColors.personIconBgColor),
            child: IconCollection.iconsCollection[index][0],
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              IconCollection.iconsCollection[index][1],
              style:
                  TextStyleCollection.terminalTextStyle.copyWith(fontSize: 14),
            ),
          )
        ],
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

  void _onSubmitInformation() {
    if (!_formKey.currentState!.validate()) return;

    if(mounted){
      setState(() {
        _isLoading = true;
      });
    }

    Timer(const Duration(seconds: 10), (){
      if(mounted){
        setState(() {
          _isLoading = false;
        });
      }
    });
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
}