import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_kusaku/Navigation/History_Kusaku/history_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'user_id': 1});
  });

  testWidgets('HistoryPage full integration flow', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HistoryPage()));

    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.byType(CircularProgressIndicator), findsNothing);

    final listFinder = find.byType(Scrollable).first;
    await tester.fling(listFinder, const Offset(0.0, 300.0), 1000.0);
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    
    await tester.fling(listFinder, const Offset(0.0, 300.0), 1000.0);
    await tester.pumpAndSettle();

    // Expect the session error text
    expect(find.text('Sesi tidak ditemukan, silakan login ulang'), findsOneWidget);

    // Tap "Coba Lagi" (Try Again) button
    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();
  });
}