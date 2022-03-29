import 'dart:io';

import 'package:generation/services/permission_management.dart';
import 'package:generation/types/types.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../config/text_collection.dart';
import 'local_data_management.dart';

/// For Current User Data
/// For Connections Data
/// For Every Connection Chat Data Should Make a Table
/// For Every Connection Activity Data Should Make a Table

class LocalStorage {
  /// Current User Data
  final String _currUserId = "_id";
  final String _currUserName = "name";
  final String _currUserAbout = "about";
  final String _currUserEmail = "email";
  final String _currUserProfilePic = "profilePic";
  final String _currUserConversationTone = "conversationTone";

  /// Connections Primary Data
  final String _conId = "_id";
  final String _conUserName = "name";
  final String _conUserAbout = "about";
  final String _conProfilePic = "profilePic";
  final String _conChatWallpaperPath = "wallpaper";

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
      print("Directory Path: ${directory!.path}");

      final Directory newDirectory =
          await Directory(directory.path + "/${FolderData.dbFolder}/").create();

      print("Directory Path: ${newDirectory.path}");

      final String path = newDirectory.path +
          "/${DataManagement.getEnvData(EnvFileKey.dbName)}.db";

      final Database getDatabase = await openDatabase(path, version: 1);
      return getDatabase;
    }
  }

  /// Create Table For Store Current User Data
  Future<void> createTableForStorePrimaryData() async {
    final Database db = await database;
    try {
      await db.execute(
          """CREATE TABLE ${DbData.currUserDb}($_currUserId TEXT PRIMARY KEY, $_currUserName TEXT, $_currUserProfilePic TEXT, $_currUserAbout TEXT, $_currUserEmail TEXT, $_currUserConversationTone TEXT)""");
    } catch (e) {
      print(
          "Error in Local Storage Create Table For Store Primary Data: ${e.toString()}");
    }
  }

  /// Insert And Update For Current User Data
  Future<void> insertUpdateDataCurrAccData({
    required String currUserId,
    required String currUserName,
    required String currUserProfilePic,
    required String currUserAbout,
    required String currUserEmail,
    required bool currConTone,
    required DBOperation dbOperation,
  }) async {
    final Database db = await database;

    final Map<String, dynamic> _accountData = <String, dynamic>{};
    _accountData[_currUserId] = currUserId;
    _accountData[_currUserName] = currUserName;
    _accountData[_currUserEmail] = currUserEmail;
    _accountData[_currUserAbout] = currUserAbout;
    _accountData[_currUserProfilePic] = currUserProfilePic;
    _accountData[_currUserConversationTone] = currConTone.toString();

    if (dbOperation == DBOperation.update) {
      await db.update(DbData.currUserDb, _accountData,
          where: """$_currUserId = "$currUserId" """);
      return;
    }

    await db.insert(DbData.currUserDb, _accountData);
  }

  /// Read Operation for Current Account
  getDataForCurrAccount() async {
    final Database db = await database;

    final List<Map<String, Object?>> result =
        await db.rawQuery("""SELECT * FROM ${DbData.currUserDb}""");

    if (result.isEmpty) {
      print("No Current User Data Found From Local Database");
      return;
    }

    return result[0];
  }

  /// Create Table to Store Connections Primary Data
  Future<void> createTableForConnectionsPrimaryData() async {
    final Database db = await database;
    try {
      await db.execute(
          """CREATE TABLE ${DbData.connectionsDb}($_conId TEXT PRIMARY KEY, $_conUserName TEXT, $_conProfilePic TEXT, $_conUserAbout TEXT, $_conChatWallpaperPath TEXT)""");
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
      String? wallpaper}) async {
    final Database db = await database;

    final Map<String, dynamic> _conData = <String, dynamic>{};
    _conData[_conId] = id;
    _conData[_conUserName] = name;
    _conData[_conUserAbout] = about;
    _conData[_conProfilePic] = profilePic;
    _conData[_conChatWallpaperPath] = wallpaper;

    if (dbOperation == DBOperation.insert) {
      await db.insert(DbData.connectionsDb, _conData);
    } else {
      await db.update(DbData.connectionsDb, _conData,
          where: """$_conId = "$id" """);
    }
  }

  /// Delete particular connection
  Future<bool> deleteConnectionPrimaryData({required String id}) async {
    final Database db = await database;

    final _rowAffected =
        await db.delete(DbData.connectionsDb, where: """$_conId = "$id" """);
    if (_rowAffected == 1) return true;
    return false;
  }

  /// Get Connections Primary Data. If id null, it returns all the data. Get Particular Connection Data
  /// By Passing Connection Id
  getConnectionPrimaryData({String? id}) async{
    final Database db = await database;

    if(id == null) return await db.rawQuery("""SELECT * FROM ${DbData.connectionsDb}""");

    final data = await db.rawQuery("""SELECT * FROM ${DbData.connectionsDb} WHERE $_conId = "$id" """);
    if(data.isEmpty) return false;
    return data[0];
  }
}
