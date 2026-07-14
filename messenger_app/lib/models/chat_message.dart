import 'enums.dart';

/// Chat message model matching backend `ChatMessageDto`.
class ChatMessage {
  final int? id;
  final String? sender;
  final String? receiver;
  final MessageType messageType;
  final MediaType? mediaType;
  final String? message;
  final String? fileUrl;
  final Reactions? senderReaction;
  final Reactions? receiverReaction;
  final bool isEdited;
  final String? editedMessage;
  final bool isReceived;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;

  const ChatMessage({
    this.id,
    this.sender,
    this.receiver,
    this.messageType = MessageType.TEXT,
    this.mediaType,
    this.message,
    this.fileUrl,
    this.senderReaction,
    this.receiverReaction,
    this.isEdited = false,
    this.editedMessage,
    this.isReceived = false,
    this.isRead = false,
    this.readAt,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      sender: json['sender'],
      receiver: json['receiver'],
      messageType: MessageType.fromString(json['messageType'] ?? 'TEXT'),
      mediaType: MediaType.fromString(json['mediaType']),
      message: json['message'],
      fileUrl: json['fileUrl'],
      senderReaction: Reactions.fromString(json['senderReaction']),
      receiverReaction: Reactions.fromString(json['receiverReaction']),
      isEdited: json['isEdited'] ?? false,
      editedMessage: json['editedMessage'],
      isReceived: json['isReceived'] ?? false,
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'messageType': messageType.name,
        'message': message,
        if (fileUrl != null) 'fileUrl': fileUrl,
        if (mediaType != null) 'mediaType': mediaType!.name,
      };

  /// Whether this message was sent by the given phone number.
  bool isSentBy(String phoneNumber) => sender == phoneNumber;
}

/// Represents a conversation (contact pair) with its messages.
class Conversation {
  final int? contactId;
  final String otherUserPhone;
  final String otherUserName;
  final List<ChatMessage> messages;
  final bool isOnline;

  const Conversation({
    this.contactId,
    required this.otherUserPhone,
    required this.otherUserName,
    this.messages = const [],
    this.isOnline = false,
  });

  ChatMessage? get lastMessage =>
      messages.isNotEmpty ? messages.last : null;

  int get unreadCount => messages.where((m) => !m.isRead).length;

  Conversation copyWith({
    int? contactId,
    String? otherUserPhone,
    String? otherUserName,
    List<ChatMessage>? messages,
    bool? isOnline,
  }) {
    return Conversation(
      contactId: contactId ?? this.contactId,
      otherUserPhone: otherUserPhone ?? this.otherUserPhone,
      otherUserName: otherUserName ?? this.otherUserName,
      messages: messages ?? this.messages,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
