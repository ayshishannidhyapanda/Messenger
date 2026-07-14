import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

/// State management for authentication.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final StorageService _storage;

  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  AuthProvider(this._authService, this._storage);

  // ── Getters ────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _authService.isLoggedIn;
  String? get currentPhone => _storage.userPhone;
  String? get currentName => _storage.userName;

  // ── Register ───────────────────────────────────────────────────────────

  Future<bool> register(UserCreateRequest request) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.register(request);

    _setLoading(false);
    if (!result.success) {
      _errorMessage = result.message;
      notifyListeners();
    }
    return result.success;
  }

  // ── OTP Verify ─────────────────────────────────────────────────────────

  Future<bool> verifyOtp(OtpVerifyRequest request) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.verifyOtp(request);

    _setLoading(false);
    if (!result.success) {
      _errorMessage = result.message;
      notifyListeners();
    }
    return result.success;
  }

  // ── Login ──────────────────────────────────────────────────────────────

  Future<bool> login({
    required String mobNumber,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authService.login(
      mobNumber: mobNumber,
      password: password,
    );

    _setLoading(false);

    if (result.success && result.user != null) {
      _currentUser = result.user;
      notifyListeners();
      return true;
    }

    _errorMessage = result.message;
    notifyListeners();
    return false;
  }

  // ── Logout ─────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
