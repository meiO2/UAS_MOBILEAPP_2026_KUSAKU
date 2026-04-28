import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../config/api_config.dart';

class _StampCard {
  final int id;
  final String imageUrl;
  final String title;
  final int points;
  final String deadline;
  final String rewardLabel;
  final bool isExpired;

  const _StampCard({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.points,
    required this.deadline,
    required this.rewardLabel,
    required this.isExpired,
  });

  factory _StampCard.fromJson(Map<String, dynamic> json) {
    final DateTime dt = DateTime.parse(json['deadline']).toLocal();
    const List<String> bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return _StampCard(
      id: json['id'],
      imageUrl: json['image'] ?? '',
      title: json['title'] ?? '',
      points: json['points_needed'] ?? 0,
      deadline: '${dt.day} ${bulan[dt.month]} ${dt.year}',
      rewardLabel: json['reward_label'] ?? '',
      isExpired: json['is_expired'] ?? false,
    );
  }
}

class KusakuStampPage extends StatefulWidget {
  const KusakuStampPage({super.key});

  @override
  State<KusakuStampPage> createState() => _KusakuStampPageState();
}

class _KusakuStampPageState extends State<KusakuStampPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isLoading = true;
  String? _errorMessage;
  int _userPoints = 0;
  int? _userId;

  List<_StampCard> _aktif = [];
  List<_StampCard> _tidakAktif = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        setState(() {
          _errorMessage = 'Sesi tidak ditemukan, silakan login ulang';
          _isLoading = false;
        });
        return;
      }

      _userId = userId;

      final results = await Future.wait([
        http.get(Uri.parse('${ApiConfig.baseUrl}stamp/view/')),
        http.get(Uri.parse('${ApiConfig.baseUrl}balance/$userId/')),
      ]);

      if (results[0].statusCode != 200) {
        setState(() {
          _errorMessage = 'Gagal memuat stamp (${results[0].statusCode})';
          _isLoading = false;
        });
        return;
      }

      final allStamps = (jsonDecode(results[0].body) as List)
          .map((e) => _StampCard.fromJson(e))
          .toList();

      int userPoints = 0;
      if (results[1].statusCode == 200) {
        userPoints = (jsonDecode(results[1].body)['kusaku_points'] ?? 0) as int;
      }

      setState(() {
        _aktif = allStamps.where((s) => !s.isExpired).toList();
        _tidakAktif = allStamps.where((s) => s.isExpired).toList();
        _userPoints = userPoints;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Koneksi gagal: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _redeem(_StampCard card) async {
    if (_userPoints < card.points) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Poin tidak cukup. Kamu punya $_userPoints poin, butuh ${card.points}.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tukar Stamp?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
            'Kamu akan menukar ${card.points} Kusaku Points untuk "${card.title}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D4ED8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Ya, tukar'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}stamps/redeem/${card.id}/$_userId/'),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stamp berhasil ditukarkan! 🎉'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
        _loadData();
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'Gagal menukar stamp.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Koneksi gagal: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title: const Text('Kusaku Stamp',
            style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(text: 'Aktif'),
            Tab(text: 'Tidak aktif'),
          ],
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
                          onPressed: _loadData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D4ED8),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _StampList(
                      cards: _aktif,
                      isActive: true,
                      userPoints: _userPoints,
                      onRedeem: _redeem,
                    ),
                    _StampList(
                      cards: _tidakAktif,
                      isActive: false,
                      userPoints: _userPoints,
                      onRedeem: _redeem,
                    ),
                  ],
                ),
    );
  }
}

class _StampList extends StatelessWidget {
  final List<_StampCard> cards;
  final bool isActive;
  final int userPoints;
  final Future<void> Function(_StampCard) onRedeem;

  const _StampList({
    required this.cards,
    required this.isActive,
    required this.userPoints,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard_outlined,
                size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              isActive ? 'Belum ada stamp aktif' : 'Belum ada stamp tidak aktif',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cards.length,
      itemBuilder: (_, i) => _StampCardWidget(
        card: cards[i],
        userPoints: userPoints,
        onRedeem: onRedeem,
        isActive: isActive,
      ),
    );
  }
}

class _StampCardWidget extends StatelessWidget {
  final _StampCard card;
  final int userPoints;
  final bool isActive;
  final Future<void> Function(_StampCard) onRedeem;

  const _StampCardWidget({
    required this.card,
    required this.userPoints,
    required this.isActive,
    required this.onRedeem,
  });

  String _formatPoints(int p) => p
      .toString()
      .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    final bool canRedeem = isActive && userPoints >= card.points;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 130,
                  child: card.imageUrl.isNotEmpty
                      ? Image.network(
                          '${ApiConfig.baseUrl.replaceAll('api/', '')}${card.imageUrl.startsWith('/') ? card.imageUrl.substring(1) : card.imageUrl}',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBBF24),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Reward',
                            style: TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        Text(card.rewardLabel,
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
                if (!isActive)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                      ),
                      child: const Center(
                        child: Text('KADALUARSA',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 2)),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Info + redeem button
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF111827))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.card_giftcard,
                        size: 16, color: Color(0xFF1D4ED8)),
                    const SizedBox(width: 6),
                    Text('${_formatPoints(card.points)} Kusaku Points',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D4ED8))),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Berlaku sampai ${card.deadline}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280))),
                if (isActive) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canRedeem ? () => onRedeem(card) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D4ED8),
                        disabledBackgroundColor: const Color(0xFFBFDBFE),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        canRedeem ? 'Tukar Sekarang' : 'Poin Tidak Cukup',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFF1E3A8A),
        child: Center(
          child: Icon(Icons.image_outlined,
              size: 40, color: Colors.white.withOpacity(0.4)),
        ),
      );
}