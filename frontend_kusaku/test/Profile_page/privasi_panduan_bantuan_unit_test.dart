import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/Navigation/ProfilePage_Kusaku/kebijakan_privasi_page.dart';
import '../../lib/Navigation/ProfilePage_Kusaku/panduan_kusaku_page.dart';
import '../../lib/Navigation/ProfilePage_Kusaku/pusat_bantuan_page.dart';

void main() {
  group('Unit/Component Tests - KebijakanPrivasiPage', () {
    testWidgets('Harus memiliki struktur Scaffold, AppBar, dan SingleChildScrollView', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: KebijakanPrivasiPage()));

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      
      // Cek title statis
      final titleFinder = find.text('Kebijakan Privasi');
      expect(titleFinder, findsOneWidget);
      
      // Cek warna AppBar
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, const Color(0xFF1D4ED8));
    });
  });

  group('Unit/Component Tests - PanduanKusakuPage', () {
    testWidgets('Harus merender tepat 2 judul panduan saat pertama dimuat', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PanduanKusakuPage()));

      // Kita tahu di kode ada 2 _GuideSection: 'Cara Pakai A.I Kusaku' dan 'Kusaku Stamp'
      expect(find.text('Cara Pakai A.I Kusaku'), findsOneWidget);
      expect(find.text('Kusaku Stamp'), findsOneWidget);

      // Detail step belum boleh ada yang dirender di awal
      expect(find.text('Tekan "Finance" di halaman home'), findsNothing);
    });
  });

  group('Unit/Component Tests - PusatBantuanPage', () {
    testWidgets('Harus merender tepat 4 kategori utama saat pertama dimuat', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PusatBantuanPage()));

      // Memastikan 4 kategori utama ada
      expect(find.text('Akun dan Pengaturan'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
      expect(find.text('Pembayaran'), findsOneWidget);
      expect(find.text('Top UP dan Tagihan'), findsOneWidget);

      // Memastikan ListView ada sebagai pembungkusnya
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}