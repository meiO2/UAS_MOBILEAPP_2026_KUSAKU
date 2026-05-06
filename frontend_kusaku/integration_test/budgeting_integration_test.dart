import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_kusaku/Navigation/Finance_Kusaku/chat_si_pintar_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'user_id': 1,
      'username': 'TestUser',
    });
  });

  testWidgets(
    'End-to-End Chat Flow: Type message, receive response, adjust budget, save settings',
    (WidgetTester tester) async {
      // ── 1. Pump ONLY the ChatSiPintarPage wrapped in MaterialApp ──────────
      // Launching app.main() boots the full app (login screens, nav guards,
      // etc.) which means ChatSiPintarPage may never appear.
      // We go directly to the page instead.
      await tester.pumpWidget(
        const MaterialApp(
          home: ChatSiPintarPage(),
        ),
      );

      // ── 2. Wait for initState async work to complete ───────────────────────
      // _loadUser + _loadCategories + getInitialBudget are all awaited inside
      // initState callbacks. Give them up to 10 s on a real device/emulator.
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // ── 3. Verify the greeting appeared (sanity check) ────────────────────
      expect(
        find.textContaining('Halo pejuang rupiah'),
        findsOneWidget,
        reason: 'Greeting message should appear after init',
      );

      // ── 4. Find the text field ─────────────────────────────────────────────
      // Use byType(TextField) — there is only one visible input field.
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget,
          reason: 'Chat input TextField must be present');

      // ── 5. Type message ───────────────────────────────────────────────────
      await tester.enterText(
          textField, 'Halo Si Pintar, tolong atur budget gaji 5 juta');
      await tester.pump(); // flush the text change

      // ── 6. Tap send ───────────────────────────────────────────────────────
      final sendButton = find.byIcon(Icons.send_rounded);
      expect(sendButton, findsOneWidget,
          reason: 'Send button must be present');
      await tester.tap(sendButton);

      // ── 7. Wait for the user bubble to appear ────────────────────────────
      // pumpAndSettle with a generous timeout covers the real HTTP round-trip.
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // ── 8. Assert the user message is visible ────────────────────────────
      expect(
        find.text('Halo Si Pintar, tolong atur budget gaji 5 juta'),
        findsOneWidget,
        reason: 'User message bubble must appear in the list',
      );

      // ── 9. Save settings if the preferences card is visible ──────────────
      // The card is shown in the FIRST Si Pintar message (showPreferences=true).
      // Scroll up to find it in case the new AI reply pushed it off screen.
      final simpanButton =
          find.widgetWithText(ElevatedButton, 'Simpan Pengaturan');

      if (simpanButton.evaluate().isNotEmpty) {
        // Ensure the button is scrolled into view before tapping.
        await tester.ensureVisible(simpanButton);
        await tester.pumpAndSettle();

        await tester.tap(simpanButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        expect(
          find.textContaining('Pengaturan kamu sudah disimpan'),
          findsOneWidget,
          reason: 'Save confirmation message should appear',
        );
      }
    },
  );
}