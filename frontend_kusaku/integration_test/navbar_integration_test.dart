import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frontend_kusaku/navbar.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user navigates through navbar', (tester) async {
    await tester.pumpWidget(
  MaterialApp(
    home: MainShell(
      pages: const [
        Center(child: Text('HomePage')),
        Center(child: Text('FinancePage')),
        Center(child: Text('HistoryPage')),
        Center(child: Text('ProfilePage')),
      ],
    ),
  ),
);

await tester.pumpAndSettle();

    expect(find.text('Profile'), findsWidgets);
  });
}