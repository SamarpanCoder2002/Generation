import 'package:flutter/material.dart';
import 'package:generation/types/types.dart';

class ConnectionCollectionProvider extends ChangeNotifier {
  List<dynamic> _chatConnectionsDataCollection = [
    {
      "id": 1,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Samarpan",
      "notSeenMsgCount": 5,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up?? https://www.samarpandasgupta.com/static/media/samarpan_dasgupta.48a013aa.png",
        "time": "22:07:03",
      },
      "lastMessageDate": "26 July",
    },
    {
      "id": 2,
      "profilePic":
      "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Samarpan",
      "notSeenMsgCount": 6,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "22:07:03",
      },
      "lastMessageDate": "26 July",
    },
    {
      "id": 3,
      "profilePic":
      "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Samarpan",
      "notSeenMsgCount": 1,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "22:07:03",
      },
      "lastMessageDate": "26 July",
    },
    {
      "id": 4,
      "profilePic":
      "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Samarpan",
      "notSeenMsgCount": 3,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "22:07:03",
      },
      "lastMessageDate": "26 July",
    },
    {
      "id": 5,
      "profilePic":
      "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Samarpan",
      "notSeenMsgCount": 10,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "22:07:03",
      },
      "lastMessageDate": "26 July",
    },
    {
      "id": 6,
      "profilePic":
      "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Samarpan",
      "notSeenMsgCount": 150,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "22:07:03",
      },
      "lastMessageDate": "26 July",
    },
    {
      "id": 7,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Samarpan",
      "notSeenMsgCount": 225,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "22:07:03",
      },
      "lastMessageDate": "26 July",
    },
    {
      "id": 8,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Samarpan",
      "notSeenMsgCount": 214,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "22:07:03",
      },
      "lastMessageDate": "3 Dec",
    },
    {
      "id": 9,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Samarpan",
      "notSeenMsgCount": 214,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "22:07:03",
      },
      "lastMessageDate": "26 July",
    },
    {
      "id": 10,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Samarpan",
      "notSeenMsgCount": 217,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "22:07:03",
      },
      "lastMessageDate": "01/12/2020",
    },
    {
      "id": 11,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Samarpan",
      "notSeenMsgCount": 125,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "22:07:03",
      },
      "lastMessageDate": "26 July",
    },
    {
      "id": 12,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Samarpan",
      "notSeenMsgCount": 178,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "22:07:03",
      },
      "lastMessageDate": "26 July",
    },
    {
      "id": 13,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Samarpan",
      "notSeenMsgCount": 14,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "22:07:03",
      },
      "lastMessageDate": "14/06/2019",
    },
    {
      "id": 14,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Samarpan",
      "notSeenMsgCount": 78,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "22:07:03",
      },
      "lastMessageDate": "26 July",
    },
    {
      "id": 15,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Samarpan",
      "notSeenMsgCount": 95,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "22:07:03",
      },
      "lastMessageDate": "1 July",
    },
    {
      "id": 16,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Samarpan",
      "notSeenMsgCount": 17,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "22:07:03",
      },
      "lastMessageDate": "26 July",
    },
  ];

  setFreshData(incomingData) {
    if (incomingData == null) return;

    _chatConnectionsDataCollection = incomingData;
    notifyListeners();
  }

  addNewData(incomingNewData) {
    if (incomingNewData == null) return;

    _chatConnectionsDataCollection = [
      ..._chatConnectionsDataCollection,
      ...incomingNewData
    ];
    notifyListeners();
  }

  getData() => _chatConnectionsDataCollection;

  getDataLength() => _chatConnectionsDataCollection.length;
}
