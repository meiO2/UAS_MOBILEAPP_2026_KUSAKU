import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/Navigation/Scan_Kusaku/scan_page.dart';

void main() {
  group('ScanPage - Initial Component Tests', () {
    Widget createScanWidget() {
      return const MaterialApp(
        home: ScanPage(),
      );
    }

    testWidgets('Harus menampilkan teks instruksi QRIS secara default', (WidgetTester tester) async {
      await tester.pumpWidget(createScanWidget());

      // Memastikan headline dan subheadline untuk mode QRIS tampil
      expect(find.text('Bayar lebih cepat & aman'), findsOneWidget);
      expect(find.text('Arahkan kamera ke kode QR'), findsOneWidget);
      
      // Memastikan TopBar menampilkan title Scan QRIS
      expect(find.text('Scan QRIS'), findsOneWidget);
    });

    testWidgets('Harus menampilkan 3 tombol aksi utama (Flash, Nota, Galeri)', (WidgetTester tester) async {
      await tester.pumpWidget(createScanWidget());

      // Memastikan tombol Flash ada
      expect(find.textContaining('Nyalakan'), findsOneWidget);
      expect(find.textContaining('Flash'), findsOneWidget);
      expect(find.byIcon(Icons.flash_on_rounded), findsOneWidget);

      // Memastikan tombol Unggah Nota ada
      expect(find.textContaining('Unggah'), findsOneWidget);
      expect(find.textContaining('Nota'), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);

      // Memastikan tombol Upload Galeri ada
      expect(find.textContaining('Upload Dari'), findsOneWidget);
      expect(find.textContaining('Galeri'), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });
  });
}