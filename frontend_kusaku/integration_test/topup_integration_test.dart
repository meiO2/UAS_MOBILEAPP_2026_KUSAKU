import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/topup_page.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/topup_pulsa_page.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/topup_store_page.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('TopUpPage Integration Test', () {
    setUp(() async {
      // Mock SharedPreferences BEFORE widget loads
      SharedPreferences.setMockInitialValues({
        'user_id': 123,
        'phone_number': '08123456789',
      });
    });

    testWidgets('Full flow test', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TopUpPage(),
        ),
      );

      // Wait for async load (_loadUser)
      await tester.pumpAndSettle();

      // ✅ Check if Kusaku code is displayed
      expect(find.text('Kode Kusaku: 08123456789'), findsOneWidget);

      // ✅ Check buttons exist
      expect(find.text('Pulsa'), findsOneWidget);
      expect(find.text('Alfamart'), findsOneWidget);
      expect(find.text('Indomaret'), findsOneWidget);
      expect(find.text('Lawson'), findsOneWidget);

      // =========================
      // 🔹 TEST NAVIGATION: Pulsa
      // =========================
      await tester.tap(find.text('Pulsa'));
      await tester.pumpAndSettle();

      expect(find.byType(TopUpPulsaPage), findsOneWidget);

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // =========================
      // 🔹 TEST NAVIGATION: Alfamart
      // =========================
      await tester.tap(find.text('Alfamart'));
      await tester.pumpAndSettle();

      expect(find.byType(TopUpStorePage), findsOneWidget);

      // Optional: verify parameter (if UI shows it)
      expect(find.textContaining('Alfamart'), findsWidgets);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // =========================
      // 🔹 TEST NAVIGATION: Indomaret
      // =========================
      await tester.tap(find.text('Indomaret'));
      await tester.pumpAndSettle();

      expect(find.byType(TopUpStorePage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // =========================
      // 🔹 TEST NAVIGATION: Lawson
      // =========================
      await tester.tap(find.text('Lawson'));
      await tester.pumpAndSettle();

      expect(find.byType(TopUpStorePage), findsOneWidget);
    });
  });
}