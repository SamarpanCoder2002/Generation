import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../config/colors_collection.dart';
import '../../config/text_style_collection.dart';

class ChatBoxHeaderSection extends StatelessWidget {
  final Map<String, dynamic> connectionData;
  final BuildContext context;

  const ChatBoxHeaderSection(
      {Key? key, required this.connectionData, required this.context})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _headingSection();
  }

  _headingSection() {
    return Container(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            _backButton(),
            _headerProfilePicSection(),
            _profileShortInformationSection(),
            _terminalSection(),
          ],
        ));
  }

  _headerProfilePicSection() {
    return Container(
      width: 45,
      height: 45,
      margin: EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
          color: AppColors.searchBarBgDarkMode.withOpacity(0.5),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.darkBorderGreenColor, width: 2),
          image: connectionData["profilePic"] == null
              ? null
              : DecorationImage(
                  image: NetworkImage(connectionData["profilePic"]),
                  fit: BoxFit.cover)),
    );
  }

  _profileShortInformationSection() {
    return Container(
      width: (MediaQuery.of(context).size.width - 40) / 1.7,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              connectionData["connectionName"],
              overflow: TextOverflow.ellipsis,
              style:
                  TextStyleCollection.headingTextStyle.copyWith(fontSize: 16),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Online",
                style: TextStyleCollection.terminalTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _terminalSection() {
    return InkWell(
      child: Image.asset(
        "assets/images/video.png",
        width: 30,
      ),
      onTap: () {
        print("Video clickjed");
      },
    );
  }

  _backButton() {
    return InkWell(
      child: Icon(
        Icons.arrow_back_outlined,
        size: 20,
        color: AppColors.pureWhiteColor,
      ),
      onTap: () {},
    );
  }
}
