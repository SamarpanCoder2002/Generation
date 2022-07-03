import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:generation/config/colors_collection.dart';
import 'package:generation/providers/contacts_provider.dart';
import 'package:generation/providers/theme_provider.dart';
import 'package:generation/screens/common/contact_card_design.dart';
import 'package:generation/services/local_data_management.dart';
import 'package:provider/provider.dart';

import '../../../config/images_path_collection.dart';
import '../../../config/text_collection.dart';
import '../../../config/text_style_collection.dart';
import '../../../providers/chat/chat_creation_section_provider.dart';
import '../../../providers/chat/chat_scroll_provider.dart';
import '../../../providers/chat/messaging_provider.dart';
import '../../../config/types.dart';

class ContactsCollection extends StatefulWidget {
  const ContactsCollection({Key? key}) : super(key: key);

  @override
  State<ContactsCollection> createState() => _ContactsCollectionState();
}

class _ContactsCollectionState extends State<ContactsCollection> {
  final ContactManagement _contactManagement = ContactManagement();

  @override
  Widget build(BuildContext context) {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Scaffold(
      backgroundColor: AppColors.getChatBgColor(_isDarkMode),
      floatingActionButton: Provider.of<ContactsProvider>(context)
                  .getLengthOfTotalFilteredContacts() >
              0
          ? _sendButton()
          : null,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _headingSection(),
              const SizedBox(height: 15),
              _selectedContactsCollection(),
              if (Provider.of<ContactsProvider>(context)
                      .getLengthOfTotalFilteredContacts() >
                  0)
                const SizedBox(height: 15),
              _searchBar(),
              const SizedBox(height: 15),
              _screenHeading(),
              _contactsCollection(),
            ],
          ),
        ),
      ),
    );
  }

  _headingSection() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(left: 23),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Provider.of<ContactsProvider>(context)
                          .getLengthOfTotalFilteredContacts() ==
                      0
                  ? AppText.appName
                  : "Filtered Contacts",
              style: TextStyleCollection.headingTextStyle.copyWith(
                  fontSize: 20,
                  color: _isDarkMode
                      ? AppColors.pureWhiteColor
                      : AppColors.lightTextColor),
            ),
            if (Provider.of<ContactsProvider>(context)
                    .getLengthOfTotalFilteredContacts() >
                0)
              TextButton(
                child: Text(
                  "Clear Selection",
                  style: TextStyleCollection.headingTextStyle.copyWith(
                      fontSize: 14,
                      color: _isDarkMode
                          ? AppColors.pureWhiteColor
                          : AppColors.lightTextColor),
                ),
                onPressed: () {
                  Provider.of<ContactsProvider>(context, listen: false)
                      .resetData();
                },
              )
          ],
        ));
  }

  _searchBar() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: _isDarkMode
            ? AppColors.searchBarBgDarkMode
            : AppColors.pureWhiteColor,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(
              Icons.search_outlined,
              color: _isDarkMode
                  ? AppColors.pureWhiteColor
                  : AppColors.lightTextColor.withOpacity(0.8),
            ),
          ),
          Expanded(
            child: TextField(
              cursorColor: _isDarkMode
                  ? AppColors.pureWhiteColor
                  : AppColors.lightTextColor.withOpacity(0.8),
              style: TextStyleCollection.searchTextStyle.copyWith(
                  color: _isDarkMode
                      ? AppColors.pureWhiteColor
                      : AppColors.lightTextColor.withOpacity(0.8)),
              onChanged: (inputVal) =>
                  Provider.of<ContactsProvider>(context, listen: false)
                      .filteredData(inputVal),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Search",
                hintStyle: TextStyleCollection.searchTextStyle.copyWith(
                    color: _isDarkMode
                        ? AppColors.pureWhiteColor.withOpacity(0.8)
                        : AppColors.lightTextColor.withOpacity(0.8)),
              ),
            ),
          )
        ],
      ),
    );
  }

  _screenHeading() {
    final _isDarkMode = Provider.of<ThemeProvider>(context).isDarkTheme();

    return Align(
      alignment: Alignment.topLeft,
      child: Text(
        "Contacts",
        style: TextStyleCollection.secondaryHeadingTextStyle.copyWith(
            color: _isDarkMode
                ? AppColors.pureWhiteColor
                : AppColors.lightTextColor),
      ),
    );
  }

  _contactsCollection() {
    return Container(
      width: double.maxFinite,
      height: Provider.of<ContactsProvider>(context)
                  .getLengthOfTotalFilteredContacts() ==
              0
          ? MediaQuery.of(context).size.height / 1.25
          : MediaQuery.of(context).size.height / 1.8,
      margin: const EdgeInsets.only(top: 5),
      child: Provider.of<ContactsProvider>(context)
                  .getLengthOfTotalPhoneContacts() >
              0
          ? ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: Provider.of<ContactsProvider>(context)
                  .getLengthOfTotalPhoneContacts(),
              itemBuilder: (_, index) {
                final contact = Provider.of<ContactsProvider>(context)
                    .getAllPhoneContacts()[index];

                final _phoneNumbersCollection = contact.phones;

                return _contactManagement.contactCard(
                    name: contact.displayName ?? "",
                    phNumber: _phoneNumbersCollection == null
                        ? ""
                        : _phoneNumbersCollection.isEmpty
                            ? ""
                            : _phoneNumbersCollection[0].value.toString(),
                    isSelected: false,
                    context: context,
                    contactIndex: index);
              },
            )
          : Center(
              child: Text(
                "No Contacts Found",
                style: TextStyleCollection.activityTitleTextStyle
                    .copyWith(fontSize: 16),
              ),
            ),
    );
  }

  _sendButton() {
    return FloatingActionButton(
      tooltip: 'Send Selected Contacts',
      shape: const CircleBorder(
          side: BorderSide(color: AppColors.pureWhiteColor, width: 1)),
      elevation: 10,
      backgroundColor: AppColors.searchBarBgDarkMode,
      child: Image.asset(
        IconImages.sendImagePath,
        width: 28,
      ),
      onPressed: () {
        final List<Contact> _filteredContacts =
            Provider.of<ContactsProvider>(context, listen: false)
                .getFilteredContacts();

        Provider.of<ContactsProvider>(context, listen: false).resetData();

        final _replyMsg =
            Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                .getReplyModifiedMsg();

        for (final filterContact in _filteredContacts) {
          final _phoneNumbersCollection = filterContact.phones;

          Provider.of<ChatBoxMessagingProvider>(context, listen: false)
              .sendMsgManagement(
                  msgType: ChatMessageType.contact.toString(),
                  message: {
                    PhoneNumberData.number: _phoneNumbersCollection!.isNotEmpty
                        ? _phoneNumbersCollection[0].value ?? ""
                        : "",
                    PhoneNumberData.name: filterContact.displayName,
                    PhoneNumberData.numberLabel:
                        _phoneNumbersCollection[0].label
                  },
                  additionalData: _replyMsg.isEmpty
                      ? null
                      : {'reply': DataManagement.toJsonString(_replyMsg)});
        }

        if (_replyMsg.isNotEmpty) {
          Provider.of<ChatBoxMessagingProvider>(context, listen: false)
              .removeReplyMsg();
          Provider.of<ChatCreationSectionProvider>(context, listen: false)
              .backToNormalHeightForReply();
        }

        Provider.of<ChatScrollProvider>(context, listen: false)
            .animateToBottom();

        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
  }

  _selectedContactsCollection() {
    if (Provider.of<ContactsProvider>(context)
            .getLengthOfTotalFilteredContacts() ==
        0) return const Center();

    return ConstrainedBox(
        constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
            minHeight: 0,
            maxHeight: MediaQuery.of(context).size.height / 4.6),
        child: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            controller: Provider.of<ContactsProvider>(context)
                .getFilteredContactsScrollController(),
            physics: const BouncingScrollPhysics(),
            itemCount: Provider.of<ContactsProvider>(context)
                .getLengthOfTotalFilteredContacts(),
            itemBuilder: (_, index) {
              final contact = Provider.of<ContactsProvider>(context)
                  .getFilteredContacts()[index];

              final _phoneNumbersCollection = contact.phones;

              return _contactManagement.contactCard(
                  name: contact.displayName ?? "",
                  phNumber: _phoneNumbersCollection == null
                      ? ""
                      : _phoneNumbersCollection.isEmpty
                          ? ""
                          : _phoneNumbersCollection[0].value.toString(),
                  isSelected: true,
                  context: context,
                  contactIndex: index);
            },
          ),
        ));
  }
}
