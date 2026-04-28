import 'package:flutter/material.dart';
import 'package:frontend_kusaku/Navigation/ProfilePage_Kusaku/ubah_email_page.dart';
import 'package:frontend_kusaku/Navigation/ProfilePage_Kusaku/ubah_nomor_page.dart';
import '../../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UbahProfilePage extends StatefulWidget {
  const UbahProfilePage({super.key});

  @override
  State<UbahProfilePage> createState() => _UbahProfilePageState();
}

class _UbahProfilePageState extends State<UbahProfilePage> {
  final TextEditingController _namaController = TextEditingController();

  String _nomorHP = '';
  String _email = '';
  int? _userId;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getInt('user_id');

      if (_userId == null) {
        setState(() {
          _errorMessage = 'User tidak ditemukan. Silakan login ulang.';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}users/profile/$_userId/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _namaController.text = data['username'] ?? '';
          _nomorHP = data['phone_number'] ?? '';
          _email = data['email'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat profil. Coba lagi.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Koneksi gagal: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _onSimpan() async {
    if (_userId == null) return;

    setState(() => _isSaving = true);

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}users/profile/update/$_userId/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _namaController.text.trim(),
          'email': _email,
          'phone_number': _nomorHP,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil disimpan!'),
            backgroundColor: Color(0xFF1D4ED8),
          ),
        );
        Navigator.of(context).pop();
      } else {
        final data = jsonDecode(response.body);
        _showError(data['message'] ?? 'Gagal menyimpan profil.');
      }
    } catch (e) {
      _showError('Koneksi gagal: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _onUbahNomor() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDBEAFE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone,
                      color: Color(0xFF1D4ED8), size: 36),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1D4ED8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.question_mark,
                      color: Colors.white, size: 13),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Yakin mau ubah nomor HP?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF111827)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kamu akan memutuskan aplikasi lain yang\nsebelumnya terhubung dengan akun\nKusaku',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.5),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B7280),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Ga jadi deh'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const UbahNomorPage())).then((_) => _loadProfile());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D4ED8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('Ya, ubah'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title: const Text('Ubah Profile',
            style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1D4ED8)))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            _loadProfile();
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // ── Avatar ──
                            Container(
                              width: double.infinity,
                              color: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 28),
                              child: Center(
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFBFDBFE),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _namaController.text.isNotEmpty
                                          ? _namaController.text[0]
                                              .toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1D4ED8)),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ── Nama Lengkap ──
                            Container(
                              color: Colors.white,
                              padding:
                                  const EdgeInsets.fromLTRB(16, 14, 16, 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Nama Lengkap',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280))),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _namaController,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF111827)),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xFFF3F4F6),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 1),

                            // ── Nomor HP ──
                            Container(
                              color: Colors.white,
                              padding:
                                  const EdgeInsets.fromLTRB(16, 14, 16, 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Nomor HP',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280))),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(_nomorHP,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Color(0xFF111827))),
                                      ),
                                      TextButton(
                                        onPressed: _onUbahNomor,
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text('Ubah',
                                            style: TextStyle(
                                                color: Color(0xFF1D4ED8),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 1),

                            // ── Email ──
                            Container(
                              color: Colors.white,
                              padding:
                                  const EdgeInsets.fromLTRB(16, 14, 16, 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Email',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280))),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(_email,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Color(0xFF111827))),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const UbahEmailPage()),
                                        ).then((_) => _loadProfile()),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text('Ubah',
                                            style: TextStyle(
                                                color: Color(0xFF1D4ED8),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Simpan button ──
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _onSimpan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D4ED8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text('Simpan',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}