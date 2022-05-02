import 'package:flutter/material.dart';
import 'package:generation/types/types.dart';

class ConnectionCollectionProvider extends ChangeNotifier {
  List<dynamic> _searchedChatConnectionsDataCollection = [];
  final List<dynamic> _selectedSearchedChatConnectionsDataCollection = [];
  List<dynamic> _chatConnectionsDataCollection = [

  ];

  initialize(){
    _searchedChatConnectionsDataCollection = _chatConnectionsDataCollection;
  }

  setForSelection(){
    for(final connection in _chatConnectionsDataCollection){
      _selectedSearchedChatConnectionsDataCollection.add({...connection,"isSelected": false});
    }
  }

  updateParticularSelectionData(incoming, index){
    resetSelectionData();
    setForSelection();
    _selectedSearchedChatConnectionsDataCollection[index] = incoming;
    notifyListeners();

  }

  removeConnectionAtIndex(int index){
    _searchedChatConnectionsDataCollection.removeAt(index);
    notifyListeners();
  }



  selectUnselectMultipleConnection(incoming, index){
    if(_selectedSearchedChatConnectionsDataCollection[index] == null){
      _selectedSearchedChatConnectionsDataCollection[index] = incoming;
    }else{
      _selectedSearchedChatConnectionsDataCollection.remove(index);
    }

    notifyListeners();
  }

  resetSelectionData(){
    _selectedSearchedChatConnectionsDataCollection.clear();
  }

  getWillSelectData() => _selectedSearchedChatConnectionsDataCollection;

  getWillSelectDataLength() => _selectedSearchedChatConnectionsDataCollection.length;

  setFreshData(incomingData) {
    if (incomingData == null) return;

    _chatConnectionsDataCollection = incomingData;
    _searchedChatConnectionsDataCollection = incomingData;
    notifyListeners();
  }

  addNewData(incomingNewData) {
    if (incomingNewData == null) return;

    _chatConnectionsDataCollection = [
      ..._chatConnectionsDataCollection,
      ...incomingNewData
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
