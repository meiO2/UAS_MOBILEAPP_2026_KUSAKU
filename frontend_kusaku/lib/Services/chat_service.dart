import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ChatResponse {
  final String reply;
  final String type;
  final Map<String, dynamic>? data;

  ChatResponse({
    required this.reply,
    required this.type,
    this.data,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      reply: json['reply'] ?? '',
      type: json['type'] ?? 'text',
      data: json['data'],
    );
  }
}

class ChatService {
  static Future<ChatResponse> sendMessage(int userId, String message) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}ai/message/$userId/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"message": message}),
    );

    if (response.statusCode == 200) {
      return ChatResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to send message: ${response.statusCode}");
    }
  }

  // Returns list of {"id", "name", "percentage", "enabled"}
  static Future<List<Map<String, dynamic>>> getCategories(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}categories/$userId/'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      // Backend already returns flat: {id, name, percentage, enabled}
      return data.map<Map<String, dynamic>>((item) => {
        "id": item['id'],
        "name": item['name'],
        "percentage": (item['percentage'] as num).toDouble(),
        "enabled": item['enabled'] ?? true,
      }).toList();
    } else {
      throw Exception("Failed to load categories: ${response.statusCode}");
    }
  }

  static Future<ChatResponse> getInitialBudget(int userId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}ai/init-budget/$userId/'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return ChatResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to get initial budget: ${response.statusCode}");
    }
  }

  static Future<void> saveCategories(
      int userId, List<Map<String, dynamic>> categories) async {

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}categories/update/$userId/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "categories": categories.map((cat) => {
          "id": cat['id'],
          "percentage": cat['percentage'],
          "enabled": cat['enabled'],
        }).toList(),
      }),
    );

    if (response.statusCode != 200) {
      print(response.body);
      throw Exception("Failed to save categories: ${response.statusCode}");
    }
  }
}

