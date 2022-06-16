import 'dart:async';

import 'package:flutter/material.dart';
import 'package:generation/db_operations/firestore_operations.dart';

import '../../services/debugging.dart';

class RequestConnectionsProvider extends ChangeNotifier {
  List<dynamic> _searchedConnections = [];
  List<dynamic> _requestConnections = [];
  final RealTimeOperations _realTimeOperations = RealTimeOperations();
  late StreamSubscription _receivedRequestStream;

  initialize({bool update = false}) {
    _searchedConnections = _requestConnections;
    if (update) notifyListeners();
  }

  getRequestConnections() => _requestConnections;

  remoteReceiveRequestDataStream() {
    _receivedRequestStream =
        _realTimeOperations.getReceivedRequestUsers().listen((querySnapShot) {
      setConnections(querySnapShot.docs);
      initialize(update: true);
    });
  }

  destroyReceivedRequestStream() {
    _receivedRequestStream.cancel();
    notifyListeners();
  }

  removeFromSearch(int index) {
  //  if(_searchedConnections.length - 1 <= index) return;
    try{
      _searchedConnections.removeAt(index);
      notifyListeners();
    }catch(e){
      debugShow("Error in Remove From SEarch Incoming Reuqets: $e");
    }
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
    initialize(update: true);
  }

  getConnections() => _searchedConnections;

  getConnectionsLength() => _searchedConnections.length;
}
