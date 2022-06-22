import 'package:flutter/material.dart';
import 'package:generation/services/encryption_operations.dart';

import '../../services/debugging.dart';

class AllAvailableConnectionsProvider extends ChangeNotifier {
  List<dynamic> _searchedConnections = [];
  List<dynamic> _allAvailableConnections = [];

  initialize({bool update = false}) {
    _searchedConnections = _allAvailableConnections;
    if (update) notifyListeners();
  }

  setConnections(incomingConnections) {
    _allAvailableConnections = incomingConnections;
    initialize(update: true);
    //initialize(update: true);
  }

  removeIndexFromSearch(int indexInSearch) {
    debugShow("Here After Sent Connection Request");
  if(indexInSearch > _searchedConnections.length - 1) return;
    _searchedConnections.removeAt(indexInSearch);
    notifyListeners();
  }

  operateOnSearch(searchKeyword) {
    List<dynamic> _tempSearchedCollection = [];

    if (searchKeyword == "" || searchKeyword == null) {
      _searchedConnections = _allAvailableConnections;
      notifyListeners();
      return;
    }

    for (final connection in _allAvailableConnections) {
      if (Secure.decode(connection["name"])
          .toString()
          .toLowerCase()
          .contains(searchKeyword.toString().toLowerCase())) {
        _tempSearchedCollection.add(connection);
      }
    }

    _searchedConnections = _tempSearchedCollection;
    notifyListeners();
  }

  getConnections() => _searchedConnections;

  getConnectionsLength() => _searchedConnections.length;
}
