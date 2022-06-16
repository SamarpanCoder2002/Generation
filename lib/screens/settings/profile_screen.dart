import 'dart:io';

import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/screens/common/button.dart';
import 'package:generation/screens/common/image_showing_screen.dart';
import 'package:generation/services/input_system_services.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:generation/services/navigation_management.dart';
import 'package:generation/services/toast_message_show.dart';
import 'package:generation/config/types.dart';
import 'package:provider/provider.dart';

import '../../config/text_style_collection.dart';
import '../../providers/theme_provider.dart';
import '../../services/debugging.dart';
import '../../services/device_specific_operations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LocalStorage _localStorage = LocalStorage();
  final Map<String, dynamic> _actualProfileData = {};
  final Map<String, dynamic> _editableProfileData = {};

  bool _isLoading = true;

  _getProfileData() async {
    final Map<String, dynamic> _currAccData =
        await _localStorage.getDataForCurrAccount();

    debugShow("Current Account data: $_currAccData");

    if (mounted) {
      setState(() {
        _currAccData.forEach((key, value) {
          _actualProfileData[key] = value;
          _editableProfileData[key] = value;
        });
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _getProfileData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Scaffold(
      backgroundColor: AppColors.getBgColor(_isDarkMode),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.all(20),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          children: [
            if (_isLoading) _loadingIndicator(),
            if (_isLoading)
              const SizedBox(
                height: 20,
              ),
            _heading(),
            _profileImageSection(),
            const SizedBox(height: 20),
            _commonSection(
                iconData: Icons.account_circle_outlined,
                heading: "Name",
                mapKey: "name",
                nameValue: _editableProfileData["name"] ?? ""),
            const SizedBox(height: 10),
            _commonSection(
                iconData: Icons.info_outlined,
                heading: "About",
                mapKey: "about",
                nameValue: _editableProfileData["about"] ?? ""),
            const SizedBox(height: 10),
            _commonSection(
                iconData: Icons.email_outlined,
                heading: "Email",
                mapKey: "email",
                showEditSection: false,
                nameValue: _editableProfileData["email"] ?? ""),
            const SizedBox(height: 30),
            if (!_isLoading) _saveButton(),
          ],
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

  _heading() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(left: 5),
        child: Row(
          children: [
            InkWell(
              child: Icon(
                Icons.arrow_back_outlined,
                color: _isDarkMode
                    ? AppColors.pureWhiteColor
                    : AppColors.lightChatConnectionTextColor,
              ),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              "Profile",
              style: TextStyleCollection.headingTextStyle.copyWith(
                  fontSize: 20,
                  color: _isDarkMode
                      ? AppColors.pureWhiteColor
                      : AppColors.lightChatConnectionTextColor),
            ),
          ],
        ));
  }

  _profileImageSection() {
    return _editableProfileData.isEmpty
        ? const Center()
        : Center(
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
        Navigation.intent(
            context,
            ImageShowingScreen(
                imgPath: _editableProfileData["profilePic"],
                imageType:
                    _editableProfileData["profilePic"].startsWith("https")
                        ? ImageType.network
                        : ImageType.file), afterWork: () {
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
            color: AppColors.getImageBgColor(_isDarkMode),
            border: Border.all(color: AppColors.darkBorderGreenColor, width: 3),
            image: _editableProfileData["profilePic"]?.startsWith("https")
                ? DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(_editableProfileData["profilePic"]),
                  )
                : DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(File(_editableProfileData["profilePic"])),
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
    return _editableProfileData.isEmpty
        ? const Center()
        : SizedBox(
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
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

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
                style: TextStyleCollection.terminalTextStyle.copyWith(
                    color: _isDarkMode
                        ? AppColors.pureWhiteColor.withOpacity(0.6)
                        : AppColors.lightChatConnectionTextColor
                            .withOpacity(0.6)),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 40 - 100,
              child: Text(
                nameValue,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
                    fontSize: 14,
                    color: _isDarkMode
                        ? AppColors.pureWhiteColor
                        : AppColors.lightChatConnectionTextColor),
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
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
        margin: const EdgeInsets.only(top: 10),
        child: IconButton(
          icon: Icon(
            Icons.create_rounded,
            color: AppColors.getIconColor(_isDarkMode),
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

  _imageTakingOption() {
    final InputOption _inputOption = InputOption(context);
    final _isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkTheme();

    _onCameraPressed() async {
      final String? imgPath =
          await _inputOption.takeImageFromCamera(forChat: false);
      if (imgPath == null) return;

      if (mounted) {
        setState(() {
          _editableProfileData["profilePic"] = imgPath;
        });
      }
    }

    _onGalleryPressed() async {
      final String? imgPath = await _inputOption.pickSingleImageFromGallery();

      debugShow("Image Path is: $imgPath");

      if (imgPath == null) return;

      if (mounted) {
        setState(() {
          _editableProfileData["profilePic"] = imgPath;
        });
      }
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        builder: (_) => Container(
              color: AppColors.getBgColor(_isDarkMode),
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  commonElevatedButton(
                      btnText: "Camera",
                      onPressed: _onCameraPressed,
                      bgColor: AppColors.getElevatedBtnColor(_isDarkMode)),
                  commonElevatedButton(
                      btnText: "Gallery",
                      onPressed: _onGalleryPressed,
                      bgColor: AppColors.getElevatedBtnColor(_isDarkMode))
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

  _saveButton() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    if (_actualProfileData["profilePic"] ==
            _editableProfileData["profilePic"] &&
        _actualProfileData["name"] == _editableProfileData["name"] &&
        _actualProfileData["name"] == _editableProfileData["name"] &&
        _actualProfileData["about"] == _editableProfileData["about"] &&
        _actualProfileData["email"] == _editableProfileData["email"]) {
      return const Center();
    }

    return Center(
        child: commonElevatedButton(
            btnText: "Save",
            onPressed: _onSave,
            bgColor: AppColors.getElevatedBtnColor(_isDarkMode)));
  }

  _onSave() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final DBOperations _dbOperations = DBOperations();
    final _response = await _dbOperations.createAccount(
        name: _editableProfileData["name"],
        about: _editableProfileData["about"],
        profilePic: _editableProfileData["profilePic"],
        update: true);

    if (_response["success"]) {
      final _updatedData = _response["data"];
      await _localStorage.insertUpdateDataCurrAccData(
          currUserId: _updatedData["id"],
          currUserName: _updatedData["name"],
          currUserProfilePic: _updatedData["profilePic"],
          currUserAbout: _updatedData["about"],
          currUserEmail: _editableProfileData["email"],
          dbOperation: DBOperation.update);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    if (_response["success"]) {
      if (mounted) {
        setState(() {
          _actualProfileData["profilePic"] = _editableProfileData["profilePic"];
          _actualProfileData["name"] = _editableProfileData["name"];
          _actualProfileData["name"] = _editableProfileData["name"];
          _actualProfileData["about"] = _editableProfileData["about"];
          _actualProfileData["email"] = _editableProfileData["email"];
        });
      }

      showToast(
          title: _response["message"],
          toastIconType: ToastIconType.success,
          toastDuration: 6,
          showFromTop: false);
    } else {
      showToast(
          title: "Profile Update Failed",
          toastIconType: ToastIconType.success,
          toastDuration: 6,
          showFromTop: false);
    }
  }
}
