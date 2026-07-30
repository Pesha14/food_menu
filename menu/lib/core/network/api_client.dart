import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'api_exception.dart';

/// Every response from menu_api follows the same envelope:
/// { "success": bool, "statusCode": int, "message": str, "data": ... }
///
/// This client unwraps that envelope, attaches the JWT bearer token when
/// one is supplied, and turns any failure into an [ApiException].
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<dynamic> get(String path, {String? token}) async {
    final response = await _client
        .get(_uri(path), headers: _headers(token))
        .timeout(ApiConfig.requestTimeout);
    return _unwrap(response);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final response = await _client
        .post(
          _uri(path),
          headers: _headers(token),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(ApiConfig.requestTimeout);
    return _unwrap(response);
  }

  dynamic _unwrap(http.Response response) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'Unexpected response from server.',
        statusCode: response.statusCode,
      );
    }

    final success = json['success'] == true;
    if (!success) {
      throw ApiException(
        json['message']?.toString() ?? 'Request failed.',
        statusCode: json['statusCode'] as int? ?? response.statusCode,
      );
    }

    return json['data'];
  }
}
