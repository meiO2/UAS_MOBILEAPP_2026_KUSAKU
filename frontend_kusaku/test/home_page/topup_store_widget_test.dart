import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/topup_store_page.dart';

Future<void> _pumpPage(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: TopUpStorePage(storeName: 'Alfamart', userId: 1)));
  await tester.pump();
}

void main() {
  group('TopUpStore - widget', () {
    testWidgets('enter nominal and show confirmation panel', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pumpPage(tester);

      // Tap digits 1 0 0 0 => 1000
      await tester.tap(find.text('1').first);
      await tester.pump();
      await tester.tap(find.text('0').first);
      await tester.pump();
      await tester.tap(find.text('0').first);
      await tester.pump();
      await tester.tap(find.text('0').first);
      await tester.pumpAndSettle();

      // Konfirmasi button should appear and be tappable
      final confirmBtn = find.widgetWithText(ElevatedButton, 'Konfirmasi').first;
      expect(confirmBtn, findsOneWidget);

      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Confirmation panel should show details
      expect(find.text('Konfirmasi Pembayaran'), findsOneWidget);
      expect(find.textContaining('Nominal Top Up'), findsOneWidget);
      expect(find.textContaining('Metode Top Up'), findsOneWidget);
      // check formatted nominal shows '1.000' somewhere
      expect(find.textContaining('1.000'), findsWidgets);
    });
  });
}
