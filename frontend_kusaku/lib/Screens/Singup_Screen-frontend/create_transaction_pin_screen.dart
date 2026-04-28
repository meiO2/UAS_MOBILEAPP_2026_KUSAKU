import 'package:flutter/material.dart';

import '../../Widgets/kusaku_auth_widgets.dart';
import 'confirm_transaction_pin_screen.dart';

class CreateTransactionPinScreen extends StatefulWidget {
  const CreateTransactionPinScreen({
    required this.username,
    required this.password,
    required this.email,
    required this.phoneNumber,
    required this.otp,
    super.key,
  });

  final String username;
  final String password;
  final String email;
  final String phoneNumber;
  final String otp;

  @override
  State<CreateTransactionPinScreen> createState() => _CreateTransactionPinScreenState();
}

class _CreateTransactionPinScreenState extends State<CreateTransactionPinScreen> {
  String _pin = '';

  void _onNumberPressed(String value) {
    if (_pin.length >= 6) return;
    setState(() {
      _pin += value;
    });
  }

  void _onBackspacePressed() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  void _onConfirmPressed() {
    if (_pin.length != 6) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConfirmTransactionPinScreen(
          initialPin: _pin,
          username: widget.username,
          password: widget.password,
          email: widget.email,
          phoneNumber: widget.phoneNumber,
          otp: widget.otp,
        ),
      ),
    );
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
                                'Create a Transaction PIN',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Icon(Icons.close, size: 18, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            6,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index < _pin.length
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
                                    onTap: () => _onNumberPressed(number),
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
                                  onTap: _onConfirmPressed,
                                  backgroundColor: _pin.length == 6
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
  final VoidCallback onTap;
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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