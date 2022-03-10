import 'dart:async';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

class ContactsProvider extends ChangeNotifier {
  List<Contact> _phoneContacts = [];
  final List<Contact> _filteredPhoneContacts = [];
  final ScrollController _filteredContactsController = ScrollController();

  setPhoneContacts(List<Contact> incomingContacts) {
    _phoneContacts = incomingContacts;
    notifyListeners();
  }

  getFilteredContactsScrollController() => _filteredContactsController;

  getAllPhoneContacts() => _phoneContacts;

  getLengthOfTotalPhoneContacts() => _phoneContacts.length;

  getFilteredContacts() => _filteredPhoneContacts;

  getLengthOfTotalFilteredContacts() => _filteredPhoneContacts.length;

  selectContact(index) {
    _filteredPhoneContacts.add(_phoneContacts[index]);
    _phoneContacts.removeAt(index);

    notifyListeners();

    if (_filteredPhoneContacts.length == 1) return;

    Timer(const Duration(milliseconds: 100), () {
      _filteredContactsController
          .animateTo(
        _filteredContactsController.position.maxScrollExtent,
        curve: Curves.fastLinearToSlowEaseIn,
        duration: const Duration(milliseconds: 750),
      )
          .whenComplete(() {
        notifyListeners();
      });
    });
  }

  unselectContact(index) {
    _phoneContacts.add(_filteredPhoneContacts[index]);
    _filteredPhoneContacts.removeAt(index);

    _phoneContacts.sort((firstContact, secondContact) => firstContact
        .displayName
        .toString()
        .compareTo(secondContact.displayName.toString()));
    notifyListeners();
  }

  filteredData(String query) async {
    final List<Contact> contacts = await ContactsService.getContacts(
        withThumbnails: false, query: query.isEmpty ? null : query);

    if (_filteredPhoneContacts.isNotEmpty) {
      contacts
          .removeWhere((contact) => _filteredPhoneContacts.contains(contact));
    }
    setPhoneContacts(contacts);
  }
}
