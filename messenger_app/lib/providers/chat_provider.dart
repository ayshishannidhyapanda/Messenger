import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/enums.dart';
import '../services/chat_service.dart';

/// State management for chat messages and conversations.
class ChatProvider extends ChangeNotifier {
  final ChatSocketService _chatSocket;
  final String _myPhone;

  final Map<String, Conversation> _conversations = {};
  bool _isConnected = false;
  String? _error;

  ChatProvider(this._chatSocket, this._myPhone) {
    _chatSocket.onMessageReceived = _onMessageReceived;
    _chatSocket.onPresenceChanged = _onPresenceChanged;
    _chatSocket.onConnectionChanged = _onConnectionChanged;
    _chatSocket.onError = _onError;
  }

  // ── Getters ────────────────────────────────────────────────────────────
  List<Conversation> get conversations {
    final list = _conversations.values.toList();
    // Sort by last message time (most recent first)
    list.sort((a, b) {
      final aTime = a.lastMessage?.createdAt ?? DateTime(2000);
      final bTime = b.lastMessage?.createdAt ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });
    return list;
  }

  bool get isConnected => _isConnected;
  String? get error => _error;

  /// Get or create a conversation for a given phone number.
  Conversation getConversation(String phone) {
    return _conversations[phone] ??
        Conversation(otherUserPhone: phone, otherUserName: phone);
  }

  List<ChatMessage> getMessages(String otherPhone) {
    return _conversations[otherPhone]?.messages ?? [];
  }

  // ── Actions ────────────────────────────────────────────────────────────

  /// Connect to the WebSocket.
  void connect() => _chatSocket.connect();

  /// Disconnect from the WebSocket.
  void disconnect() => _chatSocket.disconnect();

  /// Send a text message to another user.
  void sendTextMessage(String receiverPhone, String text) {
    final message = ChatMessage(
      sender: _myPhone,
      receiver: receiverPhone,
      messageType: MessageType.TEXT,
      message: text,
      createdAt: DateTime.now(),
    );

    _chatSocket.sendMessage(
      senderPhone: _myPhone,
      receiverPhone: receiverPhone,
      message: message,
    );

    // Optimistically add to local state
    _addMessageToConversation(receiverPhone, message);
  }

  /// Start a new conversation (for the "new chat" flow).
  void startConversation(String phone, String name) {
    if (!_conversations.containsKey(phone)) {
      _conversations[phone] = Conversation(
        otherUserPhone: phone,
        otherUserName: name,
      );
      notifyListeners();
    }
  }

  // ── Socket callbacks ───────────────────────────────────────────────────

  void _onMessageReceived(ChatMessage message) {
    // Determine the "other" user in this conversation
    final otherPhone =
        message.sender == _myPhone ? message.receiver! : message.sender!;
    _addMessageToConversation(otherPhone, message);
  }

  void _onPresenceChanged(String phone, bool online) {
    if (_conversations.containsKey(phone)) {
      _conversations[phone] =
          _conversations[phone]!.copyWith(isOnline: online);
      notifyListeners();
    }
  }

  void _onConnectionChanged(bool connected) {
    _isConnected = connected;
    notifyListeners();
  }

  void _onError(String error) {
    _error = error;
    notifyListeners();
    // Clear error after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      _error = null;
      notifyListeners();
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  void _addMessageToConversation(String otherPhone, ChatMessage message) {
    final existing = _conversations[otherPhone];
    if (existing != null) {
      _conversations[otherPhone] = existing.copyWith(
        messages: [...existing.messages, message],
      );
    } else {
      _conversations[otherPhone] = Conversation(
        otherUserPhone: otherPhone,
        otherUserName: otherPhone, // Will be updated when we get user info
        messages: [message],
      );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _chatSocket.disconnect();
    super.dispose();
  }
}
