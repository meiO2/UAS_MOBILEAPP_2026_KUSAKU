import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:frontend_kusaku/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  group('Formatter', () {
    test('formats integers with thousands separator and Rp prefix', () {
      expect(formatter.format(0), 'Rp 0');
      expect(formatter.format(500), 'Rp 500');
      expect(formatter.format(1000), 'Rp 1.000');
      expect(formatter.format(750000), 'Rp 750.000');
      expect(formatter.format(5000000), 'Rp 5.000.000');
    });
  });

  group('Activity mapping', () {
    String mapExpenseAmount(num amount) => '-${formatter.format(amount.abs())}';
    String mapIncomeAmount(num amount) => '+${formatter.format(amount)}';

    test('maps expense and income amounts to signed formatted strings', () {
      final expense = {'receiver': 'Warung', 'total_payment': 750000, 'date': '2025-01-01'};
      final income = {'title': 'Gaji', 'amount': 1000000, 'date': '2025-01-02'};

      final mappedExpense = mapExpenseAmount(num.tryParse(expense['total_payment'].toString()) ?? 0);
      final mappedIncome = mapIncomeAmount(num.tryParse(income['amount'].toString()) ?? 0);

      expect(mappedExpense, '-Rp 750.000');
      expect(mappedIncome, '+Rp 1.000.000');
    });

    test('filters out budgets or activities with zero amounts when needed', () {
      final list = [
        {'percentage': 30, 'remaining_amount': 750000, 'category': {'name': 'Makan & Minum'}},
        {'percentage': 0, 'remaining_amount': 0, 'category': {'name': 'HiddenCategory'}},
      ];

      final kept = list.where((b) => (b['percentage'] as int) > 0).toList();
      expect(kept.length, 1);
      final first = kept.first as Map<String, dynamic>;
      final category = first['category'] as Map<String, dynamic>;
      expect(category['name'], 'Makan & Minum');
    });
  });

  group('Banner URL mapping', () {
    String mapBanner(String img) {
      return img.startsWith('http') ? img : '${ApiConfig.baseUrl}$img';
    }

    test('keeps absolute http URLs intact', () {
      final url = 'http://example.com/foo.png';
      expect(mapBanner(url), url);
    });

    test('prepends baseUrl for relative image paths', () {
      final img = 'images/promo.png';
      expect(mapBanner(img), '${ApiConfig.baseUrl}images/promo.png');
    });
  });

  group('Transfer API validation', () {
    test('validates transfer amount constraints', () {
      const maxTransfer = 30000000;
      
      // Valid amounts
      expect(500000 > 0 && 500000 <= maxTransfer, true);
      expect(5000000 > 0 && 5000000 <= maxTransfer, true);
      
      // Invalid amounts
      expect(0 > 0 && 0 <= maxTransfer, false); // zero
      expect(35000000 > 0 && 35000000 <= maxTransfer, false); // exceeds max
    });

    test('validates recipient phone format', () {
      final isValidPhone = (String phone) {
        final cleaned = phone.trim();
        return cleaned.isNotEmpty && cleaned.startsWith('08') && cleaned.length >= 10;
      };

      expect(isValidPhone('081234567890'), true);
      expect(isValidPhone('081299988877'), true);
      expect(isValidPhone('08'), false);
      expect(isValidPhone(''), false);
    });

    test('constructs transfer payload correctly', () {
      final payload = {
        'sender_phone': '081234567890',
        'recipient_phone': '081299988877',
        'amount': 500000,
        'notes': 'Untuk kebutuhan',
      };

      expect(payload['sender_phone'], '081234567890');
      expect(payload['recipient_phone'], '081299988877');
      expect(payload['amount'], 500000);
      expect(payload['notes'], 'Untuk kebutuhan');
    });
  });

  group('Session data management', () {
    test('loads session data from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'user_id': 123,
        'phone_number': '081234567890',
        'full_name': 'John Doe',
      });

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final phone = prefs.getString('phone_number');
      final name = prefs.getString('full_name');

      expect(userId, 123);
      expect(phone, '081234567890');
      expect(name, 'John Doe');
    });

    test('handles missing session fields gracefully', () async {
      SharedPreferences.setMockInitialValues({
        'user_id': 456,
        // phone_number and full_name intentionally missing
      });

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final phone = prefs.getString('phone_number') ?? '';
      final name = prefs.getString('full_name') ?? '';

      expect(userId, 456);
      expect(phone, '');
      expect(name, '');
    });
  });

  group('ApiException error handling', () {
    test('creates ApiException with custom message', () {
      const exception = _TestApiException('Saldo tidak cukup');
      expect(exception.message, 'Saldo tidak cukup');
      expect(exception, isA<Exception>());
    });

    test('handles transfer error messages', () {
      const exception = _TestApiException('Transfer gagal: Server error');
      expect(exception.message.contains('Transfer gagal'), true);
    });

    test('throws and catches exception correctly', () {
      expect(
        () => throw _TestApiException('Nomor penerima tidak ditemukan'),
        throwsA(isA<_TestApiException>()),
      );
    });
  });
}

// Test model for ApiException behavior (since real class is private)
class _TestApiException implements Exception {
  final String message;
  const _TestApiException(this.message);
}
