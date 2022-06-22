import 'package:flutter/material.dart';

class ConnectionManagementProvider extends ChangeNotifier {
  final List<String> _tabsCollection = ["Available", "Incoming", "Sent"];

  getTabsCollection() => _tabsCollection;

  getTabsCollectionLength() => _tabsCollection.length;
}
