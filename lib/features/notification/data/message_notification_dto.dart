class MessageNotificationDTO {
  final String id;
  final String sender;
  final String content;
  final DateTime timestamp;
  final String chatName;

  MessageNotificationDTO({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    required this.chatName,
  });

  // factory MessageNotificationDTO.fromJson(Map<String, dynamic> json) {
  //   return MessageNotificationDTO(
  //     id: json['id'].toString(), // Convert int to String
  //     sender: "${json['sender']['firstName']} ${json['sender']['lastName']}",
  //     content: json['content'] as String,
  //     timestamp: DateTime.parse(json['timestamp'] as String),
  //     chatName: json['linkedMessage']['chatId'].toString(),
  //   );
  // }

    factory MessageNotificationDTO.fromJson(Map<String, dynamic> json) {
    return MessageNotificationDTO(
      id: json['id'].toString(), // Convert int to String
      sender: json['sender'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      chatName: json['chatName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'chatName': chatName,
    };
  }
}