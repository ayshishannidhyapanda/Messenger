/// User model matching backend `UserResponseDto`.
class User {
  final String? firstName;
  final String? lastName;
  final String mobNumber;
  final String? email;
  final bool isPhoneNumberVerified;

  const User({
    this.firstName,
    this.lastName,
    required this.mobNumber,
    this.email,
    this.isPhoneNumberVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['firstName'],
      lastName: json['lastName'],
      mobNumber: json['mobNumber'] ?? '',
      email: json['email'],
      isPhoneNumberVerified: json['isPhoneNumberVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'mobNumber': mobNumber,
        'email': email,
        'isPhoneNumberVerified': isPhoneNumberVerified,
      };

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  String get initials {
    final f = firstName?.isNotEmpty == true ? firstName![0] : '';
    final l = lastName?.isNotEmpty == true ? lastName![0] : '';
    return '$f$l'.toUpperCase();
  }
}

/// Registration request matching backend `UserCreateDTO`.
class UserCreateRequest {
  final String username;
  final String firstName;
  final String lastName;
  final String mobNumber;
  final String email;
  final String password;

  const UserCreateRequest({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.mobNumber,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
        'mobNumber': mobNumber,
        'email': email,
        'password': password,
      };
}

/// OTP verification request matching backend `OtpVerifyDto`.
class OtpVerifyRequest {
  final String identifier;
  final String otp;

  const OtpVerifyRequest({required this.identifier, required this.otp});

  Map<String, dynamic> toJson() => {
        'identifier': identifier,
        'otp': otp,
      };
}
