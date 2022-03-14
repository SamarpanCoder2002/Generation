class ChatMessageModel {
  final String type;
  final String holder;
  final String message;
  final String time;
  final dynamic additionalData;

  ChatMessageModel(
      this.type, this.message, this.time, this.holder, this.additionalData);

  factory ChatMessageModel.toJson(
          {required String type,
          required String message,
          required String time,
          required String holder,
          required dynamic additionalData}) =>
      ChatMessageModel(type, message, time, holder, additionalData);
}
