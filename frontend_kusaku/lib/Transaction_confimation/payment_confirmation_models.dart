import 'package:flutter/material.dart';

enum PaymentFlowStatus { idle, submitting, success, failure }

enum PaymentMethodType { qris, transfer, ewallet, virtualAccount, other }

class PaymentMerchantInfo {
  const PaymentMerchantInfo({
    required this.name,
    required this.accountName,
    required this.transactedAt,
    this.logoText,
  });

  final String name;
  final String accountName;
  final DateTime transactedAt;
  final String? logoText;

  static DateTime _parseTransactionDateTime(Map<String, dynamic> json) {
    final transactionDate = (json['transaction_date'] ?? '').toString();
    final transactionTime = (json['transaction_time'] ?? '').toString();

    if (transactionDate.isNotEmpty && transactionTime.isNotEmpty) {
      final combined = DateTime.tryParse('${transactionDate}T$transactionTime');
      if (combined != null) {
        return combined;
      }
    }

    return DateTime.tryParse(
          (json['transacted_at'] ??
                  json['created_at'] ??
                  json['transaction_date'] ??
                  '')
              .toString(),
        ) ??
        DateTime.now();
  }

  factory PaymentMerchantInfo.fromJson(Map<String, dynamic> json) {
    return PaymentMerchantInfo(
      name: (json['name'] ?? json['merchant_name'] ?? 'Merchant').toString(),
      accountName: (json['account_name'] ??
              json['recipient_name'] ??
              json['merchant_PT'] ??
              json['merchant_account_name'] ??
              '-')
          .toString(),
      transactedAt: _parseTransactionDateTime(json),
      logoText: json['logo_text']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'account_name': accountName,
      'transacted_at': transactedAt.toIso8601String(),
      'logo_text': logoText,
    };
  }
}

class PaymentCategoryData {
  const PaymentCategoryData({
    required this.id,
    required this.name,
    required this.remainingAmount,
    required this.icon,
    this.subtitle = 'Sisa bulan ini',
    this.isSaving = false,
  });

  final String id;
  final String name;
  final int remainingAmount;
  final IconData icon;
  final String subtitle;
  final bool isSaving;

  factory PaymentCategoryData.fromJson(
    Map<String, dynamic> json, {
    required IconData icon,
  }) {
    final rawRemaining = json['remaining_amount'] ?? json['remaining'] ?? 0;
    final remainingAmount = switch (rawRemaining) {
      int value => value,
      double value => value.round(),
      String value => int.tryParse(value) ?? 0,
      _ => 0,
    };

    return PaymentCategoryData(
      id: (json['id'] ?? json['category_id'] ?? '').toString(),
      name: (json['name'] ?? json['category_name'] ?? 'Kategori').toString(),
      remainingAmount: remainingAmount,
      icon: icon,
      subtitle: (json['subtitle'] ?? 'Sisa bulan ini').toString(),
      isSaving: json['is_saving'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'remaining_amount': remainingAmount,
      'subtitle': subtitle,
      'is_saving': isSaving,
    };
  }
}

class PaymentConfirmationData {
  const PaymentConfirmationData({
    required this.transactionId,
    required this.methodType,
    required this.methodLabel,
    required this.amount,
    required this.transactionFee,
    required this.remainingBalance,
    required this.merchant,
    required this.categories,
    this.successTitle = 'Payment Successful!',
    this.successMethodLabel,
  });

  final String transactionId;
  final PaymentMethodType methodType;
  final String methodLabel;
  final int amount;
  final int transactionFee;
  final int remainingBalance;
  final PaymentMerchantInfo merchant;
  final List<PaymentCategoryData> categories;
  final String successTitle;
  final String? successMethodLabel;

  int get totalAmount => amount + transactionFee;

  factory PaymentConfirmationData.fromJson(
    Map<String, dynamic> json, {
    required List<PaymentCategoryData> categories,
  }) {
    final rawMethod = (json['method_type'] ?? json['payment_method'] ?? '')
        .toString()
        .toLowerCase();
    final methodType = switch (rawMethod) {
      'qris' => PaymentMethodType.qris,
      'transfer' => PaymentMethodType.transfer,
      'ewallet' => PaymentMethodType.ewallet,
      'virtual_account' => PaymentMethodType.virtualAccount,
      _ => PaymentMethodType.other,
    };

    int parseAmount(dynamic value) {
      return switch (value) {
        int amount => amount,
        double amount => amount.round(),
        String amount =>
          int.tryParse(amount) ??
          double.tryParse(amount.replaceAll(',', '.'))?.round() ??
          0,
        _ => 0,
      };
    }

    return PaymentConfirmationData(
      transactionId: (json['transaction_id'] ?? json['id'] ?? '').toString(),
      methodType: methodType,
      methodLabel:
          (json['method_label'] ?? json['payment_method_label'] ?? 'Pembayaran')
              .toString(),
      amount: parseAmount(json['amount']),
      transactionFee: parseAmount(json['transaction_fee']),
      remainingBalance: parseAmount(
        json['remaining_balance'] ?? json['balance_after_transaction'],
      ),
      merchant: PaymentMerchantInfo.fromJson(
        (json['merchant'] as Map<String, dynamic>?) ?? json,
      ),
      categories: categories,
      successTitle: (json['success_title'] ?? 'Payment Successful!').toString(),
      successMethodLabel: json['success_method_label']?.toString(),
    );
  }
}

class PaymentDetailLine {
  const PaymentDetailLine({
    required this.label,
    required this.displayValue,
    this.valueColor,
  });

  final String label;
  final String displayValue;
  final Color? valueColor;
}

class PaymentSubmissionPayload {
  const PaymentSubmissionPayload({
    required this.transactionId,
    required this.categoryId,
    required this.pin,
    required this.amount,
    required this.methodType,
    required this.usedSavingBalance,
  });

  final String transactionId;
  final String categoryId;
  final String pin;
  final int amount;
  final PaymentMethodType methodType;
  final bool usedSavingBalance;

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'category_id': categoryId,
      'pin': pin,
      'amount': amount,
      'method_type': methodType.name,
      'used_saving_balance': usedSavingBalance,
    };
  }
}

class PaymentSubmissionResult {
  const PaymentSubmissionResult({
    required this.isSuccess,
    this.errorMessage,
    this.successMessage,
  });

  final bool isSuccess;
  final String? errorMessage;
  final String? successMessage;
}
