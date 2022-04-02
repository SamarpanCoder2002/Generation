import 'dart:io';

import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/screens/common/button.dart';
import 'package:generation/screens/common/image_showing_screen.dart';
import 'package:generation/services/input_system_services.dart';
import 'package:generation/services/toast_message_show.dart';
import 'package:generation/types/types.dart';
import 'package:provider/provider.dart';

import '../../config/text_style_collection.dart';
import '../../providers/theme_provider.dart';
import '../../services/device_specific_operations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Map<String, dynamic> _actualProfileData = {};

  final Map<String, dynamic> _editableProfileData = {
    "profile_image":
        "https://media.self.com/photos/618eb45bc4880cebf08c1a5b/4:3/w_2687,h_2015,c_limit/1236337133",
    "name": "Samarpan Dasgupta",
    "user_name": "SamarpanCoder2002",
    "about": "What You Seek is Seeking You",
    "email": "samarpanofficial2021@gmail.com"
  };

  @override
  void initState() {
    _actualProfileData["profile_image"] = _editableProfileData["profile_image"];
    _actualProfileData["name"] = _editableProfileData["name"];
    _actualProfileData["user_name"] = _editableProfileData["user_name"];
    _actualProfileData["about"] = _editableProfileData["about"];
    _actualProfileData["email"] = _editableProfileData["email"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkMode,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.all(20),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          children: [
            _heading(),
            _profileImageSection(),
            const SizedBox(height: 20),
            _commonSection(
                iconData: Icons.account_circle_outlined,
                heading: "Name",
                mapKey: "name",
                nameValue: _editableProfileData["name"]),
            const SizedBox(height: 10),
            // _commonSection(
            //     iconData: Icons.person_outline_outlined,
            //     heading: "User Name",
            //     mapKey: "user_name",
            //     nameValue: _editableProfileData["user_name"]),
            // const SizedBox(height: 10),
            _commonSection(
                iconData: Icons.info_outlined,
                heading: "About",
                mapKey: "about",
                nameValue: _editableProfileData["about"]),
            const SizedBox(height: 10),
            _commonSection(
                iconData: Icons.email_outlined,
                heading: "Email",
                mapKey: "email",
                showEditSection: false,
                nameValue: _editableProfileData["email"]),
            const SizedBox(height: 30),
            _saveButton(),
          ],
        ),
      ),
    );
  }

  _heading() {
    return Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(left: 5),
        child: Row(
          children: [
            InkWell(
              child: const Icon(
                Icons.arrow_back_outlined,
                color: AppColors.pureWhiteColor,
              ),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              "Profile",
              style:
                  TextStyleCollection.headingTextStyle.copyWith(fontSize: 20),
            ),
          ],
        ));
  }

  _profileImageSection() {
    return Center(
      child: Stack(
        children: [
          _imageSection(),
          _imagePickingSection(),
        ],
      ),
    );
  }

  _imageSection() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return InkWell(
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ImageShowingScreen(
                    imgPath: _editableProfileData["profile_image"],
                    imageType: _editableProfileData["profile_image"]
                            .startsWith("https")
                        ? ImageType.network
                        : ImageType.file))).then((value) {
          showStatusAndNavigationBar();

          changeOnlyNavigationBarColor(
              navigationBarColor: AppColors.getBgColor(_isDarkMode));
        });
      },
      child: Container(
        width: 125,
        height: 125,
        margin: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: AppColors.oppositeMsgDarkModeColor,
            border: Border.all(color: AppColors.darkBorderGreenColor, width: 3),
            image: _editableProfileData["profile_image"].startsWith("https")
                ? DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(_editableProfileData["profile_image"]),
                  )
                : DecorationImage(
                    fit: BoxFit.cover,
                    image:
                        FileImage(File(_editableProfileData["profile_image"])),
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

  _commonSection(
      {required IconData iconData,
      required String heading,
      required String mapKey,
      required String nameValue,
      bool showEditSection = true}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _nameLeftSection(
              iconData: iconData, heading: heading, nameValue: nameValue),
          showEditSection
              ? _editSection(
                  previousValue: nameValue,
                  parameterKey: mapKey,
                  editContent: heading)
              : const Center(),
        ],
      ),
    );
  }

  _nameLeftSection(
      {required IconData iconData,
      required String heading,
      required String nameValue}) {
    return Row(
      children: [
        Icon(
          iconData,
          color: AppColors.darkBorderGreenColor,
          size: 25,
        ),
        const SizedBox(
          width: 15,
        ),
        Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width - 40 - 100,
              child: Text(
                heading,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyleCollection.terminalTextStyle
                    .copyWith(color: AppColors.pureWhiteColor.withOpacity(0.6)),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 40 - 100,
              child: Text(
                nameValue,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyleCollection.secondaryHeadingTextStyle
                    .copyWith(fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  _editSection(
      {required String editContent,
      required String previousValue,
      required String parameterKey}) {
    return Container(
        margin: const EdgeInsets.only(top: 10),
        child: IconButton(
          icon: const Icon(
            Icons.create_rounded,
            color: AppColors.pureWhiteColor,
            size: 20,
          ),
          onPressed: () {
            _editing(
                editContent: editContent,
                previousValue: previousValue,
                parameterKey: parameterKey);
          },
        ));
  }

  _saveButton() {
    if (_actualProfileData["profile_image"] ==
            _editableProfileData["profile_image"] &&
        _actualProfileData["name"] == _editableProfileData["name"] &&
        _actualProfileData["user_name"] == _editableProfileData["user_name"] &&
        _actualProfileData["about"] == _editableProfileData["about"] &&
        _actualProfileData["email"] == _editableProfileData["email"]) {
      return const Center();
    }

    return Center(
        child: commonElevatedButton(
            btnText: "Save",
            onPressed: () {
              if (mounted) {
                setState(() {
                  _actualProfileData["profile_image"] =
                      _editableProfileData["profile_image"];
                  _actualProfileData["name"] = _editableProfileData["name"];
                  _actualProfileData["user_name"] =
                      _editableProfileData["user_name"];
                  _actualProfileData["about"] = _editableProfileData["about"];
                  _actualProfileData["email"] = _editableProfileData["email"];
                });
              }

              showToast(context,
                  title: "Profile Updated",
                  toastIconType: ToastIconType.success,
                  toastDuration: 6,
                  showFromTop: false);
            }));
  }

  _imageTakingOption() {
    final InputOption _inputOption = InputOption(context);

    showModalBottomSheet(
        context: context,
        elevation: 5,
        builder: (_) => Container(
              color: AppColors.backgroundDarkMode,
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final String? imgPath = await _inputOption
                          .takeImageFromCamera(forChat: false);
                      if (imgPath == null) return;

                      if (mounted) {
                        setState(() {
                          _editableProfileData["profile_image"] = imgPath;
                        });
                      }
                    },
                    child: const Text("Camera"),
                    style: ElevatedButton.styleFrom(
                        primary: AppColors.oppositeMsgDarkModeColor),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final String? imgPath =
                          await _inputOption.pickSingleImageFromGallery();

                      if (imgPath == null) return;

                      if (mounted) {
                        setState(() {
                          _editableProfileData["profile_image"] = imgPath;
                        });
                      }
                    },
                    child: const Text("Gallery"),
                    style: ElevatedButton.styleFrom(
                        primary: AppColors.oppositeMsgDarkModeColor),
                  ),
                ],
              ),
            ));
  }

  _editing(
      {required String editContent,
      required String previousValue,
      required String parameterKey}) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: AppColors.oppositeMsgDarkModeColor,
              title: Text(
                editContent,
                style: TextStyleCollection.secondaryHeadingTextStyle
                    .copyWith(fontSize: 14),
              ),
              content: TextFormField(
                cursorColor: AppColors.pureWhiteColor,
                style: TextStyleCollection.searchTextStyle,
                initialValue: _editableProfileData[parameterKey],
                onChanged: (inputVal) {
                  if (mounted) {
                    setState(() {
                      _editableProfileData[parameterKey] = inputVal;
                    });
                  }
                },
                decoration: InputDecoration(
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.pureWhiteColor)),
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.pureWhiteColor)),
                  hintText: "Enter $editContent Here",
                  hintStyle: TextStyleCollection.searchTextStyle.copyWith(
                      fontSize: 16,
                      color: AppColors.pureWhiteColor.withOpacity(0.8)),
                ),
              ),
              actions: [
                Center(
                  child: commonElevatedButton(
                      btnText: "Ok",
                      onPressed: () => Navigator.pop(context),
                      bgColor: AppColors.myMsgDarkModeColor),
                ),
              ],
            ));
  }
}
