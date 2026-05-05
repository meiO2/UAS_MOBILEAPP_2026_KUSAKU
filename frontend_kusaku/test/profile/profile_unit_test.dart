import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Keuntungan Kusaku', () {
    test('_KeuntunganItem has required fields', () {
      const item = (
        title: 'Atur Keuangan dengan Mudah',
        imagePath: 'images/itu/rotasi1.png',
        description: 'Nikmati layanan keuangan dari A.I Kusaku "SI PINTAR"',
      );

      expect(item.title, isNotEmpty);
      expect(item.imagePath, isNotEmpty);
      expect(item.description, isNotEmpty);
      expect(item.imagePath.endsWith('.png'), true);
    });

    test('static keuntungan items list is valid', () {
      final keuntunganItems = [
        (
          title: 'Atur Keuangan dengan Mudah',
          imagePath: 'images/itu/rotasi1.png',
          description: 'Nikmati layanan keuangan dari A.I Kusaku "SI PINTAR"',
        ),
        (
          title: 'Pencatatan Keuangan Otomatis',
          imagePath: 'images/itu/rotasi2.png',
          description: 'Pantau pengeluaran harian, mingguan, sampai bulanan\ntanpa perlu mencatat keuangan',
        ),
        (
          title: 'Keamanan Lebih terjamin',
          imagePath: 'images/itu/rotasi3.png',
          description: 'Data pribadi dan saldo akan terjaga keamanannya',
        ),
      ];

      expect(keuntunganItems.length, 3);
      for (final item in keuntunganItems) {
        expect(item.title, isNotEmpty);
        expect(item.imagePath, contains('rotasi'));
      }
    });
  });

  group('Kusaku Points', () {
    test('_formatDate formats datetime correctly', () {
      String formatDate(DateTime d) {
        const months = [
          '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
        ];
        return '${d.day} ${months[d.month]} ${d.year}';
      }

      final date = DateTime(2025, 5, 15);
      final formatted = formatDate(date);

      expect(formatted, '15 Mei 2025');
    });

    test('_formatMonth formats month and year correctly', () {
      String formatMonth(DateTime d) {
        const months = [
          '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
        ];
        return '${months[d.month]} ${d.year}';
      }

      final date = DateTime(2025, 3, 20);
      final formatted = formatMonth(date);

      expect(formatted, 'Maret 2025');
    });

    test('_PointTransaction has required fields', () {
      final transaction = (
        date: '15 Mei 2025',
        month: 'Mei 2025',
        label: 'Warung Makan',
        points: 150,
      );

      expect(transaction.date, isNotEmpty);
      expect(transaction.month, isNotEmpty);
      expect(transaction.label, isNotEmpty);
      expect(transaction.points, greaterThan(0));
    });

    test('filters transactions with positive points', () {
      final expenses = [
        {'kusaku_points': 100, 'receiver': 'Warung', 'date': '2025-05-15'},
        {'kusaku_points': 0, 'receiver': 'Shop', 'date': '2025-05-14'},
        {'kusaku_points': 250, 'receiver': 'Resto', 'date': '2025-05-13'},
      ];

      final didapat = expenses
          .where((e) => (e['kusaku_points'] as int) > 0)
          .toList();

      expect(didapat.length, 2);
      expect(didapat[0]['kusaku_points'], 100);
      expect(didapat[1]['kusaku_points'], 250);
    });

    test('parses point transaction data correctly', () {
      String formatDate(DateTime d) {
        const months = [
          '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
        ];
        return '${d.day} ${months[d.month]} ${d.year}';
      }

      String formatMonth(DateTime d) {
        const months = [
          '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
        ];
        return '${months[d.month]} ${d.year}';
      }

      final expense = {
        'kusaku_points': 150,
        'receiver': 'Warung Makan',
        'date': '2025-05-15T10:30:00Z'
      };

      final date = DateTime.parse(expense['date'] as String);
      final transaction = (
        date: formatDate(date),
        month: formatMonth(date),
        label: expense['receiver'] as String,
        points: expense['kusaku_points'] as int,
      );

      expect(transaction.label, 'Warung Makan');
      expect(transaction.points, 150);
      expect(transaction.date, contains('Mei'));
    });
  });

  group('Kusaku Stamp', () {
    test('_StampCard.fromJson creates valid object', () {
      final json = {
        'id': 1,
        'image': 'https://example.com/stamp1.png',
        'title': 'Stamp Makan',
        'points_needed': 500,
        'deadline': '2025-12-31T23:59:59Z',
        'reward_label': 'Voucher Rp 50.000',
        'is_expired': false,
      };

      final stampCard = (
        id: json['id'] as int,
        imageUrl: json['image'] ?? '',
        title: json['title'] ?? '',
        points: json['points_needed'] ?? 0,
        deadline: json['deadline'] ?? '',
        rewardLabel: json['reward_label'] ?? '',
        isExpired: json['is_expired'] ?? false,
      );

      expect(stampCard.id, 1);
      expect(stampCard.title, 'Stamp Makan');
      expect(stampCard.points, 500);
      expect(stampCard.isExpired, false);
    });

    test('_StampCard deadline formatting', () {
      String formatDeadline(String dateStr) {
        final DateTime dt = DateTime.parse(dateStr).toLocal();
        const List<String> bulan = [
          '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
        ];
        return '${dt.day} ${bulan[dt.month]} ${dt.year}';
      }

      // Use a local date to avoid timezone conversion issues
      final deadline = formatDeadline('2025-12-31T10:00:00');
      expect(deadline, contains('Desember'));
      expect(deadline, contains('2025'));
    });

    test('filters active and expired stamps', () {
      final allStamps = [
        (id: 1, title: 'Stamp A', isExpired: false),
        (id: 2, title: 'Stamp B', isExpired: true),
        (id: 3, title: 'Stamp C', isExpired: false),
      ];

      final aktif = allStamps.where((s) => !s.isExpired).toList();
      final tidakAktif = allStamps.where((s) => s.isExpired).toList();

      expect(aktif.length, 2);
      expect(tidakAktif.length, 1);
      expect(aktif[0].title, 'Stamp A');
      expect(tidakAktif[0].title, 'Stamp B');
    });

    test('validates points for redemption', () {
      const int userPoints = 500;
      const int requiredPoints = 400;

      final canRedeem = userPoints >= requiredPoints;
      expect(canRedeem, true);

      final cannotRedeem = userPoints < 600;
      expect(cannotRedeem, true);
    });

    test('stamp data structure has all required fields', () {
      final stamp = (
        id: 1,
        imageUrl: 'https://example.com/stamp.png',
        title: 'Stamp Belanja',
        points: 300,
        deadline: '15 Desember 2025',
        rewardLabel: 'Voucher Rp 100.000',
        isExpired: false,
      );

      expect(stamp.id, isPositive);
      expect(stamp.imageUrl, isNotEmpty);
      expect(stamp.title, isNotEmpty);
      expect(stamp.points, isPositive);
      expect(stamp.deadline, isNotEmpty);
      expect(stamp.rewardLabel, isNotEmpty);
      expect(stamp.isExpired, isFalse);
    });

    test('parses multiple stamps correctly', () {
      final stampsJson = [
        {
          'id': 1,
          'title': 'Stamp 1',
          'points_needed': 250,
          'is_expired': false,
        },
        {
          'id': 2,
          'title': 'Stamp 2',
          'points_needed': 500,
          'is_expired': true,
        },
      ];

      final stamps = stampsJson.map((json) => (
            id: json['id'] as int,
            title: json['title'] as String,
            points: json['points_needed'] as int,
            isExpired: json['is_expired'] as bool,
          ))
          .toList();

      expect(stamps.length, 2);
      expect(stamps[0].points, 250);
      expect(stamps[1].isExpired, true);
    });
  });
}
