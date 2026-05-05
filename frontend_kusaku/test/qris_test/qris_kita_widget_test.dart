import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/qris_kita_page.dart';

void main() {
  // Helper to fix the RenderFlex overflow by simulating a taller screen
  void setTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    
    // Reset the screen size after the test finishes
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  // Helper
  Widget buildSubject(WidgetTester tester, {int userId = 1}) {
    setTallScreen(tester); // Apply tall screen to our subject
    return MaterialApp(
      home: QrisKitaPage(userId: userId),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  group('AppBar', () {
    testWidgets('shows title "Qris Kita"', (tester) async {
      await tester.pumpWidget(buildSubject(tester));
      expect(find.text('Qris Kita'), findsOneWidget);
    });

    testWidgets('has correct blue background color', (tester) async {
      await tester.pumpWidget(buildSubject(tester));
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, const Color(0xFF1D4ED8));
    });

    testWidgets('has back arrow icon', (tester) async {
      await tester.pumpWidget(buildSubject(tester));
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });

  // ── Back navigation ────────────────────────────────────────────────────────
  group('Back navigation', () {
    testWidgets('tapping back arrow pops the page', (tester) async {
      setTallScreen(tester); // Apply tall screen here too!

      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(body: Text('Home')),
        ),
      );

      // Push QrisKitaPage on top of Home
      tester.state<NavigatorState>(find.byType(Navigator)).push(
            MaterialPageRoute(
              builder: (_) => QrisKitaPage(userId: 1),
            ),
          );
      await tester.pumpAndSettle();

      expect(find.text('Qris Kita'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Back to Home
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Qris Kita'), findsNothing);
    });
  });

  // ── Different userIds ──────────────────────────────────────────────────────
  group('UserId variations', () {
    testWidgets('renders with userId 0', (tester) async {
      await tester.pumpWidget(buildSubject(tester, userId: 0));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders with large userId', (tester) async {
      await tester.pumpWidget(buildSubject(tester, userId: 999999));
      expect(tester.takeException(), isNull);
    });
  });
}