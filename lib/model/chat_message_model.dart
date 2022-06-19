import 'dart:ui';

import 'package:generation/services/encryption_manager.dart';
import 'package:generation/services/local_data_management.dart';

class ChatMessageModel {
  final String type;
  final String holder;
  final dynamic message;
  final String date;
  final String time;
  final dynamic additionalData;

  ChatMessageModel(this.type, this.message, this.time, this.holder,
      this.additionalData, this.date);

  factory ChatMessageModel.copy(ChatMessageModel chatMessageModel) =>
      ChatMessageModel(
          chatMessageModel.type,
          chatMessageModel.message,
          chatMessageModel.time,
          chatMessageModel.holder,
          chatMessageModel.additionalData,
          chatMessageModel.date);

  factory ChatMessageModel.toJson(
          {required String type,
          required dynamic message,
          required String date,
          required String time,
          required String holder,
          required dynamic additionalData}) =>
      ChatMessageModel(type, message, time, holder, additionalData, date);

  factory ChatMessageModel.toDecodedJson(
      {required String type,
      required dynamic message,
      required String date,
      required String time,
      required String holder,
      required dynamic additionalData}) {
    dynamic _decodedAdditionalData = Secure.decode(additionalData);
    if(_decodedAdditionalData != ''){
      _decodedAdditionalData = DataManagement.fromJsonString(_decodedAdditionalData);
    }

    return ChatMessageModel(
        Secure.decode(type),
        Secure.decode(message),
        Secure.decode(time),
        Secure.decode(holder),
        _decodedAdditionalData == '' ? null : _decodedAdditionalData,
        Secure.decode(date));
  }
}
