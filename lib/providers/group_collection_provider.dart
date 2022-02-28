import 'package:flutter/material.dart';
import 'package:generation/types/types.dart';

class GroupCollectionProvider extends ChangeNotifier {
  List<dynamic> _groupDataCollection = [
    {
      "id": 1,
      "profilePic":
      "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "groupName": "Rock Life",
      "notSeenMsgCount": 5,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up?? https://www.Rock Lifedasgupta.com/static/media/Rock Life_dasgupta.48a013aa.png",
        "time": "26 July",
        "holderId": "45",
        "holderName": "Sukannya",
      },

    },
    {
      "id": 2,
      "profilePic":
      "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "groupName": "Rock Life",
      "notSeenMsgCount": 6,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
        "holderId": "45",
        "holderName": "Sukannya",
      },

    },
    {
      "id": 3,
      "profilePic":
      "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "groupName": "Rock Life",
      "notSeenMsgCount": 1,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
        "holderId": "45",
        "holderName": "Sukannya",
      },

    },
    {
      "id": 4,
      "profilePic":
      "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "groupName": "Rock Life",
      "notSeenMsgCount": 3,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
        "holderId": "45",
        "holderName": "Sukannya",
      },

    },
    {
      "id": 5,
      "profilePic":
      "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "groupName": "Rock Life",
      "notSeenMsgCount": 10,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
        "holderId": "45",
        "holderName": "Sukannya",
      },

    },
    {
      "id": 6,
      "profilePic":
      "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "groupName": "Rock Life",
      "notSeenMsgCount": 150,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
        "holderId": "45",
        "holderName": "Sukannya",
      },

    },
    {
      "id": 7,
      "profilePic":
      "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "groupName": "Rock Life",
      "notSeenMsgCount": 225,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
        "holderId": "45",
        "holderName": "Sukannya",
      },

    },
    {
      "id": 8,
      "profilePic":
      "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "groupName": "Rock Life",
      "notSeenMsgCount": 214,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
        "holderId": "45",
        "holderName": "Sukannya",
      },
      "lastMessageDate": "3 Dec",
    },
    {
      "id": 9,
      "profilePic":
      "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "groupName": "Rock Life",
      "notSeenMsgCount": 214,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
        "holderId": "45",
        "holderName": "Sukannya",
      },

    },
    {
      "id": 10,
      "profilePic":
      "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "groupName": "Rock Life",
      "notSeenMsgCount": 217,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
        "holderId": "45",
        "holderName": "Sukannya",
      },
      "lastMessageDate": "01/12/2020",
    },
    {
      "id": 11,
      "profilePic":
      "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "groupName": "Rock Life",
      "notSeenMsgCount": 125,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
        "holderId": "45",
        "holderName": "Sukannya",
      },

    },
    {
      "id": 12,
      "profilePic":
      "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "groupName": "Rock Life",
      "notSeenMsgCount": 178,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
        "holderId": "45",
        "holderName": "Sukannya",
      },

    },
    {
      "id": 13,
      "profilePic":
      "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "groupName": "Rock Life",
      "notSeenMsgCount": 14,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
        "holderId": "45",
        "holderName": "Sukannya",
      },
      "lastMessageDate": "14/06/2019",
    },
    {
      "id": 14,
      "profilePic":
      "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "groupName": "Rock Life",
      "notSeenMsgCount": 78,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
        "holderId": "45",
        "holderName": "Sukannya",
      },

    },
    {
      "id": 15,
      "profilePic":
      "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "groupName": "Rock Life",
      "notSeenMsgCount": 95,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
        "holderId": "45",
        "holderName": "Sukannya",
      },
      "lastMessageDate": "1 July",
    },
    {
      "id": 16,
      "profilePic":
      "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "groupName": "Rock Life",
      "notSeenMsgCount": 17,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
        "holderId": "45",
        "holderName": "Sukannya",
      },

    },
  ];

  setFreshData(incomingData) {
    if (incomingData == null) return;

    _groupDataCollection = incomingData;
    notifyListeners();
  }

  addNewData(incomingNewData) {
    if (incomingNewData == null) return;

    _groupDataCollection = [
      ..._groupDataCollection,
      ...incomingNewData
    ];
    notifyListeners();
  }

  getData() => _groupDataCollection;

  getDataLength() => _groupDataCollection.length;
}
