// topup_integration_test.dart
// Integration tests — exercise complete multi-step user flows across pages.
// SharedPreferences is seeded; HTTP calls are expected to fail gracefully
// (network not available in test runner) so flows are asserted up to and
// including the network boundary.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/topup_page.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/topup_pulsa_page.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/topup_store_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Widget _wrap(Widget child) => MaterialApp(home: child);

Future<void> _seedPrefs({
  int userId = 1,
  String phoneNumber = '081234567890',
}) async {
  SharedPreferences.setMockInitialValues({
    'user_id': userId,
    'phone_number': phoneNumber,
  });
}

/// Types all digits of [number] on the store keypad one by one.
Future<void> _typeNominal(WidgetTester tester, String number) async {
  for (final ch in number.split('')) {
    await tester.tap(find.text(ch));
    await tester.pump();
  }
}

/// Enters a 6-digit PIN on the PinBottomSheet.
Future<void> _enterPin(WidgetTester tester,
    [String pin = '123456']) async {
  for (final ch in pin.split('')) {
    await tester.tap(find.text(ch).last);
    await tester.pump();
  }
  // Allow the 300 ms callback delay to fire.
  await tester.pump(const Duration(milliseconds: 400));
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ═══════════════════════════════════════════════════════════════════════════
  // Flow 1 – TopUpPage → Pulsa page navigation
  // ═══════════════════════════════════════════════════════════════════════════
  group('Integration – TopUpPage → Pulsa navigation', () {
    setUp(() async => _seedPrefs());

    testWidgets('landing on TopUpPage shows all methods after prefs load',
        (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPage()));
      await tester.pumpAndSettle();

      expect(find.text('Pulsa'),    findsOneWidget);
      expect(find.text('Alfamart'), findsOneWidget);
      expect(find.text('Indomaret'),findsOneWidget);
      expect(find.text('Lawson'),   findsOneWidget);
    });

    testWidgets('tap Pulsa → arrive on Pulsa page → back → back on TopUpPage',
        (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pulsa'));
      await tester.pumpAndSettle();

      // We are now on TopUpPulsaPage.
      expect(find.text('Fee: 20%'), findsOneWidget);

      // Go back.
      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await tester.pumpAndSettle();

      // Back on TopUpPage.
      expect(find.text('Alfamart'), findsOneWidget);
    });

    testWidgets('tap Alfamart → arrive on StorePage → back → back on TopUpPage',
        (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alfamart'));
      await tester.pumpAndSettle();

      expect(find.text('Nominal Top up'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await tester.pumpAndSettle();

      expect(find.text('Indomaret'), findsOneWidget);
    });

    testWidgets('tap Lawson → arrive on StorePage for Lawson', (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lawson'));
      await tester.pumpAndSettle();

      expect(find.text('Lawson'), findsWidgets);
      expect(find.text('Nominal Top up'), findsOneWidget);
    });

    testWidgets('phone number on TopUpPage reflects prefs value',
        (tester) async {
      await _seedPrefs(phoneNumber: '082211113333');
      await tester.pumpWidget(_wrap(const TopUpPage()));
      await tester.pumpAndSettle();

      expect(find.text('Kode Kusaku: 082211113333'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Flow 2 – TopUpPulsaPage – package selection & confirmation cycle
  // ═══════════════════════════════════════════════════════════════════════════
  group('Integration – TopUpPulsaPage – selection & confirmation', () {
    setUp(() async => _seedPrefs());

    testWidgets(
        'select 5.000 → confirmation shows → back → deselected → select 100.000',
        (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPulsaPage()));
      await tester.pumpAndSettle();

      // Select first package.
      await tester.tap(find.text('5.000'));
      await tester.pump();
      expect(find.text('Konfirmasi Pembayaran'), findsOneWidget);
      expect(find.text('Pulsa 5.000'), findsOneWidget);

      // Go back to deselect.
      await tester.tap(find.byIcon(Icons.arrow_back).last);
      await tester.pump();
      expect(find.text('Konfirmasi Pembayaran'), findsNothing);

      // Select a different package.
      await tester.tap(find.text('100.000'));
      await tester.pump();
      expect(find.text('Pulsa 100.000'), findsOneWidget);
      expect(find.text('Pulsa 5.000'),   findsNothing);
    });

    testWidgets('each package shows correct bayar in confirmation row',
        (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPulsaPage()));
      await tester.pumpAndSettle();

      // Map of nominal label → expected bayar label in confirmation.
      final cases = {
        '10.000': 'Bayar: Rp 12.000',
        '25.000': 'Bayar: Rp 30.000',
        '50.000': 'Bayar: Rp 60.000',
      };

      for (final entry in cases.entries) {
        await tester.tap(find.text(entry.key));
        await tester.pump();
        // The bayar label is inside the grid card.
        expect(find.text(entry.value), findsOneWidget,
            reason: 'Bayar label missing for ${entry.key}');
        // Reset.
        await tester.tap(find.byIcon(Icons.arrow_back).last);
        await tester.pump();
      }
    });

    testWidgets(
        'Konfirmasi button opens PIN sheet when category is loaded '
        '(simulated by pumping without HTTP mock → button disabled)',
        (tester) async {
      // Without a mock HTTP client, _hiburanCategoryId is null → disabled.
      await tester.pumpWidget(_wrap(const TopUpPulsaPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('15.000'));
      await tester.pump();

      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull,
          reason: 'Button must be disabled when category id is null');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Flow 3 – TopUpStorePage – full keypad → confirm → PIN flow
  // ═══════════════════════════════════════════════════════════════════════════
  group('Integration – TopUpStorePage – nominal entry → PIN flow', () {
    Widget buildStore([String name = 'Alfamart']) =>
        _wrap(TopUpStorePage(storeName: name, userId: 1));

    testWidgets('enter 50000 → confirmation panel shows correct values',
        (tester) async {
      await tester.pumpWidget(buildStore());
      await tester.pumpAndSettle();

      await _typeNominal(tester, '50000');

      await tester.tap(find.text('Konfirmasi'));
      await tester.pump();

      expect(find.text('Konfirmasi Pembayaran'), findsOneWidget);
      expect(find.text('Rp 50.000'),  findsOneWidget); // Nominal Top Up
      expect(find.text('Rp 10.000'),  findsOneWidget); // Fee
      expect(find.text('Rp 60.000'),  findsOneWidget); // Total
    });

    testWidgets('enter nominal → confirm → open PIN → enter 6 digits → sheet dismissed',
        (tester) async {
      await tester.pumpWidget(buildStore());
      await tester.pumpAndSettle();

      await _typeNominal(tester, '10000');

      await tester.tap(find.text('Konfirmasi'));
      await tester.pump();

      // Open PIN.
      await tester.tap(find.text('Konfirmasi').last);
      await tester.pump();
      expect(find.text('Masukan PIN'), findsOneWidget);

      // Enter 6 digits.
      await _enterPin(tester);
      await tester.pumpAndSettle();

      // PIN sheet is dismissed.
      expect(find.text('Masukan PIN'), findsNothing);
    });

    testWidgets('back arrow after confirmation resets nominal to empty',
        (tester) async {
      await tester.pumpWidget(buildStore());
      await tester.pumpAndSettle();

      await _typeNominal(tester, '999');

      await tester.tap(find.text('Konfirmasi'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back).last);
      await tester.pump();

      // After reset, nominal display is '0' (placeholder).
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Konfirmasi Pembayaran'), findsNothing);
    });

    testWidgets('entering max nominal (10000000) then one more digit shows snackbar',
        (tester) async {
      await tester.pumpWidget(buildStore());
      await tester.pumpAndSettle();

      // Type 10000000 (8 digits).
      await _typeNominal(tester, '10000000');
      // Try to add one more digit.
      await tester.tap(find.text('1'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Indomaret store page shows Indomaret in confirmation row',
        (tester) async {
      await tester.pumpWidget(buildStore('Indomaret'));
      await tester.pumpAndSettle();

      await _typeNominal(tester, '20000');

      await tester.tap(find.text('Konfirmasi'));
      await tester.pump();

      expect(find.text('Indomaret'), findsWidgets);
    });

    testWidgets('fee and total update when a different nominal is typed after reset',
        (tester) async {
      await tester.pumpWidget(buildStore());
      await tester.pumpAndSettle();

      // First nominal.
      await _typeNominal(tester, '10000');
      await tester.tap(find.text('Konfirmasi'));
      await tester.pump();
      expect(find.text('Rp 2.000'),  findsOneWidget); // fee
      expect(find.text('Rp 12.000'), findsOneWidget); // total

      // Reset.
      await tester.tap(find.byIcon(Icons.arrow_back).last);
      await tester.pump();

      // Second nominal.
      await _typeNominal(tester, '50000');
      await tester.tap(find.text('Konfirmasi'));
      await tester.pump();

      expect(find.text('Rp 10.000'), findsOneWidget); // fee
      expect(find.text('Rp 60.000'), findsOneWidget); // total
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Flow 4 – PIN sheet within Pulsa & Store pages
  // ═══════════════════════════════════════════════════════════════════════════
  group('Integration – PinBottomSheet within pages', () {
    testWidgets(
        'store page: partial PIN (< 6 digits) does not dismiss sheet',
        (tester) async {
      await tester.pumpWidget(
          _wrap(const TopUpStorePage(storeName: 'Alfamart', userId: 1)));
      await tester.pumpAndSettle();

      await _typeNominal(tester, '5');
      await tester.tap(find.text('Konfirmasi'));
      await tester.pump();
      await tester.tap(find.text('Konfirmasi').last);
      await tester.pump();

      // Enter only 3 digits.
      for (final k in ['1', '2', '3']) {
        await tester.tap(find.text(k).last);
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 400));

      // Sheet still visible.
      expect(find.text('Masukan PIN'), findsOneWidget);
    });

    testWidgets('store page: backspace in PIN sheet works correctly',
        (tester) async {
      await tester.pumpWidget(
          _wrap(const TopUpStorePage(storeName: 'Alfamart', userId: 1)));
      await tester.pumpAndSettle();

      await _typeNominal(tester, '5');
      await tester.tap(find.text('Konfirmasi'));
      await tester.pump();
      await tester.tap(find.text('Konfirmasi').last);
      await tester.pump();

      // Type 2 digits, backspace once, type 5 more → should still reach 6.
      for (final k in ['1', '2']) {
        await tester.tap(find.text(k).last);
        await tester.pump();
      }
      await tester.tap(find.text('⌫'));
      await tester.pump();
      // Now 1 digit in pin.
      for (final k in ['2', '3', '4', '5', '6']) {
        await tester.tap(find.text(k).last);
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      // Sheet dismissed after 6 digits.
      expect(find.text('Masukan PIN'), findsNothing);
    });
  });
}