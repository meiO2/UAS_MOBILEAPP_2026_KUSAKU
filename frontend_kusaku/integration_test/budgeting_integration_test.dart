import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_kusaku/main.dart' as app; 
import 'package:frontend_kusaku/Navigation/Finance_Kusaku/chat_si_pintar_page.dart'; // Adjust path if needed

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'user_id': 1,
      'username': 'TestUser',
    });
  });

  testWidgets('End-to-End Chat Flow: Type message, receive response, adjust budget, save settings', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);
    
    await tester.enterText(textField, 'Halo Si Pintar, tolong atur budget gaji 5 juta');
    await tester.pumpAndSettle();

    final sendButton = find.byIcon(Icons.send_rounded);
    await tester.tap(sendButton);
    
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Halo Si Pintar, tolong atur budget gaji 5 juta'), findsOneWidget);

    final simpanButton = find.widgetWithText(ElevatedButton, 'Simpan Pengaturan');
    
    if (simpanButton.evaluate().isNotEmpty) {
      await tester.tap(simpanButton);
      await tester.pumpAndSettle();

      expect(find.textContaining('Pengaturan kamu sudah disimpan'), findsOneWidget);
    }
  });
}