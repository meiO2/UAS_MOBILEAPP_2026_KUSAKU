import 'package:flutter/material.dart';

class KusakuColors {
  static const Color backgroundBlue = Color(0xFFDBEAFE);
  static const Color cardPurple = Color(0xFFD8B4FE);
  static const Color primaryDark = Color(0xFF3B2E4B);
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color lightBlue = Color(0xFF93C5FD);
  static const Color fieldBackground = Color(0xFFF3F4F6);
  static const Color hint = Color(0xFF9CA3AF);
}

class KusakuAuthHeader extends StatelessWidget {
  const KusakuAuthHeader({
    required this.logoAsset,
    required this.titleAsset,
    super.key,
  });

  final String logoAsset;
  final String titleAsset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Column(
        children: [
          Image.asset(
            logoAsset,
            width: 96,
            height: 96,
          ),
          const SizedBox(height: 8),
          Image.asset(
            titleAsset,
            width: 150,
          ),
        ],
      ),
    );
  }
}

class KusakuAuthCard extends StatelessWidget {
  const KusakuAuthCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: KusakuColors.cardPurple,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

class KusakuInputField extends StatelessWidget {
  const KusakuInputField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KusakuColors.fieldBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 13,
            color: KusakuColors.hint,
          ),
          prefixIcon: const Icon(Icons.circle, color: Colors.transparent, size: 0),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ).copyWith(
          prefixIcon: Icon(icon, color: KusakuColors.primaryDark),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

class KusakuGradientButton extends StatelessWidget {
  const KusakuGradientButton({
    required this.text,
    required this.onPressed,
    super.key,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      height: 46,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [KusakuColors.primaryBlue, KusakuColors.lightBlue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class KusakuBottomPinPanel extends StatelessWidget {
  const KusakuBottomPinPanel({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 7,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.lock, size: 18),
                label: const Text(
                  'LOGIN WITH PIN',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: KusakuColors.primaryDark,
                  side: const BorderSide(color: KusakuColors.primaryDark, width: 2),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KusakuPinInputDialog extends StatefulWidget {
  const KusakuPinInputDialog({
    this.title = 'Enter your PIN',
    this.pinLength = 6,
    super.key,
  });

  final String title;
  final int pinLength;

  @override
  State<KusakuPinInputDialog> createState() => _KusakuPinInputDialogState();
}

class _KusakuPinInputDialogState extends State<KusakuPinInputDialog> {
  String _pin = '';

  void _appendDigit(String digit) {
    if (_pin.length >= widget.pinLength) return;
    setState(() {
      _pin += digit;
    });
  }

  void _deleteDigit() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  void _submitPin() {
    if (_pin.length == widget.pinLength) {
      Navigator.of(context).pop(_pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.pinLength, (index) {
                final bool filled = index < _pin.length;
                return Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: filled ? KusakuColors.primaryBlue : const Color(0xFFE5E7EB),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              shrinkWrap: true,
              childAspectRatio: 1.6,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (int i = 1; i <= 9; i++) _PinKeyButton(label: '$i', onTap: () => _appendDigit('$i')),
                _PinKeyButton(
                  icon: Icons.backspace_outlined,
                  onTap: _deleteDigit,
                  foregroundColor: KusakuColors.primaryBlue,
                ),
                _PinKeyButton(label: '0', onTap: () => _appendDigit('0')),
                _PinKeyButton(
                  icon: Icons.check,
                  onTap: _submitPin,
                  backgroundColor: const Color(0xFF2F1BE0),
                  foregroundColor: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PinKeyButton extends StatelessWidget {
  const _PinKeyButton({
    this.label,
    this.icon,
    required this.onTap,
    this.backgroundColor = const Color(0xFFE5E7EB),
    this.foregroundColor = const Color(0xFF3642C5),
  });

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        overlayColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ).copyWith(
        splashFactory: NoSplash.splashFactory,
      ),
      child: icon != null
          ? Icon(icon, size: 24)
          : Text(
              label ?? '',
              style: const TextStyle(fontSize: 36 / 2, fontWeight: FontWeight.w700),
            ),
    );
  }
}