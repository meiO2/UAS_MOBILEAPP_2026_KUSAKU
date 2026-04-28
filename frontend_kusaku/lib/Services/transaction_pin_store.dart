// In transaction_pin_store.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class TransactionPinStore {
  static const _key = 'transaction_pin';
  static String? _pin;

  static String? get pin => _pin;
  static bool get hasPin => _pin != null && _pin!.isNotEmpty;

  static Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _pin = prefs.getString(_key);
  }

  static Future<void> setPin(String value) async {
    _pin = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value);
  }

  static Future<void> clearPin() async {
    _pin = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<bool> verifyPinRemote(int userId, String pin) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}users/verify-pin/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'pin': pin}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}