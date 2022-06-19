import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/services/encryption_operations.dart';
import 'package:generation/services/local_data_management.dart';
import 'package:generation/services/local_database_services.dart';
import 'package:generation/config/types.dart';
import 'package:provider/provider.dart';

import '../config/text_collection.dart';
import '../db_operations/types.dart';
import '../services/debugging.dart';
import '../services/directory_management.dart';
import '../services/toast_message_show.dart';
import 'chat/messaging_provider.dart';

class ConnectionCollectionProvider extends ChangeNotifier {
  List<dynamic> _searchedChatConnectionsDataCollection = [];

  //final List<dynamic> _selectedSearchedChatConnectionsDataCollection = [];
  final Map<String, bool> _selectedConnections = {};
  List<dynamic> _chatConnectionsDataCollection = [];
  List<String> _activityConnDataCollection = [];
  final Map<String, dynamic> _localConnectedUsersMap = {};
  final LocalStorage _localStorage = LocalStorage();
  final DBOperations _dbOperations = DBOperations();
  final RealTimeOperations _realTimeOperations = RealTimeOperations();
  final Dio _dio = Dio();
  late StreamSubscription _connectedDataStream;

  late StreamSubscription _removeConnectionStream;
  final Map<
      String,
      Map<Stream<DocumentSnapshot<Map<String, dynamic>>>,
          StreamSubscription?>> _realTimeMsgListeners = {};
  final Map<
      String,
      Map<Stream<DocumentSnapshot<Map<String, dynamic>>>,
          StreamSubscription?>> _realTimeActivityListeners = {};
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

  getActivityConnectionData() => _activityConnDataCollection;

  fetchLocalConnectedUsers(context) async {
    try {
      final _conPrimaryData = await _localStorage.getConnectionPrimaryData();

      for (Map<String, dynamic> connData in _conPrimaryData) {
        _chatConnectionsDataCollection.add(connData);
        _localConnectedUsersMap[connData["id"].toString()] = {...connData};
        _realTimeMsgListeners[connData["id"].toString()] = {
          _realTimeOperations.getChatMessages(connData["id"].toString()): null
        };
        _realTimeActivityListeners[connData["id"].toString()] = {
          _realTimeOperations.getActivityData(connData["id"].toString()): null
        };
        _manageHavingActivity(connData["id"]);
        //_notSeenMsgStore(connData);
        notifyListeners();
      }

      initialize(update: true);

      _connStreamManagement();
      _remoteConnectedDataStream(context);
      _managingRemoveConnRequest(context);
      _dbOperations.getAvailableUsersData(context);
    } catch (e) {
      debugShow("Error in Fetch Local Connected Users: $e");
    }
  }

  _manageHavingActivity(connId) {
    _localStorage
        .getAllActivity(
            tableName: DataManagement.generateTableNameForNewConnectionActivity(
                connId))
        .then((data) {
      if (data == null) return;
      if (data.isEmpty) return;

      _activityConnDataCollection.add(connId);
      notifyListeners();
    });
  }

  updateParticularConnectionData(String id, connUpdatedData) {
    _localConnectedUsersMap[id]["name"] = connUpdatedData["name"];
    _localConnectedUsersMap[id]["email"] = connUpdatedData["email"];
    _localConnectedUsersMap[id]["about"] = connUpdatedData["about"];
    _localConnectedUsersMap[id]["profilePic"] = connUpdatedData["profilePic"];
    _localConnectedUsersMap[id][DBPath.notification] =
        connUpdatedData[DBPath.notification];
    _localConnectedUsersMap[id][DBPath.notificationDeactivated] =
        connUpdatedData[DBPath.notificationDeactivated];

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
    _removeConnectionStream.cancel();
    for (final particularData in _realTimeMsgListeners.values.toList()) {
      particularData.values.toList()[0]?.cancel();
    }
    for (final particularActivityData
        in _realTimeActivityListeners.values.toList()) {
      particularActivityData.values.toList()[0]?.cancel();
    }
    notifyListeners();
  }

  _connStreamManagement() {
    for (final connId in _realTimeMsgListeners.keys.toList()) {
      final _particularMessageSteam =
          _realTimeMsgListeners[connId]?.keys.toList()[0];
      final _particularActivityStream =
          _realTimeActivityListeners[connId]?.keys.toList()[0];

      if (_realTimeMsgListeners[connId]?[_particularMessageSteam!] == null) {
        _makeMessageStreamSubscription(_particularMessageSteam, connId);
        _makeActivityStreamSubscription(_particularActivityStream, connId);
      }
    }
  }

  _makeMessageStreamSubscription(_particularSteam, connId) {
    final _streamSubscription = _particularSteam?.listen((docSnapShot) {
      final _docData = docSnapShot.data();

      if (_docData != null &&
          _docData.isNotEmpty &&
          _localConnectedUsersMap[connId] != null) {
        final _incomingMessagesCollection = _docData["data"];
        final _remoteLatestMsg = _incomingMessagesCollection.isEmpty
            ? <String, dynamic>{}
            : DataManagement.fromJsonString(
                    Secure.decode(_incomingMessagesCollection.last))
                .values
                .toList()
                .first;
        _manageMsgStreamData(
            remoteLatestMsg: _remoteLatestMsg,
            connData: _localConnectedUsersMap[connId],
            notSeenMessages: _incomingMessagesCollection.length.toString());
      }
    });

    _realTimeMsgListeners[connId]?[_particularSteam!] = _streamSubscription;
    notifyListeners();
  }

  _makeActivityStreamSubscription(_particularSteam, connId) {
    final _streamSubscription = _particularSteam?.listen((docSnapShot) {
      final _docData = docSnapShot.data();

      if (_docData != null &&
          _docData.isNotEmpty &&
          _localConnectedUsersMap[connId] != null) {
        final _activityCollection = _docData[DBPath.data] ?? [];
        _storeActivityData(_activityCollection, connId);
      }
    });

    _realTimeActivityListeners[connId]?[_particularSteam!] =
        _streamSubscription;
    notifyListeners();
  }

  _storeActivityData(List<dynamic> activityCollection, String connId) async {
    debugShow('Activity Collection length: ${activityCollection.length}');

    for (var activity in activityCollection) {
      activity = DataManagement.fromJsonString(Secure.decode(activity));
      final _oldParticularData = await _localStorage.getParticularActivity(
          tableName:
              DataManagement.generateTableNameForNewConnectionActivity(connId),
          activityId: activity["id"]);

      debugShow('Suspected Activity id Top: ${activity["id"]}');

      debugShow('Old Particular Activity Data:  $_oldParticularData');

      if (_oldParticularData.isEmpty) {
        if (_activityConnDataCollection.isEmpty) {
          _activityConnDataCollection.add(connId);
        } else {
          if (_activityConnDataCollection.contains(connId)) {
            _activityConnDataCollection.remove(connId);
          }
          _activityConnDataCollection.insert(0, connId);
        }
        notifyListeners();

        await _storeActivityInLocalStorage(activity, connId);

        if (activity['type'] == ActivityContentType.image.toString() ||
            activity['type'] == ActivityContentType.audio.toString() ||
            activity['type'] == ActivityContentType.video.toString()) {
          _downloadActivityContentWithUpdate(activity, connId);
        }
      }
    }
  }

  _downloadActivityContentWithUpdate(activity, connId) async {
    String _mediaStorePath = "";

    if (activity['type'] == ActivityContentType.image.toString()) {
      final _dirPath = await createImageStoreDir();
      _mediaStorePath =
          createImageFile(dirPath: _dirPath, name: DateTime.now().toString());
    } else if (activity['type'] == ActivityContentType.video.toString()) {
      final _dirPath = await createVideoStoreDir();
      _mediaStorePath =
          createVideoFile(dirPath: _dirPath, name: DateTime.now().toString());
    } else if (activity['type'] == ActivityContentType.audio.toString()) {
      final _dirPath = await createVoiceStoreDir();
      _mediaStorePath =
          createAudioFile(dirPath: _dirPath, name: DateTime.now().toString());
    }

    _dio.download(activity['message'], _mediaStorePath).whenComplete(() async {
      debugShow("${activity['type']} Activity Media Download Completed");
      activity['message'] = _mediaStorePath;

      _storeActivityInLocalStorage(activity, connId, insert: false);
    });
  }

  Future<void> _storeActivityInLocalStorage(activity, connId,
      {bool insert = true}) async {
    await _localStorage.insertUpdateTableForActivity(
        tableName:
            DataManagement.generateTableNameForNewConnectionActivity(connId),
        activityId: activity["id"],
        activityHolderId: Secure.encode(activity["holderId"]) ?? '',
        activityType: Secure.encode(activity['type']) ?? '',
        date: Secure.encode(activity['date']) ?? '',
        time: Secure.encode(activity['time']) ?? '',
        msg: Secure.encode(activity['message']) ?? '',
        additionalData: Secure.encode(DataManagement.toJsonString(activity["additionalThings"])),
        dbOperation: insert ? DBOperation.insert : DBOperation.update);
  }

  _manageMsgStreamData(
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

    _activityStreamForNewConnection(incomingNewData);
  }

  _activityStreamForNewConnection(incomingNewData) {
    final _newStream =
        _realTimeOperations.getActivityData(incomingNewData["id"].toString());
    _realTimeActivityListeners[incomingNewData["id"].toString()] = {
      _newStream: null
    };
    notifyListeners();
    //_makeActivityStreamSubscription(_newStream, incomingNewData['id']);
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

  bool notificationPermitted(String connId) {
    debugShow("notification checkid id: $connId");

    debugShow(
        "notification: ${_localConnectedUsersMap[connId][DBPath.notification]}");
    debugShow(
        "notification list: ${_localConnectedUsersMap[connId][DBPath.notificationDeactivated]}");

    bool _checkInNotificationDeactivatedList() {
      final _notificationDeactivatedList =
          _localConnectedUsersMap[connId][DBPath.notificationDeactivated];
      if (_notificationDeactivatedList == null) return true;
      return !(_notificationDeactivatedList.contains(_dbOperations.currUid));
    }

    if (_localConnectedUsersMap[connId][DBPath.notification] == null) {
      return _checkInNotificationDeactivatedList();
    } else {
      if (_localConnectedUsersMap[connId][DBPath.notification] == 'false') {
        return false;
      } else {
        return _checkInNotificationDeactivatedList();
      }
    }
  }

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

  void _managingRemoveConnRequest(BuildContext context) {
    _removeConnectionStream = _realTimeOperations
        .getRemoveConnectionRequestData()
        .listen((DocumentSnapshot<Map<String, dynamic>> docSnapShot) {
      final _data = docSnapShot.data();
      if (_data == null) return;
      if (_data[DBPath.data] == null) return;
      if (_data[DBPath.data].isEmpty) return;

      for (final _connId in _data[DBPath.data]) {
        if (Provider.of<ChatBoxMessagingProvider>(context, listen: false)
                .getPartnerUserId() ==
            _connId) {
          Provider.of<ChatBoxMessagingProvider>(context, listen: false)
              .popUpScreen();
        }

        _localStorage.deleteConnectionPrimaryData(id: _connId);

        showToast(
            title:
                '${_localConnectedUsersMap[_connId]["name"]} ${TextCollection.removeYou}',
            toastIconType: ToastIconType.info,
            showFromTop: false);

        _chatConnectionsDataCollection
            .removeWhere((connData) => connData["id"] == _connId);

        _searchedChatConnectionsDataCollection
            .removeWhere((connData) => connData["id"] == _connId);
        notifyListeners();
      }

      _dbOperations.resetRemoveSpecialRequest();
    });
  }

  afterClearChatMessages(Map<String, dynamic> connData) {
    _localConnectedUsersMap[connData["id"]] = {
      ...connData,
      "chatLastMsg": null,
      "notSeenMsgCount": '0'
    };

    notifyListeners();
  }
}
