import 'package:flutter/material.dart';

class RequestConnectionsProvider extends ChangeNotifier {
  List<dynamic> _searchedConnections = [];
  List<dynamic> _requestConnections = [
    {
      "id": 1,
      "name": "Amitava Garai",
      "description": "When Music Mixed With Passion, heart will spread love automatically",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 2,
      "name": "Samarpan Dasgupta",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 3,
      "name": "Mintu Roy",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 4,
      "name": "Publiky Roy",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 5,
      "name": "Pura Vadito",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 6,
      "name": "Kuby Cis",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 7,
      "name": "Monte Karlo",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 8,
      "name": "Pura Vadica",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 9,
      "name": "Syntha Mond",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 10,
      "name": "Piyush Bansal",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 11,
      "name": "Replica Mysis",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 12,
      "name": "Mio da More",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 13,
      "name": "Oberoy Bant",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 14,
      "name": "Anupam Mittal",
      "description": "What you seek is seeking you",
      "photo":
          "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
  ];

  initialize(){
    _searchedConnections = _requestConnections;
  }

  operateOnSearch(searchKeyword) {
    List<dynamic> _tempSearchedCollection = [];

    if (searchKeyword == "" || searchKeyword == null) {
      _searchedConnections = _requestConnections;
      notifyListeners();
      return;
    }

    for (final connection in _requestConnections) {
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

  setConnections(incomingConnections) {
    _requestConnections = incomingConnections;
    notifyListeners();
  }

  getConnections() => _searchedConnections;

  getConnectionsLength() => _searchedConnections.length;
}
