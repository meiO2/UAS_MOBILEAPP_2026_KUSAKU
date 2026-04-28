import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Services/transaction_pin_store.dart';
import '../../Widgets/kusaku_auth_widgets.dart';
import 'phone_signin_screen.dart';
import '../Singup_Screen-frontend/sign_up_screen.dart';
import '../ForgotPassword_Screen-frontend/forgot_password_screen.dart';
import 'package:frontend_kusaku/navbar.dart';

import '../../config/api_config.dart';
import 'package:local_auth/local_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _phoneController;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneController = TextEditingController();
    _loadLastSession();
  }

  Future<void> _loadLastSession() async {
    await TransactionPinStore.loadFromPrefs();

    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('last_username');
    if (savedUsername != null) {
      setState(() {
        _usernameController.text = savedUsername;
      });
    }

    final fingerprintEnabled = prefs.getBool('fingerprint_enabled') ?? false;
    if (fingerprintEnabled && savedUsername != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) _loginWithFingerprint();
    }
  }

  Future<void> _loginWithFingerprint() async {
    try {
      final bool canCheck = await _localAuth.canCheckBiometrics;
      final bool isSupported = await _localAuth.isDeviceSupported();

      if (!canCheck || !isSupported) return;

      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Login ke Kusaku dengan sidik jari',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!authenticated || !mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        _showSnackBar('Sesi tidak ditemukan, login dengan password dulu');
        return;
      }

      if (!mounted) return;
      await prefs.setBool('is_authenticated', true);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } catch (e) {
      _showSnackBar('Biometrik gagal: $e');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in both fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}users/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_username', username);
        await prefs.setInt('user_id', data['user_id']);
        await prefs.setBool('is_authenticated', true);

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      } else {
        final errorData = jsonDecode(response.body);
        _showSnackBar(errorData['error'] ?? 'Username or password incorrect');
      }
    } catch (e) {
      _showSnackBar('Connection failed. Is the server running on 10.227.3.130?');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KusakuColors.backgroundBlue,
      bottomNavigationBar: KusakuBottomPinPanel(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          final savedUsername = prefs.getString('last_username');
          final userId = prefs.getInt('user_id');

          if (savedUsername == null || userId == null) {
            _showSnackBar('Please login with your password first.');
            return;
          }

          if (!mounted) return;
          final String? pin = await showDialog<String>(
            context: context,
            builder: (context) => const KusakuPinInputDialog(),
          );

          if (!mounted || pin == null || pin.isEmpty) return;

          // Show loading while we verify remotely
          setState(() => _isLoading = true);

          final isCorrect = await TransactionPinStore.verifyPinRemote(userId, pin);

          if (!mounted) return;
          setState(() => _isLoading = false);

          if (isCorrect) {
            await prefs.setBool('is_authenticated', true);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainShell()),
            );
          } else {
            _showSnackBar('PIN salah. Silakan coba lagi.');
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              KusakuAuthHeader(
                logoAsset: 'assets/images/Logo.png',
                titleAsset: 'assets/images/KUSAKU.png',
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topCenter,
                child: FractionallySizedBox(
                  widthFactor: 0.95,
                  child: KusakuAuthCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Welcome Back!',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(height: 18),
                          KusakuInputField(
                            controller: _usernameController,
                            hintText: 'Username',
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 10),
                          KusakuInputField(
                            controller: _passwordController,
                            hintText: 'Password',
                            icon: Icons.lock,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.only(top: 10, right: 12),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(fontSize: 11, color: KusakuColors.primaryBlue),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : KusakuGradientButton(
                                    text: 'Log in',
                                    onPressed: _handleLogin,
                                  ),
                          ),
                          // FIX 2: Fingerprint icon removed — runs silently on app init
                          const SizedBox(height: 20),
                          const Divider(
                            thickness: 2,
                            color: Color(0xFF9F8BC9),
                          ),
                          const SizedBox(height: 20),
                          KusakuInputField(
                            controller: _phoneController,
                            hintText: 'Phone Number',
                            icon: Icons.smartphone,
                            keyboardType: TextInputType.phone,
                            readOnly: true,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const PhoneSignInScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account yet? ",
                                style: TextStyle(fontSize: 12, color: Color(0xFF1F2937)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: KusakuColors.primaryBlue,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}