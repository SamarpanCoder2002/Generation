class ChatMessageModel {
  final String type;
  final String holder;
  final dynamic message;
  final String date;
  final String time;
  final dynamic additionalData;

  ChatMessageModel(this.type, this.message, this.time, this.holder,
      this.additionalData, this.date);

  factory ChatMessageModel.toJson(
          {required String type,
          required dynamic message,
          required String date,
          required String time,
          required String holder,
          required dynamic additionalData}) =>
      ChatMessageModel(type, message, time, holder, additionalData, date);
}
