import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/Navigation/Finance_Kusaku/chat_si_pintar_page.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'user_id': 1,
      'username': 'TestUser',
    });
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ChatSiPintarPage()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    // Drain background async work (the 400 HTTP errors from ChatService)
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();

    expect(
      find.byType(CircularProgressIndicator),
      findsNothing,
      reason: 'Page is still loading. Increase pump durations in pumpPage.',
    );
  }

  group('ChatSiPintarPage Widget Tests', () {
    testWidgets(
      'Renders Chat Page and tests Response Widget (_SiPintarBubble)',
      (WidgetTester tester) async {
        await pumpPage(tester);
        expect(
          find.text('Halo pejuang rupiah! Yuk, atur finansialmu sebaik mungkin.'),
          findsOneWidget,
        );
        expect(find.text('Si Pintar'), findsWidgets);
        expect(find.text('Chat si Pintar'), findsOneWidget);
      },
    );

    testWidgets(
      'Tests Suggestion Widget (_PreferencesCard) & _applyBudgetSuggestion',
      (WidgetTester tester) async {
        await pumpPage(tester);
        expect(
          find.text('Ini kategori kamu saat ini. Kamu bisa atur sendiri ya! 😊'),
          findsOneWidget,
        );
        expect(find.text('Pilih Kategori yang Ingin Digunakan!'), findsOneWidget);
        expect(find.text('(AI Rekomendasi)'), findsOneWidget);
        expect(find.widgetWithText(ElevatedButton, 'Simpan Pengaturan'), findsOneWidget);
        expect(find.widgetWithText(OutlinedButton, 'Tambah Kategori Baru'), findsOneWidget);
      },
    );

    testWidgets(
      'Tests Save Settings Button & _onSimpanPengaturan',
      (WidgetTester tester) async {
        await pumpPage(tester);

        final simpanButton = find.widgetWithText(ElevatedButton, 'Simpan Pengaturan');
        expect(simpanButton, findsOneWidget);

        await tester.ensureVisible(simpanButton);
        await tester.pump();
        await tester.tap(simpanButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();

        final feedbackSave = find.textContaining('Pengaturan kamu sudah disimpan');
        final feedbackFail = find.textContaining('Gagal menyimpan pengaturan');
        expect(
          feedbackSave.evaluate().isNotEmpty || feedbackFail.evaluate().isNotEmpty,
          isTrue,
          reason: 'Expected a success or failure message after tapping Simpan.',
        );
      },
    );

    testWidgets(
      'Tambah Kategori Baru button opens dialog',
      (WidgetTester tester) async {
        await pumpPage(tester);

        final tambahButton = find.widgetWithText(OutlinedButton, 'Tambah Kategori Baru');
        expect(tambahButton, findsOneWidget);

        await tester.ensureVisible(tambahButton);
        await tester.pump();
        await tester.tap(tambahButton);
        await tester.pumpAndSettle();

        expect(find.text('Tambah Kategori Baru'), findsWidgets);
        expect(find.widgetWithText(ElevatedButton, 'Tambah'), findsOneWidget);
        expect(find.widgetWithText(TextButton, 'Batal'), findsOneWidget);

        final dialogTextField = tester.widget<TextField>(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(TextField),
          ),
        );
        expect(dialogTextField.decoration?.hintText, 'Nama kategori...');
      },
    );
  });
}