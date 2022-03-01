import 'package:flutter/material.dart';

class SentConnectionsProvider extends ChangeNotifier{
  List<dynamic> _sentConnections = [
    {
      "id": 1,
      "name": "Sukannya Paul",
      "description": "Flirt is a part of life",
      "photo": "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 2,
      "name": "Samarpan Dasgupta",
      "description": "What you seek is seeking you",
      "photo": "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 3,
      "name": "Samarpan Dasgupta",
      "description": "What you seek is seeking you",
      "photo": "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 4,
      "name": "Samarpan Dasgupta",
      "description": "What you seek is seeking you",
      "photo": "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 5,
      "name": "Samarpan Dasgupta",
      "description": "What you seek is seeking you",
      "photo": "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 6,
      "name": "Samarpan Dasgupta",
      "description": "What you seek is seeking you",
      "photo": "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 7,
      "name": "Samarpan Dasgupta",
      "description": "What you seek is seeking you",
      "photo": "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 8,
      "name": "Samarpan Dasgupta",
      "description": "What you seek is seeking you",
      "photo": "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 9,
      "name": "Samarpan Dasgupta",
      "description": "What you seek is seeking you",
      "photo": "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 10,
      "name": "Samarpan Dasgupta",
      "description": "What you seek is seeking you",
      "photo": "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },




    {
      "id":11,
      "name": "Samarpan Dasgupta",
      "description": "What you seek is seeking you",
      "photo": "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 12,
      "name": "Samarpan Dasgupta",
      "description": "What you seek is seeking you",
      "photo": "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 13,
      "name": "Samarpan Dasgupta",
      "description": "What you seek is seeking you",
      "photo": "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
    {
      "id": 14,
      "name": "Samarpan Dasgupta",
      "description": "What you seek is seeking you",
      "photo": "https://static.wikia.nocookie.net/prowrestling/images/a/ad/Wwe_the_rock_png_by_double_a1698_day9ylt-pre_%281%29.png/revision/latest?cb=20190225014047",
    },
  ];

  setConnections(incomingConnections){
    _sentConnections = incomingConnections;
    notifyListeners();
  }

  getConnections() => _sentConnections;

  getConnectionsLength() => _sentConnections.length;
}