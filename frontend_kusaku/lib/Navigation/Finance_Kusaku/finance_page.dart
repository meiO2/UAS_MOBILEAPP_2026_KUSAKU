import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_kusaku/Navigation/Finance_Kusaku/chat_si_pintar_page.dart';
import 'package:frontend_kusaku/services/finance_service.dart';
import 'dart:async';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  double _balance = 0;
  double _totalIncome = 0;
  List<dynamic> _budgets = [];
  bool _isLoading = true;
  bool _isPolling = false;
  Timer? _pollTimer;

  static const Map<String, IconData> _iconMap = {
    'Kebutuhan Rumah': Icons.home_outlined,
    'Makan & Minum':   Icons.restaurant_outlined,
    'Transportasi':    Icons.directions_car_outlined,
    'Investasi':       Icons.trending_up_outlined,
    'Tabungan':        Icons.savings_outlined,
    'Hiburan':         Icons.movie_outlined,
    'Tagihan':         Icons.receipt_outlined,
    'Kesehatan':       Icons.local_hospital_outlined,
    'Pendidikan':      Icons.school_outlined,
  };

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _pollData());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? int.tryParse(prefs.getString('user_id') ?? '0');
      if (userId == null) {
        print('❌ NO USER ID');
        return;
      }

      print('✅ userId: $userId');

      final results = await Future.wait([
        FinanceService.fetchBalance(userId),
        FinanceService.fetchBudgets(userId),
      ]);

      final balanceData = results[0] as Map<String, dynamic>;
      final budgetData  = results[1] as List<dynamic>;

      setState(() {
        _balance     = (balanceData['balance'] as num).toDouble();
        _totalIncome = (balanceData['total_income'] as num).toDouble();
        _budgets = budgetData
          .where((b) => (b['percentage'] as num) > 0)
          .toList();
        print('✅ FILTERED BUDGETS: ${_budgets.length}');
        _isLoading = false;
      });
    } catch (e, stack) {
      print('❌ ERROR: $e');
      print(stack);
      setState(() => _isLoading = false);
    }
  }

  String _formatRp(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  String _getDaysRemainingLabel() {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final remaining = lastDay.difference(now).inDays + 1;
    final monthName = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ][now.month];
    return 'Bulan $monthName tersisa $remaining hari lagi';
  }

  String _getMonthYearLabel() {
    final now = DateTime.now();
    final monthName = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ][now.month];
    return '$monthName ${now.year}';
  }

  List<_CalendarDay> _getCurrentWeekDays() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    const dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return List.generate(7, (i) {
      final day = startOfWeek.add(Duration(days: i));
      return _CalendarDay(
        day: dayLabels[i],
        date: day.day,
        isToday: day.day == now.day &&
                 day.month == now.month &&
                 day.year == now.year,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getCurrentWeekDays();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 60, 167),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Pengaturan Keuanganmu',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          children: [
            // ── Header ──
            Container(
              width: double.infinity,
              color: const Color.fromARGB(255, 233, 246, 255),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Saldo card ──
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ChatSiPintarPage()),
                    ).then((_) => _loadData()),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FF),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Saldo Bulan Ini',
                                  style: TextStyle(
                                    color: Color(0xFF1E3A8A),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  _isLoading ? 'Memuat...' : _formatRp(_balance),
                                  style: const TextStyle(
                                    color: Color(0xFF1E3A8A),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Divider(
                                  color: const Color(0xFF1E3A8A).withOpacity(0.3),
                                  thickness: 1,
                                  height: 1,
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  _getDaysRemainingLabel(),
                                  style: const TextStyle(
                                    color: Color(0xFF1E3A8A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              width: 60,
                              height: 60,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 208, 55, 255).withOpacity(0.67),
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/sipintar/sipintar.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Calendar ──
                  Center(
                    child: Text(
                      _getMonthYearLabel(),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 109, 143, 255),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Scrollable week row ──
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: weekDays
                          .map((d) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: _DayCell(day: d),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),

            // ── Category list ──
            if (_isLoading)
              const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator(color: Color(0xFF1D4ED8))),
              )
            else if (_budgets.isEmpty)
              _EmptyBudgetState(onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChatSiPintarPage()),
                ).then((_) => _loadData());
              })
            else
              ..._budgets.map((budget) {
                final categoryName = budget['category']['name'] as String;
                final remaining = (budget['remaining_amount'] as num).toDouble();
                return _CategoryTile(
                  icon: _iconMap[categoryName] ?? Icons.category_outlined,
                  iconColor: const Color.fromARGB(255, 70, 119, 255),
                  label: categoryName,
                  sisaBulanIni: remaining,
                  formatRp: _formatRp,
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Future<void> _pollData() async {
    if (_isPolling) return;
    _isPolling = true;
    try {
      await _loadData();
    } finally {
      _isPolling = false;
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}


class _DayCell extends StatelessWidget {
  final _CalendarDay day;
  const _DayCell({required this.day});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          day.day,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 65,
          height: 30,
          decoration: BoxDecoration(
            color: day.isToday
                ? const Color.fromARGB(255, 86, 154, 255)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${day.date}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: day.isToday ? FontWeight.w700 : FontWeight.w800,
                color: day.isToday ? Colors.white : const Color(0xFF1E3A8A),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final double sisaBulanIni;
  final String Function(double) formatRp;

  const _CategoryTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sisaBulanIni,
    required this.formatRp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const Text(
                  'Sisa bulan ini',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
          Text(
            formatRp(sisaBulanIni),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarDay {
  final String day;
  final int date;
  final bool isToday;
  const _CalendarDay({
    required this.day,
    required this.date,
    this.isToday = false,
  });
}

class _EmptyBudgetState extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyBudgetState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kamu belum mengatur budget',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Yuk atur budget kamu dulu supaya pengeluaran lebih terkontrol!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Atur Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}