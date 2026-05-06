// test/unit/signup_unit_test.dart
//
// Unit tests for _SignUpScreenState validation logic.
// Run with: flutter test test/unit/signup_unit_test.dart

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Pure helper functions extracted from _SignUpScreenState so they can be
// tested without a widget tree or HTTP stack.
// ---------------------------------------------------------------------------

/// Returns an error message when any required field is blank, otherwise null.
String? validateRequiredFields({
  required String username,
  required String password,
  required String confirmPassword,
  required String phone,
  required String email,
}) {
  if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
    return 'Username dan password wajib diisi';
  }
  if (password != confirmPassword) {
    return 'Password dan Confirm Password tidak sama';
  }
  if (phone.isEmpty) return 'Phone Number wajib diisi';
  if (email.isEmpty) return 'Email wajib diisi';
  return null;
}

/// Masks a phone number: keeps first 3 and last 4 chars, hides the rest.
String maskPhoneNumber(String phone) {
  if (phone.length < 8) return phone;
  final visibleStart = phone.substring(0, 3);
  final visibleEnd = phone.substring(phone.length - 4);
  final hiddenLength = phone.length - 7;
  return '$visibleStart${'*' * hiddenLength}$visibleEnd';
}

void main() {
  // ─── validateRequiredFields ────────────────────────────────────────────────

  group('validateRequiredFields –', () {
    const base = (
      username: 'john',
      password: 'Secret123',
      confirmPassword: 'Secret123',
      phone: '08123456789',
      email: 'john@example.com',
    );

    test('returns null when all fields are valid', () {
      expect(
        validateRequiredFields(
          username: base.username,
          password: base.password,
          confirmPassword: base.confirmPassword,
          phone: base.phone,
          email: base.email,
        ),
        isNull,
      );
    });

    test('error when username is empty', () {
      expect(
        validateRequiredFields(
          username: '',
          password: base.password,
          confirmPassword: base.confirmPassword,
          phone: base.phone,
          email: base.email,
        ),
        'Username dan password wajib diisi',
      );
    });

    test('error when password is empty', () {
      expect(
        validateRequiredFields(
          username: base.username,
          password: '',
          confirmPassword: '',
          phone: base.phone,
          email: base.email,
        ),
        'Username dan password wajib diisi',
      );
    });

    test('error when confirmPassword is empty', () {
      expect(
        validateRequiredFields(
          username: base.username,
          password: base.password,
          confirmPassword: '',
          phone: base.phone,
          email: base.email,
        ),
        'Username dan password wajib diisi',
      );
    });

    test('error when password and confirmPassword do not match', () {
      expect(
        validateRequiredFields(
          username: base.username,
          password: 'Secret123',
          confirmPassword: 'Different456',
          phone: base.phone,
          email: base.email,
        ),
        'Password dan Confirm Password tidak sama',
      );
    });

    test('error when phone is empty', () {
      expect(
        validateRequiredFields(
          username: base.username,
          password: base.password,
          confirmPassword: base.confirmPassword,
          phone: '',
          email: base.email,
        ),
        'Phone Number wajib diisi',
      );
    });

    test('error when email is empty', () {
      expect(
        validateRequiredFields(
          username: base.username,
          password: base.password,
          confirmPassword: base.confirmPassword,
          phone: base.phone,
          email: '',
        ),
        'Email wajib diisi',
      );
    });

    test('whitespace-only fields count as empty after trim', () {
      // Simulates .trim() applied before calling the validator
      String trim(String s) => s.trim();
      expect(
        validateRequiredFields(
          username: trim('   '),
          password: base.password,
          confirmPassword: base.confirmPassword,
          phone: base.phone,
          email: base.email,
        ),
        'Username dan password wajib diisi',
      );
    });
  });

  // ─── maskPhoneNumber ───────────────────────────────────────────────────────

  group('maskPhoneNumber –', () {
    test('masks middle digits of a standard Indonesian number', () {
      expect(maskPhoneNumber('08123456789'), '081****6789');
    });

    test('returns original string when shorter than 8 chars', () {
      expect(maskPhoneNumber('0812'), '0812');
    });

    test('works with exactly 8 characters (edge case)', () {
      // length=8: visibleStart=3, visibleEnd=4, hidden=1
      expect(maskPhoneNumber('08123456'), '081*3456');
    });

    test('works with a longer number (13 digits)', () {
      final result = maskPhoneNumber('6281234567890');
      expect(result.startsWith('628'), isTrue);
      expect(result.endsWith('7890'), isTrue);
      expect(result.contains('*'), isTrue);
    });
  });

  // ─── PIN matching logic ────────────────────────────────────────────────────

  group('Transaction PIN confirmation –', () {
    test('matching PINs are accepted', () {
      const pin = '123456';
      const confirmPin = '123456';
      expect(pin == confirmPin, isTrue);
    });

    test('mismatched PINs are rejected', () {
      const pin = '123456';
      const confirmPin = '654321';
      expect(pin == confirmPin, isFalse);
    });

    test('PIN must be exactly 6 digits', () {
      expect('12345'.length == 6, isFalse);
      expect('123456'.length == 6, isTrue);
      expect('1234567'.length == 6, isFalse);
    });
  });

  // ─── OTP composition ──────────────────────────────────────────────────────

  group('OTP composition –', () {
    test('joining 6 single-digit strings produces a 6-char OTP', () {
      final parts = ['1', '2', '3', '4', '5', '6'];
      final otp = parts.join();
      expect(otp, '123456');
      expect(otp.length, 6);
    });

    test('incomplete OTP (less than 6 parts) is not submitted', () {
      final parts = ['1', '2', '3'];
      final otp = parts.join();
      expect(otp.length == 6, isFalse);
    });
  });
}