import 'package:flutter/material.dart';
import 'package:generation/services/encryption_operations.dart';

class SentConnectionsProvider extends ChangeNotifier {
  List<dynamic> _searchedConnections = [];
  List<dynamic> _sentConnections = [

  ];

  initialize({bool update = false}) {
    _searchedConnections = _sentConnections;
    if(update) notifyListeners();
  }

  setConnections(incomingConnections) {
    _sentConnections = incomingConnections;
    initialize(update: true);
  }

  operateOnSearch(searchKeyword) {
    List<dynamic> _tempSearchedCollection = [];

    if (searchKeyword == "" || searchKeyword == null) {
      _searchedConnections = _sentConnections;
      notifyListeners();
      return;
    }

    for (final connection in _sentConnections) {
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

  void removeIndexFromSearch(int index) {
    //if(_searchedConnections.length - 1 <= index) return;
    _searchedConnections.removeAt(index);
    notifyListeners();
  }
}
