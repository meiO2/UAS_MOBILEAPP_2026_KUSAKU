import 'package:flutter/material.dart';
import '../../Widgets/kusaku_auth_widgets.dart';
import 'change_password_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  const ForgotPasswordOtpScreen({
    required this.email,
    super.key,
  });

  final String email;

  @override
  State<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String _maskPhoneNumber(String phone) {
    if (phone.length < 8) return phone;
    final visibleStart = phone.substring(0, 3);
    final visibleEnd = phone.substring(phone.length - 3);
    final hiddenLength = phone.length - 6;
    return '$visibleStart${'*' * hiddenLength}$visibleEnd';
  }

  void _onOtpChanged(int index, String value) async {
    if (value.isEmpty) return;

    if (index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length == 6) {
      try {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}users/verify-otp/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': widget.email,
            'otp': otp,
          }),
        );

        if (response.statusCode == 200) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ChangePasswordScreen(
                email: widget.email,
                otp: otp,
              ),
            ),
          );
        } else {
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data.toString())),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection error')),
        );
      }
    }
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
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topCenter,
                child: FractionallySizedBox(
                  widthFactor: 0.97,
                  child: KusakuAuthCard(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.zero,
                                foregroundColor: Colors.black87,
                              ),
                              child: const Text('< Back', style: TextStyle(fontSize: 11)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Verification Code (OTP)',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Verification code already sent to ${_maskPhoneNumber(widget.email)}. Please enter the code within 3 minutes.',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              6,
                              (index) => Padding(
                                padding: EdgeInsets.only(right: index == 5 ? 0 : 8),
                                child: SizedBox(
                                  width: 34,
                                  height: 42,
                                  child: TextField(
                                    controller: _otpControllers[index],
                                    focusNode: _focusNodes[index],
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    onChanged: (v) => _onOtpChanged(index, v),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.zero,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: KusakuColors.primaryBlue),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: 72,
                              height: 22,
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('OTP resent successfully')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  padding: EdgeInsets.zero,
                                  backgroundColor: KusakuColors.primaryBlue,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Resend', style: TextStyle(fontSize: 9)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
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
