import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../config/api_constants.dart';
import '../models/chat_message.dart';
import 'server_config_service.dart';
import 'storage_service.dart';

/// Callback types for incoming WebSocket events.
typedef OnMessageReceived = void Function(ChatMessage message);
typedef OnPresenceChanged = void Function(String phone, bool online);
typedef OnError = void Function(String error);
typedef OnConnectionChanged = void Function(bool connected);

/// STOMP-over-WebSocket client for real-time messaging.
class ChatSocketService {
  final ServerConfigService _serverConfig;
  final StorageService _storage;

  StompClient? _client;
  bool _isConnected = false;
  int _reconnectAttempts = 0;

  // Callbacks
  OnMessageReceived? onMessageReceived;
  OnPresenceChanged? onPresenceChanged;
  OnError? onError;
  OnConnectionChanged? onConnectionChanged;

  ChatSocketService(this._serverConfig, this._storage);

  bool get isConnected => _isConnected;

  /// Connect to the STOMP WebSocket endpoint.
  void connect() {
    if (_isConnected || _client != null) return;

    final wsUrl = _serverConfig.buildWsUrl(ApiConstants.wsEndpoint);
    final cookie = _storage.sessionCookie ?? '';

    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        stompConnectHeaders: {
          'Cookie': cookie,
        },
        webSocketConnectHeaders: {
          'Cookie': cookie,
        },
        onConnect: _onConnect,
        onDisconnect: _onDisconnect,
        onStompError: _onStompError,
        onWebSocketError: _onWebSocketError,
        heartbeatIncoming: const Duration(seconds: 10),
        heartbeatOutgoing: const Duration(seconds: 10),
        reconnectDelay: Duration(
          seconds: _calculateBackoff(),
        ),
      ),
    );

    _client!.activate();
  }

  /// Disconnect from the WebSocket.
  void disconnect() {
    _client?.deactivate();
    _client = null;
    _isConnected = false;
    onConnectionChanged?.call(false);
  }

  /// Send a private chat message.
  void sendMessage({
    required String senderPhone,
    required String receiverPhone,
    required ChatMessage message,
  }) {
    if (!_isConnected || _client == null) return;

    _client!.send(
      destination: ApiConstants.stompSendPrivate,
      headers: {
        'senderPhone': senderPhone,
        'receiverPhone': receiverPhone,
        'content-type': 'application/json',
      },
      body: jsonEncode(message.toJson()),
    );
  }

  // ── Connection callbacks ───────────────────────────────────────────────

  void _onConnect(StompFrame frame) {
    _isConnected = true;
    _reconnectAttempts = 0;
    onConnectionChanged?.call(true);

    // Subscribe to personal message queue
    _client!.subscribe(
      destination: ApiConstants.stompQueueMessages,
      callback: _handleIncomingMessage,
    );

    // Subscribe to error queue
    _client!.subscribe(
      destination: ApiConstants.stompQueueErrors,
      callback: _handleError,
    );

    // Subscribe to presence topic
    _client!.subscribe(
      destination: ApiConstants.stompTopicPresence,
      callback: _handlePresence,
    );
  }

  void _onDisconnect(StompFrame frame) {
    _isConnected = false;
    _reconnectAttempts++;
    onConnectionChanged?.call(false);
  }

  void _onStompError(StompFrame frame) {
    onError?.call(frame.body ?? 'STOMP error');
  }

  void _onWebSocketError(dynamic error) {
    _isConnected = false;
    onConnectionChanged?.call(false);
    onError?.call('WebSocket error: $error');
  }

  // ── Message handlers ───────────────────────────────────────────────────

  void _handleIncomingMessage(StompFrame frame) {
    if (frame.body == null) return;
    try {
      final json = jsonDecode(frame.body!) as Map<String, dynamic>;

      // The backend may send a ChatMessageDto or a ContactsDto.
      // If it has 'messageType', it's a ChatMessageDto.
      // If it has 'contactId', it's a ContactsDto with embedded chats.
      if (json.containsKey('messageType')) {
        final message = ChatMessage.fromJson(json);
        onMessageReceived?.call(message);
      } else if (json.containsKey('chats') && json['chats'] is List) {
        // ContactsDto — extract the latest chat message
        final chats = (json['chats'] as List)
            .map((c) => ChatMessage.fromJson(c as Map<String, dynamic>))
            .toList();
        if (chats.isNotEmpty) {
          onMessageReceived?.call(chats.last);
        }
      }
    } catch (e) {
      onError?.call('Failed to parse message: $e');
    }
  }

  void _handleError(StompFrame frame) {
    if (frame.body == null) return;
    try {
      final json = jsonDecode(frame.body!) as Map<String, dynamic>;
      final errorMsg = json['message'] ?? json['error'] ?? 'Unknown error';
      onError?.call(errorMsg.toString());
    } catch (_) {
      onError?.call(frame.body!);
    }
  }

  void _handlePresence(StompFrame frame) {
    if (frame.body == null) return;
    try {
      final json = jsonDecode(frame.body!) as Map<String, dynamic>;
      final phone = json['phone'] as String? ?? json['username'] as String?;
      final status = json['status'] as String?;
      if (phone != null && status != null) {
        onPresenceChanged?.call(phone, status == 'ONLINE');
      }
    } catch (_) {
      // Ignore malformed presence events
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  int _calculateBackoff() {
    // Exponential backoff: 1s, 2s, 4s, 8s, ... capped at 30s
    final seconds = (1 << _reconnectAttempts).clamp(1, 30);
    return seconds;
  }
}
