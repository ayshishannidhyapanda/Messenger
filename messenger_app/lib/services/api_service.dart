import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import 'server_config_service.dart';
import 'storage_service.dart';

/// Central HTTP client that attaches the session cookie to every request.
class ApiService {
  final ServerConfigService _serverConfig;
  final StorageService _storage;
  final http.Client _client = http.Client();

  ApiService(this._serverConfig, this._storage);

  // ── Headers ────────────────────────────────────────────────────────────

  Map<String, String> _jsonHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    final cookie = _storage.sessionCookie;
    if (cookie != null && cookie.isNotEmpty) {
      headers['Cookie'] = cookie;
    }
    return headers;
  }

  Map<String, String> _formHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    final cookie = _storage.sessionCookie;
    if (cookie != null && cookie.isNotEmpty) {
      headers['Cookie'] = cookie;
    }
    return headers;
  }

  // ── Core HTTP methods ──────────────────────────────────────────────────

  /// POST with JSON body. Returns parsed [ApiResponse].
  Future<ApiResponse<T>> postJson<T>(
    String path,
    Map<String, dynamic> body, {
    T Function(dynamic)? fromJsonT,
  }) async {
    final url = _serverConfig.buildUrl(path);
    final response = await _client.post(
      Uri.parse(url),
      headers: _jsonHeaders(),
      body: jsonEncode(body),
    );
    _extractSessionCookie(response);
    return _parseResponse<T>(response, fromJsonT);
  }

  /// POST with form-encoded body. Returns parsed [ApiResponse].
  Future<ApiResponse<T>> postForm<T>(
    String path,
    Map<String, String> fields, {
    T Function(dynamic)? fromJsonT,
  }) async {
    final url = _serverConfig.buildUrl(path);
    final response = await _client.post(
      Uri.parse(url),
      headers: _formHeaders(),
      body: fields,
    );
    _extractSessionCookie(response);
    return _parseResponse<T>(response, fromJsonT);
  }

  /// GET request. Returns parsed [ApiResponse].
  Future<ApiResponse<T>> get<T>(
    String path, {
    T Function(dynamic)? fromJsonT,
  }) async {
    final url = _serverConfig.buildUrl(path);
    final response = await _client.get(
      Uri.parse(url),
      headers: _jsonHeaders(),
    );
    _extractSessionCookie(response);
    return _parseResponse<T>(response, fromJsonT);
  }

  // ── Cookie extraction ──────────────────────────────────────────────────

  void _extractSessionCookie(http.Response response) {
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null) {
      // Extract JSESSIONID from Set-Cookie header
      final match = RegExp(r'JSESSIONID=([^;]+)').firstMatch(setCookie);
      if (match != null) {
        _storage.setSessionCookie('JSESSIONID=${match.group(1)}');
      }
    }
  }

  // ── Response parsing ───────────────────────────────────────────────────

  ApiResponse<T> _parseResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJsonT,
  ) {
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiResponse.fromJson(json, fromJsonT);
    } catch (e) {
      // If response is not JSON (e.g. plain string from verifyOtp)
      return ApiResponse<T>(
        timestamp: DateTime.now().toIso8601String(),
        status: response.statusCode,
        statusText: response.reasonPhrase ?? '',
        success: response.statusCode >= 200 && response.statusCode < 300,
        message: response.body,
      );
    }
  }

  void dispose() => _client.close();
}
