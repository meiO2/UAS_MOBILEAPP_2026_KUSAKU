// topup_widget_test.dart
// Widget tests — render widgets in isolation, assert UI state.
// No real HTTP or SharedPreferences; mocked values are seeded before each group.

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ═══════════════════════════════════════════════════════════════════════════
  // TopUpPage
  // ═══════════════════════════════════════════════════════════════════════════
  group('Widget – TopUpPage', () {
    setUp(() async => _seedPrefs());

    testWidgets('renders AppBar with "Top Up" title', (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPage()));
      await tester.pump();
      expect(find.text('Top Up'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator before prefs load',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_wrap(const TopUpPage()));
      // Before pumpAndSettle the async _loadUser has not completed.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows "Kode Kusaku:" prefix', (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPage()));
      await tester.pumpAndSettle();
      expect(find.textContaining('Kode Kusaku:'), findsOneWidget);
    });

    testWidgets('shows phone number from SharedPreferences', (tester) async {
      await _seedPrefs(phoneNumber: '089900001111');
      await tester.pumpWidget(_wrap(const TopUpPage()));
      await tester.pumpAndSettle();
      expect(find.text('Kode Kusaku: 089900001111'), findsOneWidget);
    });

    testWidgets('shows fallback dash when phone_number key is absent',
        (tester) async {
      SharedPreferences.setMockInitialValues({'user_id': 1});
      await tester.pumpWidget(_wrap(const TopUpPage()));
      await tester.pumpAndSettle();
      expect(find.text('Kode Kusaku: -'), findsOneWidget);
    });

    testWidgets('renders all four method labels', (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPage()));
      await tester.pumpAndSettle();
      for (final label in ['Pulsa', 'Alfamart', 'Indomaret', 'Lawson']) {
        expect(find.text(label), findsOneWidget, reason: 'Missing: $label');
      }
    });

    testWidgets('four circular icon containers are present', (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPage()));
      await tester.pumpAndSettle();
      final circles = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) =>
              c.decoration is BoxDecoration &&
              (c.decoration as BoxDecoration).shape == BoxShape.circle)
          .length;
      expect(circles, greaterThanOrEqualTo(4));
    });

    testWidgets('tapping Pulsa navigates to TopUpPulsaPage', (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPage()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pulsa'));
      await tester.pumpAndSettle();
      expect(find.text('Fee: 20%'), findsOneWidget);
    });

    testWidgets('tapping Alfamart navigates to TopUpStorePage', (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPage()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alfamart'));
      await tester.pumpAndSettle();
      expect(find.text('Nominal Top up'), findsOneWidget);
    });

    testWidgets('tapping Indomaret navigates to TopUpStorePage',
        (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPage()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Indomaret'));
      await tester.pumpAndSettle();
      expect(find.text('Indomaret'), findsWidgets);
    });

    testWidgets('tapping Lawson navigates to TopUpStorePage', (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPage()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lawson'));
      await tester.pumpAndSettle();
      expect(find.text('Lawson'), findsWidgets);
    });

    testWidgets('AppBar back button pops the page', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Navigator(
          onGenerateRoute: (_) =>
              MaterialPageRoute(builder: (_) => const TopUpPage()),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await tester.pumpAndSettle();
      expect(find.text('Pulsa'), findsNothing);
    });

    testWidgets('blue container background color is correct', (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPage()));
      await tester.pumpAndSettle();
      final blueContainers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) =>
              c.decoration is BoxDecoration &&
              (c.decoration as BoxDecoration).color ==
                  const Color(0xFF1D4ED8))
          .length;
      expect(blueContainers, greaterThanOrEqualTo(1));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // TopUpPulsaPage
  // ═══════════════════════════════════════════════════════════════════════════
  group('Widget – TopUpPulsaPage', () {
    setUp(() async => _seedPrefs(phoneNumber: '081298765432'));

    testWidgets('renders AppBar with "Pulsa" title', (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPulsaPage()));
      await tester.pump();
      expect(find.text('Pulsa'), findsOneWidget);
    });

    testWidgets('shows phone number from SharedPreferences', (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPulsaPage()));
      await tester.pumpAndSettle();
      expect(find.text('081298765432'), findsOneWidget);
    });

    testWidgets('shows "Fee: 20%" label', (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPulsaPage()));
      await tester.pumpAndSettle();
      expect(find.text('Fee: 20%'), findsOneWidget);
    });

    testWidgets('shows "Pemilihan paket pulsa" heading', (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPulsaPage()));
      await tester.pumpAndSettle();
      expect(find.text('Pemilihan paket pulsa'), findsOneWidget);
    });

    testWidgets('renders all 6 package nominal labels', (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPulsaPage()));
      await tester.pumpAndSettle();
      for (final n in [
        '5.000',
        '10.000',
        '15.000',
        '25.000',
        '50.000',
        '100.000'
      ]) {
        expect(find.text(n), findsOneWidget, reason: 'Missing nominal $n');
      }
    });

    testWidgets('renders bayar labels for each package', (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPulsaPage()));
      await tester.pumpAndSettle();
      expect(find.textContaining('Bayar: Rp'), findsNWidgets(6));
    });

    testWidgets('no confirmation panel before a package is selected',
        (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPulsaPage()));
      await tester.pumpAndSettle();
      expect(find.text('Konfirmasi Pembayaran'), findsNothing);
    });

    testWidgets('selecting a package shows confirmation panel', (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPulsaPage()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5.000'));
      await tester.pump();
      expect(find.text('Konfirmasi Pembayaran'), findsOneWidget);
    });

    testWidgets('product row shows correct package nominal', (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPulsaPage()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('25.000'));
      await tester.pump();
      expect(find.text('Pulsa 25.000'), findsOneWidget);
    });

    testWidgets('confirmation panel shows "Metode Pembayaran: Kusaku"',
        (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPulsaPage()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10.000'));
      await tester.pump();
      expect(find.text('Kusaku'), findsOneWidget);
    });

    testWidgets('back arrow in confirmation panel resets selection',
        (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPulsaPage()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5.000'));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_back).last);
      await tester.pump();
      expect(find.text('Konfirmasi Pembayaran'), findsNothing);
    });

    testWidgets('switching package updates product label', (tester) async {
      await tester.pumpWidget(_wrap(const TopUpPulsaPage()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5.000'));
      await tester.pump();
      await tester.tap(find.text('100.000'));
      await tester.pump();
      expect(find.text('Pulsa 100.000'), findsOneWidget);
      expect(find.text('Pulsa 5.000'), findsNothing);
    });

    testWidgets(
        'Konfirmasi button is disabled when hiburanCategoryId is null',
        (tester) async {
      // No HTTP mock → category fetch fails silently → button disabled.
      await tester.pumpWidget(_wrap(const TopUpPulsaPage()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5.000'));
      await tester.pump();
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // PinBottomSheet
  // ═══════════════════════════════════════════════════════════════════════════
  group('Widget – PinBottomSheet', () {
    Widget buildPin({required VoidCallback onSuccess}) =>
        _wrap(Scaffold(body: PinBottomSheet(onSuccess: onSuccess)));

    testWidgets('renders "Masukan PIN" title', (tester) async {
      await tester.pumpWidget(buildPin(onSuccess: () {}));
      expect(find.text('Masukan PIN'), findsOneWidget);
    });

    testWidgets('renders digits 1-9 and 0', (tester) async {
      await tester.pumpWidget(buildPin(onSuccess: () {}));
      for (final k in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']) {
        expect(find.text(k), findsOneWidget, reason: 'Missing key $k');
      }
    });

    testWidgets('renders backspace key', (tester) async {
      await tester.pumpWidget(buildPin(onSuccess: () {}));
      expect(find.text('⌫'), findsOneWidget);
    });

    testWidgets('typing a digit shows a masked dot', (tester) async {
      await tester.pumpWidget(buildPin(onSuccess: () {}));
      await tester.tap(find.text('3'));
      await tester.pump();
      expect(find.text('*'), findsOneWidget);
    });

    testWidgets('backspace removes the last digit', (tester) async {
      await tester.pumpWidget(buildPin(onSuccess: () {}));
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.text('⌫'));
      await tester.pump();
      expect(find.text('*'), findsNothing);
    });

    testWidgets('6 digits triggers onSuccess after delay', (tester) async {
      bool called = false;
      await tester.pumpWidget(buildPin(onSuccess: () => called = true));
      for (final k in ['1', '2', '3', '4', '5', '6']) {
        await tester.tap(find.text(k).last);
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 350));
      expect(called, isTrue);
    });

    testWidgets('onSuccess not fired for fewer than 6 digits', (tester) async {
      bool called = false;
      await tester.pumpWidget(buildPin(onSuccess: () => called = true));
      for (final k in ['1', '2', '3', '4', '5']) {
        await tester.tap(find.text(k).last);
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 350));
      expect(called, isFalse);
    });

    testWidgets('more than 6 taps fires onSuccess exactly once',
        (tester) async {
      int callCount = 0;
      await tester.pumpWidget(buildPin(onSuccess: () => callCount++));
      for (int i = 0; i < 9; i++) {
        await tester.tap(find.text('1'));
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 350));
      expect(callCount, equals(1));
    });

    testWidgets('six asterisk dots are visible after full pin entry',
        (tester) async {
      await tester.pumpWidget(buildPin(onSuccess: () {}));
      for (final k in ['1', '2', '3', '4', '5', '6']) {
        await tester.tap(find.text(k).last);
        await tester.pump();
      }
      expect(find.text('*'), findsNWidgets(6));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // TopUpStorePage
  // ═══════════════════════════════════════════════════════════════════════════
  group('Widget – TopUpStorePage', () {
    const userId = 42;

    Widget buildStore(String storeName) =>
        _wrap(TopUpStorePage(storeName: storeName, userId: userId));

    testWidgets('renders AppBar with "Top up" title', (tester) async {
      await tester.pumpWidget(buildStore('Alfamart'));
      expect(find.text('Top up'), findsOneWidget);
    });

    testWidgets('shows store name in body header', (tester) async {
      await tester.pumpWidget(buildStore('Indomaret'));
      await tester.pumpAndSettle();
      expect(find.text('Indomaret'), findsWidgets);
    });

    testWidgets('shows "Nominal Top up" label', (tester) async {
      await tester.pumpWidget(buildStore('Alfamart'));
      expect(find.text('Nominal Top up'), findsOneWidget);
    });

    testWidgets('initial nominal display is "0"', (tester) async {
      await tester.pumpWidget(buildStore('Alfamart'));
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('keypad digits are rendered', (tester) async {
      await tester.pumpWidget(buildStore('Alfamart'));
      for (final k in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']) {
        expect(find.text(k), findsOneWidget);
      }
      expect(find.text('⌫'), findsOneWidget);
    });

    testWidgets('typing updates the nominal display', (tester) async {
      await tester.pumpWidget(buildStore('Alfamart'));
      await tester.pumpAndSettle();
      for (final k in ['1', '0', '0', '0', '0']) {
        await tester.tap(find.text(k));
        await tester.pump();
      }
      expect(find.text('10.000'), findsOneWidget);
    });

    testWidgets('backspace deletes last digit', (tester) async {
      await tester.pumpWidget(buildStore('Alfamart'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('⌫'));
      await tester.pump();
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('Konfirmasi button appears after non-zero nominal',
        (tester) async {
      await tester.pumpWidget(buildStore('Alfamart'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5'));
      await tester.pump();
      expect(find.text('Konfirmasi'), findsOneWidget);
    });

    testWidgets('Konfirmasi button absent when nominal is zero', (tester) async {
      await tester.pumpWidget(buildStore('Alfamart'));
      await tester.pumpAndSettle();
      expect(find.text('Konfirmasi'), findsNothing);
    });

    testWidgets('tapping Konfirmasi shows confirmation panel', (tester) async {
      await tester.pumpWidget(buildStore('Alfamart'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('Konfirmasi'));
      await tester.pump();
      expect(find.text('Konfirmasi Pembayaran'), findsOneWidget);
    });

    testWidgets('confirmation panel shows Metode Top Up row', (tester) async {
      await tester.pumpWidget(buildStore('Alfamart'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('Konfirmasi'));
      await tester.pump();
      expect(find.text('Metode Top Up'), findsOneWidget);
    });

    testWidgets('confirmation panel shows Fee row', (tester) async {
      await tester.pumpWidget(buildStore('Alfamart'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('Konfirmasi'));
      await tester.pump();
      expect(find.text('Fee'), findsOneWidget);
    });

    testWidgets('confirmation panel shows Total Pembayaran row',
        (tester) async {
      await tester.pumpWidget(buildStore('Alfamart'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('Konfirmasi'));
      await tester.pump();
      expect(find.text('Total Pembayaran'), findsOneWidget);
    });

    testWidgets('back arrow in confirmation panel resets state', (tester) async {
      await tester.pumpWidget(buildStore('Alfamart'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('Konfirmasi'));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_back).last);
      await tester.pump();
      expect(find.text('Konfirmasi Pembayaran'), findsNothing);
    });

    testWidgets('tapping final Konfirmasi opens PIN sheet', (tester) async {
      await tester.pumpWidget(buildStore('Alfamart'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('Konfirmasi'));
      await tester.pump();
      await tester.tap(find.text('Konfirmasi').last);
      await tester.pump();
      expect(find.text('Masukan PIN'), findsOneWidget);
    });

    testWidgets('store name appears in confirmation Metode row',
        (tester) async {
      await tester.pumpWidget(buildStore('Lawson'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('9'));
      await tester.pump();
      await tester.tap(find.text('Konfirmasi'));
      await tester.pump();
      // "Lawson" appears as both header and in the detail row.
      expect(find.text('Lawson'), findsWidgets);
    });

    testWidgets('snackbar shown when nominal exceeds 10_000_000',
        (tester) async {
      await tester.pumpWidget(buildStore('Alfamart'));
      await tester.pumpAndSettle();

      // Build a nominal just at the limit first (10 digits).
      // Type "1" then seven "0"s = 10000000.
      await tester.tap(find.text('1'));
      await tester.pump();
      for (int i = 0; i < 7; i++) {
        await tester.tap(find.text('0'));
        await tester.pump();
      }
      // One more digit would exceed the limit.
      await tester.tap(find.text('1'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}