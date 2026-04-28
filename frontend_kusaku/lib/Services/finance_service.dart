import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_kusaku/config/api_config.dart';

class FinanceService {
  static Future<Map<String, dynamic>> fetchBalance(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}balance/$userId/'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load balance: ${response.body}');
  }

  static Future<List<dynamic>> fetchBudgets(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}budget/$userId/'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data is List) return data;
      throw Exception('Invalid budget format');
    }

    throw Exception('Failed to load budgets: ${response.body}');
  }

  static Future<void> updateBudgets(int userId, List<Map<String, dynamic>> payload) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}budget/$userId/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update budgets: ${response.body}');
    }
  }
}