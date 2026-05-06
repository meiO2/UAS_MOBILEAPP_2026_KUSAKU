import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TopUpStore - unit', () {
    String formatRp(int amount) {
      return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    }

    test('formats numbers with thousands separators', () {
      expect(formatRp(0), '0');
      expect(formatRp(500), '500');
      expect(formatRp(1000), '1.000');
      expect(formatRp(750000), '750.000');
    });

    test('fee and total calculations (20% fee)', () {
      const feeRate = 0.20;
      int nominal = 100000;
      final fee = (nominal * feeRate).round();
      final total = nominal + fee;

      expect(fee, 20000);
      expect(total, 120000);
    });

    test('store image path uses lowercase store name', () {
      String imagePathFor(String store) => 'assets/images/topup/${store.toLowerCase()}.png';

      expect(imagePathFor('Alfamart'), 'assets/images/topup/alfamart.png');
      expect(imagePathFor('Indomaret'), 'assets/images/topup/indomaret.png');
    });
  });
}
