import 'package:flutter/material.dart';
import 'package:generation/services/local_database_services.dart';

class StatusCollectionProvider extends ChangeNotifier {
  final LocalStorage _localStorage = LocalStorage();
  Map<String,dynamic> _currAccData = {};
  List<dynamic> _activityDataCollection = [
    {
      "id": 1,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "isActive": true,
      "connectionName": "Samarpan",
    },
    {
      "id": 2,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/3/34/Elon_Musk_Royal_Society_%28crop2%29.jpg",
      "isActive": true,
      "connectionName": "Sukannya",
    },
    {
      "id": 3,
      "profilePic":
          "https://static01.nyt.com/images/2021/05/25/multimedia/25xp-johncena/25xp-johncena-mobileMasterAt3x.jpg",
      "isActive": true,
      "connectionName": "Samarpan",
    },
    {
      "id": 4,
      "profilePic":
          "https://www.samarpandasgupta.com/static/media/samarpan_dasgupta.48a013aa.png",
      "isActive": true,
      "connectionName": "Sukannya",
    },
    {
      "id": 5,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "isActive": false,
      "connectionName": "Samarpan",
    },
    {
      "id": 6,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/3/34/Elon_Musk_Royal_Society_%28crop2%29.jpg",
      "isActive": false,
      "connectionName": "Sukannya",
    },
    {
      "id": 7,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "isActive": false,
      "connectionName": "Samarpan",
    },
    {
      "id": 8,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/3/34/Elon_Musk_Royal_Society_%28crop2%29.jpg",
      "isActive": false,
      "connectionName": "Sukannya",
    },
    {
      "id": 9,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "isActive": false,
      "connectionName": "Samarpan",
    },
    {
      "id": 10,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/3/34/Elon_Musk_Royal_Society_%28crop2%29.jpg",
      "isActive": false,
      "connectionName": "Sukannya",
    },
    {
      "id": 11,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "isActive": false,
      "connectionName": "Samarpan",
    },
    {
      "id": 12,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/3/34/Elon_Musk_Royal_Society_%28crop2%29.jpg",
      "isActive": false,
      "connectionName": "Sukannya",
    },
    {
      "id": 13,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "isActive": false,
      "connectionName": "Samarpan",
    },
    {
      "id": 14,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/3/34/Elon_Musk_Royal_Society_%28crop2%29.jpg",
      "isActive": false,
      "connectionName": "Sukannya",
    },
    {
      "id": 15,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "isActive": false,
      "connectionName": "Samarpan",
    },
    {
      "id": 16,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/3/34/Elon_Musk_Royal_Society_%28crop2%29.jpg",
      "isActive": false,
      "connectionName": "Sukannya",
    },
  ];

  initialize()async{
    final _currAccData = await _localStorage.getDataForCurrAccount();
    this._currAccData = _currAccData;
  }

  Map<String,dynamic> getCurrentAccData() => _currAccData;

  setFreshData(incomingActivityData) {
    if (incomingActivityData == null) return;

    _activityDataCollection = incomingActivityData;
    notifyListeners();
  }

  addNewData(incomingNewData) {
    if (incomingNewData == null) return;

    _activityDataCollection = [..._activityDataCollection, ...incomingNewData];
    notifyListeners();
  }

  getData() => _activityDataCollection;

  getDataLength() => _activityDataCollection.length;


}
