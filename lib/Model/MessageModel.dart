class MessageModel {

  MessageModel(this.sender_id, this.message,this.timestamp);

  final String sender_id;
  final String message;
  final String timestamp;

  factory MessageModel.fromJson(Map<dynamic, dynamic> parsedJson) {
    return MessageModel(
        parsedJson['sender_id'].toString(),
        parsedJson['message'].toString(),
        parsedJson['timestamp'].toString()
    );
  }

}