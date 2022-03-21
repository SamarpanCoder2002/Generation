import 'package:flutter/material.dart';

class StorageProvider extends ChangeNotifier{
  List<dynamic> _imagesCollection = [
    "https://images.pexels.com/photos/1129413/pexels-photo-1129413.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/1496373/pexels-photo-1496373.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/1078983/pexels-photo-1078983.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/757889/pexels-photo-757889.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/916337/pexels-photo-916337.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/4740583/pexels-photo-4740583.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/2860705/pexels-photo-2860705.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/922472/pexels-photo-922472.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/1496372/pexels-photo-1496372.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/3273786/pexels-photo-3273786.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/3617500/pexels-photo-3617500.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/3222255/pexels-photo-3222255.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/207353/pexels-photo-207353.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/5641973/pexels-photo-5641973.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
  ];
  List<dynamic> _videosCollection = [];
  List<dynamic> _audioCollection = [];
  List<dynamic> _documentCollection = [];

  setImagesCollection(List<dynamic> incoming){
    _imagesCollection = incoming;
    notifyListeners();
  }

  getImagesCollection() => _imagesCollection;

  setVideosCollection(List<dynamic> incoming){
    _videosCollection = incoming;
    notifyListeners();
  }

  getVideosCollection() => _videosCollection;

  setAudioCollection(List<dynamic> incoming){
    _audioCollection = incoming;
    notifyListeners();
  }

  getAudioCollection() => _audioCollection;

  setDocumentCollection(List<dynamic> incoming){
    _documentCollection = incoming;
    notifyListeners();
  }

  getDocumentCollection() => _documentCollection;
}