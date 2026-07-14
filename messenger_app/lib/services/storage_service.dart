import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] for type-safe access.
class StorageService {
  static const String _keyServerUrl = 'server_url';
  static const String _keySessionCookie = 'session_cookie';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserName = 'user_name';
  static const String _keyUserFirstName = 'user_first_name';
  static const String _keyUserLastName = 'user_last_name';
  static const String _keyUserEmail = 'user_email';

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Server URL ─────────────────────────────────────────────────────────
  String? get serverUrl => _prefs.getString(_keyServerUrl);
  Future<void> setServerUrl(String url) => _prefs.setString(_keyServerUrl, url);
  Future<void> clearServerUrl() => _prefs.remove(_keyServerUrl);

  // ── Session cookie ─────────────────────────────────────────────────────
  String? get sessionCookie => _prefs.getString(_keySessionCookie);
  Future<void> setSessionCookie(String cookie) =>
      _prefs.setString(_keySessionCookie, cookie);
  Future<void> clearSessionCookie() => _prefs.remove(_keySessionCookie);

  // ── User info ──────────────────────────────────────────────────────────
  String? get userPhone => _prefs.getString(_keyUserPhone);
  Future<void> setUserPhone(String phone) =>
      _prefs.setString(_keyUserPhone, phone);

  String? get userName => _prefs.getString(_keyUserName);
  Future<void> setUserName(String name) =>
      _prefs.setString(_keyUserName, name);

  String? get userFirstName => _prefs.getString(_keyUserFirstName);
  Future<void> setUserFirstName(String name) =>
      _prefs.setString(_keyUserFirstName, name);

  String? get userLastName => _prefs.getString(_keyUserLastName);
  Future<void> setUserLastName(String name) =>
      _prefs.setString(_keyUserLastName, name);

  String? get userEmail => _prefs.getString(_keyUserEmail);
  Future<void> setUserEmail(String email) =>
      _prefs.setString(_keyUserEmail, email);

  bool get hasSession => sessionCookie != null && sessionCookie!.isNotEmpty;
  bool get hasServerUrl => serverUrl != null && serverUrl!.isNotEmpty;

  /// Clear all session-related data (on logout).
  Future<void> clearSession() async {
    await clearSessionCookie();
    await _prefs.remove(_keyUserPhone);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserFirstName);
    await _prefs.remove(_keyUserLastName);
    await _prefs.remove(_keyUserEmail);
  }

  /// Clear everything (full reset).
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
