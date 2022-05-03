import 'package:flutter/material.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:generation/types/types.dart';

class ConnectionCollectionProvider extends ChangeNotifier {
  List<dynamic> _searchedChatConnectionsDataCollection = [];
  final List<dynamic> _selectedSearchedChatConnectionsDataCollection = [];
  List<dynamic> _chatConnectionsDataCollection = [];
  final Map<String, dynamic> _localConnectedUsersMap = {};
  final LocalStorage _localStorage = LocalStorage();
  final DBOperations _dbOperations = DBOperations();

  initialize({bool update = false}) {
    _searchedChatConnectionsDataCollection = _chatConnectionsDataCollection;
    if (update) notifyListeners();
  }

  fetchLocalConnectedUsers(context) async {
    try {
      final _conPrimaryData = await _localStorage.getConnectionPrimaryData();

      for (final connData in _conPrimaryData) {
        _chatConnectionsDataCollection.add(connData);
        _localConnectedUsersMap[connData["id"].toString()] = connData;
        notifyListeners();
      }

      initialize(update: true);
      _dbOperations.getAvailableUsersData(context);
    } catch (e) {
      print("Error in Fetch Local Connected Users: $e");
    }
  }

  manageRemoteDataCollection(incomingData) {


    for (final remoteData in incomingData) {
      final _data = remoteData.data();


      if (!_localConnectedUsersMap.containsKey(_data["id"].toString())) {
        _localConnectedUsersMap[_data["id"].toString()] = _data;
        addNewData(_data);
        _localStorage.insertUpdateConnectionPrimaryData(
            id: _data["id"],
            name: _data["name"],
            profilePic: _data["profilePic"],
            about: _data["about"],
            dbOperation: DBOperation.insert);

        initialize(update: true);
      }else{
        print("PResent: ${remoteData.id}");
      }
    }
  }

  setForSelection() {
    for (final connection in _chatConnectionsDataCollection) {
      _selectedSearchedChatConnectionsDataCollection
          .add({...connection, "isSelected": false});
    }
  }

  updateParticularSelectionData(incoming, index) {
    resetSelectionData();
    setForSelection();
    _selectedSearchedChatConnectionsDataCollection[index] = incoming;
    notifyListeners();
  }

  removeConnectionAtIndex(int index) {
    _searchedChatConnectionsDataCollection.removeAt(index);
    notifyListeners();
  }

  selectUnselectMultipleConnection(incoming, index) {
    if (_selectedSearchedChatConnectionsDataCollection[index] == null) {
      _selectedSearchedChatConnectionsDataCollection[index] = incoming;
    } else {
      _selectedSearchedChatConnectionsDataCollection.remove(index);
    }

    notifyListeners();
  }

  resetSelectionData() {
    _selectedSearchedChatConnectionsDataCollection.clear();
  }

  getWillSelectData() => _selectedSearchedChatConnectionsDataCollection;

  getWillSelectDataLength() =>
      _selectedSearchedChatConnectionsDataCollection.length;

  setFreshData(incomingData) {
    if (incomingData == null) return;

    _chatConnectionsDataCollection = incomingData;
    _searchedChatConnectionsDataCollection = incomingData;
    notifyListeners();
  }

  addNewData(incomingNewData) {
    if (incomingNewData == null) return;

    _chatConnectionsDataCollection = [
      incomingNewData,
      ..._chatConnectionsDataCollection,
    ];
    notifyListeners();
  }

  operateOnSearch(searchKeyword) {
    List<dynamic> _tempSearchedCollection = [];

    if (searchKeyword == "" || searchKeyword == null) {
      _searchedChatConnectionsDataCollection = _chatConnectionsDataCollection;
      notifyListeners();
      return;
    }

    for (final connection in _chatConnectionsDataCollection) {
      if (connection["name"]
          .toString()
          .toLowerCase()
          .contains(searchKeyword.toString().toLowerCase())) {
        _tempSearchedCollection.add(connection);
      }
    }

    _searchedChatConnectionsDataCollection = _tempSearchedCollection;
    notifyListeners();
  }

  getData() => _searchedChatConnectionsDataCollection;

  getDataLength() => _searchedChatConnectionsDataCollection.length;
}
