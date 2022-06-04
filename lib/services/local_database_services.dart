import 'dart:io';

import 'package:generation/config/size_collection.dart';
import 'package:generation/services/permission_management.dart';
import 'package:generation/config/types.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../config/stored_string_collection.dart';
import '../config/text_collection.dart';
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
      print("Storage Permission Required under local database services");
      return _database;
    } else {
      final Directory? directory = await getExternalStorageDirectory();

      final Directory newDirectory =
          await Directory(directory!.path + "/${FolderData.dbFolder}/")
              .create();

      final String path = newDirectory.path +
          "/${DataManagement.getEnvData(EnvFileKey.dbName)}.db";

      final Database getDatabase = await openDatabase(path, version: 1);
      return getDatabase;
    }
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
      print(
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
      print("No Current User Data Found From Local Database");
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
      print(
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
          _conData[_conNotificationManually] =
              _oldConnPrimaryData[_conNotificationManually];
        }

        await db.update(DbData.connectionsTable, _conData,
            where: """$_conId = "$id" """);
      }
    } catch (e) {
      print("ERROR in insertUpdateConnectionPrimaryData: $e");
    }
  }

  /// Delete particular connection
  Future<bool> deleteConnectionPrimaryData(
      {required String id, bool allowDeleteOtherRelatedTable = false}) async {
    final Database db = await database;

    final _rowAffected =
        await db.delete(DbData.connectionsTable, where: """$_conId = "$id" """);

    print("row Affected:  $_rowAffected");

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
  getConnectionPrimaryData({String? id}) async {
    final Database db = await database;

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
      print(
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
  deleteDataFromParticularChatConnTable(
      {required String tableName, String? msgId}) async {
    final Database db = await database;

    if (msgId == null) {
      await db.delete(tableName);
      print("Deletion done chat");
    } else {
      await db.delete(tableName, where: """$_msgId = "$msgId" """);
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
          """CREATE TABLE $tableName($_activityHolderId TEXT, $_activityId TEXT PRIMARY KEY, $_activityMessage TEXT, $_activityType TEXT, $_activityDate TEXT, $_activityTime TEXT, $_activityAdditionalThings TEXT)""");
    } catch (e) {
      print("Error in _createTableForActivity Chat: ${e.toString()}");
    }
  }

  /// Insert Data in particular connection Activity Messages
  Future<void> insertUpdateTableForActivity(
      {required String tableName,
      required String activityId,
      required String activityHolderId,
      required String activityType,
      required String date,
      required String time,
      required String msg,
      required dynamic additionalData,
      required DBOperation dbOperation}) async {
    final Database db = await database;

    final Map<String, dynamic> _activityData = <String, dynamic>{};

    _activityData[_activityId] = activityId;
    _activityData[_activityHolderId] = activityHolderId;
    _activityData[_activityType] = activityType;
    _activityData[_activityDate] = date;
    _activityData[_activityTime] = time;
    _activityData[_activityMessage] = msg;
    _activityData[_activityAdditionalThings] =
        DataManagement.toJsonString(additionalData);

    dbOperation == DBOperation.insert
        ? db.insert(tableName, _activityData)
        : db.update(tableName, _activityData,
            where: """$_activityHolderId = "$activityHolderId" """);
  }

  deleteActivity({required String tableName, String? activityId}) async {
    final Database db = await database;

    if (activityId == null) {
      await db.delete(tableName);
      print("Delete Activity");
    } else {
      await db.delete(tableName, where: """$_activityId = "$activityId" """);
    }
  }

  getAllActivity(
      {required String tableName, required String activityHolderId}) async {
    final Database db = await database;

    final _activitySet = await db.rawQuery(
        """ SELECT * FROM $tableName WHERE $_activityHolderId = "$activityHolderId" """);

    return _activitySet;
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
        .then((value) => print("Stored Data"));

    print(
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
}
