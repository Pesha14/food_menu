/// Thrown whenever the backend returns a non-success response, or the
/// request fails outright (timeout, no connection, bad JSON, etc.).
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  /// True when this failure means the session is no longer valid and the
  /// app should return to the login screen.
  bool get isUnauthorized => statusCode == 401 || statusCode == 403;

  @override
  String toString() => message;
}
