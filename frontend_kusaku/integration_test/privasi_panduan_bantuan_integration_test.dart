import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../lib/Navigation/ProfilePage_Kusaku/kebijakan_privasi_page.dart';
import '../lib/Navigation/ProfilePage_Kusaku/panduan_kusaku_page.dart';
import '../lib/Navigation/ProfilePage_Kusaku/pusat_bantuan_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget createApp() {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const KebijakanPrivasiPage())),
                child: const Text('Ke Privasi'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PanduanKusakuPage())),
                child: const Text('Ke Panduan'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PusatBantuanPage())),
                child: const Text('Ke Bantuan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets(
      'E2E Flow: Navigasi, Scroll, dan Interaksi pada semua halaman statis',
      (WidgetTester tester) async {
    await tester.pumpWidget(createApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    // ==================
    // 1. FLOW PRIVASI
    // ==================
    await tester.tap(find.text('Ke Privasi'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    // Scroll down to simulate reading
    final scrollPrivasi = find.byType(SingleChildScrollView).first;
    await tester.drag(scrollPrivasi, const Offset(0, -1500));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Back to main menu
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    // ==================
    // 2. FLOW PANDUAN
    // ==================
    await tester.tap(find.text('Ke Panduan'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    // ✅ Scroll into view before tapping — fixes the off-screen/obscured error
    await tester.ensureVisible(find.text('Cara Pakai A.I Kusaku'));
    await tester.pump();
    await tester.tap(find.text('Cara Pakai A.I Kusaku'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    // Scroll to read steps
    final scrollPanduan = find.byType(SingleChildScrollView).first;
    await tester.drag(scrollPanduan, const Offset(0, -500));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Close the AI guide section
    await tester.ensureVisible(find.text('Cara Pakai A.I Kusaku'));
    await tester.pump();
    await tester.tap(find.text('Cara Pakai A.I Kusaku'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Back to main menu
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    // ==================
    // 3. FLOW BANTUAN
    // ==================
    await tester.tap(find.text('Ke Bantuan'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    // Scroll down to find "Top UP dan Tagihan"
    final listBantuan = find.byType(ListView).first;
    await tester.drag(listBantuan, const Offset(0, -300));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // ✅ Ensure visible before tap
    await tester.ensureVisible(find.text('Top UP dan Tagihan'));
    await tester.pump();
    await tester.tap(find.text('Top UP dan Tagihan'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    // Open the first FAQ
    await tester.ensureVisible(
        find.text('Berapa lama proses Top Up melalui minimarket?'));
    await tester.pump();
    await tester.tap(
        find.text('Berapa lama proses Top Up melalui minimarket?'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    // Back to root
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    // Verify we're back at root
    expect(find.text('Ke Privasi'), findsOneWidget);
  });
}