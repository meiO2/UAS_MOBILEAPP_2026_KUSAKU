import 'package:flutter/material.dart';
import '../../Widgets/kusaku_auth_widgets.dart';
import '../Login_Screen-frontend/login_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ChangePasswordScreen({
    required this.email,
    required this.otp,
    super.key,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late final TextEditingController _newPasswordController;
  late final TextEditingController _reenterPasswordController;

  bool _obscureNewPassword = true;
  bool _obscureReenterPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController = TextEditingController();
    _reenterPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _reenterPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitChangePassword() async {
    if (_isLoading) return;

    final newPassword = _newPasswordController.text.trim();
    final reenterPassword = _reenterPasswordController.text.trim();

    if (newPassword.isEmpty || reenterPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password baru wajib diisi')),
      );
      return;
    }

    if (newPassword != reenterPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak sama')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}users/reset-password/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'otp': widget.otp,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil direset')),
        );

        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
                              child: const Text(
                                '< Back',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Change Password',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          KusakuInputField(
                            controller: _newPasswordController,
                            hintText: 'Enter New Password',
                            icon: Icons.lock,
                            obscureText: _obscureNewPassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          KusakuInputField(
                            controller: _reenterPasswordController,
                            hintText: 'Reenter New Password',
                            icon: Icons.lock,
                            obscureText: _obscureReenterPassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureReenterPassword =
                                      !_obscureReenterPassword;
                                });
                              },
                              icon: Icon(
                                _obscureReenterPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : KusakuGradientButton(
                                    text: 'Change Password',
                                    onPressed: _submitChangePassword,
                                  ),
                          ),
                          const SizedBox(height: 14),
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