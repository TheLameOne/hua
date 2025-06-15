class ChatMessage {
  final String username;
  final String message;
  final bool isOwnMessage;
  final DateTime timestamp;
  final bool isSystemMessage;

  ChatMessage({
    required this.username,
    required this.message,
    required this.isOwnMessage,
    required this.timestamp,
    this.isSystemMessage = false,
  });
}
