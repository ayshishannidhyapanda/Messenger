/// Centralised API path constants that mirror the Spring Boot backend.
///
/// The base URL is provided at runtime via [ServerConfigService] so these
/// are path-only constants.
class ApiConstants {
  ApiConstants._();

  // ── REST endpoints (relative to base URL) ──────────────────────────────
  static const String register = '/api/v1/register';
  static const String verifyOtp = '/api/v1/verifyOtp';
  static const String login = '/api/v1/login';

  // ── WebSocket ──────────────────────────────────────────────────────────
  static const String wsEndpoint = '/api/ws';

  // ── STOMP destinations ─────────────────────────────────────────────────
  static const String stompSendPrivate = '/app/chat.private';
  static const String stompQueueMessages = '/user/queue/messages';
  static const String stompQueueErrors = '/user/queue/errors';
  static const String stompTopicPresence = '/topic/presence';

  // ── Health check ───────────────────────────────────────────────────────
  static const String healthCheck = '/api/actuator/health';
}
