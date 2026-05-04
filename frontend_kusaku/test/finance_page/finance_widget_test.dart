import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class CalendarDay {
  final String day;
  final int date;
  final bool isToday;
  const CalendarDay({required this.day, required this.date, this.isToday = false});
}

class DayCell extends StatelessWidget {
  final CalendarDay day;
  const DayCell({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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

String _formatRp(double amount) {
  return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  )}';
}

class CategoryTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final double sisaBulanIni;
  final String Function(double) formatRp;

  const CategoryTile({
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

class EmptyBudgetState extends StatelessWidget {
  final VoidCallback onTap;
  const EmptyBudgetState({super.key, required this.onTap});

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
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
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

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('[Widget] DayCell', () {
    testWidgets('renders day abbreviation text', (tester) async {
      await tester.pumpWidget(
        wrap(DayCell(day: const CalendarDay(day: 'Mon', date: 5))),
      );
      expect(find.text('Mon'), findsOneWidget);
    });

    testWidgets('renders date number as text', (tester) async {
      await tester.pumpWidget(
        wrap(DayCell(day: const CalendarDay(day: 'Tue', date: 17))),
      );
      expect(find.text('17'), findsOneWidget);
    });

    testWidgets('today cell has blue highlight container', (tester) async {
      await tester.pumpWidget(
        wrap(DayCell(day: const CalendarDay(day: 'Wed', date: 11, isToday: true))),
      );

      final highlighted = tester.widgetList<Container>(find.byType(Container))
          .where((c) {
        final deco = c.decoration;
        return deco is BoxDecoration &&
            deco.color == const Color.fromARGB(255, 86, 154, 255);
      });
      expect(highlighted, isNotEmpty);
    });

    testWidgets('non-today cell has no blue highlight', (tester) async {
      await tester.pumpWidget(
        wrap(DayCell(day: const CalendarDay(day: 'Thu', date: 12, isToday: false))),
      );

      final highlighted = tester.widgetList<Container>(find.byType(Container))
          .where((c) {
        final deco = c.decoration;
        return deco is BoxDecoration &&
            deco.color == const Color.fromARGB(255, 86, 154, 255);
      });
      expect(highlighted, isEmpty);
    });

    testWidgets('today date text is white', (tester) async {
      await tester.pumpWidget(
        wrap(DayCell(day: const CalendarDay(day: 'Fri', date: 9, isToday: true))),
      );
      final dateTexts = tester.widgetList<Text>(find.text('9'));
      expect(dateTexts.any((t) => t.style?.color == Colors.white), isTrue);
    });

    testWidgets('non-today date text is dark blue', (tester) async {
      await tester.pumpWidget(
        wrap(DayCell(day: const CalendarDay(day: 'Sat', date: 10, isToday: false))),
      );
      final dateTexts = tester.widgetList<Text>(find.text('10'));
      expect(
        dateTexts.any((t) => t.style?.color == const Color(0xFF1E3A8A)),
        isTrue,
      );
    });

    testWidgets('today label text also renders in dark blue', (tester) async {
      await tester.pumpWidget(
        wrap(DayCell(day: const CalendarDay(day: 'Sun', date: 1, isToday: true))),
      );
      final labelTexts = tester.widgetList<Text>(find.text('Sun'));
      expect(
        labelTexts.any((t) => t.style?.color == const Color(0xFF1E3A8A)),
        isTrue,
      );
    });

    testWidgets('contains a Column at its root', (tester) async {
      await tester.pumpWidget(
        wrap(DayCell(day: const CalendarDay(day: 'Mon', date: 3))),
      );
      expect(find.byType(Column), findsWidgets);
    });
  });

  group('[Widget] CategoryTile', () {
    Widget buildTile({
      IconData icon = Icons.restaurant_outlined,
      Color iconColor = const Color(0xFF4677FF),
      String label = 'Makan & Minum',
      double sisaBulanIni = 750000,
    }) {
      return wrap(CategoryTile(
        icon: icon,
        iconColor: iconColor,
        label: label,
        sisaBulanIni: sisaBulanIni,
        formatRp: _formatRp,
      ));
    }

    testWidgets('renders category label', (tester) async {
      await tester.pumpWidget(buildTile(label: 'Makan & Minum'));
      expect(find.text('Makan & Minum'), findsOneWidget);
    });

    testWidgets('renders "Sisa bulan ini" subtitle', (tester) async {
      await tester.pumpWidget(buildTile());
      expect(find.text('Sisa bulan ini'), findsOneWidget);
    });

    testWidgets('renders provided icon', (tester) async {
      await tester.pumpWidget(buildTile(icon: Icons.home_outlined));
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    });

    testWidgets('shows formatted Rp amount – 750 000', (tester) async {
      await tester.pumpWidget(buildTile(sisaBulanIni: 750000));
      expect(find.text('Rp 750.000'), findsOneWidget);
    });

    testWidgets('shows formatted Rp amount – 1 500 000', (tester) async {
      await tester.pumpWidget(buildTile(sisaBulanIni: 1500000));
      expect(find.text('Rp 1.500.000'), findsOneWidget);
    });

    testWidgets('shows "Rp 0" when remaining amount is zero', (tester) async {
      await tester.pumpWidget(buildTile(sisaBulanIni: 0));
      expect(find.text('Rp 0'), findsOneWidget);
    });

    testWidgets('renders all 9 supported category icons without error',
        (tester) async {
      const iconMap = {
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
      for (final entry in iconMap.entries) {
        await tester.pumpWidget(
          buildTile(icon: entry.value, label: entry.key),
        );
        expect(find.text(entry.key), findsOneWidget,
            reason: '${entry.key} label should render');
        expect(find.byIcon(entry.value), findsOneWidget,
            reason: '${entry.key} icon should render');
      }
    });

    testWidgets('contains an Icon widget', (tester) async {
      await tester.pumpWidget(buildTile());
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('contains a Row at its root', (tester) async {
      await tester.pumpWidget(buildTile());
      expect(find.byType(Row), findsWidgets);
    });
  });

  group('[Widget] EmptyBudgetState', () {
    testWidgets('renders headline text', (tester) async {
      await tester.pumpWidget(wrap(EmptyBudgetState(onTap: () {})));
      expect(find.text('Kamu belum mengatur budget'), findsOneWidget);
    });

    testWidgets('renders descriptive subtitle', (tester) async {
      await tester.pumpWidget(wrap(EmptyBudgetState(onTap: () {})));
      expect(
        find.textContaining('pengeluaran lebih terkontrol'),
        findsOneWidget,
      );
    });

    testWidgets('renders wallet icon', (tester) async {
      await tester.pumpWidget(wrap(EmptyBudgetState(onTap: () {})));
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    });

    testWidgets('"Atur Sekarang" button is visible', (tester) async {
      await tester.pumpWidget(wrap(EmptyBudgetState(onTap: () {})));
      expect(find.text('Atur Sekarang'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('"Atur Sekarang" button fires the onTap callback', (tester) async {
      bool fired = false;
      await tester.pumpWidget(
        wrap(EmptyBudgetState(onTap: () => fired = true)),
      );
      await tester.tap(find.text('Atur Sekarang'));
      await tester.pump();
      expect(fired, isTrue);
    });

    testWidgets('onTap is only called once per tap', (tester) async {
      int callCount = 0;
      await tester.pumpWidget(
        wrap(EmptyBudgetState(onTap: () => callCount++)),
      );
      await tester.tap(find.text('Atur Sekarang'));
      await tester.pump();
      expect(callCount, equals(1));
    });

    testWidgets('contains a Center widget at root', (tester) async {
      await tester.pumpWidget(wrap(EmptyBudgetState(onTap: () {})));
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('full subtitle text is present', (tester) async {
      await tester.pumpWidget(wrap(EmptyBudgetState(onTap: () {})));
      expect(
        find.text(
          'Yuk atur budget kamu dulu supaya pengeluaran lebih terkontrol!',
        ),
        findsOneWidget,
      );
    });
  });

  group('[Widget] Balance display via _formatRp in CategoryTile', () {
    testWidgets('large balance 5 000 000 renders correctly', (tester) async {
      await tester.pumpWidget(wrap(CategoryTile(
        icon: Icons.savings_outlined,
        iconColor: Colors.blue,
        label: 'Tabungan',
        sisaBulanIni: 5000000,
        formatRp: _formatRp,
      )));
      expect(find.text('Rp 5.000.000'), findsOneWidget);
    });

    testWidgets('small balance 500 renders correctly', (tester) async {
      await tester.pumpWidget(wrap(CategoryTile(
        icon: Icons.savings_outlined,
        iconColor: Colors.blue,
        label: 'Tabungan',
        sisaBulanIni: 500,
        formatRp: _formatRp,
      )));
      expect(find.text('Rp 500'), findsOneWidget);
    });
  });
}