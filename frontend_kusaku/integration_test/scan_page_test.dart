import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../lib/Navigation/Scan_Kusaku/scan_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E ScanPage: Interaksi Tombol UI utama', (WidgetTester tester) async {
    // Jalankan aplikasi langsung di halaman Scan
    await tester.pumpWidget(const MaterialApp(
      home: ScanPage(),
    ));

    // Tunggu kamera dan UI selesai diinisialisasi
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verifikasi kita berada di halaman scan
    expect(find.text('Scan QRIS'), findsOneWidget);

    // 1. Uji Toggle Flash Button
    final flashIcon = find.byIcon(Icons.flash_on_rounded);
    await tester.tap(flashIcon);
    await tester.pumpAndSettle();
    
    // Verifikasi UI merespons
    expect(find.text('Flash Aktif'), findsOneWidget);

    // Kembalikan Flash ke semula
    await tester.tap(flashIcon);
    await tester.pumpAndSettle();

    // 2. Uji tombol Upload Galeri
    // CATATAN: Pada test integrasi asli, menekan galeri/kamera akan menghentikan sementara test 
    // karena native OS overlay menutupi aplikasi. Kita hanya memastikan tombolnya "clickable".
    final galleryIcon = find.byIcon(Icons.image_outlined);
    expect(galleryIcon, findsOneWidget);
    
    // 3. Uji tombol Unggah Nota
    final notaIcon = find.byIcon(Icons.receipt_long_rounded);
    expect(notaIcon, findsOneWidget);

    // Jika ingin memastikan tombol Back bekerja:
    // await tester.tap(find.byIcon(Icons.arrow_back));
    // await tester.pumpAndSettle();
  });
}