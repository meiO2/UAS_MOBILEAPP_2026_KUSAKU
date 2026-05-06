import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatSiPintarPage extends StatelessWidget {
  const ChatSiPintarPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Si Pintar')),
        body: const Center(child: Text('Halaman Si Pintar')),
      );
}

class FinanceService {
  static Future<Map<String, dynamic>> fetchBalance(int userId) async =>
      {'balance': 5000000.0, 'total_income': 10000000.0};

  static Future<List<dynamic>> fetchBudgets(int userId) async => [
        {
          'percentage': 30,
          'remaining_amount': 750000,
          'category': {'name': 'Makan & Minum'},
        },
        {
          'percentage': 20,
          'remaining_amount': 400000,
          'category': {'name': 'Transportasi'},
        },
        {
          'percentage': 0,  // ← filtered out; should NOT appear
          'remaining_amount': 0,
          'category': {'name': 'HiddenCategory'},
        },
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Full FinancePage implementation (inline so integration test is self-contained)
// ─────────────────────────────────────────────────────────────────────────────

class _CalendarDay {
  final String day;
  final int date;
  final bool isToday;
  const _CalendarDay({required this.day, required this.date, this.isToday = false});
}

class _DayCell extends StatelessWidget {
  final _CalendarDay day;
  const _DayCell({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(day.day,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E3A8A))),
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
            child: Text('${day.date}',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        day.isToday ? FontWeight.w700 : FontWeight.w800,
                    color:
                        day.isToday ? Colors.white : const Color(0xFF1E3A8A))),
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
    super.key,
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
                Text(label,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827))),
                const Text('Sisa bulan ini',
                    style:
                        TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
          Text(formatRp(sisaBulanIni),
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827))),
        ],
      ),
    );
  }
}

class _EmptyBudgetState extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyBudgetState({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet_outlined,
                size: 64, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 16),
            const Text('Kamu belum mengatur budget',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827))),
            const SizedBox(height: 8),
            const Text(
              'Yuk atur budget kamu dulu supaya pengeluaran lebih terkontrol!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Atur Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId =
          prefs.getInt('user_id') ?? int.tryParse(prefs.getString('user_id') ?? '0') ?? 0;

      final results = await Future.wait([
        FinanceService.fetchBalance(userId),
        FinanceService.fetchBudgets(userId),
      ]);

      final balanceData = results[0] as Map<String, dynamic>;
      final budgetData  = results[1] as List<dynamic>;

      setState(() {
        _balance     = (balanceData['balance'] as num).toDouble();
        _totalIncome = (balanceData['total_income'] as num).toDouble();
        _budgets     = budgetData
            .where((b) => (b['percentage'] as num) > 0)
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  String _formatRp(double amount) =>
      'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      )}';

  String _getDaysRemainingLabel() {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final remaining = lastDay.difference(now).inDays + 1;
    const monthNames = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return 'Bulan ${monthNames[now.month]} tersisa $remaining hari lagi';
  }

  String _getMonthYearLabel() {
    final now = DateTime.now();
    const monthNames = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${monthNames[now.month]} ${now.year}';
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
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          children: [
            Container(
              width: double.infinity,
              color: const Color.fromARGB(255, 233, 246, 255),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saldo card
                  GestureDetector(
                    key: const Key('saldo_card'),
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (_) => const ChatSiPintarPage()))
                        .then((_) => _loadData()),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Saldo Bulan Ini',
                              style: TextStyle(
                                  color: Color(0xFF1E3A8A),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text(
                            _isLoading ? 'Memuat...' : _formatRp(_balance),
                            key: const Key('balance_text'),
                            style: const TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontSize: 24,
                                fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),
                          Text(_getDaysRemainingLabel(),
                              key: const Key('days_remaining_text'),
                              style: const TextStyle(
                                  color: Color(0xFF1E3A8A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Month/year label
                  Center(
                    child: Text(
                      _getMonthYearLabel(),
                      key: const Key('month_year_label'),
                      style: const TextStyle(
                          color: Color.fromARGB(255, 109, 143, 255),
                          fontSize: 18,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Week row
                  SingleChildScrollView(
                    key: const Key('week_scroll'),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: weekDays
                          .map((d) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: _DayCell(day: d),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Budget list or empty state
            if (_isLoading)
              const SizedBox(
                height: 200,
                child: Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF1D4ED8))),
              )
            else if (_budgets.isEmpty)
              _EmptyBudgetState(
                key: const Key('empty_budget'),
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (_) => const ChatSiPintarPage()))
                    .then((_) => _loadData()),
              )
            else
              ..._budgets.map((budget) {
                final name = budget['category']['name'] as String;
                final remaining = (budget['remaining_amount'] as num).toDouble();
                return _CategoryTile(
                  key: Key('tile_$name'),
                  icon: _iconMap[name] ?? Icons.category_outlined,
                  iconColor: const Color.fromARGB(255, 70, 119, 255),
                  label: name,
                  sisaBulanIni: remaining,
                  formatRp: _formatRp,
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Pump FinancePage with a faked SharedPreferences user_id
  Future<void> pumpFinancePage(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'user_id': 1});
    await tester.pumpWidget(
      const MaterialApp(home: FinancePage()),
    );
    // Let async _loadData complete
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  group('[Integration] AppBar', () {
    testWidgets('shows correct app bar title', (tester) async {
      await pumpFinancePage(tester);
      expect(find.text('Pengaturan Keuanganmu'), findsOneWidget);
    });

    testWidgets('app bar has correct blue background', (tester) async {
      await pumpFinancePage(tester);
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(const Color.fromARGB(255, 21, 60, 167)));
    });
  });

  group('[Integration] Balance card', () {
    testWidgets('"Saldo Bulan Ini" label is visible', (tester) async {
      await pumpFinancePage(tester);
      expect(find.text('Saldo Bulan Ini'), findsOneWidget);
    });

    testWidgets('balance amount is displayed after loading', (tester) async {
      await pumpFinancePage(tester);
      expect(find.byKey(const Key('balance_text')), findsOneWidget);
      final text = tester.widget<Text>(find.byKey(const Key('balance_text')));
      expect(text.data, equals('Rp 5.000.000'));
    });

    testWidgets('loading indicator resolves and balance text appears', (tester) async {
      SharedPreferences.setMockInitialValues({'user_id': 1});
      await tester.pumpWidget(const MaterialApp(home: FinancePage()));
      // Let all async work finish
      await tester.pumpAndSettle(const Duration(seconds: 2));
      // After loading completes, the real balance must be shown (not "Memuat...")
      expect(find.text('Memuat...'), findsNothing);
      expect(find.byKey(const Key('balance_text')), findsOneWidget);
    });

    testWidgets('days remaining label is shown', (tester) async {
      await pumpFinancePage(tester);
      final label = tester.widget<Text>(
          find.byKey(const Key('days_remaining_text')));
      expect(label.data, contains('hari lagi'));
    });
  });

  group('[Integration] Calendar week strip', () {
    testWidgets('month/year header is visible', (tester) async {
      await pumpFinancePage(tester);
      final label = tester.widget<Text>(
          find.byKey(const Key('month_year_label')));
      expect(label.data, isNotEmpty);
      // Contains a 4-digit year
      expect(label.data, matches(RegExp(r'\d{4}')));
    });

    testWidgets('all 7 day-abbreviation labels are rendered', (tester) async {
      await pumpFinancePage(tester);
      for (final day in ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']) {
        expect(find.text(day), findsOneWidget,
            reason: '$day should appear in the week strip');
      }
    });

    testWidgets('horizontal scroll view is present for the week strip',
        (tester) async {
      await pumpFinancePage(tester);
      expect(find.byKey(const Key('week_scroll')), findsOneWidget);
    });
  });

  group('[Integration] Category budget tiles', () {
    testWidgets('Makan & Minum tile is visible', (tester) async {
      await pumpFinancePage(tester);
      expect(find.text('Makan & Minum'), findsOneWidget);
    });

    testWidgets('Transportasi tile is visible', (tester) async {
      await pumpFinancePage(tester);
      expect(find.text('Transportasi'), findsOneWidget);
    });

    testWidgets('Makan & Minum tile shows correct remaining amount',
        (tester) async {
      await pumpFinancePage(tester);
      expect(find.text('Rp 750.000'), findsOneWidget);
    });

    testWidgets('Transportasi tile shows correct remaining amount',
        (tester) async {
      await pumpFinancePage(tester);
      expect(find.text('Rp 400.000'), findsOneWidget);
    });

    testWidgets('"Sisa bulan ini" subtitle appears for each budget tile',
        (tester) async {
      await pumpFinancePage(tester);
      // Two tiles, each with its own subtitle
      expect(find.text('Sisa bulan ini'), findsNWidgets(2));
    });

    testWidgets('budget with 0% is NOT rendered (filter check)', (tester) async {
      await pumpFinancePage(tester);
      // 'HiddenCategory' from the stub has percentage == 0
      expect(find.text('HiddenCategory'), findsNothing);
    });
  });

  group('[Integration] Empty budget state', () {
    Future<void> pumpEmpty(WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'user_id': 1});
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: _EmptyBudgetState(onTap: () {}),
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('headline is shown', (tester) async {
      await pumpEmpty(tester);
      expect(find.text('Kamu belum mengatur budget'), findsOneWidget);
    });

    testWidgets('subtitle is shown', (tester) async {
      await pumpEmpty(tester);
      expect(
        find.text(
          'Yuk atur budget kamu dulu supaya pengeluaran lebih terkontrol!',
        ),
        findsOneWidget,
      );
    });

    testWidgets('wallet icon is shown', (tester) async {
      await pumpEmpty(tester);
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    });

    testWidgets('"Atur Sekarang" button is tappable and fires callback',
        (tester) async {
      bool tapped = false;
      SharedPreferences.setMockInitialValues({'user_id': 1});
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: _EmptyBudgetState(onTap: () => tapped = true),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Atur Sekarang'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });

  group('[Integration] Navigation – saldo card → ChatSiPintarPage', () {
    testWidgets('tapping saldo card navigates to Si Pintar page', (tester) async {
      await pumpFinancePage(tester);
      await tester.tap(find.byKey(const Key('saldo_card')));
      await tester.pumpAndSettle();
      expect(find.text('Si Pintar'), findsOneWidget);
    });

    testWidgets('back navigation returns to FinancePage', (tester) async {
      await pumpFinancePage(tester);
      await tester.tap(find.byKey(const Key('saldo_card')));
      await tester.pumpAndSettle();

      // Pop back
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Pengaturan Keuanganmu'), findsOneWidget);
    });
  });

  group('[Integration] Pull-to-refresh', () {
    testWidgets('RefreshIndicator is present in the widget tree', (tester) async {
      await pumpFinancePage(tester);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}