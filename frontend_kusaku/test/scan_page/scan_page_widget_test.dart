import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import '../../lib/Navigation/Scan_Kusaku/scan_page.dart';

void main() {
  // Setup untuk mencegah MissingPluginException dari image_picker & mobile_scanner di environment test
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    const MethodChannel('plugins.flutter.io/image_picker')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      return null; // Memalsukan batal memilih gambar
    });
    const MethodChannel('dev.steenbakker.mobile_scanner/scanner')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      return true; // Memalsukan inisialisasi scanner & toggle flash
    });
  });

  group('ScanPage - Action Buttons Widget Tests', () {
    Widget createScanWidget() {
      return const MaterialApp(home: ScanPage());
    }

    testWidgets('Tombol Flash harus mengubah status Flash Aktif/Mati', (WidgetTester tester) async {
      await tester.pumpWidget(createScanWidget());

      final flashButton = find.byIcon(Icons.flash_on_rounded);
      expect(flashButton, findsOneWidget);

      // Tap untuk menyalakan Flash
      await tester.tap(flashButton);
      await tester.pump();

      // Memastikan teks berubah menjadi Flash Aktif
      expect(find.text('Flash Aktif'), findsOneWidget);
      
      // Memastikan status label "Flash aktif" muncul di UI (ScanStatusChip)
      expect(find.text('Flash aktif'), findsOneWidget);

      // Tap untuk mematikan Flash
      await tester.tap(flashButton);
      await tester.pump();

      // Memastikan status kembali
      expect(find.text('Flash mati'), findsOneWidget);
    });

    testWidgets('Tombol Unggah Nota harus memunculkan status mengambil foto', (WidgetTester tester) async {
      await tester.pumpWidget(createScanWidget());

      final notaButton = find.byIcon(Icons.receipt_long_rounded);
      
      // Tap tombol Unggah Nota
      await tester.tap(notaButton);
      await tester.pump(); // Pump 1 frame untuk menangkap state sebelum async picker selesai

      // Karena kita me-mock picker me-return null (batal), status message akan berubah
      await tester.pumpAndSettle();
      expect(find.text('Pengambilan foto dibatalkan'), findsOneWidget);
    });

    testWidgets('Tombol Upload Galeri harus memunculkan status membuka galeri', (WidgetTester tester) async {
      await tester.pumpWidget(createScanWidget());

      final galleryButton = find.byIcon(Icons.image_outlined);

      // Tap tombol Upload Galeri
      await tester.tap(galleryButton);
      await tester.pump();

      // Setelah picker mengembalikan null (dari mock), aplikasi menangani pembatalan
      await tester.pumpAndSettle();
      expect(find.text('Pemilihan gambar dibatalkan'), findsOneWidget);
    });
  });
}