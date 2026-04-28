import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_kusaku/config/api_config.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/transfer_page.dart';

class QrisKitaPage extends StatelessWidget {
  final int userId;

  const QrisKitaPage({
    super.key,
    required this.userId,
  });

  // Lookup user by ID → returns _Recipient-compatible data
  Future<Map<String, String>?> _lookupUserById(int id) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}users/profile/$id/');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return {
          'phone': data['phone_number'] as String? ?? '',
          'name':  data['username']     as String? ?? '',
        };
      }
    } catch (_) {}
    return null;
  }

  Future<void> _onQrScanned(BuildContext context, String rawValue) async {
    final scannedId = int.tryParse(rawValue.trim());
    if (scannedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR tidak valid')),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final user = await _lookupUserById(scannedId);
    if (!context.mounted) return;
    Navigator.of(context).pop(); // dismiss loading

    if (user == null || user['phone']!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengguna tidak ditemukan')),
      );
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TransferPage(
        prefilledRecipientPhone: user['phone'],
        prefilledRecipientName:  user['name'],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title: const Text(
          'Qris Kita',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // QR container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFF1D4ED8),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: QrImageView(
                    data: userId.toString(),
                    version: QrVersions.auto,
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Tinggal Scan dan Bayar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}