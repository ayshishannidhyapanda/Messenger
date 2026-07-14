/// Generic API response wrapper matching the backend `ApiResponse<T>`.
class ApiResponse<T> {
  final String timestamp;
  final int status;
  final String statusText;
  final bool success;
  final String? message;
  final T? data;
  final String? error;
  final String? errorCode;
  final String? path;
  final String? action;
  final String? redirectUrl;

  const ApiResponse({
    required this.timestamp,
    required this.status,
    required this.statusText,
    required this.success,
    this.message,
    this.data,
    this.error,
    this.errorCode,
    this.path,
    this.action,
    this.redirectUrl,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      timestamp: json['timestamp'] ?? '',
      status: json['status'] ?? 0,
      statusText: json['statusText'] ?? '',
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      error: json['error'],
      errorCode: json['errorCode'],
      path: json['path'],
      action: json['action'],
      redirectUrl: json['redirectUrl'],
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}
