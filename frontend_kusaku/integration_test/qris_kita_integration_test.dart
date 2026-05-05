import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/qris_kita_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp({int userId = 1}) {
    return MaterialApp(
      home: QrisKitaPage(userId: userId),
    );
  }

  // ── 1. Initial render ──────────────────────────────────────────────────────
  group('Initial render', () {
    testWidgets('shows AppBar title "Qris Kita"', (tester) async {
      await tester.pumpWidget(buildApp(userId: 7));
      await tester.pumpAndSettle();
      expect(find.text('Qris Kita'), findsOneWidget);
    });

    testWidgets('shows subtitle text', (tester) async {
      await tester.pumpWidget(buildApp(userId: 7));
      await tester.pumpAndSettle();
      expect(find.text('Tinggal Scan dan Bayar'), findsOneWidget);
    });

    testWidgets('shows back arrow icon', (tester) async {
      await tester.pumpWidget(buildApp(userId: 7));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('renders without exception for userId 42', (tester) async {
      await tester.pumpWidget(buildApp(userId: 42));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without exception for userId 0', (tester) async {
      await tester.pumpWidget(buildApp(userId: 0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  // ── 2. AppBar appearance ───────────────────────────────────────────────────
  group('AppBar appearance', () {
    testWidgets('AppBar has correct blue background', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, const Color(0xFF1D4ED8));
    });

    testWidgets('Scaffold background is white', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.white);
    });
  });

  // ── 3. Back navigation ─────────────────────────────────────────────────────
  group('Back navigation', () {
    testWidgets('tapping back arrow pops QrisKitaPage', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(body: Text('Home')),
        ),
      );
      await tester.pumpAndSettle();

      tester.state<NavigatorState>(find.byType(Navigator)).push(
            MaterialPageRoute(
              builder: (_) => const QrisKitaPage(userId: 1),
            ),
          );
      await tester.pumpAndSettle();

      expect(find.text('Qris Kita'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Qris Kita'), findsNothing);
    });
  });
}