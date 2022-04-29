import 'package:flutter/material.dart';

class AllAvailableConnectionsProvider extends ChangeNotifier {
  List<dynamic> _searchedConnections = [];
  List<dynamic> _allAvailableConnections = [
    {
      "id": 1,
      "name": "Samarpan Dasgupta",
      "description": "What you seek is seeking you. Love From Bottom as Passionate Lover. Normal Man with Good Passion.",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 2,
      "name": "Hobbs and Shaw",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 3,
      "name": "Mary Dangtal",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 4,
      "name": "Oberoy",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 5,
      "name": "Kishav Mondal",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 6,
      "name": "Jamini Roy",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 7,
      "name": "Oliv Deb",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 8,
      "name": "Idol Myth",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 9,
      "name": "Raoby Singh",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 10,
      "name": "Monta Re",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 11,
      "name": "Raj Somani",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 12,
      "name": "Monte Cristo",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 13,
      "name": "Pura Tica",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 14,
      "name": "Monalisa",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
  ];

  initialize({bool update = false}){
    _searchedConnections = _allAvailableConnections;
    if(update) notifyListeners();
  }

  setConnections(incomingConnections) {
    _allAvailableConnections = incomingConnections;
    notifyListeners();
  }

  removeIndexFromSearch(int indexInSearch){
    _searchedConnections.removeAt(indexInSearch);
    notifyListeners();
  }

  operateOnSearch(searchKeyword) {
    List<dynamic> _tempSearchedCollection = [];

    if (searchKeyword == "" || searchKeyword == null) {
      _searchedConnections = _allAvailableConnections;
      notifyListeners();
      return;
    }

    for (final connection in _allAvailableConnections) {
      if (connection["name"]
          .toString()
          .toLowerCase()
          .contains(searchKeyword.toString().toLowerCase())) {
        _tempSearchedCollection.add(connection);
      }
    }

    _searchedConnections = _tempSearchedCollection;
    notifyListeners();
  }

  getConnections() => _searchedConnections;

  getConnectionsLength() => _searchedConnections.length;

}
