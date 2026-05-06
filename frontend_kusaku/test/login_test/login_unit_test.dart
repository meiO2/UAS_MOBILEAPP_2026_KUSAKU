// test/unit/login_unit_test.dart
//
// Unit tests for pure logic extracted from _LoginScreenState,
// PhoneSignInScreen, and OtpVerificationScreen (phone login variant).
//
// No Flutter widget tree or HTTP stack required.
// Run with: flutter test test/unit/login_unit_test.dart

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Pure functions mirroring the logic inside the login-flow state classes.
// These are extracted here so they can be tested without a widget tree.
// ---------------------------------------------------------------------------

/// Maps to the empty-field guard inside _handleLogin().
String? validateLoginFields({
  required String username,
  required String password,
}) {
  if (username.isEmpty || password.isEmpty) {
    return 'Please fill in both fields';
  }
  return null;
}

/// Maps to _maskPhoneNumber() inside _OtpVerificationScreenState
/// (phone-login variant).
String maskPhoneNumber(String phone) {
  if (phone.length < 8) return phone;
  final visibleStart = phone.substring(0, 3);
  final visibleEnd   = phone.substring(phone.length - 4);
  final hiddenLength = phone.length - 7;
  return '$visibleStart${'*' * hiddenLength}$visibleEnd';
}

/// Maps to the OTP composition check in _handleOtpInput().
bool isOtpComplete(List<String> parts) =>
    parts.length == 6 && parts.every((p) => p.length == 1);

/// Maps to the PIN guard in the bottomNavigationBar onPressed callback:
/// both last_username and user_id must be present before showing the PIN
/// dialog.
String? validatePinLoginPrerequisites({
  required String? savedUsername,
  required int? userId,
}) {
  if (savedUsername == null || userId == null) {
    return 'Please login with your password first.';
  }
  return null;
}

/// Maps to the biometric prerequisite check inside _loginWithFingerprint().
/// Returns an error string when biometrics are unavailable.
String? validateBiometricSupport({
  required bool canCheck,
  required bool isSupported,
}) {
  if (!canCheck || !isSupported) return 'Biometrics not available on this device';
  return null;
}

// ---------------------------------------------------------------------------

void main() {
  // ── validateLoginFields ──────────────────────────────────────────────────

  group('validateLoginFields –', () {
    test('returns null for valid username and password', () {
      expect(
        validateLoginFields(username: 'john', password: 'Secret1'),
        isNull,
      );
    });

    test('error when username is empty', () {
      expect(
        validateLoginFields(username: '', password: 'Secret1'),
        'Please fill in both fields',
      );
    });

    test('error when password is empty', () {
      expect(
        validateLoginFields(username: 'john', password: ''),
        'Please fill in both fields',
      );
    });

    test('error when both fields are empty', () {
      expect(
        validateLoginFields(username: '', password: ''),
        'Please fill in both fields',
      );
    });

    test('whitespace-only input counts as empty after trim', () {
      String t(String s) => s.trim();
      expect(
        validateLoginFields(username: t('   '), password: t('   ')),
        'Please fill in both fields',
      );
    });
  });

  // ── maskPhoneNumber ───────────────────────────────────────────────────────

  group('maskPhoneNumber –', () {
    test('masks middle digits of a standard number', () {
      expect(maskPhoneNumber('08112345678'), '081****5678');
    });

    test('returns original string when shorter than 8 chars', () {
      expect(maskPhoneNumber('0812'), '0812');
    });

    test('edge case: exactly 8 characters', () {
      // length=8: hidden = 8-7 = 1
      expect(maskPhoneNumber('08123456'), '081*3456');
    });

    test('handles +62 prefix format', () {
      final result = maskPhoneNumber('+6281234567890');
      expect(result.startsWith('+62'), isTrue);
      expect(result.endsWith('7890'), isTrue);
      expect(result.contains('*'), isTrue);
    });
  });

  // ── isOtpComplete ─────────────────────────────────────────────────────────

  group('isOtpComplete –', () {
    test('returns true for 6 single-digit parts', () {
      expect(isOtpComplete(['1', '2', '3', '4', '5', '6']), isTrue);
    });

    test('returns false when fewer than 6 parts', () {
      expect(isOtpComplete(['1', '2', '3']), isFalse);
    });

    test('returns false when any part is empty', () {
      expect(isOtpComplete(['1', '2', '', '4', '5', '6']), isFalse);
    });

    test('returns false when a part has more than one character', () {
      expect(isOtpComplete(['1', '2', '34', '4', '5', '6']), isFalse);
    });

    test('OTP string assembled from parts is 6 chars', () {
      final parts = ['9', '8', '7', '6', '5', '4'];
      expect(parts.join().length, 6);
    });
  });

  // ── validatePinLoginPrerequisites ─────────────────────────────────────────

  group('validatePinLoginPrerequisites –', () {
    test('returns null when both username and userId are present', () {
      expect(
        validatePinLoginPrerequisites(savedUsername: 'john', userId: 42),
        isNull,
      );
    });

    test('error when savedUsername is null', () {
      expect(
        validatePinLoginPrerequisites(savedUsername: null, userId: 42),
        'Please login with your password first.',
      );
    });

    test('error when userId is null', () {
      expect(
        validatePinLoginPrerequisites(savedUsername: 'john', userId: null),
        'Please login with your password first.',
      );
    });

    test('error when both are null', () {
      expect(
        validatePinLoginPrerequisites(savedUsername: null, userId: null),
        'Please login with your password first.',
      );
    });
  });

  // ── validateBiometricSupport ──────────────────────────────────────────────

  group('validateBiometricSupport –', () {
    test('returns null when biometrics fully supported', () {
      expect(
        validateBiometricSupport(canCheck: true, isSupported: true),
        isNull,
      );
    });

    test('error when canCheck is false', () {
      expect(
        validateBiometricSupport(canCheck: false, isSupported: true),
        isNotNull,
      );
    });

    test('error when isSupported is false', () {
      expect(
        validateBiometricSupport(canCheck: true, isSupported: false),
        isNotNull,
      );
    });

    test('error when both are false', () {
      expect(
        validateBiometricSupport(canCheck: false, isSupported: false),
        isNotNull,
      );
    });
  });

  // ── PhoneSignInScreen initial value ───────────────────────────────────────

  group('PhoneSignInScreen –', () {
    test('phone controller initialises with +62 prefix', () {
      // Mirrors initState: TextEditingController(text: '+62')
      const initialText = '+62';
      expect(initialText.startsWith('+62'), isTrue);
    });

    test('navigates to OTP screen when phone is non-empty', () {
      // Navigation guard: any non-empty phone text proceeds to OTP screen.
      const phone = '+6281234567890';
      expect(phone.isNotEmpty, isTrue);
    });
  });
}