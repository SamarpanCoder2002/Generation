import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/config/text_style_collection.dart';
import 'package:provider/provider.dart';

import '../../providers/contacts_provider.dart';

class ContactManagement {
  Widget contactCard(
      {required String name,
      required String phNumber,
      required bool isSelected,
      required BuildContext context,
      required int contactIndex}) {
    return Card(
      elevation: 2,
      color: AppColors.oppositeMsgDarkModeColor,
      shadowColor: AppColors.pureWhiteColor,
      child: ListTile(
        title: Text(
          name,
          overflow: TextOverflow.ellipsis,
          style:
              TextStyleCollection.activityTitleTextStyle.copyWith(fontSize: 16),
        ),
        subtitle: Container(
            margin: const EdgeInsets.only(top: 5),
            child: Text(
              phNumber,
              style: TextStyleCollection.activityTitleTextStyle
                  .copyWith(fontWeight: FontWeight.normal),
            )),
        leading: IconButton(
          icon: Icon(
            isSelected ? Icons.circle : Icons.circle_outlined,
            color: AppColors.pureWhiteColor,
          ),
          onPressed: () {
            if(isSelected) {
              Provider.of<ContactsProvider>(context, listen: false)
                .unselectContact(contactIndex);
            }else{
              Provider.of<ContactsProvider>(context, listen: false)
                  .selectContact(contactIndex);
            }
          },
        ),
      ),
    );
  }
}
