import 'package:flutter_test/flutter_test.dart';

/// Matches _FinancePageState._formatRp
String formatRp(double amount) {
  return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  )}';
}

/// Matches _FinancePageState._getDaysRemainingLabel
String getDaysRemainingLabel(DateTime now) {
  final lastDay = DateTime(now.year, now.month + 1, 0);
  final remaining = lastDay.difference(now).inDays + 1;
  const monthNames = [
    '',
    'Januari', 'Februari', 'Maret',    'April',   'Mei',      'Juni',
    'Juli',    'Agustus',  'September', 'Oktober', 'November', 'Desember',
  ];
  return 'Bulan ${monthNames[now.month]} tersisa $remaining hari lagi';
}

/// Matches _FinancePageState._getMonthYearLabel
String getMonthYearLabel(DateTime now) {
  const monthNames = [
    '',
    'Januari', 'Februari', 'Maret',    'April',   'Mei',      'Juni',
    'Juli',    'Agustus',  'September', 'Oktober', 'November', 'Desember',
  ];
  return '${monthNames[now.month]} ${now.year}';
}

class CalendarDay {
  final String day;
  final int date;
  final bool isToday;
  const CalendarDay({
    required this.day,
    required this.date,
    this.isToday = false,
  });
}

List<CalendarDay> getCurrentWeekDays(DateTime now) {
  final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
  const dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  return List.generate(7, (i) {
    final day = startOfWeek.add(Duration(days: i));
    return CalendarDay(
      day: dayLabels[i],
      date: day.day,
      isToday: day.day == now.day &&
          day.month == now.month &&
          day.year == now.year,
    );
  });
}

/// Mirrors the budget filter: only budgets with percentage > 0 are shown.
List<Map<String, dynamic>> filterBudgets(List<Map<String, dynamic>> raw) {
  return raw.where((b) => (b['percentage'] as num) > 0).toList();
}

void main() {
  group('[Unit] formatRp – balance amount formatting', () {
    test('formats zero as "Rp 0"', () {
      expect(formatRp(0), equals('Rp 0'));
    });

    test('formats sub-thousand: 500 → "Rp 500"', () {
      expect(formatRp(500), equals('Rp 500'));
    });

    test('formats exact thousand: 1000 → "Rp 1.000"', () {
      expect(formatRp(1000), equals('Rp 1.000'));
    });

    test('formats 750 000 → "Rp 750.000"', () {
      expect(formatRp(750000), equals('Rp 750.000'));
    });

    test('formats 5 000 000 → "Rp 5.000.000"', () {
      expect(formatRp(5000000), equals('Rp 5.000.000'));
    });

    test('formats 10 000 000 → "Rp 10.000.000"', () {
      expect(formatRp(10000000), equals('Rp 10.000.000'));
    });

    test('formats 100 000 000 → "Rp 100.000.000"', () {
      expect(formatRp(100000000), equals('Rp 100.000.000'));
    });

    test('always starts with "Rp "', () {
      for (final v in [0, 999, 12345, 9999999]) {
        expect(formatRp(v.toDouble()), startsWith('Rp '));
      }
    });

    test('truncates decimal part (toStringAsFixed(0))', () {
      expect(formatRp(1500.75), equals('Rp 1.501'));
    });
  });

  group('[Unit] getDaysRemainingLabel – days left in month', () {
    test('January 1st → 31 days remaining', () {
      expect(
        getDaysRemainingLabel(DateTime(2025, 1, 1)),
        equals('Bulan Januari tersisa 31 hari lagi'),
      );
    });

    test('January 31st → 1 day remaining', () {
      expect(
        getDaysRemainingLabel(DateTime(2025, 1, 31)),
        equals('Bulan Januari tersisa 1 hari lagi'),
      );
    });

    test('February 1st (non-leap 2025) → 28 days remaining', () {
      expect(
        getDaysRemainingLabel(DateTime(2025, 2, 1)),
        equals('Bulan Februari tersisa 28 hari lagi'),
      );
    });

    test('February 28th (non-leap 2025) → 1 day remaining', () {
      expect(
        getDaysRemainingLabel(DateTime(2025, 2, 28)),
        equals('Bulan Februari tersisa 1 hari lagi'),
      );
    });

    test('February 1st (leap 2024) → 29 days remaining', () {
      expect(
        getDaysRemainingLabel(DateTime(2024, 2, 1)),
        equals('Bulan Februari tersisa 29 hari lagi'),
      );
    });

    test('December 1st → 31 days remaining', () {
      expect(
        getDaysRemainingLabel(DateTime(2025, 12, 1)),
        equals('Bulan Desember tersisa 31 hari lagi'),
      );
    });

    test('contains correct Indonesian month name for every month', () {
      const expectedNames = {
        1:  'Januari',   2:  'Februari', 3:  'Maret',
        4:  'April',     5:  'Mei',       6:  'Juni',
        7:  'Juli',      8:  'Agustus',   9:  'September',
        10: 'Oktober',   11: 'November',  12: 'Desember',
      };
      for (final e in expectedNames.entries) {
        final label = getDaysRemainingLabel(DateTime(2025, e.key, 1));
        expect(label, contains(e.value),
            reason: 'Month ${e.key} should use "${e.value}"');
      }
    });

    test('label ends with "hari lagi"', () {
      expect(
        getDaysRemainingLabel(DateTime(2025, 6, 15)),
        endsWith('hari lagi'),
      );
    });
  });

  group('[Unit] getMonthYearLabel – header month/year string', () {
    test('returns "Januari 2025" for January 2025', () {
      expect(getMonthYearLabel(DateTime(2025, 1, 10)), equals('Januari 2025'));
    });

    test('returns "Juni 2025" for June 2025', () {
      expect(getMonthYearLabel(DateTime(2025, 6, 1)), equals('Juni 2025'));
    });

    test('returns "Desember 2024" for December 2024', () {
      expect(
          getMonthYearLabel(DateTime(2024, 12, 31)), equals('Desember 2024'));
    });

    test('includes the 4-digit year', () {
      final label = getMonthYearLabel(DateTime(2026, 3, 5));
      expect(label, contains('2026'));
    });
  });

  group('[Unit] CalendarDay model', () {
    test('stores day label correctly', () {
      const cd = CalendarDay(day: 'Mon', date: 12);
      expect(cd.day, equals('Mon'));
    });

    test('stores date correctly', () {
      const cd = CalendarDay(day: 'Mon', date: 12);
      expect(cd.date, equals(12));
    });

    test('isToday defaults to false', () {
      const cd = CalendarDay(day: 'Fri', date: 20);
      expect(cd.isToday, isFalse);
    });

    test('isToday can be set to true', () {
      const cd = CalendarDay(day: 'Fri', date: 20, isToday: true);
      expect(cd.isToday, isTrue);
    });

    test('accepts all seven day abbreviations without error', () {
      const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      for (var i = 0; i < labels.length; i++) {
        final cd = CalendarDay(day: labels[i], date: i + 1);
        expect(cd.day, equals(labels[i]));
      }
    });
  });

  group('[Unit] getCurrentWeekDays – weekly calendar logic', () {
    test('always returns exactly 7 days', () {
      final days = getCurrentWeekDays(DateTime(2025, 6, 11));
      expect(days.length, equals(7));
    });

    test('day labels are in Sun–Sat order', () {
      final days = getCurrentWeekDays(DateTime(2025, 6, 11));
      expect(
        days.map((d) => d.day).toList(),
        equals(['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']),
      );
    });

    test('exactly one day is marked isToday', () {
      final days = getCurrentWeekDays(DateTime(2025, 6, 11));
      expect(days.where((d) => d.isToday).length, equals(1));
    });

    test('2025-06-11 (Wednesday) is marked as isToday on Wed', () {
      final days = getCurrentWeekDays(DateTime(2025, 6, 11));
      final today = days.firstWhere((d) => d.isToday);
      expect(today.day, equals('Wed'));
      expect(today.date, equals(11));
    });

    test('2025-06-08 (Sunday) is marked as isToday on Sun', () {
      final days = getCurrentWeekDays(DateTime(2025, 6, 8));
      final today = days.firstWhere((d) => d.isToday);
      expect(today.day, equals('Sun'));
      expect(today.date, equals(8));
    });

    test('2025-06-14 (Saturday) is marked as isToday on Sat', () {
      final days = getCurrentWeekDays(DateTime(2025, 6, 14));
      final today = days.firstWhere((d) => d.isToday);
      expect(today.day, equals('Sat'));
      expect(today.date, equals(14));
    });

    test('dates are consecutive or wrap at month boundary', () {
      final days = getCurrentWeekDays(DateTime(2025, 6, 11));
      for (var i = 1; i < days.length; i++) {
        final prev = days[i - 1].date;
        final curr = days[i].date;
        expect(curr == prev + 1 || curr == 1, isTrue,
            reason: 'Expected $curr to follow $prev');
      }
    });

    test('all date values are valid calendar days (1–31)', () {
      final days = getCurrentWeekDays(DateTime(2025, 6, 11));
      for (final d in days) {
        expect(d.date, inInclusiveRange(1, 31));
      }
    });
  });

  group('[Unit] budget filter – only percentage > 0 is shown', () {
    test('removes budgets with percentage == 0', () {
      final raw = [
        {'percentage': 0,  'remaining_amount': 0,      'category': {'name': 'X'}},
        {'percentage': 30, 'remaining_amount': 750000, 'category': {'name': 'Makan & Minum'}},
      ];
      final filtered = filterBudgets(raw);
      expect(filtered.length, equals(1));
      expect(filtered.first['category']['name'], equals('Makan & Minum'));
    });

    test('keeps all budgets when all have percentage > 0', () {
      final raw = [
        {'percentage': 20, 'remaining_amount': 400000, 'category': {'name': 'Transportasi'}},
        {'percentage': 30, 'remaining_amount': 750000, 'category': {'name': 'Makan & Minum'}},
      ];
      expect(filterBudgets(raw).length, equals(2));
    });

    test('returns empty list when all percentages are 0', () {
      final raw = [
        {'percentage': 0, 'remaining_amount': 0, 'category': {'name': 'A'}},
        {'percentage': 0, 'remaining_amount': 0, 'category': {'name': 'B'}},
      ];
      expect(filterBudgets(raw), isEmpty);
    });

    test('returns empty list for empty input', () {
      expect(filterBudgets([]), isEmpty);
    });

    test('preserves category name and remaining_amount of kept budgets', () {
      final raw = [
        {'percentage': 15, 'remaining_amount': 250000, 'category': {'name': 'Hiburan'}},
      ];
      final result = filterBudgets(raw);
      expect(result.first['category']['name'], equals('Hiburan'));
      expect(result.first['remaining_amount'], equals(250000));
    });
  });
}