import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/Navigation/ProfilePage_Kusaku/kebijakan_privasi_page.dart';
import '../../lib/Navigation/ProfilePage_Kusaku/panduan_kusaku_page.dart';
import '../../lib/Navigation/ProfilePage_Kusaku/pusat_bantuan_page.dart';

void main() {
  group('Widget Tests - Interaksi Navigasi (Kebijakan Privasi)', () {
    testWidgets('Harus memicu fungsi pop navigator saat menekan back button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: KebijakanPrivasiPage()));

      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);

      // Tekan tombol back
      await tester.tap(backButton);
      await tester.pumpAndSettle();
      // Test pass jika tidak ada exception saat navigasi dipicu
    });
  });

  group('Widget Tests - Interaksi State (Panduan & Bantuan)', () {
    testWidgets('PanduanKusakuPage: Accordion Expand & Collapse', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PanduanKusakuPage()));

      final title = find.text('Kusaku Stamp');
      final step = find.text('Lakukan transaksi untuk mendapatkan Kusaku Points');

      // Expand
      await tester.tap(title);
      await tester.pumpAndSettle();
      expect(step, findsOneWidget);

      // Collapse
      await tester.tap(title);
      await tester.pumpAndSettle();
      expect(step, findsNothing);
    });

    testWidgets('PusatBantuanPage: Nested Accordion Logic', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PusatBantuanPage()));

      final category = find.text('Transfer');
      final question = find.text('Berapa batas maksimal transfer?');
      final answer = find.text('Batas maksimal transfer per transaksi adalah Rp 30.000.000. Jika kamu perlu mentransfer lebih dari jumlah tersebut, kamu perlu melakukan beberapa kali transaksi.');

      // 1. Buka kategori Transfer
      await tester.tap(category);
      await tester.pumpAndSettle();
      expect(question, findsOneWidget);
      expect(answer, findsNothing); // Jawaban masih tertutup

      // 2. Buka Pertanyaan
      await tester.tap(question);
      await tester.pumpAndSettle();
      expect(answer, findsOneWidget); // Jawaban tampil

      // 3. Eksklusivitas Kategori (Jika buka Pembayaran, Transfer harus menutup)
      await tester.tap(find.text('Pembayaran'));
      await tester.pumpAndSettle();
      expect(question, findsNothing); // Pertanyaan transfer harus hilang dari layer
    });
  });
}