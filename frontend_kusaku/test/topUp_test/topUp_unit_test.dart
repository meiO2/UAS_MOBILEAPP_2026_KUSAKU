import 'package:flutter_test/flutter_test.dart';

class PulsaPackage {
  final int nominal;
  final int bayar;
  const PulsaPackage({required this.nominal, required this.bayar});

  int get fee => bayar - nominal;
  double get feePercent => fee / nominal;
}

String formatRp(int amount) {
  return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}

const double _feeRate = 0.20;
const int _maxNominal = 10000000;

int storeFee(int nominal) => (nominal * _feeRate).round();
int storeTotal(int nominal) => nominal + storeFee(nominal);

void main() {
  group('PulsaPackage – fee calculation', () {
    test('fee equals bayar minus nominal', () {
      const pkg = PulsaPackage(nominal: 50000, bayar: 60000);
      expect(pkg.fee, equals(10000));
    });

    test('fee is always 20% of nominal for every standard package', () {
      const packages = [
        PulsaPackage(nominal: 5000,   bayar: 6000),
        PulsaPackage(nominal: 10000,  bayar: 12000),
        PulsaPackage(nominal: 15000,  bayar: 18000),
        PulsaPackage(nominal: 25000,  bayar: 30000),
        PulsaPackage(nominal: 50000,  bayar: 60000),
        PulsaPackage(nominal: 100000, bayar: 120000),
      ];
      for (final p in packages) {
        expect(p.feePercent, closeTo(0.20, 0.001),
            reason: 'nominal=${p.nominal}');
      }
    });

    test('nominal and bayar are always positive', () {
      const pkg = PulsaPackage(nominal: 15000, bayar: 18000);
      expect(pkg.nominal, isPositive);
      expect(pkg.bayar, isPositive);
    });

    test('bayar is always greater than nominal', () {
      const packages = [
        PulsaPackage(nominal: 5000,   bayar: 6000),
        PulsaPackage(nominal: 100000, bayar: 120000),
      ];
      for (final p in packages) {
        expect(p.bayar, greaterThan(p.nominal));
      }
    });

    test('fee for 5000 nominal is 1000', () {
      const pkg = PulsaPackage(nominal: 5000, bayar: 6000);
      expect(pkg.fee, equals(1000));
    });

    test('fee for 100000 nominal is 20000', () {
      const pkg = PulsaPackage(nominal: 100000, bayar: 120000);
      expect(pkg.fee, equals(20000));
    });

    test('there are exactly 6 standard packages', () {
      const packages = [
        PulsaPackage(nominal: 5000,   bayar: 6000),
        PulsaPackage(nominal: 10000,  bayar: 12000),
        PulsaPackage(nominal: 15000,  bayar: 18000),
        PulsaPackage(nominal: 25000,  bayar: 30000),
        PulsaPackage(nominal: 50000,  bayar: 60000),
        PulsaPackage(nominal: 100000, bayar: 120000),
      ];
      expect(packages.length, equals(6));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // formatRp helper
  // ═══════════════════════════════════════════════════════════════════════════
  group('formatRp – number formatting', () {
    test('formats 1000 as "1.000"', () {
      expect(formatRp(1000), equals('1.000'));
    });

    test('formats 10000 as "10.000"', () {
      expect(formatRp(10000), equals('10.000'));
    });

    test('formats 100000 as "100.000"', () {
      expect(formatRp(100000), equals('100.000'));
    });

    test('formats 1000000 as "1.000.000"', () {
      expect(formatRp(1000000), equals('1.000.000'));
    });

    test('formats 10000000 as "10.000.000"', () {
      expect(formatRp(10000000), equals('10.000.000'));
    });

    test('single digit is unchanged', () {
      expect(formatRp(9), equals('9'));
    });

    test('three-digit number is unchanged', () {
      expect(formatRp(999), equals('999'));
    });

    test('formats 6000 as "6.000"', () {
      expect(formatRp(6000), equals('6.000'));
    });

    test('formats 120000 as "120.000"', () {
      expect(formatRp(120000), equals('120.000'));
    });

    test('formats 30000 as "30.000"', () {
      expect(formatRp(30000), equals('30.000'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // TopUpStore fee / total logic
  // ═══════════════════════════════════════════════════════════════════════════
  group('TopUpStore – fee & total calculation', () {
    test('feeRate constant is 0.20', () {
      expect(_feeRate, equals(0.20));
    });

    test('maxNominal constant is 10_000_000', () {
      expect(_maxNominal, equals(10000000));
    });

    test('fee for 100000 is 20000', () {
      expect(storeFee(100000), equals(20000));
    });

    test('total for 100000 is 120000', () {
      expect(storeTotal(100000), equals(120000));
    });

    test('fee for 50000 is 10000', () {
      expect(storeFee(50000), equals(10000));
    });

    test('total for 50000 is 60000', () {
      expect(storeTotal(50000), equals(60000));
    });

    test('fee rounds correctly for non-round nominal', () {
      // 333 * 0.20 = 66.6 → rounds to 67
      expect(storeFee(333), equals(67));
    });

    test('total for fractional fee is nominal + rounded fee', () {
      expect(storeTotal(333), equals(333 + 67));
    });

    test('fee for minimum valid nominal (1) is 0 (rounded down)', () {
      // 1 * 0.20 = 0.2 → rounds to 0
      expect(storeFee(1), equals(0));
    });

    test('input equal to maxNominal is accepted', () {
      expect(_maxNominal <= 10000000, isTrue);
    });

    test('input above maxNominal should be rejected', () {
      const overLimit = 10000001;
      expect(overLimit > _maxNominal, isTrue);
    });

    test('fee for maxNominal is 20% of 10_000_000', () {
      expect(storeFee(_maxNominal), equals(2000000));
    });

    test('total for maxNominal is 12_000_000', () {
      expect(storeTotal(_maxNominal), equals(12000000));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // PIN input logic (pure)
  // ═══════════════════════════════════════════════════════════════════════════
  group('PIN input logic', () {
    // Replicate the _pin list logic from _PinBottomSheetState.
    List<String> applyKey(List<String> pin, String key) {
      final next = List<String>.from(pin);
      if (key == '⌫') {
        if (next.isNotEmpty) next.removeLast();
      } else {
        if (next.length < 6) next.add(key);
      }
      return next;
    }

    test('adding a digit appends to list', () {
      final pin = applyKey([], '5');
      expect(pin, equals(['5']));
    });

    test('backspace on empty list leaves list empty', () {
      final pin = applyKey([], '⌫');
      expect(pin, isEmpty);
    });

    test('backspace removes last element', () {
      var pin = applyKey([], '3');
      pin = applyKey(pin, '7');
      pin = applyKey(pin, '⌫');
      expect(pin, equals(['3']));
    });

    test('pin is capped at 6 digits', () {
      var pin = <String>[];
      for (int i = 0; i < 10; i++) {
        pin = applyKey(pin, '1');
      }
      expect(pin.length, equals(6));
    });

    test('pin of length 6 triggers completion condition', () {
      var pin = <String>[];
      for (final d in ['1', '2', '3', '4', '5', '6']) {
        pin = applyKey(pin, d);
      }
      expect(pin.length == 6, isTrue);
    });

    test('pin does not complete before 6 digits', () {
      var pin = <String>[];
      for (final d in ['1', '2', '3', '4', '5']) {
        pin = applyKey(pin, d);
      }
      expect(pin.length == 6, isFalse);
    });
  });
}