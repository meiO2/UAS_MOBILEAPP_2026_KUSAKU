import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/topup_pulsa_page.dart';
import 'package:frontend_kusaku/config/api_config.dart';

class TopUpStorePage extends StatefulWidget {
  final String storeName;
  final int userId;
  const TopUpStorePage({super.key, required this.storeName, required this.userId});

  @override
  State<TopUpStorePage> createState() => _TopUpStorePageState();
}

class _TopUpStorePageState extends State<TopUpStorePage> {
  String _inputNominal = '';
  bool _showConfirmation = false;
  bool _paymentSuccess = false;
  bool _isLoading = false;

  static const int _maxNominal = 10000000;
  static const double _feeRate = 0.20;

  int get _nominal => int.tryParse(_inputNominal) ?? 0;
  int get _fee => (_nominal * _feeRate).round();
  int get _total => _nominal + _fee;

  String _formatRp(int amount) {
    return amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  void _onKey(String key) {
    setState(() {
      if (key == '⌫') {
        if (_inputNominal.isNotEmpty) {
          _inputNominal = _inputNominal.substring(0, _inputNominal.length - 1);
        }
      } else {
        final next = _inputNominal + key;
        final val = int.tryParse(next) ?? 0;
        if (val <= _maxNominal) {
          _inputNominal = next;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maksimal nominal top up adalah Rp 10.000.000'),
              backgroundColor: Color(0xFFDC2626),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  void _onKonfirmasi() {
    if (_nominal <= 0) return;
    setState(() => _showConfirmation = true);
  }

  void _onFinalKonfirmasi() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PinBottomSheet(
        onSuccess: () {
          Navigator.of(context).pop();
          _submitTopUp();
        },
      ),
    );
  }

  Future<void> _submitTopUp() async {
    setState(() => _isLoading = true);

    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}incomes/${widget.userId}/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': _nominal,  // only the nominal, fee is not added to balance
          'title': 'Top Up via ${widget.storeName}',
          'description': 'Top up di ${widget.storeName}, fee: Rp ${_formatRp(_fee)}',
        }),
      );

      if (res.statusCode == 201) {
        setState(() => _paymentSuccess = true);
      } else {
        final body = jsonDecode(res.body);
        _showSnack(body['error'] ?? 'Top Up gagal');
      }
    } catch (e) {
      _showSnack('Gagal terhubung ke server');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFFDC2626),
    ));
  }

  void _reset() {
    setState(() {
      _inputNominal = '';
      _showConfirmation = false;
      _paymentSuccess = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title: const Text('Top up',
            style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store logo + name
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/topup/${widget.storeName.toLowerCase()}.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.storefront_outlined,
                                  color: Color(0xFF9CA3AF),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.storeName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 24, color: Color(0xFFE5E7EB)),

                      const Text(
                        'Nominal Top up',
                        style:
                            TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Text(
                            'Rp  ',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          Text(
                            _inputNominal.isEmpty
                                ? '0'
                                : _formatRp(_nominal),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: _inputNominal.isEmpty
                                  ? const Color(0xFFD1D5DB)
                                  : const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 24, color: Color(0xFFE5E7EB)),

                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 2.5,
                        children: [
                          '1', '2', '3',
                          '4', '5', '6',
                          '7', '8', '9',
                          '',  '0', '⌫',
                        ].map((key) {
                          if (key.isEmpty) return const SizedBox();
                          return TextButton(
                            onPressed: () => _onKey(key),
                            child: Text(
                              key,
                              style: TextStyle(
                                fontSize: key == '⌫' ? 18 : 22,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1D4ED8),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      if (_nominal > 0 && !_showConfirmation)
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _onKonfirmasi,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1D4ED8),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: const Text('Konfirmasi',
                                style:
                                    TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom confirmation panel
              if (_showConfirmation)
                Container(
                  width: double.infinity,
                  color: const Color(0xFF1D4ED8),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _reset,
                            child: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Konfirmasi Pembayaran',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_paymentSuccess) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  color: Color(0xFF16A34A), size: 40),
                              const SizedBox(height: 4),
                              const Text(
                                'Payment Successful!',
                                style: TextStyle(
                                  color: Color(0xFF16A34A),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Rp ${_formatRp(_total)}',
                                style: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      _DetailRow(
                          label: 'Metode Top Up', value: widget.storeName),
                      const SizedBox(height: 6),
                      _DetailRow(
                          label: 'Nominal Top Up',
                          value: 'Rp ${_formatRp(_nominal)}'),
                      const SizedBox(height: 6),
                      _DetailRow(
                          label: 'Fee', value: 'Rp ${_formatRp(_fee)}'),
                      const Divider(height: 20, color: Colors.white24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Pembayaran',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                          Text('Rp ${_formatRp(_total)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (!_paymentSuccess)
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _onFinalKonfirmasi,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1D4ED8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: const Text('Konfirmasi',
                                style:
                                    TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}