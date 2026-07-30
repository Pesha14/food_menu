import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/menu_models.dart';
import '../services/menu_service.dart';

final menuServiceProvider = Provider<MenuService>(
  (ref) => MenuService(client: ref.read(apiClientProvider)),
);

/// Re-fetches automatically whenever the auth session changes (i.e. on
/// every fresh login), since menus are filtered server-side per staff.
final availableMenusProvider = FutureProvider<List<MenuItem>>((ref) async {
  final session = ref.watch(authProvider);
  if (session == null) return <MenuItem>[];

  final service = ref.read(menuServiceProvider);
  return service.getAvailableMenus(token: session.token);
});

/// The single meal the staff member has tapped (Step 3 of the flow).
/// Only one item is held at a time -- the guide's flow is one meal per
/// transaction, not a multi-item cart.
final selectedMenuItemProvider = StateProvider<MenuItem?>((ref) => null);
