import 'dart:io';

import 'package:flutter/material.dart';
import 'package:generation/config/countable_data_collection.dart';
import 'package:generation/db_operations/firestore_operations.dart';
import 'package:generation/providers/local_storage_provider.dart';
import 'package:generation/services/permission_management.dart';
import 'package:generation/config/types.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../config/stored_string_collection.dart';
import '../config/text_collection.dart';
import 'debugging.dart';
import 'local_data_management.dart';

/// For Current User Data
/// For Connections Data
/// For Every Connection Chat Data Should Make a Table
/// For Every Connection Activity Data Should Make a Table

class LocalStorage {
  /// Current User Data
  final String _currUserId = "id";
  final String _currUserName = "name";
  final String _currUserAbout = "about";
  final String _currUserEmail = "email";
  final String _currUserProfilePic = "profilePic";
  final String _currGlobalNotification = "notification";
  final String _currWallpaper = "wallpaper";

  /// Connections Primary Data
  final String _conId = "id";
  final String _conUserName = "name";
  final String _conUserAbout = "about";
  final String _conProfilePic = "profilePic";
  final String _conChatWallpaperPath = "wallpaper";
  final String _conChatWallpaperManually = "wallpaperManually";
  final String _conLastMsgData = "chatLastMsg";
  final String _conNotSeenMsgCount = "notSeenMsgCount";
  final String _conNotificationManually = "notificationManually";
  final String _conChatTableName = "chatTableName";
  final String _conActivityTableName = "connectionTableName";

  /// Chat Message Data
  final String _msgId = "id";
  final String _msgType = "type";
  final String _msgHolder = "holder";
  final String _msgData = "message";
  final String _msgDate = "date";
  final String _msgTime = "time";
  final String _msgAdditionalData = "additionalData";

  /// Activity Data
  final String _activityId = "id";
  final String _activityHolderId = "holderId";
  final String _activityType = "type";
  final String _activityDate = "date";
  final String _activityTime = "time";
  final String _activityMessage = "message";
  final String _activityAdditionalThings = "additionalThings";
  final String _activityVisited = "visited";

  final PermissionManagement _permissionManagement = PermissionManagement();

  static late LocalStorage _localStorageHelper = LocalStorage._createInstance();
  static late Database _database;

  LocalStorage._createInstance();

  factory LocalStorage() {
    _localStorageHelper = LocalStorage._createInstance();
    return _localStorageHelper;
  }

  Future<Database> get database async {
    _database = await initializeDatabase();
    return _database;
  }

  Future<Database> initializeDatabase() async {
    final storagePermissionResponse =
        await _permissionManagement.storagePermission();
    if (!storagePermissionResponse) {
      debugShow("Storage Permission Required under local database services");
      return _database;
    } else {
      final Directory? directory = await getExternalStorageDirectory();

      final Directory newDirectory =
          await Directory(directory!.path + "/${FolderData.dbFolder}/")
              .create();

      final String path = newDirectory.path +
          "/${DataManagement.getEnvData(EnvFileKey.dbName)}.db";
      DataManagement.storeStringData(StoredString.dbPath, path);
      return await _getDatabase(path: path);
    }
  }

  Future<Database> _getDatabase({String? path}) async {
    path ??= await DataManagement.getStringData(StoredString.dbPath);

    if (path == null) {
      final Directory? directory = await getExternalStorageDirectory();

      final Directory newDirectory =
          await Directory(directory!.path + "/${FolderData.dbFolder}/")
              .create();

      path = newDirectory.path +
          "/${DataManagement.getEnvData(EnvFileKey.dbName)}.db";
      DataManagement.storeStringData(StoredString.dbPath, path);
    }

    final Database getDatabase = await openDatabase(path, version: 1);
    _database = getDatabase;
    return _database;
  }

  storeDbInstance(context) async {
    final Database db = await database;
    Provider.of<LocalStorageProvider>(context, listen: false).setDb(db);
  }

  /// ** Current User Data Operation ** ///

  /// Create Table For Store Current User Data
  Future<void> createTableForStorePrimaryData() async {
    final Database db = await database;
    try {
      await db.execute(
          """CREATE TABLE ${DbData.currUserTable}($_currUserId TEXT PRIMARY KEY, $_currUserName TEXT, $_currUserProfilePic TEXT, $_currUserAbout TEXT, $_currUserEmail TEXT, $_currGlobalNotification TEXT, $_currWallpaper TEXT)""");

      _createTableForActivity(tableName: DbData.myActivityTable);
    } catch (e) {
      debugShow(
          "Error in Local Storage Create Table For Store Primary Data: ${e.toString()}");
    }
  }

  /// Insert And Update For Current User Data
  Future<void> insertUpdateDataCurrAccData(
      {required String currUserId,
      required String currUserName,
      required String currUserProfilePic,
      required String currUserAbout,
      required String currUserEmail,
      required DBOperation dbOperation,
      NotificationType? notificationType,
      String? wallpaperPath}) async {
    final Database db = await database;

    final Map<String, dynamic> _accountData = <String, dynamic>{};
    _accountData[_currUserId] = currUserId;
    _accountData[_currUserName] = currUserName;
    _accountData[_currUserEmail] = currUserEmail;
    _accountData[_currUserAbout] = currUserAbout;
    _accountData[_currUserProfilePic] = currUserProfilePic;
    _accountData[_currGlobalNotification] =
        '${notificationType ?? NotificationType.unMuted.toString()}';
    _accountData[_currWallpaper] = wallpaperPath;

    if (dbOperation == DBOperation.update) {
      final _oldCurrAccData = await getDataForCurrAccount();

      if (notificationType == null) {
        _accountData[_currGlobalNotification] =
            _oldCurrAccData[_currGlobalNotification];
      }

      if (wallpaperPath == null) {
        _accountData[_currWallpaper] = _oldCurrAccData[_currWallpaper];
      }

      await db.update(DbData.currUserTable, _accountData,
          where: """$_currUserId = "$currUserId" """);
      return;
    }

    await db.insert(DbData.currUserTable, _accountData);
  }

  /// Read Operation for Current Account
  getDataForCurrAccount() async {
    final Database db = await database;

    final List<Map<String, Object?>> result =
        await db.rawQuery("""SELECT * FROM ${DbData.currUserTable}""");

    if (result.isEmpty) {
      debugShow("No Current User Data Found From Local Database");
      return;
    }

    return result[0];
  }

  /// ** Connections Primary Data Operation ** ///

  /// Create Table to Store Connections Primary Data
  Future<void> createTableForConnectionsPrimaryData() async {
    final Database db = await database;
    try {
      await db.execute(
          """CREATE TABLE ${DbData.connectionsTable}($_conId TEXT PRIMARY KEY, $_conUserName TEXT, $_conProfilePic TEXT, $_conUserAbout TEXT, $_conChatWallpaperPath TEXT, $_conLastMsgData TEXT, $_conNotSeenMsgCount TEXT, $_conChatWallpaperManually TEXT, $_conNotificationManually TEXT)""");
    } catch (e) {
      debugShow(
          "Error in Local Storage Create Table For Store Primary Data: ${e.toString()}");
    }
  }

  /// Insert Or Update Operation for Connection Primary Data Table
  Future<void> insertUpdateConnectionPrimaryData(
      {required String id,
      required String name,
      required String profilePic,
      required String about,
      required DBOperation dbOperation,
      dynamic lastMsgData,
      dynamic notSeenMsgCount,
      String? wallpaper,
      String? chatWallpaperManually,
      String? notificationTypeManually}) async {
    try {
      final Database db = await database;

      final Map<String, dynamic> _conData = <String, dynamic>{};
      _conData[_conId] = id;
      _conData[_conUserName] = name;
      _conData[_conUserAbout] = about;
      _conData[_conProfilePic] = profilePic;
      _conData[_conChatWallpaperPath] = wallpaper;
      _conData[_conChatWallpaperManually] = chatWallpaperManually.toString();
      _conData[_conLastMsgData] =
          lastMsgData == null ? null : DataManagement.toJsonString(lastMsgData);
      _conData[_conNotSeenMsgCount] =
          notSeenMsgCount == null ? '0' : notSeenMsgCount.toString();
      _conData[_conNotificationManually] =
          notificationTypeManually ?? NotificationType.unMuted.toString();



      if (dbOperation == DBOperation.insert) {
        await db.insert(DbData.connectionsTable, _conData);

        _conData[_conChatTableName] =
            DataManagement.generateTableNameForNewConnectionChat(id);
        _conData[_conActivityTableName] =
            DataManagement.generateTableNameForNewConnectionActivity(id);

        _createTableForConnectionChat(tableName: _conData[_conChatTableName]);
        _createTableForActivity(tableName: _conData[_conActivityTableName]);
      } else {
        final _oldConnPrimaryData = await getConnectionPrimaryData(id: id);

        if (chatWallpaperManually == null) {
          _conData[_conChatWallpaperManually] =
              _oldConnPrimaryData[_conChatWallpaperManually];
        }

        if (notificationTypeManually == null) {
          print('Old Notification Data: ${_oldConnPrimaryData[_conNotificationManually]}');

          _conData[_conNotificationManually] =
              _oldConnPrimaryData[_conNotificationManually];
        }

        print('Notification Manually: $notificationTypeManually      Value Stored: ${_conData[_conNotificationManually]}');

        await db.update(DbData.connectionsTable, _conData,
            where: """$_conId = "$id" """);
      }
    } catch (e) {
      debugShow("ERROR in insertUpdateConnectionPrimaryData: $e");
    }
  }

  /// Delete particular connection
  Future<bool> deleteConnectionPrimaryData(
      {required String id, bool allowDeleteOtherRelatedTable = false}) async {
    final Database db = await database;

    final _rowAffected =
        await db.delete(DbData.connectionsTable, where: """$_conId = "$id" """);

    debugShow("row Affected:  $_rowAffected");

    if (_rowAffected == 1 && allowDeleteOtherRelatedTable) {
      deleteDataFromParticularChatConnTable(
          tableName: DataManagement.generateTableNameForNewConnectionChat(id));
      deleteActivity(
          tableName:
              DataManagement.generateTableNameForNewConnectionActivity(id));
      return true;
    }
    return false;
  }

  /// Get Connections Primary Data. If id null, it returns all the data. Get Particular Connection Data
  /// By Passing Connection Id
  getConnectionPrimaryData(
      {String? id, bool withStoragePermission = true}) async {
    final Database db =
        withStoragePermission ? await database : await _getDatabase();

    if (id == null) {
      return await db.rawQuery("""SELECT * FROM ${DbData.connectionsTable}""");
    }

    final data = await db.rawQuery(
        """SELECT * FROM ${DbData.connectionsTable} WHERE $_conId = "$id" """);
    if (data.isEmpty) return false;
    return data[0];
  }

  /// ** Chat Message Operation ** ///

  /// Create table for particular connection Chat Messages
  Future<void> _createTableForConnectionChat(
      {required String tableName}) async {
    final Database db = await database;
    try {
      await db.execute(
          """CREATE TABLE $tableName($_msgId TEXT PRIMARY KEY, $_msgType TEXT, $_msgHolder TEXT, $_msgData TEXT, $_msgDate TEXT, $_msgTime TEXT, $_msgAdditionalData TEXT)""");
    } catch (e) {
      debugShow(
          "Error in Local Storage Create Table For Connection Chat: ${e.toString()}");
    }
  }

  /// For Insert Or Update Chat Messages
  Future<void> insertUpdateMsgUnderConnectionChatTable(
      {required String chatConTableName,
      required String id,
      required String holder,
      required message,
      required String date,
      required String time,
      required String type,
      dynamic additionalData,
      required DBOperation dbOperation}) async {
    final Database db = await database;

    final Map<String, dynamic> _chatData = <String, dynamic>{};

    _chatData[_msgId] = id;
    _chatData[_msgHolder] = holder;
    _chatData[_msgData] = message;
    _chatData[_msgDate] = date;
    _chatData[_msgTime] = time;
    _chatData[_msgType] = type;
    _chatData[_msgAdditionalData] = additionalData;

    dbOperation == DBOperation.insert
        ? db.insert(chatConTableName, _chatData)
        : db.update(chatConTableName, _chatData, where: """$_msgId = "$id" """);
  }

  /// Delete Particular Connection Chat Message Table
  Future<bool> deleteDataFromParticularChatConnTable(
      {required String tableName, String? msgId}) async {
    try {
      final Database db = await database;

      if (msgId == null) {
        await db.delete(tableName);
        debugShow("Deletion done chat");
      } else {
        await db.delete(tableName, where: """$_msgId = "$msgId" """);
      }

      return true;
    } catch (e) {
      print('Error in deleteDataFromParticularChatConnTable: $e');
      return false;
    }
  }

  /// Get Paginated Data from Connection Chat Message Table
  getPaginatedChatMessage(
      {required String tableName, int paginatedNumber = 1}) async {
    final Database db = await database;
    final int _totalMsg = await getTotalMessages(tableName: tableName);

    int _desiredLimit = SizeCollection.chatMessagePaginatedLimit;
    int _msgStartWith = _totalMsg - paginatedNumber * _desiredLimit;
    if (_msgStartWith + _desiredLimit <= 0) return;

    if (_msgStartWith < 0) {
      _desiredLimit += _msgStartWith;
      _msgStartWith = 0;
    }

    final _fromStoredMessages = db.rawQuery(
        """ SELECT * FROM $tableName LIMIT $_msgStartWith,$_desiredLimit """);

    return _fromStoredMessages;
  }

  /// Get Latest Message For any Chat Message Table
  getLatestChatMessage({required String tableName}) async {
    try {
      final int _totalMessages = await getTotalMessages(tableName: tableName);

      final Database db = await database;
      final _msgSet = await db.rawQuery(
          """ SELECT * FROM $tableName LIMIT ${_totalMessages - 1},1 """);

      return _msgSet[0];
    } catch (e) {
      return null;
    }
  }

  /// ** Activity Operation ** //

  /// Create table for particular connection Chat Messages
  Future<void> _createTableForActivity({required String tableName}) async {
    final Database db = await database;
    try {
      await db.execute(
          """CREATE TABLE $tableName($_activityHolderId TEXT, $_activityId TEXT PRIMARY KEY, $_activityMessage TEXT, $_activityType TEXT, $_activityDate TEXT, $_activityTime TEXT, $_activityAdditionalThings TEXT, $_activityVisited TEXT)""");
    } catch (e) {
      debugShow("Error in _createTableForActivity Chat: ${e.toString()}");
    }
  }

  /// Insert Data in particular connection Activity Messages
  Future<bool> insertUpdateTableForActivity(
      {required String tableName,
      required String activityId,
      required String activityHolderId,
      required String activityType,
      required String date,
      required String time,
      required String msg,
      required dynamic additionalData,
      required DBOperation dbOperation,
      bool? activityVisited}) async {
    try {
      final Database db = await database;

      final Map<String, dynamic> _activityData = <String, dynamic>{};

      _activityData[_activityId] = activityId;
      _activityData[_activityHolderId] = activityHolderId;
      _activityData[_activityType] = activityType;
      _activityData[_activityDate] = date;
      _activityData[_activityTime] = time;
      _activityData[_activityMessage] = msg;
      _activityData[_activityAdditionalThings] = additionalData;
      _activityData[_activityVisited] = "${activityVisited ?? 'false'}";

      debugShow('Activity Data:  $_activityData     dbOperation: $dbOperation');

      dbOperation == DBOperation.insert
          ? db.insert(tableName, _activityData)
          : db.update(tableName, _activityData,
              where: """$_activityId = "$activityId" """);

      return true;
    } catch (e) {
      debugShow('Error in Insert or update Activity Data: $e');
      return false;
    }
  }

  deleteActivity(
      {required String tableName,
      String? activityId,
      bool withStoragePermission = true}) async {
    final Database db =
        withStoragePermission ? await database : await _getDatabase();

    if (activityId == null) {
      await db.delete(tableName);
      debugShow("Delete Activity");
    } else {
      final _response = await db
          .delete(tableName, where: """$_activityId = "$activityId" """);
      debugShow(
          'Delete Activity Response: $_response   Activity Id: $activityId');
    }
  }

  getParticularActivity(
      {required String tableName, required String activityId}) async {
    try {
      final Database db = await database;

      final _activitySet = await db.rawQuery(
          """ SELECT * FROM $tableName WHERE $_activityId = "$activityId" """);

      return _activitySet;
    } catch (e) {
      print('Error in particular activity: $e');
      return [];
    }
  }

  Stream<List<Map<String, Object?>>> getAllActivityStream(
      {required String tableName, required BuildContext context}) {
    final Database db =
        Provider.of<LocalStorageProvider>(context, listen: false).getDb;

    return db.rawQuery(""" SELECT * FROM $tableName """).asStream();

    // (await _localStorage.getAllActivityStream(tableName: DataManagement.generateTableNameForNewConnectionActivity(connId))).listen((event) {
    //
    // });
  }

  getAllActivity(
      {required String tableName, bool withStoragePermission = true}) async {
    //try {
    final Database db =
        withStoragePermission ? await database : await _getDatabase();
    return await db.rawQuery(""" SELECT * FROM $tableName """);
    // } catch (e) {
    //   debugShow('Get all activity error :${e}');
    //   return [];
    // }
  }

  getAllSeenUnseenActivity(
      {required String tableName, bool seen = true}) async {
    try {
      final Database db = await database;
      return await db.rawQuery(
          """ SELECT * FROM $tableName WHERE $_activityVisited = "$seen" """);
    } catch (e) {
      debugShow('Get all activity error :$e');
      return [];
    }
  }

  /// Get Total Messages from Any Table
  Future<int> getTotalMessages({required String tableName}) async {
    final Database db = await database;

    final List<Map<String, Object?>> data =
        await db.rawQuery("""SELECT COUNT(*) FROM $tableName""");

    return int.parse(data[0].values.first.toString());
  }

  Future<List<Map<String, Object?>>> getOldChatMessages(
      {required String tableName}) async {
    final Database db = await database;

    final List<Map<String, Object?>> data =
        await db.rawQuery("""SELECT * FROM $tableName""");

    return data;
  }

  storeDataForCurrAccount(_data, String currUserId) async {
    await createTableForStorePrimaryData();
    createTableForConnectionsPrimaryData();
    await insertUpdateDataCurrAccData(
        currUserId: currUserId,
        currUserName: _data["name"],
        currUserProfilePic: _data["profilePic"],
        currUserAbout: _data["about"],
        currUserEmail: _data["email"],
        dbOperation: DBOperation.insert);

    await DataManagement.storeStringData(
            StoredString.accCreatedBefore, DataManagement.toJsonString(_data))
        .then((value) => debugShow("Stored Data"));

    debugShow(
        "stored Data gEr: ${await DataManagement.getStringData(StoredString.accCreatedBefore)}");
  }

  Future<String?> getParticularChatWallpaper(String id) async {
    final _conPrimaryData =
        await _localStorageHelper.getConnectionPrimaryData(id: id);

    if (_conPrimaryData[_conChatWallpaperManually] == null.toString()) {
      final _currAccData = await _localStorageHelper.getDataForCurrAccount();
      return _currAccData[_currWallpaper];
    }

    return _conPrimaryData[_conChatWallpaperManually];
  }

  Future<bool> isThereGlobalChatWallpaper() async {
    final _currAccData = await _localStorageHelper.getDataForCurrAccount();
    return _currAccData[_currWallpaper].toString() != null.toString();
  }

  Future<bool> isThereParticularChatWallpaper(String partnerId) async {
    final _connPrimaryData =
        await _localStorageHelper.getConnectionPrimaryData(id: partnerId);
    return _connPrimaryData[_conChatWallpaperManually].toString() !=
        null.toString();
  }

  closeDatabase() async {
    final Database db = await database;
    await db.close();
  }

  get getDbInstance async => await database;

  deleteOwnExpiredActivity({String tableName = DbData.myActivityTable}) async {
    //try {
    debugShow('Entry 1');

    final Database db = await database;

    debugShow('Entry 2');
    final DBOperations _dbOperations = DBOperations();
    debugShow('Entry 3');
    final _activities = await db.rawQuery(""" SELECT * FROM $tableName """);
    debugShow('Entry 4');
    final _currDateTime = DateTime.now();

    debugShow('All Activities Collection: $_activities');

    for (final activity in _activities) {
      final _additionalThings = activity[_activityAdditionalThings] ?? "";
      debugShow('Additional Things: $_additionalThings');
      final _remoteData = DataManagement.fromJsonString(
          (DataManagement.fromJsonString(
                  _additionalThings.toString())["remoteData"]) ??
              "");

      // if (activity[_activityType] != ActivityContentType.text.toString()) {
      //   _dbOperations.deleteMediaFromFirebaseStorage(_remoteData['message']);
      // }

      _dbOperations.deleteParticularActivity(_remoteData);
      await _deleteEligibleActivities(
          activity: activity,
          currDateTime: _currDateTime,
          tableName: tableName);
    }
    // } catch (e) {
    //   debugShow('deleteMyExpiredActivity error :$e');
    //   return [];
    // }
  }

  manageDeleteConnectionsExpiredActivity() async {
    final _connectionsData = await getConnectionPrimaryData();
    if (_connectionsData.isEmpty) return;

    Map<String, List<dynamic>> _connData = {};
    final Database db = await database;

    for (final conn in _connectionsData) {
      try {
        final _activities = await db.rawQuery(
            """ SELECT * FROM ${DataManagement.generateTableNameForNewConnectionActivity(conn[_conId])} """);
        _connData[conn[_conId]] = _activities;
      } catch (e) {
        debugShow('Error in Get Ids: $e');
      }
    }

    final _currDateTime = DateTime.now();

    for (final connId in _connData.keys.toList()) {
      for (final activity in (_connData[connId] ?? [])) {
        await _deleteEligibleActivities(
            activity: activity,
            currDateTime: _currDateTime,
            tableName: DataManagement.generateTableNameForNewConnectionActivity(
                connId));
      }
    }
  }

  _deleteEligibleActivities(
      {required activity,
      required currDateTime,
      required String tableName}) async {
    //try {
    final _date = activity[_activityDate];
    final _time = activity[_activityTime];

    DateFormat format = DateFormat("dd MMMM, yyyy hh:mm a");
    var formattedDateTime = format.parse('$_date $_time');
    final Duration _diffDateTime = currDateTime.difference(formattedDateTime);

    if (_diffDateTime.inMinutes >= 2) {
      debugShow('Activity Deleting Msg: $activity');
      await deleteActivity(
          tableName: tableName, activityId: activity[_activityId]);
    }
    // } catch (e) {
    //   debugShow('Error in _deleteEligibleActivities: $e');
    // }
  }
}
