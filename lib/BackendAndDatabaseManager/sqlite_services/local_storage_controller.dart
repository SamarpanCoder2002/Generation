import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class LocalStorageHelper {
  // Database Columns
  String _colMessages = "Messages";
  String _colReferences = "Reference";
  String _colDate = "Date";
  String _colTime = "Time";
  String _colAbout = "About";
  String _colProfileImageUrl = "DP_Url";
  String _colEmail = "Email";

  // Create Singleton Objects(Only Created once in the whole application)
  static LocalStorageHelper _localStorageHelper;
  static Database _database;

  // Instantiate the obj
  LocalStorageHelper._createInstance();

  // For access Singleton object
  factory LocalStorageHelper() {
    if (_localStorageHelper == null)
      _localStorageHelper = LocalStorageHelper._createInstance();
    return _localStorageHelper;
  }

  Future<Database> get database async {
    if (_database == null) _database = await initializeDatabase();
    return _database;
  }

  // For make a database
  Future<Database> initializeDatabase() async {
    // Get the directory path to store the database
    final String dbPath = await getDatabasesPath();
    final String path = dbPath + '/generation_local_storage.db';

    // create the database
    final Database getDatabase = await openDatabase(path, version: 1);
    return getDatabase;
  }

  // For make a table
  Future<bool> createTable(String tableName) async {
    Database db = await this.database;
    try {
      await db.execute(
          "CREATE TABLE $tableName($_colMessages TEXT, $_colReferences INTEGER, $_colDate TEXT, $_colTime TEXT, $_colAbout TEXT, $_colProfileImageUrl TEXT, $_colEmail TEXT)");
      return true;
    } catch (e) {
      print("Error in Local Storage Create Table: ${e.toString()}");
      return false;
    }
  }

  // Insert Use Additional Data to Table
  Future<int> insertAdditionalData(
      String _tableName, String _about, String _email) async {
    Database db = await this.database; // DB Reference
    Map<String, dynamic> _helperMap =
        Map<String, dynamic>(); // Map to insert data

    // Insert Data to Map
    _helperMap[_colMessages] = "";
    _helperMap[_colReferences] = -1;
    _helperMap[_colDate] = "";
    _helperMap[_colTime] = "";
    _helperMap[_colAbout] = _about;
    _helperMap[_colProfileImageUrl] = "";
    _helperMap[_colEmail] = _email;

    // Result Insert to DB
    var result = await db.insert(_tableName, _helperMap);
    return result;
  }

  // Insert New Messages to Table
  Future<int> insertNewMessages(
      String _tableName, String _newMessage, int _ref) async {
    Database db = await this.database; // DB Reference
    Map<String, dynamic> _helperMap =
        Map<String, dynamic>(); // Map to insert data

    // Current Date
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String _dateIS = formatter.format(now);

    // Insert Data to Map
    _helperMap[_colMessages] = _newMessage;
    _helperMap[_colReferences] = _ref;
    _helperMap[_colDate] = _dateIS;
    _helperMap[_colTime] = '${DateTime.now().hour}: ${DateTime.now().minute}';
    _helperMap[_colAbout] = "";
    _helperMap[_colProfileImageUrl] = "";
    _helperMap[_colEmail] = "";

    // Result Insert to DB
    var result = await db.insert(_tableName, _helperMap);
    return result;
  }

  // Extract Connection Name from Table
  Future<List<Map<String, Object>>> extractAllTablesName() async {
    Database db = await this.database; // DB Reference
    List<Map<String, Object>> tables = await db.rawQuery(
        "SELECT tbl_name FROM sqlite_master WHERE tbl_name != 'android_metadata';");
    return tables;
  }

  // Extract Message from table
  Future<List<Map<String, dynamic>>> extractMessageData(
      String _tableName) async {
    Database db = await this.database; // DB Reference

    List<Map<String, Object>> result = await db.rawQuery(
        'SELECT $_colMessages, $_colTime, $_colReferences FROM $_tableName WHERE $_colReferences != -1');
    return result;
  }

  // Stream<List<String>> extractTables() async* {
  //   Queue<String> allData = Queue<String>();
  //
  //   List<Map<String, Object>> allTables =
  //       await LocalStorageHelper().extractAllTablesName();
  //
  //   if (allTables.isNotEmpty) {
  //     allTables.forEach((element) {
  //       allData.addFirst(element.values.toList()[0].toString());
  //     });
  //   } else
  //     print("No Data Present");
  //
  //   yield allData.toList();
  // }

  Future<String> fetchSendingInformation(String _tableName) async {
    Database db = await this.database;

    var result = await db
        .rawQuery("SELECT $_colEmail FROM $_tableName WHERE $_colTime = ''");

    return result[0].values.toList()[0];
  }

// Stream<List<Map<String, Object>>> findOutTables() {
//   Stream<List<Map<String, Object>>> take = LocalStorageHelper()
//       .extractAllTablesName()
//       .asStream()
//       .asBroadcastStream();
//   return take;
// }
}
