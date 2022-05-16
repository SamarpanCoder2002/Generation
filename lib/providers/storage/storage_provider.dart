import 'package:flutter/material.dart';

class StorageProvider extends ChangeNotifier{
  List<dynamic> _imagesCollection = [

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