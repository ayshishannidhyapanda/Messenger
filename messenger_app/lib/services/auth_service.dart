import 'dart:io';
import '../config/api_constants.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Handles registration, OTP verification, and login.
class AuthService {
  final ApiService _api;
  final StorageService _storage;

  AuthService(this._api, this._storage);

  /// Register a new user.
  Future<({bool success, String message})> register(
      UserCreateRequest request) async {
    try {
      final response = await _api.postJson(
        ApiConstants.register,
        request.toJson(),
      );
      return (success: response.status < 400, message: response.message ?? 'Registration successful');
    } catch (e) {
      return (success: false, message: e.toString());
    }
  }

  /// Verify OTP.
  Future<({bool success, String message})> verifyOtp(
      OtpVerifyRequest request) async {
    try {
      final response = await _api.postJson(
        ApiConstants.verifyOtp,
        request.toJson(),
      );
      return (success: response.success, message: response.message ?? '');
    } catch (e) {
      return (success: false, message: e.toString());
    }
  }

  /// Login with phone and password.
  Future<({bool success, String message, User? user})> login({
    required String mobNumber,
    required String password,
  }) async {
    try {
      // Gather device info
      final deviceModel = '${Platform.operatingSystem} device';
      final deviceOs = Platform.operatingSystemVersion;
      final deviceId = mobNumber.hashCode.toRadixString(16);
      final deviceToken = 'flutter-${DateTime.now().millisecondsSinceEpoch}';

      final response = await _api.postForm<Map<String, dynamic>>(
        ApiConstants.login,
        {
          'mobNumber': mobNumber,
          'password': password,
          'deviceModel': deviceModel,
          'deviceOs': deviceOs,
          'deviceId': deviceId,
          'deviceToken': deviceToken,
        },
        fromJsonT: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final user = User.fromJson(response.data!);

        // Persist user info
        await _storage.setUserPhone(user.mobNumber);
        await _storage.setUserName(user.fullName);
        if (user.firstName != null) {
          await _storage.setUserFirstName(user.firstName!);
        }
        if (user.lastName != null) {
          await _storage.setUserLastName(user.lastName!);
        }
        if (user.email != null) {
          await _storage.setUserEmail(user.email!);
        }

        return (
          success: true,
          message: response.message ?? 'Login successful',
          user: user,
        );
      }

      return (
        success: false,
        message: response.message ?? response.error ?? 'Login failed',
        user: null,
      );
    } catch (e) {
      return (success: false, message: e.toString(), user: null);
    }
  }

  /// Whether the user has a saved session.
  bool get isLoggedIn => _storage.hasSession;

  /// Log out: clear session data.
  Future<void> logout() async {
    await _storage.clearSession();
  }
}

