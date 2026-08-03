/// Central place for backend connection settings.
///
/// 10.0.2.2 is the special alias the Android emulator uses to reach
/// "localhost" on the host machine. If you're running on a physical
/// device, replace this with your machine's LAN IP (e.g. 192.168.x.x)
/// and make sure the device is on the same network.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://192.168.100.196:5000/api/v1';

  static const Duration requestTimeout = Duration(seconds: 15);
}
