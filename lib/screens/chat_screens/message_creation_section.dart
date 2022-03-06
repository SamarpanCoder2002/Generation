import 'package:flutter/material.dart';
import 'package:generation/providers/messaging_provider.dart';
import 'package:provider/provider.dart';

import '../../config/colors_collection.dart';
import '../../config/text_style_collection.dart';
import '../../types/types.dart';

class MessageCreationSection extends StatelessWidget {
  final BuildContext context;

  const MessageCreationSection({Key? key, required this.context})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 50,
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            width: 0,
            color: AppColors.chatDarkBackgroundColor,
          )),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 40,
              width: MediaQuery.of(context).size.width - 80,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: AppColors.messageWritingSectionColor),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {},
                      color: AppColors.pureWhiteColor.withOpacity(0.9),
                      icon: const Icon(Icons.emoji_emotions_outlined)),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 180,
                    child: TextField(
                      controller: Provider.of<ChatBoxMessagingProvider>(context).getTextController(),
                      style: TextStyleCollection.terminalTextStyle.copyWith(fontSize: 14),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(bottom: 10),
                        border: InputBorder.none,
                        hintText: "Write Something Here",
                        hintStyle: TextStyleCollection.searchTextStyle.copyWith(
                            color: AppColors.pureWhiteColor.withOpacity(0.8),
                            fontSize: 14),
                      ),
                    ),
                  ),
                  IconButton(
                      color: AppColors.pureWhiteColor.withOpacity(0.8),
                      onPressed: () {},
                      icon: const Icon(Icons.attachment_outlined)),
                ],
              ),
            ),
            IconButton(
              icon: Image.asset(
                "assets/images/send.png",
                width: 25,
              ),
              onPressed: () {
                final TextEditingController? _messageController = Provider.of<ChatBoxMessagingProvider>(context, listen: false).getTextController();
                Provider.of<ChatBoxMessagingProvider>(context, listen: false).setSingleNewMessage({
                  DateTime.now().toString(): {
                      "type": ChatMessageType.text.toString(),
                      "holder": Provider.of<ChatBoxMessagingProvider>(context, listen: false).getMessageHolderType().toString(),
                      "message": _messageController!.text,
                      "time": "20:40"
                  }
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
