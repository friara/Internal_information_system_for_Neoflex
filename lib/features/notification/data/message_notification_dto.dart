class MessageNotificationDTO {
  final String id;
  final String sender;
  final String content;
  final DateTime timestamp;
  final String chatName;
  final int chatId;

  MessageNotificationDTO({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    required this.chatName,
    required this.chatId, 
  });

  factory MessageNotificationDTO.fromJson(Map<String, dynamic> json) {
    return MessageNotificationDTO(
      id: json['id'].toString(),
      sender: json['sender'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      chatName: json['chatName'] as String,
      chatId: (json['chatId'] is int) 
          ? json['chatId'] as int 
          : int.tryParse(json['chatId'].toString()) ?? 0,
    );
    
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'chatName': chatName,
      'chatId': chatId,
    };
  }
}