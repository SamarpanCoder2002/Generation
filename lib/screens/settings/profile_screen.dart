import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/screens/common/button.dart';
import 'package:generation/services/input_system_services.dart';

import '../../config/text_style_collection.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
                nameValue: "Samarpan Dasgupta"),
            const SizedBox(height: 10),
            _commonSection(
                iconData: Icons.person_outline_outlined,
                heading: "User Name",
                nameValue: "SamarpanCoder2002"),
            const SizedBox(height: 10),
            _commonSection(
                iconData: Icons.info_outlined,
                heading: "About",
                nameValue: "What You Seek is Seeking You"),
            const SizedBox(height: 10),
            _commonSection(
                iconData: Icons.email_outlined,
                heading: "Email",
                nameValue: "samarpanofficial2021@gmail.com"),
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
            InkWell(child: const Icon(Icons.arrow_back_outlined, color: AppColors.pureWhiteColor,), onTap: () => Navigator.pop(context),),
            const SizedBox(width: 10,),
            Text(
              "Profile",
              style: TextStyleCollection.headingTextStyle.copyWith(fontSize: 20),
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
    return Container(
      width: 125,
      height: 125,
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: AppColors.pureWhiteColor,
          border: Border.all(color: AppColors.darkBorderGreenColor, width: 3),
          image: const DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(
                "https://media.self.com/photos/618eb45bc4880cebf08c1a5b/4:3/w_2687,h_2015,c_limit/1236337133"),
          )),
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
      required String nameValue}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _nameLeftSection(
              iconData: iconData, heading: heading, nameValue: nameValue),
          _editSection(),
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

  _editSection() {
    return Container(
        margin: const EdgeInsets.only(top: 10),
        child: IconButton(
          icon: const Icon(
            Icons.create_rounded,
            color: AppColors.pureWhiteColor,
            size: 20,
          ),
          onPressed: () {},
        ));
  }

  _saveButton() {
    return Center(
        child: commonElevatedButton(btnText: "Save", onPressed: () {}));
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
                    onPressed: () {
                      // _inputOption.takeImageFromCamera();
                    },
                    child: const Text("Camera"),
                    style: ElevatedButton.styleFrom(
                        primary: AppColors.oppositeMsgDarkModeColor),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // _inputOption.pickImageFromGallery();
                    },
                    child: const Text("Gallery"),
                    style: ElevatedButton.styleFrom(
                        primary: AppColors.oppositeMsgDarkModeColor),
                  ),
                ],
              ),
            ));
  }
}
