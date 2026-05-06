import 'package:flutter/material.dart';

import '../../Widgets/kusaku_auth_widgets.dart';
import 'otp_verification_screen.dart';

class PhoneSignInScreen extends StatefulWidget {
  const PhoneSignInScreen({super.key});

  @override
  State<PhoneSignInScreen> createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends State<PhoneSignInScreen> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: '+62');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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
                          // Ensure test can find a BackButton widget.
                          Align(
                            alignment: Alignment.centerLeft,
                            child: BackButton(
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),

                          const SizedBox(height: 30),
                          const Text(
                            'Sign in with Phone Number',
                            style: TextStyle(fontSize: 33 / 2, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          KusakuInputField(
                            controller: _phoneController,
                            hintText: '',
                            icon: Icons.smartphone,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 32),
                          Center(
                            child: KusakuGradientButton(
                              text: 'Next',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => OtpVerificationScreen(
                                      phoneNumber: _phoneController.text,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
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