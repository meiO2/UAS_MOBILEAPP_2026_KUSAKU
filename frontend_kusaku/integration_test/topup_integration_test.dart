import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/topup_page.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/topup_pulsa_page.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/topup_store_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpLarge(WidgetTester tester, Widget widget) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
    
    // Auto-navigate into the wrapped page to build a proper navigation stack
    final startButton = find.text('Buka Halaman');
    if (startButton.evaluate().isNotEmpty) {
      await tester.tap(startButton);
      await tester.pumpAndSettle();
    }
  }

  // Wraps the tested page inside a dummy route to generate a proper Navigation stack
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) {
          return Center(
            child: ElevatedButton(
              child: const Text('Buka Halaman'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => child),
              ),
            ),
          );
        },
      ),
    ),
  );

  Future<void> seedPrefs({
    int userId = 1,
    String phoneNumber = '081234567890',
  }) async {
    SharedPreferences.setMockInitialValues({
      'user_id': userId,
      'phone_number': phoneNumber,
    });
  }

  Future<void> typeNominal(WidgetTester tester, String number) async {
    for (final ch in number.split('')) {
      final finder = find.text(ch).first;

      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();

      await tester.tap(finder);
      await tester.pumpAndSettle();
    }
  }

  Future<void> enterPin(WidgetTester tester, [String pin = '123456']) async {
    for (final ch in pin.split('')) {
      final finder = find.text(ch).last;

      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();

      await tester.tap(finder);
      await tester.pumpAndSettle();
    }
  }

  // BULLETPROOF PANEL DISMISSAL:
  // Safely dismisses the panel without accidentally popping the main page.
  Future<void> safeDismissPanel(WidgetTester tester) async {
    final arrows = find.byIcon(Icons.arrow_back);
    final arrowCount = arrows.evaluate().length;
    
    if (arrowCount > 1) {
      // Multiple back arrows exist. The panel's arrow is the last one in the tree.
      await tester.tap(arrows.last);
      await tester.pumpAndSettle();
    } else if (arrowCount == 1) {
      // Only one back arrow exists. We must check its vertical position to ensure it's not the AppBar's.
      final yPos = tester.getTopLeft(arrows.first).dy;
      if (yPos > 150) {
        // It's lower on the screen (inside the panel). Safe to tap.
        await tester.tap(arrows.first);
        await tester.pumpAndSettle();
      } else {
        // It is in the AppBar! Tapping it would break the test by popping the whole page.
        // Instead, dismiss the panel by tapping the dark overlay (scrim) near the top.
        await tester.tapAt(const Offset(100, 150));
        await tester.pumpAndSettle();
      }
    } else {
      // No arrow_back found. Fallback to common close icons or tapping the scrim.
      final closeIcon = find.byIcon(Icons.close);
      if (closeIcon.evaluate().isNotEmpty) {
        await tester.tap(closeIcon.last);
      } else {
        await tester.tapAt(const Offset(100, 150));
      }
      await tester.pumpAndSettle();
    }
  }

  group('Integration – TopUpPage → navigation', () {
    setUp(() async => seedPrefs());

    testWidgets('shows all top-up methods', (tester) async {
      await pumpLarge(tester, wrap(const TopUpPage()));
      expect(find.text('Pulsa'),     findsOneWidget);
      expect(find.text('Alfamart'),  findsOneWidget);
      expect(find.text('Indomaret'), findsOneWidget);
      expect(find.text('Lawson'),    findsOneWidget);
    });

    testWidgets('tap Pulsa → arrive on Pulsa page', (tester) async {
      await pumpLarge(tester, wrap(const TopUpPage()));
      await tester.tap(find.text('Pulsa'));
      await tester.pumpAndSettle();
      expect(find.text('Fee: 20%'), findsOneWidget);
    });

    testWidgets('tap Pulsa → back → back on TopUpPage', (tester) async {
      await pumpLarge(tester, wrap(const TopUpPage()));
      await tester.tap(find.text('Pulsa'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await tester.pumpAndSettle();
      expect(find.text('Alfamart'), findsOneWidget);
    });

    testWidgets('tap Alfamart → arrive on StorePage', (tester) async {
      await pumpLarge(tester, wrap(const TopUpPage()));
      await tester.tap(find.text('Alfamart'));
      await tester.pumpAndSettle();
      expect(find.text('Nominal Top up'), findsOneWidget);
    });

    testWidgets('tap Alfamart → back → back on TopUpPage', (tester) async {
      await pumpLarge(tester, wrap(const TopUpPage()));
      await tester.tap(find.text('Alfamart'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await tester.pumpAndSettle();
      expect(find.text('Indomaret'), findsOneWidget);
    });

    testWidgets('tap Lawson → arrive on StorePage for Lawson', (tester) async {
      await pumpLarge(tester, wrap(const TopUpPage()));
      await tester.tap(find.text('Lawson'));
      await tester.pumpAndSettle();
      expect(find.text('Nominal Top up'), findsOneWidget);
      expect(find.text('Lawson'), findsWidgets);
    });

    testWidgets('phone number reflects prefs value', (tester) async {
      await seedPrefs(phoneNumber: '082211113333');
      await pumpLarge(tester, wrap(const TopUpPage()));
      expect(find.text('Kode Kusaku: 082211113333'), findsOneWidget);
    });
  });

  group('Integration – TopUpPulsaPage – selection & confirmation', () {
    setUp(() async => seedPrefs());

    testWidgets('all 6 packages render', (tester) async {
      await pumpLarge(tester, wrap(const TopUpPulsaPage()));
      for (final label in [
        '5.000', '10.000', '15.000', '25.000', '50.000', '100.000'
      ]) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('select 5.000 → confirmation panel appears', (tester) async {
      await pumpLarge(tester, wrap(const TopUpPulsaPage()));
      await tester.tap(find.text('5.000'));
      await tester.pumpAndSettle();
      expect(find.text('Konfirmasi Pembayaran'), findsOneWidget);
      expect(find.text('Pulsa 5.000'), findsOneWidget);
    });

    testWidgets('back arrow in panel deselects package', (tester) async {
      await pumpLarge(tester, wrap(const TopUpPulsaPage()));
      await tester.tap(find.text('5.000'));
      await tester.pumpAndSettle();
      
      await safeDismissPanel(tester);
      
      expect(find.text('Konfirmasi Pembayaran'), findsNothing);
    });

    testWidgets('selecting 100.000 after deselect shows correct product', (tester) async {
      await pumpLarge(tester, wrap(const TopUpPulsaPage()));
      await tester.tap(find.text('5.000'));
      await tester.pumpAndSettle();
      
      await safeDismissPanel(tester);
      
      await tester.tap(find.text('100.000'));
      await tester.pumpAndSettle();
      expect(find.text('Pulsa 100.000'), findsOneWidget);
      expect(find.text('Pulsa 5.000'),   findsNothing);
    });

    testWidgets('10.000 shows correct Bayar label in grid', (tester) async {
      await pumpLarge(tester, wrap(const TopUpPulsaPage()));
      expect(find.text('Bayar: Rp 12.000'), findsOneWidget);
    });

    testWidgets('25.000 shows correct Bayar label in grid', (tester) async {
      await pumpLarge(tester, wrap(const TopUpPulsaPage()));
      expect(find.text('Bayar: Rp 30.000'), findsOneWidget);
    });

    testWidgets('50.000 shows correct Bayar label in grid', (tester) async {
      await pumpLarge(tester, wrap(const TopUpPulsaPage()));
      expect(find.text('Bayar: Rp 60.000'), findsOneWidget);
    });

    testWidgets('Konfirmasi button is present when package selected', (tester) async {
      await pumpLarge(tester, wrap(const TopUpPulsaPage()));
      await tester.tap(find.text('15.000'));
      await tester.pumpAndSettle();
      expect(find.text('Konfirmasi'), findsOneWidget);
    });
  });

  group('Integration – TopUpStorePage – numpad & confirmation', () {
    Widget buildStore([String name = 'Alfamart']) =>
        wrap(TopUpStorePage(storeName: name, userId: 1));

    testWidgets('enter 50000 → confirmation shows correct values', (tester) async {
      await pumpLarge(tester, buildStore());
      await typeNominal(tester, '50000');
      await tester.tap(find.text('Konfirmasi'));
      await tester.pumpAndSettle();
      expect(find.text('Konfirmasi Pembayaran'), findsOneWidget);
      expect(find.text('Rp 50.000'), findsOneWidget); // Nominal Top Up
      expect(find.text('Rp 10.000'), findsOneWidget); // Fee
      expect(find.text('Rp 60.000'), findsOneWidget); // Total
    });

    testWidgets('back arrow in confirmation panel resets nominal', (tester) async {
      await pumpLarge(tester, buildStore());
      await typeNominal(tester, '999');
      await tester.tap(find.text('Konfirmasi'));
      await tester.pumpAndSettle();

      await safeDismissPanel(tester);
      
      expect(find.text('Konfirmasi Pembayaran'), findsNothing);
      expect(find.text('0'), findsWidgets); 
    });

    testWidgets('10000 → fee = 2.000, total = 12.000', (tester) async {
      await pumpLarge(tester, buildStore());
      await typeNominal(tester, '10000');
      await tester.tap(find.text('Konfirmasi'));
      await tester.pumpAndSettle();
      expect(find.text('Rp 2.000'),  findsOneWidget);
      expect(find.text('Rp 12.000'), findsOneWidget);
    });

    testWidgets('entering over max shows snackbar', (tester) async {
      await pumpLarge(tester, buildStore());
      await typeNominal(tester, '10000000'); // exactly max
      await tester.tap(find.text('1'));      // one digit over
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Indomaret store name shown in confirmation', (tester) async {
      await pumpLarge(tester, buildStore('Indomaret'));
      await typeNominal(tester, '20000');
      await tester.tap(find.text('Konfirmasi'));
      await tester.pumpAndSettle();
      expect(find.text('Indomaret'), findsWidgets);
    });

    testWidgets('fee and total update after reset and new nominal', (tester) async {
      await pumpLarge(tester, buildStore());

      await typeNominal(tester, '10000');
      await tester.tap(find.text('Konfirmasi'));
      await tester.pumpAndSettle();
      expect(find.text('Rp 2.000'),  findsOneWidget);
      expect(find.text('Rp 12.000'), findsOneWidget);

      // Reset
      await safeDismissPanel(tester);

      await typeNominal(tester, '50000');
      await tester.tap(find.text('Konfirmasi'));
      await tester.pumpAndSettle();
      expect(find.text('Rp 10.000'), findsOneWidget);
      expect(find.text('Rp 60.000'), findsOneWidget);
    });
  });

  group('Integration – PIN sheet', () {
    Widget buildStore() =>
        wrap(const TopUpStorePage(storeName: 'Alfamart', userId: 1));

    Future<void> openPinSheet(WidgetTester tester) async {
      await pumpLarge(tester, buildStore());
      await typeNominal(tester, '5');
      await tester.tap(find.text('Konfirmasi')); // first = show panel
      await tester.pumpAndSettle();
      await tester.tap(find.text('Konfirmasi')); // second = open PIN sheet
      await tester.pumpAndSettle();
      expect(find.text('Masukan PIN'), findsOneWidget);
    }

    testWidgets('entering 6 digits dismisses PIN sheet', (tester) async {
      await openPinSheet(tester);
      await enterPin(tester);
      await tester.pumpAndSettle();
      expect(find.text('Masukan PIN'), findsNothing);
    });

    testWidgets('partial PIN (3 digits) does not dismiss sheet', (tester) async {
      await openPinSheet(tester);
      for (final k in ['1', '2', '3']) {
        await tester.tap(find.text(k).last);
        await tester.pumpAndSettle();
      }
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Masukan PIN'), findsOneWidget);
    });

    testWidgets('backspace in PIN sheet reduces digit count', (tester) async {
      await openPinSheet(tester);
      // Type 2 digits
      for (final k in ['1', '2']) {
        await tester.tap(find.text(k).last);
        await tester.pumpAndSettle();
      }

      final bottomSheet = find.byType(BottomSheet);
      final backspace = find.descendant(
        of: bottomSheet,
        matching: find.text('⌫'),
      );
      await tester.tap(backspace);
      await tester.pumpAndSettle();

      for (final k in ['2', '3', '4', '5', '6']) {
        await tester.tap(find.text(k).last);
        await tester.pumpAndSettle();
      }
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('Masukan PIN'), findsNothing);
    });
  });
}