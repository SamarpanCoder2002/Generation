import 'dart:convert';

import 'package:flutter/material.dart';

class IncomingDataProvider extends ChangeNotifier{
  String incomingData = "";

  setIncomingData(dynamic incomingData){
    this.incomingData = json.encode(incomingData);
  }

  getIncomingData() => incomingData != ""? json.decode(incomingData):"";
}