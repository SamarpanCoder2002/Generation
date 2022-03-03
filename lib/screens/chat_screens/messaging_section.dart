import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:generation/screens/chat_screens/data/data.dart';
import 'package:generation/types/types.dart';

class MessagingSection extends StatelessWidget {
  final BuildContext context;

  const MessagingSection({Key? key, required this.context}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height / 1.2,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: allChatMessages.length,
          itemBuilder: (_, index) {
            final messageData = allChatMessages[index];

            print("Message Data: $messageData");

            return _textMessageSection(
                messageId: messageData.keys.toList()[0].toString(),
                messageData: messageData.values.toList()[0],
                index: index);
          },
        ));
  }

  _textMessageSection(
      {required String messageId,
      required dynamic messageData,
      required int index}) {



    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: messageData["holder"] == MessageHolderType.me.toString()?AppColors.oppositeMsgDarkModeColor:AppColors.myMsgDarkModeColor,
        borderRadius: BorderRadius.circular(20)
      ),
      margin: EdgeInsets.only(
          bottom: 20,
          right: messageData["holder"] == MessageHolderType.me.toString()
              ? MediaQuery.of(context).size.width / 6
              : 0,
          left: messageData["holder"] == MessageHolderType.other.toString()
              ? MediaQuery.of(context).size.width / 6
              : 0),
      constraints: const BoxConstraints(maxHeight: double.infinity),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                messageData["message"],
                maxLines: 3,
                softWrap: true,
                style: TextStyleCollection.terminalTextStyle,
              ),
            ),
            Text(
              messageData["time"],
              softWrap: true,
              style: TextStyleCollection.terminalTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}
