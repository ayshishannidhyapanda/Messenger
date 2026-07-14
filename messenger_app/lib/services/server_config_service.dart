import 'package:http/http.dart' as http;
import 'storage_service.dart';
import '../config/api_constants.dart';

/// Manages server URL configuration and connectivity testing.
class ServerConfigService {
  final StorageService _storage;

  ServerConfigService(this._storage);

  /// Current configured server URL (without trailing slash).
  String? get currentUrl => _storage.serverUrl;

  /// Whether a server URL has been configured.
  bool get isConfigured => _storage.hasServerUrl;

  /// Saves the server URL after normalising it.
  Future<void> saveUrl(String url) async {
    final normalised = _normalise(url);
    await _storage.setServerUrl(normalised);
  }

  /// Clears the saved server URL.
  Future<void> clearUrl() => _storage.clearServerUrl();

  /// Pings the server's health endpoint to verify connectivity.
  ///
  /// Returns `true` if the server responds with HTTP 200, `false` otherwise.
  Future<bool> testConnection(String url) async {
    try {
      final normalised = _normalise(url);
      final uri = Uri.parse('$normalised${ApiConstants.healthCheck}');
      final response = await http.get(uri, headers: {
        'ngrok-skip-browser-warning': 'true',
      }).timeout(
            const Duration(seconds: 5),
          );
      return response.statusCode < 600;
    } catch (_) {
      return false;
    }
  }

  /// Builds a full URL from the saved base + a relative path.
  String buildUrl(String path) {
    final base = currentUrl;
    if (base == null) throw StateError('Server URL not configured');
    return '$base$path';
  }

  /// Builds a WebSocket URL from the saved base + a relative path.
  String buildWsUrl(String path) {
    final base = currentUrl;
    if (base == null) throw StateError('Server URL not configured');
    // Convert http(s) to ws(s)
    final wsBase = base
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
    return '$wsBase$path';
  }

  String _normalise(String url) {
    var u = url.trim();
    // Add protocol if missing
    if (!u.startsWith('http://') && !u.startsWith('https://')) {
      u = 'http://$u';
    }
    // Remove trailing slash
    if (u.endsWith('/')) u = u.substring(0, u.length - 1);
    return u;
  }
}
