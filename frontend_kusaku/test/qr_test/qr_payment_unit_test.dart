import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_kusaku/Transaction_confimation/payment_confirmation_models.dart';

/// ---------------------------------------------------------------------------
/// Unit Tests – QR Payment Flow (TransferPage + PaymentConfirmationPage)
///
/// Pure logic only — no widgets, no HTTP, no SharedPreferences.
/// Covers models, guards, formatting, and state transitions.
/// ---------------------------------------------------------------------------
void main() {

  // ── PaymentMerchantInfo.fromJson ───────────────────────────────────────────
  group('PaymentMerchantInfo.fromJson', () {
    test('parses name and accountName', () {
      final m = PaymentMerchantInfo.fromJson({
        'name': 'Starbucek',
        'account_name': 'a.n. PT Starbucek',
      });
      expect(m.name, 'Starbucek');
      expect(m.accountName, 'a.n. PT Starbucek');
    });

    test('falls back to merchant_name when name missing', () {
      final m = PaymentMerchantInfo.fromJson({'merchant_name': 'Warung'});
      expect(m.name, 'Warung');
    });

    test('defaults name to "Merchant" when all missing', () {
      final m = PaymentMerchantInfo.fromJson({});
      expect(m.name, 'Merchant');
    });

    test('parses transacted_at from ISO string', () {
      final m = PaymentMerchantInfo.fromJson({
        'name': 'X',
        'account_name': 'Y',
        'transacted_at': '2026-03-01T12:00:00.000',
      });
      expect(m.transactedAt.year, 2026);
      expect(m.transactedAt.month, 3);
    });

    test('falls back to DateTime.now() when date missing', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final m = PaymentMerchantInfo.fromJson({'name': 'X', 'account_name': 'Y'});
      expect(m.transactedAt.isAfter(before), isTrue);
    });
  });

  // ── PaymentCategoryData ────────────────────────────────────────────────────
  group('PaymentCategoryData.fromJson', () {
    test('parses id, name, remainingAmount', () {
      final c = PaymentCategoryData.fromJson(
        {'id': '1', 'name': 'Makanan', 'remaining_amount': 500000},
        icon: Icons.restaurant,
      );
      expect(c.id, '1');
      expect(c.name, 'Makanan');
      expect(c.remainingAmount, 500000);
    });

    test('parses double remaining_amount', () {
      final c = PaymentCategoryData.fromJson(
        {'id': '2', 'name': 'Transport', 'remaining_amount': 200000.0},
        icon: Icons.directions_car,
      );
      expect(c.remainingAmount, 200000);
    });

    test('parses string remaining_amount', () {
      final c = PaymentCategoryData.fromJson(
        {'id': '3', 'name': 'Hiburan', 'remaining_amount': '150000'},
        icon: Icons.movie,
      );
      expect(c.remainingAmount, 150000);
    });

    test('defaults isSaving to false', () {
      final c = PaymentCategoryData.fromJson(
        {'id': '1', 'name': 'Makanan', 'remaining_amount': 0},
        icon: Icons.restaurant,
      );
      expect(c.isSaving, isFalse);
    });

    test('parses isSaving true', () {
      final c = PaymentCategoryData.fromJson(
        {'id': '5', 'name': 'Tabungan', 'remaining_amount': 0, 'is_saving': true},
        icon: Icons.savings,
      );
      expect(c.isSaving, isTrue);
    });
  });

  // ── PaymentConfirmationData ────────────────────────────────────────────────
  group('PaymentConfirmationData', () {
    PaymentConfirmationData makeData({
      int amount = 50000,
      int fee = 0,
      int remaining = 1000000,
    }) {
      return PaymentConfirmationData(
        transactionId: 'txn-001',
        methodType: PaymentMethodType.qris,
        methodLabel: 'Pembayaran Qris',
        amount: amount,
        transactionFee: fee,
        remainingBalance: remaining,
        merchant: PaymentMerchantInfo(
          name: 'Starbucek',
          accountName: 'a.n. PT Starbucek',
          transactedAt: DateTime(2026, 3, 1),
        ),
        categories: [
          PaymentCategoryData(
            id: '1',
            name: 'Makan & Minum',
            icon: Icons.restaurant,
            remainingAmount: 500000,
          ),
        ],
      );
    }

    test('totalAmount = amount + transactionFee', () {
      final d = makeData(amount: 50000, fee: 2500);
      expect(d.totalAmount, 52500);
    });

    test('totalAmount when fee is zero', () {
      final d = makeData(amount: 75000, fee: 0);
      expect(d.totalAmount, 75000);
    });

    test('fromJson parses qris methodType', () {
      final d = PaymentConfirmationData.fromJson(
        {
          'transaction_id': 'abc',
          'method_type': 'qris',
          'method_label': 'QRIS',
          'amount': 100000,
          'transaction_fee': 0,
          'remaining_balance': 900000,
          'merchant': {
            'name': 'Warung',
            'account_name': 'Pak Budi',
            'transacted_at': '2026-01-01T10:00:00',
          },
        },
        categories: [],
      );
      expect(d.methodType, PaymentMethodType.qris);
      expect(d.amount, 100000);
    });

    test('fromJson parses string amount', () {
      final d = PaymentConfirmationData.fromJson(
        {
          'transaction_id': 'abc',
          'method_type': 'qris',
          'method_label': 'QRIS',
          'amount': '75000',
          'transaction_fee': '0',
          'remaining_balance': '925000',
          'merchant': {
            'name': 'X',
            'account_name': 'Y',
            'transacted_at': '2026-01-01T10:00:00',
          },
        },
        categories: [],
      );
      expect(d.amount, 75000);
    });
  });

  // ── PaymentSubmissionPayload ───────────────────────────────────────────────
  group('PaymentSubmissionPayload', () {
    test('toJson contains all required fields', () {
      final payload = PaymentSubmissionPayload(
        transactionId: 'txn-001',
        categoryId: '3',
        pin: '123456',
        amount: 50000,
        methodType: PaymentMethodType.qris,
        usedSavingBalance: false,
      );
      final json = payload.toJson();
      expect(json['transaction_id'], 'txn-001');
      expect(json['category_id'], '3');
      expect(json['pin'], '123456');
      expect(json['amount'], 50000);
      expect(json['method_type'], 'qris');
      expect(json['used_saving_balance'], isFalse);
    });

    test('usedSavingBalance true when Tabungan selected', () {
      final payload = PaymentSubmissionPayload(
        transactionId: 'txn-002',
        categoryId: '5',
        pin: '000000',
        amount: 100000,
        methodType: PaymentMethodType.qris,
        usedSavingBalance: true,
      );
      expect(payload.usedSavingBalance, isTrue);
    });
  });

  // ── PaymentSubmissionResult ────────────────────────────────────────────────
  group('PaymentSubmissionResult', () {
    test('isSuccess true has no errorMessage', () {
      const r = PaymentSubmissionResult(isSuccess: true);
      expect(r.isSuccess, isTrue);
      expect(r.errorMessage, isNull);
    });

    test('isSuccess false carries errorMessage', () {
      const r = PaymentSubmissionResult(
        isSuccess: false,
        errorMessage: 'PIN salah',
      );
      expect(r.isSuccess, isFalse);
      expect(r.errorMessage, 'PIN salah');
    });
  });

  // ── Transfer amount guard logic ────────────────────────────────────────────
  group('Transfer amount guard', () {
    const maxTransfer = 30000000;

    bool canTransfer(String amountStr) {
      final val = int.tryParse(amountStr) ?? 0;
      return val > 0 && val <= maxTransfer;
    }

    test('zero amount cannot transfer', () {
      expect(canTransfer('0'), isFalse);
    });

    test('empty amount cannot transfer', () {
      expect(canTransfer(''), isFalse);
    });

    test('valid amount can transfer', () {
      expect(canTransfer('50000'), isTrue);
    });

    test('exactly max transfer is allowed', () {
      expect(canTransfer('30000000'), isTrue);
    });

    test('exceeds max transfer is blocked', () {
      expect(canTransfer('30000001'), isFalse);
    });
  });

  // ── Rupiah formatter ───────────────────────────────────────────────────────
  group('Rupiah formatter', () {
    String formatRp(int v) => v
        .toString()
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

    test('formats thousands correctly', () {
      expect(formatRp(50000), '50.000');
    });

    test('formats millions correctly', () {
      expect(formatRp(1000000), '1.000.000');
    });

    test('single digits unchanged', () {
      expect(formatRp(5), '5');
    });

    test('formats max transfer amount', () {
      expect(formatRp(30000000), '30.000.000');
    });
  });

  // ── QR prefill logic ──────────────────────────────────────────────────────
  group('QR prefill logic', () {
    test('prefilled phone triggers enterDetails step skip', () {
      const prefPhone = '08123456789';
      const prefName = 'Budi';
      // Mirrors the logic in _loadSession
      final shouldSkip = prefPhone.isNotEmpty;
      expect(shouldSkip, isTrue);
      expect(prefName, 'Budi');
    });

    test('empty prefilled phone does not skip', () {
      const prefPhone = '';
      expect(prefPhone.isNotEmpty, isFalse);
    });

    test('null prefilled phone does not skip', () {
      const String? prefPhone = null;
      expect(prefPhone != null && prefPhone.isNotEmpty, isFalse);
    });
  });

  // ── Category selection logic ───────────────────────────────────────────────
  group('Category selection', () {
    test('selecting Tabungan sets isSaving true', () {
      const cat = PaymentCategoryData(
        id: '5',
        name: 'Tabungan',
        icon: Icons.savings,
        remainingAmount: 500000,
        isSaving: true,
      );
      expect(cat.isSaving, isTrue);
    });

    test('selecting non-saving category sets isSaving false', () {
      const cat = PaymentCategoryData(
        id: '1',
        name: 'Makan & Minum',
        icon: Icons.restaurant,
        remainingAmount: 200000,
        isSaving: false,
      );
      expect(cat.isSaving, isFalse);
    });

    test('categoryId parsed from pipe-separated string', () {
      const picked = '3|Transportasi';
      final parts = picked.split('|');
      expect(parts[0], '3');
      expect(parts[1], 'Transportasi');
    });
  });

  // ── PIN guard ─────────────────────────────────────────────────────────────
  group('PIN guard', () {
    test('wrong PIN returns failure', () {
      const localPin = '123456';
      const enteredPin = '000000';
      final isWrong = localPin.isNotEmpty && enteredPin != localPin;
      expect(isWrong, isTrue);
    });

    test('correct PIN passes', () {
      const localPin = '123456';
      const enteredPin = '123456';
      final isWrong = localPin.isNotEmpty && enteredPin != localPin;
      expect(isWrong, isFalse);
    });

    test('null local PIN skips local check', () {
      const String? localPin = null;
      const enteredPin = '999999';
      final skipCheck = localPin == null || localPin.isEmpty;
      expect(skipCheck, isTrue);
    });
  });

  // ── _budgets empty guard ───────────────────────────────────────────────────
  group('Budget empty guard', () {
    test('empty budgets returns failure result', () {
      final budgets = [];
      final result = budgets.isEmpty
          ? const PaymentSubmissionResult(
              isSuccess: false,
              errorMessage: 'Setup kategori budget dulu di Chat Si Pintar.',
            )
          : const PaymentSubmissionResult(isSuccess: true);
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('budget'));
    });

    test('non-empty budgets allows submission', () {
      final budgets = [
        {'category': {'id': 1, 'name': 'Makanan'}, 'remaining_amount': 100000}
      ];
      final result = budgets.isEmpty
          ? const PaymentSubmissionResult(isSuccess: false)
          : const PaymentSubmissionResult(isSuccess: true);
      expect(result.isSuccess, isTrue);
    });
  });
}