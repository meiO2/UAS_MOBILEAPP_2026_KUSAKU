import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Services/transaction_pin_store.dart';
import '../../Services/auth_services/user_credentials_store.dart';
import '../../Widgets/kusaku_auth_widgets.dart';
import '../Login_Screen-frontend/login_screen.dart';

import '../../config/api_config.dart';

class ConfirmTransactionPinScreen extends StatefulWidget {
  const ConfirmTransactionPinScreen({
    required this.initialPin,
    required this.username,
    required this.password,
    required this.email,
    required this.phoneNumber,
    required this.otp,
    super.key,
  });

  final String initialPin;
  final String username;
  final String password;
  final String email;
  final String phoneNumber;
  final String otp;

  @override
  State<ConfirmTransactionPinScreen> createState() =>
      _ConfirmTransactionPinScreenState();
}

class _ConfirmTransactionPinScreenState
    extends State<ConfirmTransactionPinScreen> {
  String _confirmPin = '';
  bool _isLoading = false;

  void _onNumberPressed(String value) {
    if (_confirmPin.length >= 6) return;
    setState(() {
      _confirmPin += value;
    });
  }

  void _onBackspacePressed() {
    if (_confirmPin.isEmpty) return;
    setState(() {
      _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
    });
  }

  Future<void> _registerUser() async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}users/register/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": widget.email,
        "username": widget.username,
        "password": widget.password,
        "phone_number": widget.phoneNumber,
        "transaction_password": _confirmPin,
        "otp": widget.otp,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw Exception(data.toString());
    }
  }

  void _onConfirmPressed() async {
    if (_confirmPin.length != 6) return;

    if (_confirmPin != widget.initialPin) {
      setState(() {
        _confirmPin = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN tidak sama. Coba lagi.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _registerUser();

      await TransactionPinStore.setPin(_confirmPin);
      UserCredentialsStore.setCredentials(
        username: widget.username,
        password: widget.password,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Register berhasil')),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KusakuColors.backgroundBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const KusakuAuthHeader(
                logoAsset: 'assets/images/Logo.png',
                titleAsset: 'assets/images/KUSAKU.png',
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.topCenter,
                child: FractionallySizedBox(
                  widthFactor: 0.95,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF6D6CF7), width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x336D6CF7),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Confirm Transaction Password',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Icon(Icons.close,
                                  size: 18, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            6,
                            (index) => Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index < _confirmPin.length
                                    ? const Color(0xFF3743C8)
                                    : const Color(0xFFD9D9D9),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        for (final row in const [
                          ['1', '2', '3'],
                          ['4', '5', '6'],
                          ['7', '8', '9'],
                        ]) ...[
                          Row(
                            children: row.map((number) {
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: _PinPadButton(
                                    label: number,
                                    onTap: () =>
                                        _onNumberPressed(number),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: _PinPadButton(
                                  icon: Icons.backspace_outlined,
                                  onTap: _onBackspacePressed,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: _PinPadButton(
                                  label: '0',
                                  onTap: () => _onNumberPressed('0'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: _PinPadButton(
                                  icon: Icons.check,
                                  onTap: _isLoading ? null : _onConfirmPressed,
                                  backgroundColor: _confirmPin.length == 6
                                      ? const Color(0xFF2E13D4)
                                      : const Color(0xFFB6B6D9),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinPadButton extends StatelessWidget {
  const _PinPadButton({
    this.label,
    this.icon,
    required this.onTap,
    this.backgroundColor = const Color(0xFFE5E5E5),
    this.foregroundColor = const Color(0xFF3743C8),
  });

  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: icon != null
            ? Icon(icon, color: foregroundColor, size: 26)
            : Text(
                label ?? '',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: foregroundColor,
                ),
              ),
      ),
    );
  }
}