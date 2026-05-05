import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:frontend_kusaku/config/api_config.dart';

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
}
