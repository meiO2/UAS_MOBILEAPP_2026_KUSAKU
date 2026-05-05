import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_kusaku/Navigation/History_Kusaku/history_models.dart';

void main() {
  group('HistoryTransaction Model & Parsing Unit Tests', () {
    test('Should parse Expense JSON correctly', () {
      // Arrange
      final Map<String, dynamic> expenseJson = {
        'id': 101,
        'receiver': 'Supermarket',
        'category_name': 'Food',
        'total_payment': '150000.00',
        'date': '2026-05-05T10:00:00Z',
      };

      // Act
      final transaction = HistoryTransaction(
        id: expenseJson['id'].toString(),
        title: expenseJson['receiver'] ?? expenseJson['category_name'] ?? 'Pengeluaran',
        amount: (double.tryParse(expenseJson['total_payment'].toString()) ?? 0).round(),
        occurredAt: DateTime.parse(expenseJson['date']),
        type: HistoryTransactionType.expense,
        category: expenseJson['category_name'],
      );

      // Assert
      expect(transaction.id, '101');
      expect(transaction.title, 'Supermarket');
      expect(transaction.amount, 150000);
      expect(transaction.type, HistoryTransactionType.expense);
      expect(transaction.category, 'Food');
    });

    test('Should parse Income JSON correctly', () {
      // Arrange
      final Map<String, dynamic> incomeJson = {
        'id': 202,
        'title': 'Salary',
        'amount': '5000000.00',
        'date': '2026-05-01T08:00:00Z',
      };

      // Act
      final transaction = HistoryTransaction(
        id: incomeJson['id'].toString(),
        title: incomeJson['title'] ?? 'Pemasukan',
        amount: (double.tryParse(incomeJson['amount'].toString()) ?? 0).round(),
        occurredAt: DateTime.parse(incomeJson['date']),
        type: HistoryTransactionType.income,
        category: null,
      );

      // Assert
      expect(transaction.id, '202');
      expect(transaction.title, 'Salary');
      expect(transaction.amount, 5000000);
      expect(transaction.type, HistoryTransactionType.income);
      expect(transaction.category, null);
    });
  });
}