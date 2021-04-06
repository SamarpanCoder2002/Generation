import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class LocalStorageHelper {
  // Database Columns
  String _colMessages = "Messages";
  String _colReferences = "Reference";
  String _colDate = "Date";
  String _colTime = "Time";

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
  void createTable(String tableName) async {
    Database db = await this.database;
    await db.execute(
        'CREATE TABLE $tableName($_colMessages TEXT, $_colReferences INTEGER, $_colDate TEXT, $_colTime TEXT');
  }

  // Insert Data to Table
  Future<int> insertNewData(
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

    // Result Insert to DB
    var result = await db.insert(_tableName, _helperMap);
    return result;
  }

  // Extract data from table
  Future<List<Map<String, dynamic>>> extractData(String _tableName) async {
    Database db = await this.database; // DB Reference

    var result = db.rawQuery(
        'SELECT $_colMessages,$_colReferences, $_colTime FROM $_tableName');
    return result;
  }
}
