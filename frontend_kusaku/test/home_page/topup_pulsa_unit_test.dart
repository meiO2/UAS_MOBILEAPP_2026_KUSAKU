import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TopUpPulsa - unit', () {
    String formatRp(int amount) {
      return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    }

    test('formats pulsa package values', () {
      expect(formatRp(5000), '5.000');
      expect(formatRp(10000), '10.000');
      expect(formatRp(15000), '15.000');
    });

    test('package list contains nominal and bayar pairs', () {
      final packages = [
        {'nominal': 5000, 'bayar': 6000},
        {'nominal': 10000, 'bayar': 12000},
      ];

      expect(packages.length, 2);
      expect(packages[0]['bayar'], 6000);
      expect(packages[1]['nominal'], 10000);
    });
  });
}
