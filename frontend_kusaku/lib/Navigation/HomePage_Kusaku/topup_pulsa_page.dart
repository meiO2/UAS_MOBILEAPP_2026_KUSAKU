import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_kusaku/config/api_config.dart';

class TopUpPulsaPage extends StatefulWidget {
  const TopUpPulsaPage({super.key});

  @override
  State<TopUpPulsaPage> createState() => _TopUpPulsaPageState();
}

class _TopUpPulsaPageState extends State<TopUpPulsaPage> {
  int? _selectedPackage;
  bool _paymentSuccess = false;
  bool _isLoading = false;

  int? _userId;
  int? _hiburanCategoryId;
  String _phoneNumber = '0812*****890';

  final List<_PulsaPackage> _packages = const [
    _PulsaPackage(nominal: 5000, bayar: 6000),
    _PulsaPackage(nominal: 10000, bayar: 12000),
    _PulsaPackage(nominal: 15000, bayar: 18000),
    _PulsaPackage(nominal: 25000, bayar: 30000),
    _PulsaPackage(nominal: 50000, bayar: 60000),
    _PulsaPackage(nominal: 100000, bayar: 120000),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserAndCategory();
  }

  Future<void> _loadUserAndCategory() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final phone = prefs.getString('phone_number') ?? '0812*****890';

    if (userId == null) return;

    // Fetch categories to find "Hiburan"
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}categories/$userId/'),
      );

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        final hiburan = data.firstWhere(
          (c) => c['name'] == 'Hiburan',
          orElse: () => null,
        );

        setState(() {
          _userId = userId;
          _phoneNumber = phone;
          _hiburanCategoryId = hiburan?['id'];
        });
      }
    } catch (e) {
      // silently fail, button will be disabled
    }
  }

  String _formatRp(int amount) {
    return amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  void _onTapPackage(int index) {
    setState(() {
      _paymentSuccess = false;
      _selectedPackage = index;
    });
  }

  void _onConfirm() {
    if (_selectedPackage == null) return;
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
          _submitPulsaExpense();
        },
      ),
    );
  }

  Future<void> _submitPulsaExpense() async {
    if (_userId == null || _hiburanCategoryId == null || _selectedPackage == null) {
      _showSnack('Gagal memproses, coba lagi');
      return;
    }

    final pkg = _packages[_selectedPackage!];

    setState(() => _isLoading = true);

    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}expenses/$_userId/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'category': _hiburanCategoryId,
          'receiver': 'Pulsa & Internet',
          'total_payment': pkg.nominal,
          'transaction_fee': pkg.bayar - pkg.nominal, // the 20% fee
          'notes': 'Pembelian pulsa & internet via Kusaku',
        }),
      );

      if (res.statusCode == 201) {
        setState(() => _paymentSuccess = true);
      } else {
        final body = jsonDecode(res.body);
        _showSnack(body['error'] ?? 'Top Up pulsa gagal');
      }
    } catch (e) {
      _showSnack('Gagal terhubung ke server');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? Colors.green : Colors.red,
    ));
  }

  void _reset() {
    setState(() {
      _selectedPackage = null;
      _paymentSuccess = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected =
        _selectedPackage != null ? _packages[_selectedPackage!] : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title: const Text('Pulsa', style: TextStyle(fontWeight: FontWeight.w600)),
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: _paymentSuccess
                              ? const Color(0xFF1D4ED8)
                              : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _phoneNumber,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _paymentSuccess
                                ? Colors.white
                                : const Color(0xFF374151),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Pemilihan paket pulsa',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF111827)),
                      ),
                      const Text(
                        'Fee: 20%',
                        style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _packages.length,
                        itemBuilder: (context, index) {
                          final pkg = _packages[index];
                          final isSelected = _selectedPackage == index;
                          return GestureDetector(
                            onTap: () => _onTapPackage(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF1D4ED8)
                                    : const Color(0xFFBFDBFE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _formatRp(pkg.nominal),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF1D4ED8),
                                    ),
                                  ),
                                  Text(
                                    'Bayar: Rp ${_formatRp(pkg.bayar)}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: isSelected
                                          ? Colors.white70
                                          : const Color(0xFF3B82F6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom confirmation panel
              if (selected != null)
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
                                'Rp ${_formatRp(selected.bayar)}',
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
                        label: 'Produk',
                        value: 'Pulsa ${_formatRp(selected.nominal)}',
                      ),
                      const SizedBox(height: 6),
                      const _DetailRow(
                        label: 'Metode Pembayaran',
                        value: 'Kusaku',
                      ),
                      const SizedBox(height: 14),

                      if (!_paymentSuccess)
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            // Disable if category not loaded yet
                            onPressed: _hiburanCategoryId != null ? _onConfirm : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1D4ED8),
                              disabledBackgroundColor: Colors.white38,
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
                child: CircularProgressIndicator(color: Color(0xFF1D4ED8)),
              ),
            ),
        ],
      ),
    );
  }
}

// --- unchanged widgets below ---

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

class PinBottomSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  const PinBottomSheet({super.key, required this.onSuccess});

  @override
  State<PinBottomSheet> createState() => _PinBottomSheetState();
}

class _PinBottomSheetState extends State<PinBottomSheet> {
  final List<String> _pin = [];

  void _onKey(String key) {
    if (key == '⌫') {
      if (_pin.isNotEmpty) setState(() => _pin.removeLast());
    } else {
      if (_pin.length < 6) {
        setState(() => _pin.add(key));
        if (_pin.length == 6) {
          Future.delayed(const Duration(milliseconds: 300), widget.onSuccess);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Masukan PIN',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    i < _pin.length ? '*' : '',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.8,
            children: [
              ...['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫']
                  .map((key) {
                if (key.isEmpty) return const SizedBox();
                return TextButton(
                  onPressed: () => _onKey(key),
                  child: Text(key,
                      style: TextStyle(
                        fontSize: key == '⌫' ? 18 : 22,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1D4ED8),
                      )),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _PinBottomSheet extends PinBottomSheet {
  const _PinBottomSheet({required super.onSuccess});
}

class _PulsaPackage {
  final int nominal;
  final int bayar;
  const _PulsaPackage({required this.nominal, required this.bayar});
}