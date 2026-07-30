import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/staff.dart';
import '../services/auth_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(client: ref.read(apiClientProvider)),
);

/// Holds the active session for the duration of a shift. Per the
/// integration guide, this is cleared entirely after every transaction /
/// logout — there is no persistence across app restarts by design, since
/// the POS should always come back up on the login screen.
class AuthNotifier extends StateNotifier<AuthSession?> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(null);

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final session = await _authService.login(
      username: username,
      password: password,
    );
    state = session;
  }

  /// Clears the JWT token and all staff information, per the guide's
  /// "Step 6 -- Logout" requirements.
  void logout() {
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthSession?>(
  (ref) => AuthNotifier(ref.read(authServiceProvider)),
);
