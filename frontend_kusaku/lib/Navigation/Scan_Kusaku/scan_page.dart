import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as ms;

import 'package:frontend_kusaku/Widgets/scan_widgets.dart';
import 'package:frontend_kusaku/config/api_config.dart';
import 'package:frontend_kusaku/Transaction_confimation/payment_confirmation_models.dart';
import 'package:frontend_kusaku/Transaction_confimation/payment_confirmation_page.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/transfer_page.dart';
import '../Finance_Kusaku/chat_si_pintar_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({
    super.key,
    this.onFlashChanged,
    this.onGallerySubmitted,
    this.onContentTypeChanged,
  });

  final Future<void> Function(bool isFlashOn)? onFlashChanged;
  final Future<void> Function(ScanGalleryItem item)? onGallerySubmitted;
  final Future<void> Function(ScanContentType type)? onContentTypeChanged;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _isFlashOn = false;
  bool _isBusy = false;
  bool _isScanning = false;

  ScanContentType _contentType = ScanContentType.qris;
  String? _statusMessage;

  final ImagePicker _picker = ImagePicker();

  final ms.MobileScannerController _scannerController =
      ms.MobileScannerController(
        detectionSpeed: ms.DetectionSpeed.noDuplicates,
        facing: ms.CameraFacing.back,
      );

  String get _headline => _contentType == ScanContentType.receipt
      ? 'Unggah nota untuk diproses'
      : 'Bayar lebih cepat & aman';

  String get _subheadline => _contentType == ScanContentType.receipt
      ? 'Ambil gambar nota atau pilih dari galeri'
      : 'Arahkan kamera ke kode QR';

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScanColors.pageBackground,
      body: Stack(
        children: [
          if (_contentType == ScanContentType.qris)
            ms.MobileScanner(
              controller: _scannerController,
              onDetect: (ms.BarcodeCapture capture) {
                if (_isScanning) return;

                final detected = capture.barcodes
                    .map((b) => b.rawValue)
                    .whereType<String>()
                    .map((v) => v.trim())
                    .firstWhere((v) => v.isNotEmpty, orElse: () => '');

                if (detected.isNotEmpty) {
                  _isScanning = true;
                  _onQRDetected(detected);
                } else {
                  setState(() => _statusMessage = 'QR kamera tidak terbaca');
                }
              },
            ),

          Column(
            children: [
              ScanTopBar(
                title: 'Scan QRIS',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Column(
                  children: [
                    ScanInstructionSection(
                      title: _headline,
                      subtitle: _subheadline,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Expanded(child: SizedBox.shrink()),
                          const ScanGuidanceCard(),
                          if (_statusMessage != null)
                            ScanStatusChip(label: _statusMessage!),
                        ],
                      ),
                    ),
                    ScanActionBar(
                      items: [
                        ScanActionItem(
                          label: _isFlashOn ? 'Flash Aktif' : 'Nyalakan\nFlash',
                          icon: Icons.flash_on_rounded,
                          isActive: _isFlashOn,
                          onTap: _isBusy ? () {} : _toggleFlash,
                        ),
                        ScanActionItem(
                          label: _contentType == ScanContentType.receipt
                              ? 'Qris'
                              : 'Unggah\nNota',
                          icon: _contentType == ScanContentType.receipt
                              ? Icons.qr_code_scanner_rounded
                              : Icons.receipt_long_rounded,
                          onTap: _isBusy
                              ? () {}
                              : _contentType == ScanContentType.receipt
                                  ? _openQrisMode
                                  : _onUnggahNota,
                        ),
                        ScanActionItem(
                          label: 'Upload Dari\nGaleri',
                          icon: Icons.image_outlined,
                          onTap: _isBusy ? () {} : _openGallery,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomSheet: null,
    );
  }

  void _onQRDetected(String code) async {
    try {
      final qrisNumber = code.trim();

      final scannedUserId = int.tryParse(qrisNumber);
      if (scannedUserId != null) {
        setState(() {
          _isBusy = true;
          _statusMessage = 'Mencari pengguna...';
        });

        final uri = Uri.parse('${ApiConfig.baseUrl}users/profile/$scannedUserId/');
        final res = await http.get(uri);

        if (!mounted) return;

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final phone = data['phone_number'] as String? ?? '';
          final name  = data['username']     as String? ?? '';

          if (phone.isEmpty) {
            _showError('Pengguna tidak ditemukan');
            return;
          }

          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TransferPage(
                prefilledRecipientPhone: phone,
                prefilledRecipientName:  name,
              ),
            ),
          );
        } else {
          _showError('Pengguna tidak ditemukan');
        }

        return;
      }

      setState(() {
        _isBusy = true;
        _statusMessage = 'Memverifikasi QRIS...';
      });

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}qr/scan/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'qris_number': qrisNumber}),
      ).timeout(const Duration(seconds: 8));

      final dynamic payload =
          response.body.isEmpty ? null : jsonDecode(response.body);
      final body = payload is Map<String, dynamic>
          ? payload
          : <String, dynamic>{};

      if (response.statusCode == 200) {
        await _openPaymentConfirmation(body);
      } else {
        _showError(
          (body['error'] ?? body['detail'] ?? 'QRIS tidak valid atau tidak terdaftar').toString(),
        );
      }
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
      await Future.delayed(const Duration(seconds: 2));
      _isScanning = false;
    }
  }

  int _parseAmount(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final normalized = value.replaceAll(',', '.');
      final decimalValue = double.tryParse(normalized);
      if (decimalValue != null) return decimalValue.round();
    }
    return 0;
  }

  Future<void> _openPaymentConfirmation(Map<String, dynamic> body) async {
    final remainingBalance = _parseAmount(body['remaining_balance']);

    final data = PaymentConfirmationData.fromJson(
      body,
      categories: [
        PaymentCategoryData(
          id: 'food-drink',
          name: 'Makan & Minum',
          remainingAmount: remainingBalance,
          icon: Icons.fastfood_rounded,
        ),
      ],
    );

    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PaymentConfirmationPage(data: data)),
    );
  }

  void _showError(String message) {
    setState(() => _statusMessage = message);
  }

  Future<void> _toggleFlash() async {
    setState(() {
      _isFlashOn = !_isFlashOn;
      _statusMessage = _isFlashOn ? 'Flash aktif' : 'Flash mati';
    });
    _scannerController.toggleTorch();
    await widget.onFlashChanged?.call(_isFlashOn);
  }

  Future<void> _onUnggahNota() async {
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
      _statusMessage = 'Mengambil foto nota...';
    });

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) {
        setState(() => _statusMessage = 'Pengambilan foto dibatalkan');
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatSiPintarPage(initialImagePath: image.path),
        ),
      );
    } catch (e) {
      setState(() => _statusMessage = 'Gagal mengambil foto: $e');
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _openReceiptMode() async {
    setState(() {
      _contentType = ScanContentType.receipt;
      _statusMessage = 'Mode nota aktif';
    });
    await widget.onContentTypeChanged?.call(_contentType);
  }

  Future<void> _openQrisMode() async {
    setState(() {
      _contentType = ScanContentType.qris;
      _statusMessage = 'Mode QRIS aktif';
    });
    await widget.onContentTypeChanged?.call(_contentType);
  }

  Future<void> _openGallery() async {
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
      _statusMessage = 'Membuka galeri...';
    });

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        setState(() => _statusMessage = 'Pemilihan gambar dibatalkan');
        return;
      }

      setState(() => _statusMessage = 'Membaca QR dari gambar...');

      final completer = Completer<String?>();
      late StreamSubscription<ms.BarcodeCapture> sub;

      sub = _scannerController.barcodes.listen((capture) {
        final code = capture.barcodes
            .map((b) => b.rawValue)
            .whereType<String>()
            .map((v) => v.trim())
            .firstWhere((v) => v.isNotEmpty, orElse: () => '');
        if (!completer.isCompleted) {
          completer.complete(code.isEmpty ? null : code);
        }
        sub.cancel();
      });

      await _scannerController.analyzeImage(image.path);

      final detectedCode = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          sub.cancel();
          return null;
        },
      );

      if (detectedCode == null || detectedCode.isEmpty) {
        setState(() => _statusMessage = 'Tidak ada QR yang terbaca di gambar ini');
        return;
      }

      await widget.onGallerySubmitted?.call(const ScanGalleryItem(id: 'gallery-upload'));
      _isScanning = true;
      _onQRDetected(detectedCode);
    } catch (e) {
      setState(() => _statusMessage = 'Gagal membaca gambar: $e');
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }
}