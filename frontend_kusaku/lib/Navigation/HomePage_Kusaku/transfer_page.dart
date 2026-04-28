import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/topup_pulsa_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_kusaku/config/api_config.dart';


class _Session {
  static Future<Map<String, String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getInt('user_id')?.toString() ?? '',
      'phone':  prefs.getString('phone_number') ?? '',
      'name':   prefs.getString('full_name') ?? '',
    };
  }
}

class _ApiException implements Exception {
  final String message;
  const _ApiException(this.message);
}

class _TransferApi {
  static const _headers = {'Content-Type': 'application/json'};

  static Future<_Recipient?> lookup(String phone) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}transfer/lookup/?phone=$phone');
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return _Recipient(
        code: data['phone_number'] as String,
        name: data['name'] as String,
      );
    }
    return null;
  }

  static Future<List<_Recipient>> recentRecipients(String userId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}transfer/$userId/history/');
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode != 200) return [];

    final list = jsonDecode(res.body) as List<dynamic>;
    final seen  = <String>{};
    final result = <_Recipient>[];
    for (final e in list) {
      if (e['direction'] == 'sent') {
        final phone = e['counterpart_phone'] as String;
        if (seen.add(phone)) {
          result.add(_Recipient(
            code: phone,
            name: e['counterpart_name'] as String,
          ));
        }
      }
    }
    return result;
  }

  static Future<Map<String, dynamic>> send({
    required String userId,
    required String senderPhone,
    required String recipientPhone,
    required int    amount,
    required String notes,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}transfer/$userId/');
    final res = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'sender_phone':    senderPhone,
        'recipient_phone': recipientPhone,
        'amount':          amount,
        'notes':           notes,
      }),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 201) return body;
    throw _ApiException(body['error'] as String? ?? 'Transfer gagal');
  }
}


class TransferPage extends StatefulWidget {
  final String? prefilledRecipientPhone;
  final String? prefilledRecipientName;

  const TransferPage({
    super.key,
    this.prefilledRecipientPhone,
    this.prefilledRecipientName,
  });

  @override
  State<TransferPage> createState() => _TransferPageState();
}

enum _TransferStep {
  selectMethod,
  selectRecipient,
  enterDetails,
  confirm,
  pinVerify,
  success,
}

class _TransferPageState extends State<TransferPage> {
  _TransferStep _step = _TransferStep.selectMethod;

  // Session
  String _myUserId = '';
  String _myPhone  = '';
  String _myName   = '';

  // Transfer data
  String _selectedMethod   = '';
  String _recipientCode    = '';
  String _recipientName    = '';
  String _amount           = '';
  String _pesan            = '';
String _selectedCategory = '';
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;

  // Lookup
  bool        _isLooking         = false;
  String?     _lookupError;
  _Recipient? _lookedUpRecipient;

  // History
  List<_Recipient> _recentRecipients = [];
  bool             _loadingHistory   = false;

  // Submission
  bool _isSubmitting = false;

  final TextEditingController _pesanController  = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // Categories list
  List<String> _hardcodedCategories = const [
    'Kebutuhan Rumah',
    'Makan & Minum',
    'Transportasi',
    'Investasi',
    'Tabungan',
  ];

  static const int _maxTransfer = 30000000;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadCategories() async {
    if (_myUserId.isEmpty) return;
    try {
      final res = await http.get(Uri.parse('${ApiConfig.baseUrl}categories/$_myUserId/'));
      if (res.statusCode == 200) {
final dynamic jsonResponse = jsonDecode(res.body);
  final List data = jsonResponse is List ? jsonResponse : [];
        if (mounted) {
          setState(() {
            _categories = data.map((c) => {
'id': (c['id'] ?? '').toString(),
'name': c['name']?.toString() ?? 'Unknown',
            }).toList();
          });
        }
      }
    } catch (e) {
      print('Categories load failed: $e');
      // fallback hardcoded later
    }
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    print('DEBUG user_id: ${prefs.getInt('user_id')}');
    print('DEBUG phone_number: ${prefs.getString('phone_number')}');

    final s = await _Session.load();
    if (!mounted) return;
    setState(() {
      _myUserId = s['userId']!;
      _myPhone  = s['phone']!;
      _myName   = s['name']!;
    });
    if (_myPhone.isEmpty && _myUserId.isNotEmpty) {
      try {
        final uri = Uri.parse('${ApiConfig.baseUrl}users/profile/$_myUserId/');
        final res = await http.get(uri);
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('phone_number', data['phone_number'] ?? '');
          await prefs.setString('full_name', data['username'] ?? '');
          if (mounted) {
            setState(() {
              _myPhone = data['phone_number'] ?? '';
              _myName  = data['username'] ?? '';
            });
          }
        }
      } catch (e) {
        print('Fallback profile fetch failed: $e');
      }
    }
_loadRecentRecipients();
    await _loadCategories();

    // If opened from QR scan, skip straight to enterDetails
    final prefPhone = widget.prefilledRecipientPhone;
    final prefName  = widget.prefilledRecipientName;
    if (prefPhone != null && prefPhone.isNotEmpty) {
      setState(() {
        _selectedMethod = 'Kusaku';
        _recipientCode  = prefPhone;
        _recipientName  = prefName ?? '';
        _step           = _TransferStep.enterDetails;
      });
    }
  }

  Future<void> _loadRecentRecipients() async {
    if (_myUserId.isEmpty) return;
    setState(() => _loadingHistory = true);
    final recent = await _TransferApi.recentRecipients(_myUserId);
    if (!mounted) return;
    setState(() {
      _recentRecipients = recent;
      _loadingHistory   = false;
    });
  }

  Future<void> _lookupRecipient(String phone) async {
    final cleaned = phone.trim();
    if (cleaned.isEmpty) {
      setState(() { _lookedUpRecipient = null; _lookupError = null; });
      return;
    }
    setState(() { _isLooking = true; _lookupError = null; _lookedUpRecipient = null; });
    try {
      final result = await _TransferApi.lookup(cleaned);
      if (!mounted) return;
      setState(() {
        _lookedUpRecipient = result;
        _lookupError = result == null ? 'Nomor tidak ditemukan' : null;
      });
    } catch (_) {
      if (mounted) setState(() => _lookupError = 'Gagal menghubungi server');
    } finally {
      if (mounted) setState(() => _isLooking = false);
    }
  }

  Future<void> _doTransfer() async {
    setState(() => _isSubmitting = true);
    try {
      await _TransferApi.send(
        userId:         _myUserId,
        senderPhone:    _myPhone,
        recipientPhone: _recipientCode,
        amount:         _amountInt,
        notes:          _pesan,
      );

      if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
        try {
          await http.post(
            Uri.parse('${ApiConfig.baseUrl}expenses/$_myUserId/'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'category': _selectedCategoryId,
              'total_payment': _amountInt.toString(),
              'receiver': _recipientName,
              'title': 'Transfer ke $_recipientName',
              'description': _pesan,
            }),
          );
        } catch (e) {
          print('Failed to create Expense after transfer: $e');
        }
      }

      if (mounted) setState(() => _step = _TransferStep.success);
    } on _ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        backgroundColor: const Color(0xFFDC2626),
      ));
      setState(() => _step = _TransferStep.confirm);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Terjadi kesalahan, coba lagi'),
        backgroundColor: Color(0xFFDC2626),
      ));
      setState(() => _step = _TransferStep.confirm);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _selectRecipient(_Recipient r) {
    setState(() {
      _recipientCode     = r.code;
      _recipientName     = r.name;
      _lookedUpRecipient = null;
      _lookupError       = null;
      _searchController.clear();
      _step = _TransferStep.enterDetails;
    });
  }

  int    get _amountInt => int.tryParse(_amount) ?? 0;
  String _formatRp(int v) => v
      .toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  void _onAmountKey(String key) {
    setState(() {
      if (key == '⌫') {
        if (_amount.isNotEmpty) _amount = _amount.substring(0, _amount.length - 1);
      } else {
        final next = _amount + key;
        final val  = int.tryParse(next) ?? 0;
        if (val <= _maxTransfer) {
          _amount = next;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Maksimal transfer adalah Rp 30.000.000'),
            backgroundColor: Color(0xFFDC2626),
            duration: Duration(seconds: 2),
          ));
        }
      }
    });
  }

  void _goBack() {
    setState(() {
      switch (_step) {
        case _TransferStep.selectRecipient:
          _lookedUpRecipient = null; _lookupError = null; _searchController.clear();
          _step = _TransferStep.selectMethod;
          break;
        case _TransferStep.enterDetails:
          // If came from QR scan, pressing back exits the page entirely
          if (widget.prefilledRecipientPhone != null) {
            Navigator.of(context).pop();
          } else {
            _step = _TransferStep.selectRecipient;
          }
          break;
        case _TransferStep.confirm:
          _step = _TransferStep.enterDetails; break;
        case _TransferStep.pinVerify:
          _step = _TransferStep.confirm; break;
        case _TransferStep.success:
          _reset(); break;
        default:
          Navigator.of(context).pop();
      }
    });
  }

  void _reset() {
    setState(() {
      _step            = _TransferStep.selectMethod;
      _selectedMethod  = '';
      _recipientCode   = '';
      _recipientName   = '';
      _amount          = '';
      _pesan           = '';
      _selectedCategory = '';
      _lookedUpRecipient = null;
      _lookupError       = null;
      _pesanController.clear();
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _pesanController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D4ED8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_wallet,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('Kusaku',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _step == _TransferStep.selectMethod
              ? () => Navigator.of(context).pop()
              : _goBack,
        ),
        elevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildStep(),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _TransferStep.selectMethod:    return _buildSelectMethod();
      case _TransferStep.selectRecipient: return _buildSelectRecipient();
      case _TransferStep.enterDetails:    return _buildEnterDetails();
      case _TransferStep.confirm:         return _buildConfirm();
      case _TransferStep.pinVerify:       return _buildPinStep();
      case _TransferStep.success:         return _buildSuccess();
    }
  }

  // ── Step 1: Choose method ──
  Widget _buildSelectMethod() {
    return Container(
      key: const ValueKey('method'),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Kode Kusaku: $_myPhone',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1D4ED8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MethodButton(
                    icon: Icons.account_circle_outlined,
                    label: 'Kusaku',
                    onTap: () => setState(() {
                      _selectedMethod = 'Kusaku';
                      _step = _TransferStep.selectRecipient;
                    }),
                  ),
                  _MethodButton(
                    icon: Icons.account_balance_outlined,
                    label: 'Bank Lain',
                    onTap: () => setState(() {
                      _selectedMethod = 'Bank Lain';
                      _step = _TransferStep.selectRecipient;
                    }),
                  ),
                  _MethodButton(
                    icon: Icons.credit_card_outlined,
                    label: 'Virtual\nAccount',
                    onTap: () => setState(() {
                      _selectedMethod = 'Virtual Account';
                      _step = _TransferStep.selectRecipient;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Icon(Icons.history, size: 18, color: Color(0xFF6B7280)),
                SizedBox(width: 6),
                Text('Terakhir',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                SizedBox(width: 24),
                Text('Favorit',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
            const SizedBox(height: 10),
            if (_loadingHistory)
              const Center(child: CircularProgressIndicator())
            else if (_recentRecipients.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Belum ada riwayat transfer',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _recentRecipients.length,
                  itemBuilder: (_, i) {
                    final r = _recentRecipients[i];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFBFDBFE),
                        child: Icon(Icons.person, color: Color(0xFF1D4ED8)),
                      ),
                      title: Text(r.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(r.code),
                      onTap: () {
                        setState(() { _selectedMethod = 'Kusaku'; });
                        _selectRecipient(r);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Pick recipient ──
  Widget _buildSelectRecipient() {
    return Container(
      key: const ValueKey('recipient'),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kode Kusaku: $_myPhone',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              onChanged: (v) {
                setState(() {});
                Future.delayed(const Duration(milliseconds: 600), () {
                  if (_searchController.text == v) _lookupRecipient(v);
                });
              },
              decoration: InputDecoration(
                hintText: 'Masukkan kode kusaku/no. handphone',
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFF1D4ED8),
                hintMaxLines: 1,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: _isLooking
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        ))
                    : null,
              ),
            ),

            if (_lookupError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_lookupError!,
                    style: const TextStyle(
                        color: Color(0xFFDC2626), fontSize: 13)),
              ),
            if (_lookedUpRecipient != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ListTile(
                  tileColor: const Color(0xFFEFF6FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFBFDBFE),
                    child: Icon(Icons.person, color: Color(0xFF1D4ED8)),
                  ),
                  title: Text(_lookedUpRecipient!.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(_lookedUpRecipient!.code),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Color(0xFF1D4ED8)),
                  onTap: () => _selectRecipient(_lookedUpRecipient!),
                ),
              ),

            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.history, size: 18, color: Color(0xFF6B7280)),
                SizedBox(width: 6),
                Text('Terakhir',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                SizedBox(width: 24),
                Text('Favorit',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
            const SizedBox(height: 10),

            Expanded(
              child: _recentRecipients.isEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Belum ada riwayat transfer',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF9CA3AF))),
                    )
                  : ListView.builder(
                      itemCount: _recentRecipients.length,
                      itemBuilder: (_, i) {
                        final r = _recentRecipients[i];
                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFBFDBFE),
                            child: Icon(Icons.person, color: Color(0xFF1D4ED8)),
                          ),
                          title: Text(r.name,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(r.code),
                          onTap: () => _selectRecipient(r),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 3: Amount + category + pesan ──
  Widget _buildEnterDetails() {
    return Container(
      key: const ValueKey('details'),
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tujuan Transfer',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D4ED8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_recipientCode,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                        Text(_recipientName,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Dari Akun:',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  Text('Kode Kusaku: $_myPhone',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                  const Text('Jumlah',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Row(
                    children: [
                      const Text('IDR  ',
                          style: TextStyle(
                              fontSize: 18, color: Color(0xFF6B7280))),
                      Text(
                        _amount.isEmpty ? '0' : _formatRp(_amountInt),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _amount.isEmpty
                              ? const Color(0xFFD1D5DB)
                              : const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 8),

                  // ── Category picker (from File 3 UI) ──
                  const Text('Kategori',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showModalBottomSheet<String>(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (ctx) => SafeArea(
                          child: SizedBox(
                            height: MediaQuery.of(ctx).size.height * 0.5, // limit height
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                                  child: Text(
                                    'Pilih Kategori',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: ListView(
                                    children: (_categories.isNotEmpty
                                        ? _categories.map((cat) => ListTile(
                                              title: Text(cat['name']),
                                              trailing: _selectedCategoryId == cat['id']
                                                  ? const Icon(Icons.check, color: Color(0xFF1D4ED8))
                                                  : null,
                                              onTap: () => Navigator.of(ctx)
                                                  .pop('${cat['id']}|${cat['name']}'),
                                            ))
                                        : _hardcodedCategories.map((cat) => ListTile(
                                              title: Text(cat),
                                              trailing: _selectedCategory == cat
                                                  ? const Icon(Icons.check, color: Color(0xFF1D4ED8))
                                                  : null,
                                              onTap: () => Navigator.of(ctx).pop(cat),
                                            )))
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                      if (picked != null) {
                        final parts = picked.split('|');
                        if (parts.length == 2) {
                          setState(() {
                            _selectedCategoryId = parts[0];
                            _selectedCategory = parts[1];
                          });
                        } else {
                          setState(() => _selectedCategory = picked);
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _selectedCategory.isEmpty
                            ? 'Pilih satu kategori'
                            : _selectedCategory,
                        style: TextStyle(
                          fontSize: 13,
                          color: _selectedCategory.isEmpty
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 8),

                  const Text('Pesan',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  TextField(
                    controller: _pesanController,
                    onChanged: (v) => _pesan = v,
                    decoration: const InputDecoration(
                      hintText: 'Tulis pesan (opsional)',
                      border: InputBorder.none,
                      hintStyle:
                          TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                    ),
                  ),
                  const Divider(color: Color(0xFFE5E7EB)),
                ],
              ),
            ),
          ),

          // ── Numpad ──
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              children: [
                '1', '2', '3',
                '4', '5', '6',
                '7', '8', '9',
                '',  '0', '⌫',
              ].map((key) {
                if (key.isEmpty) return const SizedBox();
                return TextButton(
                  onPressed: () => _onAmountKey(key),
                  child: Text(key,
                      style: TextStyle(
                        fontSize: key == '⌫' ? 18 : 22,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1D4ED8),
                      )),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _amountInt > 0
                    ? () => setState(() => _step = _TransferStep.confirm)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  disabledBackgroundColor: const Color(0xFFBFDBFE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Konfirmasi',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 4: Confirm ──
  Widget _buildConfirm() {
    return Container(
      key: const ValueKey('confirm'),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Konfirmasi Transfer',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1D4ED8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _ConfirmBlock(title: 'Dari Akun:', lines: [_myPhone, _myName]),
                  const Divider(color: Colors.white24, height: 24),
                  _ConfirmBlock(title: 'Tujuan', lines: [
                    _recipientCode,
                    _recipientName,
                  ]),
                  const Divider(color: Colors.white24, height: 24),
                  _ConfirmBlock(title: 'Jumlah', lines: [
                    'IDR',
                    _formatRp(_amountInt),
                  ]),
                  const Divider(color: Colors.white24, height: 24),
                  // ── Kategori row (from File 3 UI) ──
                  _ConfirmBlock(title: 'Kategori', lines: [
                    _selectedCategory.isEmpty ? '-' : _selectedCategory,
                  ]),
                  if (_pesan.isNotEmpty) ...[
                    const Divider(color: Colors.white24, height: 24),
                    _ConfirmBlock(title: 'Pesan', lines: [_pesan]),
                  ],
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () =>
                    setState(() => _step = _TransferStep.pinVerify),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Konfirmasi',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 5: PIN ──
  Widget _buildPinStep() {
    if (!_isSubmitting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_step == _TransferStep.pinVerify && mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => PinBottomSheet(
              onSuccess: () {
                Navigator.of(context).pop();
                setState(() => _isSubmitting = true);
                _doTransfer();
              },
            ),
          );
        }
      });
    }

    return Container(
      key: const ValueKey('pin'),
      color: Colors.white,
      child: Center(
        child: _isSubmitting
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memproses transfer...',
                      style: TextStyle(color: Color(0xFF6B7280))),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }

  // ── Step 6: Success ──
  Widget _buildSuccess() {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    return Container(
      key: const ValueKey('success'),
      color: const Color(0xFF1D4ED8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Transfer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Divider(color: Colors.white24),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.insert_drive_file_outlined,
                      color: Color(0xFF16A34A), size: 52),
                  const Icon(Icons.check,
                      color: Color(0xFF16A34A), size: 20),
                  const SizedBox(height: 8),
                  const Text(
                    'Transfer Successful!',
                    style: TextStyle(
                      color: Color(0xFF16A34A),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${_formatRp(_amountInt)}',
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _SuccessRow(label: 'Dari Akun:', value: _myPhone),
            _SuccessRow(label: 'Tanggal  :', value: dateStr),
            _SuccessRow(label: 'Tujuan   :', value: _recipientCode),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1D4ED8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Konfirmasi',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ── Helper widgets ──

class _MethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MethodButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF1D4ED8), size: 26),
          ),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ConfirmBlock extends StatelessWidget {
  final String title;
  final List<String> lines;
  const _ConfirmBlock({required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 4),
        ...lines.map((l) => Text(l,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14))),
      ],
    );
  }
}

class _SuccessRow extends StatelessWidget {
  final String label;
  final String value;
  const _SuccessRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

class _Recipient {
  final String code;
  final String name;
  const _Recipient({required this.code, required this.name});
}