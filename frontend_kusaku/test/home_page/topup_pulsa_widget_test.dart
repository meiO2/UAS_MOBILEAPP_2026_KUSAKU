import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/topup_pulsa_page.dart';

Future<void> _pumpPage(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: TopUpPulsaPage()));
  await tester.pump();
}

void main() {
  group('TopUpPulsa - widget', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'user_id': 77,
        'phone_number': '081233344455',
      });
    });

    testWidgets('select a package and see confirmation panel', (tester) async {
      await _pumpPage(tester);

      // Tap on a package (5.000)
      await tester.tap(find.text('5.000').first);
      await tester.pumpAndSettle();

      // Confirmation panel should be visible
      expect(find.text('Konfirmasi Pembayaran'), findsOneWidget);
      expect(find.textContaining('Produk'), findsOneWidget);
      expect(find.textContaining('Pulsa 5.000'), findsOneWidget);
    });
  });
}
