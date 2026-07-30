import '../../../core/network/api_client.dart';
import '../models/staff.dart';

class AuthService {
  final ApiClient _client;

  AuthService({ApiClient? client}) : _client = client ?? ApiClient();

  /// POST /api/v1/auth/login
  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    final data = await _client.post(
      '/auth/login',
      body: {'username': username, 'password': password},
    );

    return AuthSession.fromJson(data as Map<String, dynamic>);
  }
}
