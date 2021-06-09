import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:generation/BackendAndDatabaseManager/global_controller/encrytion_maker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:generation/BackendAndDatabaseManager/global_controller/different_types.dart';

class LocalStorageHelper {
  // Database Columns
  final String _colMessages = "Messages";
  final String _colReferences = "Reference";
  final String _colMediaType = "Media";
  final String _colDate = "Date";
  final String _colTime = "Time";
  final String _colAbout = "About";
  final String _colToken = "Token";

  final String _colActivity = 'Status';
  final String _colTimeActivity = 'Status_Time';
  final String _colExtraText = 'ExtraActivityText';
  final String _colBgInformation = 'Bg_Information';

  final String _allImportantDataStore = '__ImportantDataTable__';
  final String _colAccountUserName = 'User_Name';
  final String _colAccountUserMail = 'User_Mail';
  final String _colProfileImagePath = 'DP_Path';
  final String _colProfileImageUrl = 'DP_Url';
  final String _colChatWallPaper = 'Chat_WallPaper';
  final String _colMobileNumber = 'User_Mobile_Number';
  final String _colParticularBGNStatus = 'ParticularBGNStatus';
  final String _colParticularFGNStatus = 'ParticularFGNStatus';
  final String _colCreationDate = 'Creation_Date';
  final String _colCreationTime = 'Creation_Time';

  final String _colActivitySpecial = 'ActivitySpecialOptions';

  final String _allRemainingLinksToDeleteFromFirebaseStorage =
      '__RemainingLinksToDelete__';
  final String _colLinks = 'New_Link';

  final String _notificationGlobalConfig = '__Controller_Configuration__';
  final String _colBgNotify = '__BGNotify__';
  final String _colFGNotify = '__FGNotify__';
  final String _colRemoveBirthNotification = '__RemoveBirthNotification__';
  final String _colAnonymousRemoveNotification =
      '__RemoveAnonymousNotification__';

  final String _colCallTime = '__callTime__';
  final String _colCallDate = '__callDate__';
  final String _colCallType = '__callType__';

  final EncryptionMaker _encryptionMaker = EncryptionMaker();

  /// Create Singleton Objects(Only Created once in the whole application)
  static LocalStorageHelper _localStorageHelper;
  static Database _database;

  /// Instantiate the obj
  LocalStorageHelper._createInstance();

  /// For access Singleton object
  factory LocalStorageHelper() {
    if (_localStorageHelper == null)
      _localStorageHelper = LocalStorageHelper._createInstance();
    return _localStorageHelper;
  }

  Future<Database> get database async {
    if (_database == null) _database = await initializeDatabase();
    return _database;
  }

  /// For make a database
  Future<Database> initializeDatabase() async {
    /// Get the directory path to store the database

    final Directory directory = await getExternalStorageDirectory();
    print('Directory Path: ${directory.path}');

    final Directory newDirectory =
        await Directory(directory.path + '/.Databases/').create();
    final String path = newDirectory.path + '/generation_local_storage.db';

    // create the database
    final Database getDatabase = await openDatabase(path, version: 1);
    return getDatabase;
  }

  /// For Current user and connections general data to store
  /// General Data Plays a Huge role for managing interaction with connections

  Future<void> createTableForStorePrimaryData() async {
    Database db = await this.database;
    try {
      await db.execute(
          "CREATE TABLE $_allImportantDataStore($_colAccountUserName TEXT PRIMARY KEY, $_colAccountUserMail TEXT, $_colToken TEXT, $_colProfileImagePath TEXT, $_colProfileImageUrl TEXT, $_colAbout TEXT, $_colChatWallPaper TEXT, $_colParticularBGNStatus TEXT, $_colParticularFGNStatus TEXT, $_colMobileNumber TEXT, $_colCreationDate TEXT, $_colCreationTime TEXT)");
    } catch (e) {
      print(
          "Error in Local Storage Create Table For Store Primary Data: ${e.toString()}");
    }
  }

  Future<void> insertOrUpdateDataForThisAccount({
    @required String userName,
    @required String userMail,
    @required String userToken,
    @required String userAbout,
    @required String userAccCreationDate,
    @required String userAccCreationTime,
    String chatWallpaper = '',
    String profileImagePath = '',
    String profileImageUrl = '',
    String purpose = 'insert',
  }) async {
    try {
      final Database db = await this.database;

      if (purpose != 'insert') {
        final int updateResult = await db.rawUpdate(
            "UPDATE $_allImportantDataStore SET $_colToken = '$userToken', $_colAbout = '$userAbout', $_colAccountUserMail = '$userMail', $_colCreationDate = '$userAccCreationDate', $_colCreationTime = '$userAccCreationTime' WHERE $_colAccountUserName = '$userName'");

        print('Update Result is: $updateResult');
      } else {
        final Map<String, dynamic> _accountData = Map<String, dynamic>();

        _accountData[_colAccountUserName] = userName;
        _accountData[_colAccountUserMail] = userMail;
        _accountData[_colToken] = userToken;
        _accountData[_colProfileImagePath] = profileImagePath;
        _accountData[_colProfileImageUrl] = profileImageUrl;
        _accountData[_colAbout] = userAbout;
        _accountData[_colChatWallPaper] = chatWallpaper;
        _accountData[_colMobileNumber] = '';
        _accountData[_colParticularBGNStatus] = "1";
        _accountData[_colParticularFGNStatus] = "1";
        _accountData[_colCreationDate] = userAccCreationDate;
        _accountData[_colCreationTime] = userAccCreationTime;

        await db.insert(_allImportantDataStore, _accountData);
      }
    } catch (e) {
      print('Error in Insert or Update This Account Data: ${e.toString()}');
    }
  }

  Future<void> insertProfilePictureInImportant(
      {@required String imagePath,
      @required String imageUrl,
      @required String mail}) async {
    try {
      final Database db = await this.database;

      final int result = await db.rawUpdate(
          "UPDATE $_allImportantDataStore SET $_colProfileImagePath = '$imagePath', $_colProfileImageUrl = '$imageUrl' WHERE $_colAccountUserMail = '$mail'");

      result == 1
          ? print('Success: New Profile Picture Update Successful')
          : print('Failed: New Profile Picture Update Fail');
    } catch (e) {
      print('Insert Profile Picture to Local Database Error: ${e.toString()}');
    }
  }

  Future<void> updateImportantTableExtraData(
      {String userName = '',
      String userMail = '',
      bool allUpdate = false,
      @required ExtraImportant extraImportant,
      @required String updatedVal}) async {
    try {
      final Database db = await this.database;

      if (!allUpdate && userName == '')
        userName =
            await extractImportantDataFromThatAccount(userMail: userMail);

      final String _query =
          identifyExtraImportantData(extraImportant: extraImportant);

      int result;

      if (allUpdate) {
        result = await db.rawUpdate(
            "UPDATE $_allImportantDataStore SET $_query = '$updatedVal'");
      } else {
        result = await db.rawUpdate(
            "UPDATE $_allImportantDataStore SET $_query = '$updatedVal' WHERE $_colAccountUserName = '$userName'");
      }

      print(
          'Update Important Data Store Result : ${result > 0 ? true : false}');
    } catch (e) {
      print('Update Important Table Extra Data Error: ${e.toString()}');
    }
  }

  Future<dynamic> extractImportantTableData({
    String userName = '',
    String userMail = '',
    @required ExtraImportant extraImportant,
  }) async {
    try {
      final Database db = await this.database;

      if (userName == '')
        userName =
            await extractImportantDataFromThatAccount(userMail: userMail);

      final String _query =
          identifyExtraImportantData(extraImportant: extraImportant);

      final List<Map<String, Object>> result = await db.rawQuery(
          "SELECT $_query FROM $_allImportantDataStore WHERE $_colAccountUserName = '$userName'");

      final String take = result[0][_query];

      if (take == '1' || take == '0') return take == '1' ? true : false;

      return take;
    } catch (e) {
      print('Extract Important Table Data: ${e.toString()}');
    }
  }

  /// Actually Doing Update as for delete, entire row will be rejected from table
  Future<void> deleteParticularUpdatedImportantData(
      {@required ExtraImportant extraImportant,
      @required String shouldBeDeleted}) async {
    try {
      final Database db = await this.database;

      final String query =
          identifyExtraImportantData(extraImportant: extraImportant);

      final int result = await db.rawUpdate(
          "UPDATE $_allImportantDataStore SET $query = '' WHERE $query = '$shouldBeDeleted'");

      print(result > 0
          ? 'Particular Important Data Deletion Successful'
          : 'Error: Particular Data Deletion Failed');
    } catch (e) {
      print(
          'Error: Delete Particular Updated Important Data Error: ${e.toString()}');
    }
  }

  String identifyExtraImportantData({@required ExtraImportant extraImportant}) {
    switch (extraImportant) {
      case ExtraImportant.ChatWallpaper:
        return this._colChatWallPaper;
        break;
      case ExtraImportant.BGNStatus:
        return this._colParticularBGNStatus;
        break;
      case ExtraImportant.FGNStatus:
        return this._colParticularFGNStatus;
        break;
      case ExtraImportant.MobileNumber:
        return this._colMobileNumber;
        break;
      case ExtraImportant.CreationDate:
        return this._colCreationDate;
        break;
      case ExtraImportant.CreationTime:
        return this._colCreationTime;
        break;
      case ExtraImportant.About:
        return this._colAbout;
        break;
    }

    return 'Exception';
  }

  Future<String> extractImportantDataFromThatAccount(
      {String userName = '', String userMail = ''}) async {
    final Database db = await this.database;

    List<Map<String, Object>> result = [];

    if (userMail != '')
      result = await db.rawQuery(
          "SELECT $_colAccountUserName FROM $_allImportantDataStore WHERE $_colAccountUserMail = '$userMail'");
    else
      result = await db.rawQuery(
          "SELECT $_colAccountUserMail FROM $_allImportantDataStore WHERE $_colAccountUserName = '$userName'");

    return result[0].values.first;
  }

  Future<Map<String, String>>
      extractUserNameAndProfilePicFromImportant() async {
    final Database db = await this.database;

    final List<Map<String, Object>> result = await db.rawQuery(
        'SELECT $_colAccountUserName,$_colProfileImagePath FROM $_allImportantDataStore');

    final Map<String, String> tempMap = Map<String, String>();

    result.forEach((userData) {
      tempMap[userData[_colAccountUserName]] =
          userData[_colProfileImagePath].toString();
    });

    return tempMap;
  }

  Future<String> extractToken(
      {String userMail = '', String userName = ''}) async {
    final Database db = await this.database;

    List<Map<String, Object>> result;

    if (userMail != '')
      result = await db.rawQuery(
          "SELECT $_colToken FROM $_allImportantDataStore WHERE $_colAccountUserMail = '$userMail'");
    else
      result = await db.rawQuery(
          "SELECT $_colToken FROM $_allImportantDataStore WHERE $_colAccountUserName = '$userName'");

    return result[0].values.first;
  }

  Future<String> extractProfileImageLocalPath(
      {String userMail = '', String userName = ''}) async {
    final Database db = await this.database;

    List<Map<String, Object>> result;

    if (userMail != '')
      result = await db.rawQuery(
          "SELECT $_colProfileImagePath FROM $_allImportantDataStore WHERE $_colAccountUserMail = '$userMail'");
    else
      result = await db.rawQuery(
          "SELECT $_colProfileImagePath FROM $_allImportantDataStore WHERE $_colAccountUserName = '$userName'");

    return result[0].values.first == null ? '' : result[0].values.first;
  }

  Future<String> extractProfilePicUrl({@required String userName}) async {
    final Database db = await this.database;

    final List<Map<String, Object>> result = await db.rawQuery(
        "SELECT $_colProfileImageUrl FROM $_allImportantDataStore WHERE $_colAccountUserName = '$userName'");

    if (result != null) return result[0].values.first;
    return '';
  }

  Future<List<Map<String, Object>>> extractAllUsersName(
      {bool thisAccountAllowed = false}) async {
    Database db = await this.database;
    List<Map<String, Object>> result;

    if (!thisAccountAllowed)
      result = await db.rawQuery(
          "SELECT $_colAccountUserName FROM $_allImportantDataStore WHERE $_colAccountUserMail != '${FirebaseAuth.instance.currentUser.email}'");
    else
      result = await db
          .rawQuery("SELECT $_colAccountUserName FROM $_allImportantDataStore");
    return result == null ? [] : result;
  }

  /// Make Tables for user Activity
  /// These for user Activity Data Manipulation
  /// For User Data Customization use the following functions

  /// For Make Table for Status
  Future<bool> createTableForUserActivity(String tableName) async {
    final Database db = await this.database;
    try {
      await db.execute(
          "CREATE TABLE ${tableName}_status($_colActivity, $_colTimeActivity TEXT PRIMARY KEY, $_colMediaType TEXT, $_colExtraText TEXT, $_colBgInformation TEXT, $_colActivitySpecial TEXT)");
      return true;
    } catch (e) {
      print("Error in Local Storage Create Table For Status: ${e.toString()}");
      return false;
    }
  }

  /// Insert ActivityData to Activity Table
  Future<bool> insertDataInUserActivityTable(
      {@required String tableName,
      @required String statusLinkOrString,
      MediaTypes mediaTypes,
      @required String activityTime,
      ActivitySpecialOptions activitySpecialOptions,
      String extraText = '',
      String bgInformation = ''}) async {
    try {
      final Database db = await this.database;
      final Map<String, dynamic> _activityStoreMap = Map<String, dynamic>();

      _activityStoreMap[_colActivity] = statusLinkOrString;
      _activityStoreMap[_colTimeActivity] = activityTime;
      _activityStoreMap[_colMediaType] =
          mediaTypes == null ? '' : mediaTypes.toString();
      _activityStoreMap[_colExtraText] = extraText;
      _activityStoreMap[_colBgInformation] = bgInformation;
      _activityStoreMap[_colActivitySpecial] = activitySpecialOptions == null
          ? ''
          : activitySpecialOptions.toString();

      /// Result Insert to DB
      final int result =
          await db.insert('${tableName}_status', _activityStoreMap);

      return result > 0 ? true : false;
    } catch (e) {
      print('Error: Activity Table Data insertion Error: ${e.toString()}');
      return false;
    }
  }

  /// Extract Status from Table Name
  Future<List<Map<String, dynamic>>> extractActivityForParticularUserName(
      String tableName) async {
    try {
      final Database db = await this.database;
      final List<Map<String, Object>> tables =
          await db.rawQuery("SELECT * FROM ${tableName}_status");
      return tables;
    } catch (e) {
      print('Extract USer Name Activity Exception: ${e.toString()}');
      return null;
    }
  }

  /// Delete Particular Activity record From Activity Container
  Future<void> deleteParticularActivity(
      {@required String tableName, @required String activity}) async {
    try {
      final Database db = await this.database;

      print('Here in Delete Particular Activity: $tableName   $activity');

      final int result = await db.rawDelete(
          "DELETE FROM ${tableName}_status WHERE $_colActivity = '$activity'");

      print('Deletion Result: $result');
    } catch (e) {
      print('Delete Activity From Database Error: ${e.toString()}');
    }
  }

  /// Update Particular Activity
  Future<void> updateTableActivity(
      {@required String tableName,
      @required String oldActivity,
      @required String newAddition}) async {
    try {
      final Database db = await this.database;

      final int _updateResult = await db.rawUpdate(
          "UPDATE ${tableName}_status SET $_colActivity = '$oldActivity[[[question]]]$newAddition' WHERE $_colActivity = '$oldActivity'");

      print('Update Result is: $_updateResult');
    } catch (e) {
      print('Update Table Activity Error: ${e.toString()}');
    }
  }

  /// For Debugging Purpose
  Future<void> showParticularUserAllActivity(
      {@required String tableName}) async {
    try {
      final Database db = await this.database;
      var take = await db.rawQuery("SELECT * FROM ${tableName}_status");

      print('All Activity: $take');
    } catch (e) {
      print('showParticularUserAllActivity Error: ${e.toString()}');
    }
  }

  /// Count Total Statuses for particular Table Name
  Future<int> countTotalActivitiesForParticularUserName(
      String tableName) async {
    final Database db = await this.database;
    final List<Map<String, Object>> countTotalStatus =
        await db.rawQuery('SELECT COUNT(*) FROM ${tableName}_status');

    return countTotalStatus[0].values.first;
  }

  /// All Chat Messages Manipulation will done here
  /// Message Store and customization following by the following functions
  /// Table Name same as User Name

  /// For make a table
  Future<bool> createTableForUserName(String tableName) async {
    Database db = await this.database;
    try {
      await db.execute(
          "CREATE TABLE $tableName($_colMessages TEXT, $_colReferences INTEGER, $_colMediaType TEXT, $_colDate TEXT, $_colTime TEXT)");
      return true;
    } catch (e) {
      print(
          "Error in Local Storage Create Table For User Name: ${e.toString()}");
      return false;
    }
  }

  /// Count total Messages for particular Table Name
  Future<int> _countTotalMessagesUnderATable(String _tableName) async {
    final Database db = await this.database;

    final List<Map<String, Object>> countTotalMessagesWithOneAdditionalData =
        await db.rawQuery('SELECT COUNT(*) FROM $_tableName');

    return countTotalMessagesWithOneAdditionalData[0].values.first;
  }

  /// Insert New Messages to Table
  Future<int> insertNewMessages(String _tableName, String _newMessage,
      MediaTypes _currMediaType, int _ref, String _time) async {
    Database db = await this.database; // DB Reference
    Map<String, dynamic> _helperMap =
        Map<String, dynamic>(); // Map to insert data

    /// Current Date
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('dd-MM-yyyy');
    String _dateIS = formatter.format(now);

    /// Insert Data to Map
    _helperMap[_colMessages] = _newMessage;
    _helperMap[_colReferences] = _ref;
    _helperMap[_colMediaType] = _currMediaType.toString();
    _helperMap[_colDate] = _dateIS;
    _helperMap[_colTime] = _time;

    /// Result Insert to DB
    var result = await db.insert(_tableName, _helperMap);
    print(result);

    return result;
  }

  /// Extract Message from table
  Future<List<Map<String, dynamic>>> extractMessageData(
      String _tableName) async {
    final Database db = await this.database; // DB Reference

    final List<Map<String, Object>> result = await db.rawQuery(
        'SELECT $_colMessages, $_colTime, $_colReferences, $_colMediaType, $_colDate FROM $_tableName');

    return result;
  }

  /// Delete Particular Message
  Future<bool> deleteChatMessage(
    String _tableName, {
    @required String message,
    String time,
    int reference,
    @required String mediaType,
    multipleMediaDeletion = false,
  }) async {
    try {
      final Database db = await this.database;

      print('Message: $message');
      print('Time: $time');
      print('Reference: $reference');
      print('MediaType: $mediaType');

      int result;

      if (multipleMediaDeletion)
        result = await db.rawDelete(
            "DELETE FROM $_tableName WHERE $_colMessages = '${_encryptionMaker.encryptionMaker(message)}' AND $_colMediaType = '$mediaType'");
      else
        result = await db.rawDelete(
            "DELETE FROM $_tableName WHERE $_colMessages = '${_encryptionMaker.encryptionMaker(message)}' AND $_colTime = '${_encryptionMaker.encryptionMaker(time)}' AND $_colReferences = $reference AND $_colMediaType = '$mediaType'");

      if (result == 0) {
        print('Result: $result');
        return false;
      } else {
        print('Delete From Chat Message Result: $result');
        return true;
      }
    } catch (e) {
      print('Delete From Chat Message Error: ${e.toString()}');
      return false;
    }
  }

  /// Fetch Latest Message
  Future<Map<String, String>> fetchLatestMessage(String _tableName) async {
    final Database db = await this.database;

    final int totalMessages = await _countTotalMessagesUnderATable(_tableName);

    if (totalMessages == 0) return null;

    final List<Map<String, Object>> result = await db.rawQuery(
        "SELECT $_colMessages, $_colMediaType, $_colTime FROM $_tableName LIMIT 1 OFFSET ${totalMessages - 1}");

    print('Result is: $result');
    final Map<String, String> map = Map<String, String>();

    if (result != null && result.length > 0) {
      final String _time = _encryptionMaker
          .decryptionMaker(result[0][_colTime].toString())
          .split('+')[0];

      print('Now: $_time');

      map.addAll({
        result[0][_colMessages]:
            '${_encryptionMaker.encryptionMaker(_time)}+${result[0][_colMediaType]}+localDb',
      });
    }

    print('Map is: $map');

    return map;
  }

  Future<List<Map<String, Object>>> fetchAllHistoryData(
      String _tableName) async {
    try {
      final Database db = await this.database;

      final List<Map<String, Object>> result = await db.rawQuery(
          'SELECT $_colMessages, $_colReferences, $_colMediaType, $_colTime, $_colDate FROM $_tableName');

      return result;
    } catch (e) {
      print('Fetch all History Data Error: ${e.toString()}');
      return [];
    }
  }

  Future<List<Map<String, String>>> extractParticularChatMediaByRequirement(
      {@required String tableName, @required MediaTypes mediaType}) async {
    try {
      final Database db = await this.database;

      List<Map<String, Object>> result;

      if (mediaType != MediaTypes.Video)
        result = await db.rawQuery(
            "SELECT $_colMessages FROM $tableName WHERE $_colMediaType= '$mediaType'");
      else
        result = await db.rawQuery(
            "SELECT $_colMessages, $_colTime FROM $tableName WHERE $_colMediaType= '$mediaType'");

      final List<Map<String, String>> _container = [];

      result.reversed.toList().forEach((element) async {
        int _fileSize = await File(_encryptionMaker
                .decryptionMaker(element.values.first.toString()))
            .length();

        print(
            'PAth now: ${_encryptionMaker.decryptionMaker(element[_colMessages].toString())}');

        _container.add({
          mediaType != MediaTypes.Video
                  ? _encryptionMaker
                      .decryptionMaker(element[_colMessages].toString())
                  : '${_encryptionMaker.decryptionMaker(element[_colMessages].toString())}+${_encryptionMaker.decryptionMaker(element[_colTime].toString()).split('+')[2]}':
              '${_formatBytes(_fileSize.toDouble())}',
        });
      });

      return _container;
    } catch (e) {
      print('Error: Extract Particular Chat All Media Error: ${e.toString()}');
      return [];
    }
  }

  /// Convert bytes of kb, mb, gb
  String _formatBytes(double bytes) {
    double kb = bytes / 1000;

    if (kb >= 1024.00) {
      double mb = bytes / (1000 * 1024);
      if (mb >= 1024.00)
        return '${(bytes / (1000 * 1024 * 1024)).toStringAsFixed(1)} gb';
      else
        return '${mb.toStringAsFixed(1)} mb';
    } else
      return '${kb.toStringAsFixed(1)} kb';
  }

  /// For Multiple Connection Media Send, store links in the following containing table
  /// for 24 hrs after send message.... These links will delete after 24hrs
  Future<void> createTableForRemainingLinks() async {
    final Database db = await this.database;

    await db.transaction((txn) async {
      return await txn.rawQuery(
          'CREATE TABLE $_allRemainingLinksToDeleteFromFirebaseStorage($_colLinks TEXT, $_colTime TEXT)');
    });
  }

  Future<void> insertNewLinkInLinkRemainingTable(
      {@required String link}) async {
    try {
      final Database db = await this.database;

      final Map<String, String> map = Map<String, String>();
      map[_colLinks] = _encryptionMaker.encryptionMaker(link);
      map[_colTime] =
          _encryptionMaker.encryptionMaker(DateTime.now().toString());

      int result =
          await db.insert(_allRemainingLinksToDeleteFromFirebaseStorage, map);

      print('Insert New Link Result : $result');
    } catch (e) {
      print('Insert Remaining Links Error: ${e.toString()}');
      await createTableForRemainingLinks();
      await insertNewLinkInLinkRemainingTable(link: link);
    }
  }

  /// For Debugging purpose
  Future<void> showAll() async {
    final Database db = await this.database;

    final List<Map<String, Object>> result = await db.rawQuery(
        'SELECT * from $_allRemainingLinksToDeleteFromFirebaseStorage');

    print('Storage Result is: $result');
  }

  /// Remaining Links extract to delete
  Future<Map<String, String>> extractRemainingLinks() async {
    try {
      final Database db = await this.database;

      final List<Map<String, Object>> result = await db.rawQuery(
          'SELECT * FROM $_allRemainingLinksToDeleteFromFirebaseStorage');

      final Map<String, String> map = Map<String, String>();

      result.forEach((everyResult) {
        map.addAll({
          _encryptionMaker.decryptionMaker(everyResult[_colLinks].toString()):
              _encryptionMaker
                  .decryptionMaker(everyResult[_colTime].toString()),
        });
      });

      return map;
    } catch (e) {
      print('Extract Links Error: ${e.toString()}');
      return Map<String, String>();
    }
  }

  Future<void> deleteRemainingLinksFromLocalStore(
      {@required String link}) async {
    try {
      final Database db = await this.database;

      await db.rawDelete(
          "DELETE FROM $_allRemainingLinksToDeleteFromFirebaseStorage WHERE $_colLinks = '${_encryptionMaker.encryptionMaker(link)}'");
    } catch (e) {
      print('Remaining Links Deletion Exception: ${e.toString()}');
    }
  }

  Future<void> deleteTheExistingDatabase() async {
    try {
      final Directory directory = await getExternalStorageDirectory();
      print('Directory Path: ${directory.path}');

      final Directory newDirectory =
          await Directory(directory.path + '/.Databases/').create();
      final String path = newDirectory.path + '/generation_local_storage.db';

      // delete the database
      await deleteDatabase(path);

      print('After Delete Database');
    } catch (e) {
      print('Delete Database Exception: ${e.toString()}');
    }
  }

  /// For Notification Controlling Data Store
  /// All Notification Settings Will store here
  /// For Future Use
  Future<void> createTableForNotificationGlobalConfig() async {
    final Database db = await this.database;

    try {
      await db.execute(
          'CREATE TABLE $_notificationGlobalConfig($_colBgNotify INTEGER, $_colFGNotify INTEGER, $_colRemoveBirthNotification INTEGER, $_colAnonymousRemoveNotification INTEGER)');
    } catch (e) {
      print('Notification Table Make Error: ${e.toString()}');
    }
  }

  Future<void> insertDataForNotificationGlobalConfig() async {
    final Database db = await this.database;

    try {
      final Map<String, Object> map = Map<String, Object>();

      map[_colBgNotify] = 1;
      map[_colFGNotify] = 1;
      map[_colRemoveBirthNotification] = 0;
      map[_colAnonymousRemoveNotification] = 0;

      await db.insert(_notificationGlobalConfig, map);
    } catch (e) {
      print('Notification Global Config Data Insertion Error: ${e.toString()}');
    }
  }

  Future<void> updateDataForNotificationGlobalConfig(
      {@required NConfigTypes nConfigTypes,
      @required bool updatedNotifyCondition}) async {
    final Database db = await this.database;

    try {
      final String _argumentNotify = _findBestMatch(nConfigTypes);

      await db.rawUpdate(
          'UPDATE $_notificationGlobalConfig SET $_argumentNotify = ${updatedNotifyCondition ? 1 : 0}');
    } catch (e) {
      print(
          'Exception: Update in Notification Global Config Error: ${e.toString()}');
    }
  }

  String _findBestMatch(NConfigTypes nConfigTypes) {
    switch (nConfigTypes) {
      case NConfigTypes.BgNotification:
        return this._colBgNotify;
        break;
      case NConfigTypes.FGNotification:
        return this._colFGNotify;
        break;
      case NConfigTypes.RemoveBirthNotification:
        return this._colRemoveBirthNotification;
        break;
      case NConfigTypes.RemoveAnonymousNotification:
        return this._colAnonymousRemoveNotification;
        break;
    }

    return 'Exception';
  }

  Future<bool> extractDataForNotificationConfigTable(
      {@required NConfigTypes nConfigTypes}) async {
    try {
      final Database db = await this.database;

      final String _argument = _findBestMatch(nConfigTypes);

      final List<Map<String, Object>> result = await db
          .rawQuery('SELECT $_argument FROM $_notificationGlobalConfig');

      print('Notification Extract Result: $result');

      return result[0].values.first.toString() == '1' ? true : false;
    } catch (e) {
      print(
          'Error: Extract Data From Notification Table Error: ${e.toString()}');
      return true;
    }
  }

  /// For Call Log Data Management

  Future<void> createTableForConnectionCallLogs(String tableName) async {
    try {
      final Database db = await this.database;

      await db.rawQuery(
          'CREATE TABLE ${tableName}_callHistory($_colCallDate TEXT, $_colCallTime TEXT, $_colCallType TEXT)');
    } catch (e) {
      print('Error: Create Table For Call Logs: ${e.toString()}');
    }
  }

  Future<void> insertDataForCallLog(String tableName,
      {@required String callDate,
      @required String callTime,
      CallTypes callTypes = CallTypes.AudioCall}) async {
    try {
      final Database db = await this.database;

      final Map<String, Object> tempMap = Map<String, Object>();

      tempMap[_colCallDate] = callDate;
      tempMap[_colCallTime] = callTime;
      tempMap[_colCallType] = callTypes.toString();

      final int result = await db.insert('${tableName}_callHistory', tempMap);

      print('Call Log data insertion Result: $result ');
    } catch (e) {
      print('Error: Insert data in Call Log Error: ${e.toString()}');
    }
  }

  Future<dynamic> countOrExtractTotalCallLogs(String tableName,
      {String purpose = 'COUNT'}) async {
    try {
      final Database db = await this.database;

      final List<Map<String, Object>> result = await db.rawQuery(
          "SELECT ${purpose == 'COUNT' ? 'COUNT(*)' : '*'} FROM ${tableName}_callHistory");

      print('Result is: $result');

      if (purpose == 'COUNT') return result == null ? 0 : int.parse(result[0].values.first.toString());

      return result == null ? [] : result;
    } catch (e) {
      print('Error: Count total Call Logs Error: ${e.toString()}');
      return purpose == 'COUNT' ? 0 : [];
    }
  }

  Future<void> deleteParticularConnectionAllCallLogs(String tableName) async {
    try {
      final Database db = await this.database;

      final int result =
          await db.rawDelete("DELETE FROM '${tableName}_callHistory'");

      print('Call Log Deletion Result is: $result');
    } catch (e) {
      print('Error: Delete Particular Call Log: ${e.toString()}');
    }
  }
}
