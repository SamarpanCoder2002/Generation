import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Information{
  List _imageContainer = [];
  List _contactContainer = [];
  List _messageContainer = [];
  List _receivedTimeTakeContainer = [];
  List _soundStatusContainer = [];
  List _iconDataColorContainer = [];

  Information() {
    for(int i=0;i<10;i++) {
      _imageTake();
      _contactTake();
      _messageTake();
      _receivedTimeTake();
      _soundStatusTake();
      _iconDataColorTake();
    }
  }

  List<dynamic> informationReturn(){
    List<dynamic> _store = [_imageContainer, _contactContainer, _messageContainer, _receivedTimeTakeContainer, _soundStatusContainer, _iconDataColorContainer];
    return _store;
  }

  void _imageTake(){
    String _latestImage = "images/sam.jpg";
    _imageContainer.add(_latestImage);
  }

  void _contactTake(){
    String _latestContact = "Samarpan Dasgupta";
    _contactContainer.add(_latestContact);
  }

  void _messageTake(){
    String _latestMessage = "New Message Alert";
    _messageContainer.add(_latestMessage);
  }

  void _receivedTimeTake(){
    String _latestReceivedTime = "12:00";
    _receivedTimeTakeContainer.add(_latestReceivedTime);
  }

  void _soundStatusTake(){
    IconData _latestIcon = Icons.surround_sound;
    _soundStatusContainer.add(_latestIcon);
  }

  void _iconDataColorTake(){
    Color _latestIconDataColor = Colors.green;
    _iconDataColorContainer.add(_latestIconDataColor);
  }
}