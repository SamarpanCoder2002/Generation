import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class LocalStorageProvider extends ChangeNotifier{
  late Database db;

  setDb(incoming){
    db = incoming;
    notifyListeners();
  }

  get  getDb  => db;
}