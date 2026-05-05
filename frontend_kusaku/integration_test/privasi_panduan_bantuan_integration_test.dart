import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../lib/Navigation/ProfilePage_Kusaku/kebijakan_privasi_page.dart';
import '../lib/Navigation/ProfilePage_Kusaku/panduan_kusaku_page.dart';
import '../lib/Navigation/ProfilePage_Kusaku/pusat_bantuan_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Widget dummy untuk simulasi navigasi di Integration Test
  Widget createApp() {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KebijakanPrivasiPage())),
                child: const Text('Ke Privasi'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PanduanKusakuPage())),
                child: const Text('Ke Panduan'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PusatBantuanPage())),
                child: const Text('Ke Bantuan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('E2E Flow: Navigasi, Scroll, dan Interaksi pada semua halaman statis', (WidgetTester tester) async {
    await tester.pumpWidget(createApp());
    await tester.pumpAndSettle();

    // ==================
    // 1. FLOW PRIVASI
    // ==================
    await tester.tap(find.text('Ke Privasi'));
    await tester.pumpAndSettle();
    
    // Simulate real user reading by scrolling down
    final scrollPrivasi = find.byType(SingleChildScrollView);
    await tester.drag(scrollPrivasi, const Offset(0, -1500));
    await tester.pumpAndSettle();
    
    // Back to main menu
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // ==================
    // 2. FLOW PANDUAN
    // ==================
    await tester.tap(find.text('Ke Panduan'));
    await tester.pumpAndSettle();

    // Buka panduan AI
    await tester.tap(find.text('Cara Pakai A.I Kusaku'));
    await tester.pumpAndSettle();

    // Scroll sedikit ke bawah untuk membaca step
    final scrollPanduan = find.byType(SingleChildScrollView);
    await tester.drag(scrollPanduan, const Offset(0, -500));
    await tester.pumpAndSettle();

    // Tutup panduan AI dan back
    await tester.tap(find.text('Cara Pakai A.I Kusaku'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // ==================
    // 3. FLOW BANTUAN
    // ==================
    await tester.tap(find.text('Ke Bantuan'));
    await tester.pumpAndSettle();

    // User scroll ke bawah mencari "Top UP dan Tagihan"
    final listBantuan = find.byType(ListView);
    await tester.drag(listBantuan, const Offset(0, -300));
    await tester.pumpAndSettle();

    // User klik "Top UP dan Tagihan"
    await tester.tap(find.text('Top UP dan Tagihan'));
    await tester.pumpAndSettle();

    // User buka FAQ pertama di Top Up
    await tester.tap(find.text('Berapa lama proses Top Up melalui minimarket?'));
    await tester.pumpAndSettle();

    // Selesai baca, kembali ke menu utama
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Pastikan kita sudah kembali ke halaman root (tombol navigasi terlihat lagi)
    expect(find.text('Ke Privasi'), findsOneWidget);
  });
}