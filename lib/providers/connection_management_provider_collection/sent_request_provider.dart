import 'package:flutter/material.dart';

class SentConnectionsProvider extends ChangeNotifier {
  List<dynamic> _searchedConnections = [];
  List<dynamic> _sentConnections = [
    {
      "id": 1,
      "name": "Sukannya Paul",
      "description": "Flirt is a part of life",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 2,
      "name": "Kintu Singh",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 3,
      "name": "Mono Kintu",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 4,
      "name": "Love Babbar",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 5,
      "name": "Youth Montho",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 6,
      "name": "Unki Singth",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 7,
      "name": "Ginia Kris",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 8,
      "name": "Formidable",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 9,
      "name": "Ozonolysis",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 10,
      "name": "Puratica",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 11,
      "name": "Banki Kenna",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 12,
      "name": "Monta Re",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 13,
      "name": "Dialysis",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 14,
      "name": "Urvo Kanti",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
  ];

  initialize({bool update = false}) {
    _searchedConnections = _sentConnections;
    if(update) notifyListeners();
  }

  setConnections(incomingConnections) {
    _sentConnections = incomingConnections;
    notifyListeners();
  }

  operateOnSearch(searchKeyword) {
    List<dynamic> _tempSearchedCollection = [];

    if (searchKeyword == "" || searchKeyword == null) {
      _searchedConnections = _sentConnections;
      notifyListeners();
      return;
    }

    for (final connection in _sentConnections) {
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

  void removeIndexFromSearch(int index) {
    _searchedConnections.removeAt(index);
    notifyListeners();
  }
}
