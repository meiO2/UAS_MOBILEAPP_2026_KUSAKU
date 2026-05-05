import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_kusaku/navbar.dart';

void main() {
  Widget buildTestableWidget() {
    return MaterialApp(
      home: MainShell(
        pages: const [
          Center(child: Text('HomePage')),
          Center(child: Text('FinancePage')),
          Center(child: Text('HistoryPage')),
          Center(child: Text('ProfilePage')),
        ],
      ),
    );
  }

  group('MainShell Widget Tests', () {

    testWidgets('starts on Home page', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('HomePage'), findsOneWidget);
    });

    testWidgets('tap Finance switches page', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('nav_finance')));
      await tester.pumpAndSettle();

      expect(find.text('FinancePage'), findsOneWidget);
    });

    testWidgets('tap History switches page', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('nav_history')));
      await tester.pumpAndSettle();

      expect(find.text('HistoryPage'), findsOneWidget);
    });

    testWidgets('tap Profile switches page', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('nav_profile')));
      await tester.pumpAndSettle();

      expect(find.text('ProfilePage'), findsOneWidget);
    });

    testWidgets('tap Scan opens new page (push)', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('nav_scan')).first);
      await tester.pumpAndSettle();

      expect(find.byType(Navigator), findsOneWidget);
    });
  });
}