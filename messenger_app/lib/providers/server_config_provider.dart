import 'package:flutter/material.dart';
import '../services/server_config_service.dart';

/// State management for the server URL configuration.
class ServerConfigProvider extends ChangeNotifier {
  final ServerConfigService _service;

  bool _isTesting = false;
  bool? _testResult;
  String? _errorMessage;

  ServerConfigProvider(this._service);

  // ── Getters ────────────────────────────────────────────────────────────
  bool get isConfigured => _service.isConfigured;
  String? get currentUrl => _service.currentUrl;
  bool get isTesting => _isTesting;
  bool? get testResult => _testResult;
  String? get errorMessage => _errorMessage;

  // ── Actions ────────────────────────────────────────────────────────────

  /// Test a server URL for connectivity.
  Future<bool> testConnection(String url) async {
    _isTesting = true;
    _testResult = null;
    _errorMessage = null;
    notifyListeners();

    final result = await _service.testConnection(url);

    _isTesting = false;
    _testResult = result;
    if (!result) {
      _errorMessage = 'Could not connect to server. Check the URL and make sure the server is running.';
    }
    notifyListeners();
    return result;
  }

  /// Save the server URL.
  Future<void> saveUrl(String url) async {
    await _service.saveUrl(url);
    _testResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear the saved URL.
  Future<void> clearUrl() async {
    await _service.clearUrl();
    _testResult = null;
    notifyListeners();
  }

  /// Reset test state.
  void resetTestState() {
    _testResult = null;
    _errorMessage = null;
    notifyListeners();
  }
}
