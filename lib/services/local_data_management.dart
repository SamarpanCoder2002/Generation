import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  static loadEnvData() async => await dotenv.load(fileName: ".env");/// MAke Sure There is a file named as '.env' in root dir

  static String? getEnvData(String key) => dotenv.env[key];

  static toJsonString(data) => json.encode(data).toString();
  static fromJsonString(String jsonData) => json.decode(jsonData);
}