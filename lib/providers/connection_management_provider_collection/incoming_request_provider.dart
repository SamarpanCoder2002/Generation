import 'package:flutter/material.dart';

class RequestConnectionsProvider extends ChangeNotifier {
  List<dynamic> _searchedConnections = [];
  List<dynamic> _requestConnections = [

  ];

  initialize({bool update = false}){
    _searchedConnections = _requestConnections;
    if(update) notifyListeners();
  }

  removeFromSearch(int index){
    _searchedConnections.removeAt(index);
    notifyListeners();
  }

  operateOnSearch(searchKeyword) {
    List<dynamic> _tempSearchedCollection = [];

    if (searchKeyword == "" || searchKeyword == null) {
      _searchedConnections = _requestConnections;
      notifyListeners();
      return;
    }

    for (final connection in _requestConnections) {
      if (connection["name"]
          .toString()
          .toLowerCase()
          .contains(searchKeyword.toString().toLowerCase())) {
        _tempSearchedCollection.add(connection);
      }
    }

    _searchedConnections = _tempSearchedCollection;
    notifyListeners();
  }

  setConnections(incomingConnections) {
    _requestConnections = incomingConnections;
    notifyListeners();
  }

  getConnections() => _searchedConnections;

  getConnectionsLength() => _searchedConnections.length;
}
