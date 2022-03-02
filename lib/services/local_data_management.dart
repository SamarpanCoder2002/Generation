import 'package:shared_preferences/shared_preferences.dart';

class DataManagement {
  static Future storeStringData(String key, String value) async {
    final instance = await SharedPreferences.getInstance();
    await instance.setString(key, value);
  }

  static Future getStringData(String key) async {
    final instance = await SharedPreferences.getInstance();
    return instance.getString(key);
  }

  static Future storeListData(String key, List<String> value) async{
    final instance = await SharedPreferences.getInstance();
    await instance.setStringList(key, value);
  }

  static Future<List<String>?> getListData(String key) async{
    final instance = await SharedPreferences.getInstance();
    return instance.getStringList(key);
  }
}