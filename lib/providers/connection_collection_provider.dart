import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/services/local_data_management.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:generation/types/types.dart';

class ConnectionCollectionProvider extends ChangeNotifier {
  List<dynamic> _searchedChatConnectionsDataCollection = [];
  final List<dynamic> _selectedSearchedChatConnectionsDataCollection = [];
  List<dynamic> _chatConnectionsDataCollection = [];
  final Map<String, dynamic> _localConnectedUsersMap = {};
  final LocalStorage _localStorage = LocalStorage();
  final DBOperations _dbOperations = DBOperations();
  final RealTimeOperations _realTimeOperations = RealTimeOperations();
  late StreamSubscription _connectedDataStream;
  final Map<
      String,
      Map<Stream<DocumentSnapshot<Map<String, dynamic>>>,
          StreamSubscription?>> _realTimeMsgListeners = {};

  initialize({bool update = false}) {
    _searchedChatConnectionsDataCollection = _chatConnectionsDataCollection;
    if (update) notifyListeners();
  }

  getAllChatConnectionData() => _chatConnectionsDataCollection;

  fetchLocalConnectedUsers(context) async {
    try {
      final _conPrimaryData = await _localStorage.getConnectionPrimaryData();

      for (Map<String, dynamic> connData in _conPrimaryData) {
        _chatConnectionsDataCollection.add(connData);
        _localConnectedUsersMap[connData["id"].toString()] = {...connData};
        _realTimeMsgListeners[connData["id"].toString()] = {
          _realTimeOperations.getChatMessages(connData["id"].toString()): null
        };
        notifyListeners();
      }

      initialize(update: true);
      _connStreamManagement();
      _remoteConnectedDataStream(context);
      _dbOperations.getAvailableUsersData(context);
    } catch (e) {
      print("Error in Fetch Local Connected Users: $e");
    }
  }

  updateParticularConnectionData(String id, connUpdatedData) {
    _localConnectedUsersMap[id]["name"] = connUpdatedData["name"];
    _localConnectedUsersMap[id]["email"] = connUpdatedData["email"];
    _localConnectedUsersMap[id]["about"] = connUpdatedData["about"];
    _localConnectedUsersMap[id]["profilePic"] = connUpdatedData["profilePic"];

    notifyListeners();
  }

  _remoteConnectedDataStream(context) async {
    _connectedDataStream =
        _realTimeOperations.getConnectedUsers().listen((querySnapShot) {
      final _conPrimaryData = querySnapShot.docs;

      for (final connData in _conPrimaryData) {
        if (!_localConnectedUsersMap.containsKey(connData.id.toString())) {
          _localConnectedUsersMap[connData.id.toString()] = connData.data();
          _realTimeMsgListeners[connData.id.toString()] = {
            _realTimeOperations.getChatMessages(connData.id.toString()): null
          };
          addNewData(connData.data());
          _localStorage.insertUpdateConnectionPrimaryData(
              id: connData.data()["id"],
              name: connData.data()["name"],
              profilePic: connData.data()["profilePic"],
              about: connData.data()["about"],
              notificationType: connData.data()["notification"],
              dbOperation: DBOperation.insert);
          _connStreamManagement();
        }

        initialize(update: true);
      }
    });
  }

  destroyConnectedDataStream() {
    _connectedDataStream.cancel();
    for (final particularData in _realTimeMsgListeners.values.toList()) {
      particularData.values.toList()[0]?.cancel();
    }
    notifyListeners();
  }

  _connStreamManagement() {
    for (final connId in _realTimeMsgListeners.keys.toList()) {
      final _particularSteam = _realTimeMsgListeners[connId]?.keys.toList()[0];

      if (_realTimeMsgListeners[connId]?[_particularSteam!] == null) {
        _makeStreamSubscription(_particularSteam, connId);
      }
    }
  }

  _makeStreamSubscription(_particularSteam, connId) {
    final _streamSubscription = _particularSteam?.listen((docSnapShot) {
      final _docData = docSnapShot.data();

      if (_docData != null && _docData.isNotEmpty) {
        final _incomingMessagesCollection = _docData["data"];
        _manageStreamData(
            remoteLatestMsg: _incomingMessagesCollection.isEmpty
                ? {}
                : _incomingMessagesCollection.last.values.toList().first,
            connData: _localConnectedUsersMap[connId],
            notSeenMessages: _incomingMessagesCollection.length.toString());
      }
    });

    _realTimeMsgListeners[connId]?[_particularSteam!] = _streamSubscription;
    notifyListeners();
  }

  _manageStreamData(
      {required Map<String, dynamic> remoteLatestMsg,
      required Map<String, dynamic> connData,
      required String notSeenMessages}) async {
    var _lastMsgDataToInsert = remoteLatestMsg;
    if (remoteLatestMsg.isEmpty) {
      _lastMsgDataToInsert = await _localStorage.getLatestChatMessage(
              tableName: DataManagement.generateTableNameForNewConnectionChat(
                  connData["id"])) ??
          {};
    }

    _localStorage.insertUpdateConnectionPrimaryData(
        id: connData["id"],
        name: connData["name"],
        profilePic: connData["profilePic"],
        about: connData["about"],
        notificationType: connData["notification"],
        dbOperation: DBOperation.update,
        lastMsgData: _lastMsgDataToInsert,
        notSeenMsgCount: notSeenMessages);

    connData["chatLastMsg"] = DataManagement.toJsonString(_lastMsgDataToInsert);
    connData["notSeenMsgCount"] = notSeenMessages;

    _localConnectedUsersMap[connData["id"]] = connData;
    notifyListeners();
  }

  pauseParticularConnSubscription(String connId) {
    _realTimeMsgListeners[connId]?.values.toList().first?.pause();
    notifyListeners();
  }

  resumeParticularConnSubscription(String connId) {
    _realTimeMsgListeners[connId]?.values.toList().first?.resume();
    notifyListeners();
  }

  getAndInsertLastMessage(String connId) async {
    final _getLatestChatMsg = await _localStorage.getLatestChatMessage(
            tableName:
                DataManagement.generateTableNameForNewConnectionChat(connId)) ??
        {};
    final _connData = _localConnectedUsersMap[connId];
    _connData["chatLastMsg"] = DataManagement.toJsonString(_getLatestChatMsg);
    _connData["notSeenMsgCount"] = '0';

    _localConnectedUsersMap[_connData["id"]] = _connData;
    notifyListeners();
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

  getUsersMap(String id) => _localConnectedUsersMap[id];

  getRealTimeLatestData() {}
}
