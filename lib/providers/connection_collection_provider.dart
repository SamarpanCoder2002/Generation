import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/services/local_data_management.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:generation/config/types.dart';

class ConnectionCollectionProvider extends ChangeNotifier {
  List<dynamic> _searchedChatConnectionsDataCollection = [];

  //final List<dynamic> _selectedSearchedChatConnectionsDataCollection = [];
  final Map<String, bool> _selectedConnections = {};
  List<dynamic> _chatConnectionsDataCollection = [];
  final Map<String, dynamic> _localConnectedUsersMap = {};
  final LocalStorage _localStorage = LocalStorage();
  final DBOperations _dbOperations = DBOperations();
  final RealTimeOperations _realTimeOperations = RealTimeOperations();
  late StreamSubscription _connectedDataStream;

  //late StreamSubscription _removeConnectionStream;
  final Map<
      String,
      Map<Stream<DocumentSnapshot<Map<String, dynamic>>>,
          StreamSubscription?>> _realTimeMsgListeners = {};
  Map<String, dynamic> _currAccData = {};

  initialize({bool update = false, BuildContext? context}) {
    _searchedChatConnectionsDataCollection = _chatConnectionsDataCollection;
    _fetchCurrAccData(update: update);
    if (update) {
      notifyListeners();
    } else {
      if (context != null) _dbOperations.isConnectedToDB(context);
    }
  }

  _fetchCurrAccData({bool update = false}) async {
    final _currAccData = await _localStorage.getDataForCurrAccount();
    this._currAccData = _currAccData;
    if (update) notifyListeners();
  }

  getCurrAccData() => _currAccData;

  getAllChatConnectionData() => _chatConnectionsDataCollection;

  fetchLocalConnectedUsers(context) async {
    try {
      //Map<String, dynamic> _localPriorityManagementData = {};

      // _notSeenMsgStore(connData) {
      //   if (connData["notSeenMsgCount"] != null &&
      //       int.parse(connData["notSeenMsgCount"]) > 0) {
      //     _localPriorityManagementData[connData["id"]] = {
      //       "count": int.parse(connData["notSeenMsgCount"]),
      //       "data": connData
      //     };
      //   }
      // }

      final _conPrimaryData = await _localStorage.getConnectionPrimaryData();

      for (Map<String, dynamic> connData in _conPrimaryData) {
        _chatConnectionsDataCollection.add(connData);
        _localConnectedUsersMap[connData["id"].toString()] = {...connData};
        _realTimeMsgListeners[connData["id"].toString()] = {
          _realTimeOperations.getChatMessages(connData["id"].toString()): null
        };
        //_notSeenMsgStore(connData);
        notifyListeners();
      }

      initialize(update: true);
      //_manageConnOnRemainingMessages(_localPriorityManagementData);
      _connStreamManagement();
      _remoteConnectedDataStream(context);
      //_managingRemoveConnRequest(context);
      _dbOperations.getAvailableUsersData(context);
    } catch (e) {
      print("Error in Fetch Local Connected Users: $e");
    }
  }

  // _manageConnOnRemainingMessages(Map<String, dynamic> connMap) {
  //   final _allData = connMap.values.toList();
  //   _allData.sort((first, second) => second["count"] > first["count"] ? 0 : 1);
  //
  //   print("All Data Length: ${_allData.length}");
  //
  //   for (final particularConnMap in _allData) {
  //     //_makeConnPriority(particularConnMap["data"]);
  //   }
  // }

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
              dbOperation: DBOperation.insert);
          _connStreamManagement();
        }

        initialize(update: true);
      }
    });
  }

  destroyConnectedDataStream() {
    _connectedDataStream.cancel();
    //_removeConnectionStream.cancel();
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

      if (_docData != null &&
          _docData.isNotEmpty &&
          _localConnectedUsersMap[connId] != null) {
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
        notificationTypeManually: connData["notificationManually"],
        dbOperation: DBOperation.update,
        lastMsgData: _lastMsgDataToInsert,
        notSeenMsgCount: notSeenMessages);

    connData["chatLastMsg"] = DataManagement.toJsonString(_lastMsgDataToInsert);
    connData["notSeenMsgCount"] = notSeenMessages;

    _localConnectedUsersMap[connData["id"]] = connData;
    if (connData["notSeenMsgCount"] != null &&
        int.parse(connData["notSeenMsgCount"]) > 0) makeConnPriority(connData);
    notifyListeners();
  }

  makeConnPriority(oldConnData) {
    _searchedChatConnectionsDataCollection.removeWhere(
        (connDataIterate) => connDataIterate["id"] == oldConnData["id"]);
    _searchedChatConnectionsDataCollection.insert(0, oldConnData);
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
    if (_connData == null) return;

    _connData["chatLastMsg"] = DataManagement.toJsonString(_getLatestChatMsg);
    _connData["notSeenMsgCount"] = '0';

    _localConnectedUsersMap[_connData["id"]] = _connData;
    notifyListeners();
  }

  removeConnectionAtIndex(int index) {
    _searchedChatConnectionsDataCollection.removeAt(index);
    notifyListeners();
  }

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

  bool isAnyConnectionSelected() {
    if (_selectedConnections.isEmpty) return false;
    return _selectedConnections.values.toList().contains(true);
  }

  bool isConnectionSelected(String connId) =>
      _selectedConnections[connId] ?? false;

  bool onConnectionClick(String connId) {
    if (_selectedConnections[connId] != null && _selectedConnections[connId]!) {
      _selectedConnections[connId] = false;
      notifyListeners();
      return true;
    }

    if (_selectedConnections[connId] == null &&
        getSelectedConnections().length < 3) {
      _selectedConnections[connId] = true;
      notifyListeners();
      return true;
    }

    if (_selectedConnections[connId] != null &&
        _selectedConnections[connId] == false &&
        getSelectedConnections().length < 3) {
      _selectedConnections[connId] = !(_selectedConnections[connId] ?? false);
      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

  Map<String, dynamic> getSelectedConnections() {
    Map<String, dynamic> _manuallySelected = {};
    for (final conn in _selectedConnections.keys.toList()) {
      if (_selectedConnections[conn]!) {
        _manuallySelected[conn] = _selectedConnections[conn];
      }
    }

    return _manuallySelected;
  }

  resetSelectionData() {
    _selectedConnections.clear();
    notifyListeners();
  }

// void _managingRemoveConnRequest(BuildContext context) {
//   _removeConnectionStream = _realTimeOperations
//       .getRemoveConnectionRequestData()
//       .listen((DocumentSnapshot<Map<String, dynamic>> docSnapShot) {
//     final _data = docSnapShot.data();
//     if (_data == null) return;
//     if (_data[DBPath.data] == null) return;
//     if (_data[DBPath.data].isEmpty) return;
//
//     for (final _connId in _data[DBPath.data]) {
//
//
//       if (Provider.of<ChatBoxMessagingProvider>(context, listen: false)
//               .getPartnerUserId() ==
//           _connId) {
//         Provider.of<ChatBoxMessagingProvider>(context, listen: false)
//             .popUpScreen();
//       }
//
//       showToast(context,
//           title:
//               '${_localConnectedUsersMap[_connId]["name"]} ${TextCollection.removeYou}',
//           toastIconType: ToastIconType.info,
//           showFromTop: false);
//
//       _chatConnectionsDataCollection
//           .removeWhere((connData) => connData["id"] == _connId);
//       _localConnectedUsersMap.remove(_connId);
//       initialize(update: true);
//
//       _localStorage.deleteConnectionPrimaryData(id: _connId);
//     }
//
//     _dbOperations.resetRemoveSpecialRequest();
//   });
// }
}
