import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = 'https://api.yourdomain.com'; // Replace with secure API URL

  Future<bool> authenticate(String password, String nfcId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'password': password, 'nfcId': nfcId}),
    );
    return response.statusCode == 200;
  }
}
