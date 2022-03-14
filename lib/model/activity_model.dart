class ActivityModel {
  final String type;
  final String holderId;
  final String date;
  final String time;
  final String message;
  final dynamic additionalThings;

  ActivityModel(this.type, this.message, this.additionalThings, this.holderId,
      this.date, this.time);

  factory ActivityModel.getJson(
          {required String type,
          required String holderId,
          required String date,
          required String time,
          required String message,
          required dynamic additionalThings}) =>
      ActivityModel(type, message, additionalThings, holderId, date, time);
}
