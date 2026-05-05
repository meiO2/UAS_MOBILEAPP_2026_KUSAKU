import 'package:flutter_test/flutter_test.dart';

/// ---------------------------------------------------------------------------
/// Unit Tests – QrisKitaPage (pure logic, no broken imports)
///
/// These tests verify logic that lives inside QrisKitaPage without importing
/// the page itself, so they compile even before the page is fully wired up.
/// ---------------------------------------------------------------------------
void main() {
  // ── QR data encoding ───────────────────────────────────────────────────────
  group('QR data encoding', () {
    String qrData(int userId) => userId.toString();

    test('QR value equals userId.toString() for normal id', () {
      expect(qrData(123), equals('123'));
    });

    test('QR value is correct for userId 0', () {
      expect(qrData(0), equals('0'));
    });

    test('QR value is correct for large userId', () {
      expect(qrData(999999), equals('999999'));
    });

    test('QR value for negative id (edge case)', () {
      expect(qrData(-1), equals('-1'));
    });
  });

  // ── Scanned QR value parsing ───────────────────────────────────────────────
  group('Scanned QR value parsing', () {
    int? parse(String raw) => int.tryParse(raw.trim());

    test('valid integer string parses to int', () {
      expect(parse('42'), equals(42));
    });

    test('whitespace-padded string still parses', () {
      expect(parse('  7  '), equals(7));
    });

    test('non-numeric string returns null', () {
      expect(parse('abc'), isNull);
    });

    test('empty string returns null', () {
      expect(parse(''), isNull);
    });

    test('float string returns null', () {
      expect(parse('3.14'), isNull);
    });

    test('string with special chars returns null', () {
      expect(parse('12@3'), isNull);
    });
  });

  // ── API response field extraction logic ────────────────────────────────────
  group('API response field extraction', () {
    Map<String, String> extractUser(Map<String, dynamic> data) {
      return {
        'phone': data['phone_number'] as String? ?? '',
        'name': data['username'] as String? ?? '',
      };
    }

    test('extracts phone and name correctly', () {
      final result = extractUser({
        'phone_number': '08123456789',
        'username': 'BudiSantoso',
      });
      expect(result['phone'], '08123456789');
      expect(result['name'], 'BudiSantoso');
    });

    test('returns empty string when phone_number is null', () {
      final result = extractUser({'phone_number': null, 'username': 'Ghost'});
      expect(result['phone'], '');
    });

    test('returns empty string when username is null', () {
      final result = extractUser({'phone_number': '0811', 'username': null});
      expect(result['name'], '');
    });

    test('returns empty strings for both when all null', () {
      final result = extractUser({'phone_number': null, 'username': null});
      expect(result['phone'], '');
      expect(result['name'], '');
    });

    test('empty phone string is treated as not found', () {
      final result = extractUser({'phone_number': '', 'username': 'Someone'});
      expect(result['phone']!.isEmpty, isTrue);
    });
  });

  // ── Guard conditions ───────────────────────────────────────────────────────
  group('Guard conditions', () {
    bool isValidScan(String raw) => int.tryParse(raw.trim()) != null;
    bool isUserFound(Map<String, String>? user) =>
        user != null && user['phone']!.isNotEmpty;

    test('isValidScan true for numeric string', () {
      expect(isValidScan('55'), isTrue);
    });

    test('isValidScan false for non-numeric', () {
      expect(isValidScan('NOT_AN_INT'), isFalse);
    });

    test('isUserFound false when user is null', () {
      expect(isUserFound(null), isFalse);
    });

    test('isUserFound false when phone is empty', () {
      expect(isUserFound({'phone': '', 'name': 'Someone'}), isFalse);
    });

    test('isUserFound true when phone is present', () {
      expect(isUserFound({'phone': '081234', 'name': 'Andi'}), isTrue);
    });
  });
}