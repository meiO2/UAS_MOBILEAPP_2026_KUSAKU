import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';

class KusakuPointsPage extends StatefulWidget {
  const KusakuPointsPage({super.key});

  @override
  State<KusakuPointsPage> createState() => _KusakuPointsPageState();
}

class _KusakuPointsPageState extends State<KusakuPointsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isLoading = true;
  String? _error;

  int _totalPoints = 0;
  List<_PointTransaction> _didapat = [];
  List<_PointTransaction> _terpakai = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchPoints();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchPoints() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      setState(() {
        _error = 'Sesi tidak ditemukan, silakan login ulang';
        _isLoading = false;
      });
      return;
    }

    final results = await Future.wait([
      http.get(Uri.parse('${ApiConfig.baseUrl}balance/$userId/')),
      http.get(Uri.parse('${ApiConfig.baseUrl}expenses/$userId/')),
      http.get(Uri.parse('${ApiConfig.baseUrl}stamp/history/$userId/')),
    ]);

    for (final r in results) {
      if (r.statusCode != 200) {
        setState(() {
          _error = 'Gagal memuat data (${r.statusCode})';
          _isLoading = false;
        });
        return;
      }
    }

    final balance  = jsonDecode(results[0].body);
    final expenses = jsonDecode(results[1].body) as List;
    final stamps   = jsonDecode(results[2].body) as List;

    setState(() {
      _totalPoints = balance['kusaku_points'] ?? 0;

      _didapat = expenses
          .where((e) => (e['kusaku_points'] ?? 0) > 0)
          .map((e) {
            final date = DateTime.parse(e['date']);
            return _PointTransaction(
              date: _formatDate(date),
              month: _formatMonth(date),
              label: e['receiver'] ?? 'Pengeluaran',
              points: e['kusaku_points'],
            );
          })
          .toList();

      _terpakai = stamps.map((s) {
        final date = DateTime.parse(s['redeemed_at']);
        return _PointTransaction(
          date: _formatDate(date),
          month: _formatMonth(date),
          label: 'Kusaku Stamp ${s['stamp']['title']}',
          points: s['points_used'],
        );
      }).toList();

      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _error = 'Tidak dapat terhubung ke server';
      _isLoading = false;
    });
  }
}

  String _formatDate(DateTime d) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  String _formatMonth(DateTime d) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title: const Text(
          'Kusaku Point',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1D4ED8)),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 48, color: Color(0xFF9CA3AF)),
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _fetchPoints,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Points summary header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      color: const Color(0xFFEFF6FF),
                      child: Column(
                        children: [
                          Text(
                            '$_totalPoints',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Setara dengan Rp $_totalPoints',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tabs
                    TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFF1D4ED8),
                      unselectedLabelColor: const Color(0xFF6B7280),
                      indicatorColor: const Color(0xFF1D4ED8),
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                      unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w400, fontSize: 14),
                      tabs: const [
                        Tab(text: 'Didapat'),
                        Tab(text: 'Terpakai'),
                      ],
                    ),

                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _didapat.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Belum ada poin yang didapat',
                                    style: TextStyle(color: Color(0xFF6B7280)),
                                  ),
                                )
                              : _TransactionList(
                                  transactions: _didapat,
                                  isEarned: true,
                                ),
                          _terpakai.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Belum ada poin yang terpakai',
                                    style: TextStyle(color: Color(0xFF6B7280)),
                                  ),
                                )
                              : _TransactionList(
                                  transactions: _terpakai,
                                  isEarned: false,
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<_PointTransaction> transactions;
  final bool isEarned;

  const _TransactionList({required this.transactions, required this.isEarned});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<_PointTransaction>> grouped = {};
    for (final t in transactions) {
      grouped.putIfAbsent(t.month, () => []).add(t);
    }

    return ListView(
      children: grouped.entries.expand((entry) {
        return [
          Container(
            width: double.infinity,
            color: const Color(0xFFF3F4F6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              entry.key,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...entry.value.map(
            (t) => _TransactionTile(transaction: t, isEarned: isEarned),
          ),
        ];
      }).toList(),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final _PointTransaction transaction;
  final bool isEarned;

  const _TransactionTile({required this.transaction, required this.isEarned});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            transaction.date,
            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  transaction.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Text(
                '${isEarned ? "+" : "-"}${_formatPoints(transaction.points)} Points',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isEarned
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const Divider(height: 16, thickness: 0.5, color: Color(0xFFE5E7EB)),
        ],
      ),
    );
  }

  String _formatPoints(int points) {
    return points.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}

class _PointTransaction {
  final String date;
  final String month;
  final String label;
  final int points;

  const _PointTransaction({
    required this.date,
    required this.month,
    required this.label,
    required this.points,
  });
}