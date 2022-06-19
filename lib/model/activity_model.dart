import 'package:generation/services/local_data_management.dart';

class ActivityModel {
  final String id;
  final String type;
  final String holderId;
  final String date;
  final String time;
  final String message;
  final dynamic additionalThings;

  ActivityModel(this.type, this.message, this.additionalThings, this.holderId,
      this.date, this.time, this.id);

  factory ActivityModel.getJson(
          {required String id,
          required String type,
          required String holderId,
          required String date,
          required String time,
          required String message,
          required dynamic additionalThings}) =>
      ActivityModel(type, message, additionalThings, holderId, date, time, id);

  factory ActivityModel.getDecodedJson(
      {required String id,
      required String type,
      required String holderId,
      required String date,
      required String time,
      required String message,
      required dynamic additionalThings}) {
    if (additionalThings != '') {
      additionalThings = DataManagement.fromJsonString(additionalThings);
    }
    return ActivityModel(
        type, message, additionalThings, holderId, date, time, id);
  }
}
