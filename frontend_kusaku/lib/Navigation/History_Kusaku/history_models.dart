import 'package:flutter/material.dart';

enum HistoryTab { all, income, expense }

enum HistoryTransactionType { income, expense }

enum ActiveDatePicker { none, start, end }

class HistoryTransaction {
  final String id;
  final String title;
  final int amount;
  final DateTime occurredAt;
  final HistoryTransactionType type;
  final String? category;
  final String? channel;
  final String? status;

  const HistoryTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.occurredAt,
    required this.type,
    this.category,
    this.channel,
    this.status,
  });

  bool get isExpense => type == HistoryTransactionType.expense;

  factory HistoryTransaction.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'] ?? json['total_amount'] ?? 0;
    final parsedAmount = switch (rawAmount) {
      int value => value,
      double value => value.round(),
      String value => int.tryParse(value) ?? 0,
      _ => 0,
    };

    final rawType = (json['type'] ?? json['transaction_type'] ?? '')
        .toString()
        .toLowerCase();
    final type = switch (rawType) {
      'income' => HistoryTransactionType.income,
      'expense' => HistoryTransactionType.expense,
      _ => parsedAmount >= 0
          ? HistoryTransactionType.income
          : HistoryTransactionType.expense,
    };

    final rawDate = json['occurred_at'] ??
        json['created_at'] ??
        json['transaction_date'] ??
        DateTime.now().toIso8601String();

    return HistoryTransaction(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ??
              json['description'] ??
              json['merchant_name'] ??
              'Transaksi')
          .toString(),
      amount: parsedAmount,
      occurredAt: DateTime.tryParse(rawDate.toString()) ?? DateTime.now(),
      type: type,
      category: json['category']?.toString(),
      channel: json['channel']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'occurred_at': occurredAt.toIso8601String(),
      'type': type.name,
      'category': category,
      'channel': channel,
      'status': status,
    };
  }
}

class HistorySection {
  final DateTime date;
  final String title;
  final List<HistoryTransaction> transactions;

  const HistorySection({
    required this.date,
    required this.title,
    required this.transactions,
  });
}

class HistoryFilterDraft {
  final HistoryTab category;
  final DateTime startDate;
  final DateTime endDate;
  final ActiveDatePicker activePicker;
  final DateTime focusedMonth;

  const HistoryFilterDraft({
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.activePicker,
    required this.focusedMonth,
  });

  factory HistoryFilterDraft.initial({DateTime? now}) {
    final referenceDate = now ?? DateTime.now();
    final normalized = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );

    return HistoryFilterDraft(
      category: HistoryTab.all,
      startDate: normalized.subtract(const Duration(days: 6)),
      endDate: normalized,
      activePicker: ActiveDatePicker.none,
      focusedMonth: DateTime(normalized.year, normalized.month),
    );
  }

  HistoryFilterDraft copyWith({
    HistoryTab? category,
    DateTime? startDate,
    DateTime? endDate,
    ActiveDatePicker? activePicker,
    DateTime? focusedMonth,
  }) {
    return HistoryFilterDraft(
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      activePicker: activePicker ?? this.activePicker,
      focusedMonth: focusedMonth ?? this.focusedMonth,
    );
  }

  DateTime get selectedPickerDate {
    return activePicker == ActiveDatePicker.end ? endDate : startDate;
  }
}
