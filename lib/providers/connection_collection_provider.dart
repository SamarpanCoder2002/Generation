import 'package:flutter/material.dart';
import 'package:generation/types/types.dart';

class ConnectionCollectionProvider extends ChangeNotifier {
  List<dynamic> _searchedChatConnectionsDataCollection = [];
  List<dynamic> _selectedSearchedChatConnectionsDataCollection = [];
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
        "message":
            "Hey Sexy, What's up?? https://www.samarpandasgupta.com/static/media/samarpan_dasgupta.48a013aa.png",
        "time": "26 July",
      },
    },
    {
      "id": 2,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Dasgupta",
      "notSeenMsgCount": 6,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
      },
    },
    {
      "id": 3,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Raktim",
      "notSeenMsgCount": 1,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
      },
    },
    {
      "id": 4,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Laravel",
      "notSeenMsgCount": 3,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
      },
    },
    {
      "id": 5,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "PHP",
      "notSeenMsgCount": 10,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
      },
    },
    {
      "id": 6,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Dude",
      "notSeenMsgCount": 150,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
      },
    },
    {
      "id": 7,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Sukannya",
      "notSeenMsgCount": 225,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
      },
    },
    {
      "id": 8,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Problem",
      "notSeenMsgCount": 214,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
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
        "time": "26 July",
      },
    },
    {
      "id": 10,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Duke",
      "notSeenMsgCount": 217,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
      },
      "lastMessageDate": "01/12/2020",
    },
    {
      "id": 11,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Rasia",
      "notSeenMsgCount": 125,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
      },
    },
    {
      "id": 12,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "USA",
      "notSeenMsgCount": 178,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
      },
    },
    {
      "id": 13,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Ping",
      "notSeenMsgCount": 14,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
      },
      "lastMessageDate": "14/06/2019",
    },
    {
      "id": 14,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "LandOfMard",
      "notSeenMsgCount": 78,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
      },
    },
    {
      "id": 15,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Jimken",
      "notSeenMsgCount": 95,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
      },
      "lastMessageDate": "1 July",
    },
    {
      "id": 16,
      "profilePic":
          "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwayne_Johnson_2014_%28cropped%29.jpg",
      "connectionName": "Amitava",
      "notSeenMsgCount": 17,
      "latestMessage": {
        "id": "profileId_${DateTime.now()}",
        "type": ChatMessageType.text.toString(),
        "message": "Hey Sexy, What's up??",
        "time": "26 July",
      },
    },
  ];

  initialize(){
    _searchedChatConnectionsDataCollection = _chatConnectionsDataCollection;
  }

  setForSelection(){
    for(final connection in _chatConnectionsDataCollection){
      _selectedSearchedChatConnectionsDataCollection.add({...connection,"isSelected": false});
    }
  }

  updateParticularSelectionData(incoming, index){
    resetSelectionData();
    setForSelection();
    _selectedSearchedChatConnectionsDataCollection[index] = incoming;
    notifyListeners();
  }

  resetSelectionData(){
    _selectedSearchedChatConnectionsDataCollection.clear();
  }

  getWillSelectData() => _selectedSearchedChatConnectionsDataCollection;

  getWillSelectDataLength() => _selectedSearchedChatConnectionsDataCollection.length;

  setFreshData(incomingData) {
    if (incomingData == null) return;

    _chatConnectionsDataCollection = incomingData;
    _searchedChatConnectionsDataCollection = incomingData;
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

  operateOnSearch(searchKeyword) {
    List<dynamic> _tempSearchedCollection = [];

    if (searchKeyword == "" || searchKeyword == null) {
      _searchedChatConnectionsDataCollection = _chatConnectionsDataCollection;
      notifyListeners();
      return;
    }

    for (final connection in _chatConnectionsDataCollection) {
      if (connection["connectionName"]
          .toString()
          .toLowerCase()
          .contains(searchKeyword.toString().toLowerCase())) {
        _tempSearchedCollection.add(connection);
      }
    }

    _searchedChatConnectionsDataCollection = _tempSearchedCollection;
    notifyListeners();
  }

  getData() => _searchedChatConnectionsDataCollection;

  getDataLength() => _searchedChatConnectionsDataCollection.length;
}
