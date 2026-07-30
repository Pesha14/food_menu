import '../../../core/network/api_client.dart';
import '../models/menu_models.dart';

class MenuService {
  final ApiClient _client;

  MenuService({ApiClient? client}) : _client = client ?? ApiClient();

  /// GET /api/v1/menu/available
  /// Backend already filters by staff company, date, time and
  /// availability -- the app just displays what comes back.
  Future<List<MenuItem>> getAvailableMenus({required String token}) async {
    final data = await _client.get('/menu/available', token: token);
    final list = data as List<dynamic>;
    return list
        .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
