import 'package:flutter/material.dart';
import 'package:frontend_kusaku/Transaction_confimation/payment_confirmation_models.dart';

class PaymentConfirmationColors {
  static const Color headerDark = Color(0xFF1E3A8A);
  static const Color pageBg = Color(0xFFF4F8FF);
  static const Color paymentMethodBg = Color(0xFFBCDEFF);
  static const Color paymentMethodText = Color(0xFF575AFF);
  static const Color sectionBg = Color(0xFFE3FCFF);
  static const Color detailLabel = Color(0xFF1A1A1A);
  static const Color priceRed = Color(0xFFFF0004);
  static const Color priceFree = Color(0xFF00A80B);
  static const Color priceBlue = Color(0xFF407CFF);
  static const Color categoryAmount = Color(0xFF00388D);
  static const Color selectedCategoryBg = Color(0xFFE3E5E8);
  static const Color savingCategoryBg = Color(0xFFFF8686);
  static const Color savingConfirmationBg = Color(0xFFFFC1C1);
  static const Color buttonCancel = Color(0xFFFCA5A5);
  static const Color buttonPay = Color(0xFF4032FF);
  static const Color borderGrey = Color(0xFFD5D8DE);
}

String formatPaymentCurrency(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer();

  for (var index = 0; index < digits.length; index++) {
    final reversedIndex = digits.length - index;
    buffer.write(digits[index]);
    if (reversedIndex > 1 && reversedIndex % 3 == 1) {
      buffer.write('.');
    }
  }

  return 'Rp ${buffer.toString()}';
}

String formatPaymentDateTime(DateTime value) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final localValue = value.toLocal();
  final day = localValue.day.toString();
  final month = months[localValue.month - 1];
  final hour = localValue.hour.toString().padLeft(2, '0');
  final minute = localValue.minute.toString().padLeft(2, '0');
  return '$day $month ${localValue.year} | $hour.$minute WIB';
}

IconData paymentMethodIcon(PaymentMethodType type) {
  switch (type) {
    case PaymentMethodType.qris:
      return Icons.qr_code_2_rounded;
    case PaymentMethodType.transfer:
      return Icons.account_balance_outlined;
    case PaymentMethodType.ewallet:
      return Icons.account_balance_wallet_outlined;
    case PaymentMethodType.virtualAccount:
      return Icons.credit_card_outlined;
    case PaymentMethodType.other:
      return Icons.payments_outlined;
  }
}

List<PaymentDetailLine> buildPaymentDetailLines({
  required int amount,
  required int transactionFee,
  required int remainingBalance,
}) {
  return [
    PaymentDetailLine(
      label: 'Harga',
      displayValue: formatPaymentCurrency(amount),
      valueColor: PaymentConfirmationColors.priceRed,
    ),
    PaymentDetailLine(
      label: 'Biaya Transaksi',
      displayValue: transactionFee == 0
          ? 'Gratis'
          : formatPaymentCurrency(transactionFee),
      valueColor: transactionFee == 0
          ? PaymentConfirmationColors.priceFree
          : PaymentConfirmationColors.priceRed,
    ),
    PaymentDetailLine(
      label: 'Saldo Tersisa',
      displayValue: formatPaymentCurrency(remainingBalance),
      valueColor: PaymentConfirmationColors.priceBlue,
    ),
  ];
}

class PaymentConfirmationHeader extends StatelessWidget {
  const PaymentConfirmationHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 6, bottom: 22),
      decoration: const BoxDecoration(color: PaymentConfirmationColors.headerDark),
      child: Column(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0B0B0D),
              border: Border.all(color: const Color(0xFF12246B), width: 2),
            ),
            child: Center(
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF1D4ED8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodTag extends StatelessWidget {
  const PaymentMethodTag({
    required this.label,
    required this.icon,
    super.key,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: PaymentConfirmationColors.paymentMethodBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: PaymentConfirmationColors.paymentMethodText,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: PaymentConfirmationColors.paymentMethodText,
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentCardShell extends StatelessWidget {
  const PaymentCardShell({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6D9DE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PaymentDetailsSection extends StatelessWidget {
  const PaymentDetailsSection({required this.items, super.key});

  final List<PaymentDetailLine> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: PaymentConfirmationColors.sectionBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB9DCE2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Text(
              'Rincian Pembayaran',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
            child: PaymentCardShell(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 18,
                  color: Color(0xFFE5E1E1),
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 17,
                            color: PaymentConfirmationColors.detailLabel,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          item.displayValue,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: item.valueColor ?? Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentCategoryTile extends StatelessWidget {
  const PaymentCategoryTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    this.highlightColor,
    this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final Color? highlightColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: highlightColor ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD6D9DE)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFDCE8FF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: const Color(0xFF407CFF), size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: PaymentConfirmationColors.categoryAmount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentMerchantCard extends StatelessWidget {
  const PaymentMerchantCard({
    required this.merchant,
    super.key,
  });

  final PaymentMerchantInfo merchant;

  @override
  Widget build(BuildContext context) {
    final logoText = (merchant.logoText?.isNotEmpty == true
            ? merchant.logoText!
            : merchant.name.isNotEmpty
                ? merchant.name[0]
                : 'M')
        .toUpperCase();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: PaymentCardShell(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC2C2C2)),
                color: const Color(0xFFF2F6F8),
              ),
              child: Center(
                child: Text(
                  logoText,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2A7A57),
                    height: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    merchant.name,
                    style: const TextStyle(
                      fontSize: 39 / 2,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    merchant.accountName,
                    style: const TextStyle(
                      fontSize: 32 / 2,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formatPaymentDateTime(merchant.transactedAt),
                        style: const TextStyle(
                          fontSize: 31 / 2,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentCategorySection extends StatelessWidget {
  const PaymentCategorySection({
    required this.selectedCategory,
    required this.categories,
    required this.selectedIndex,
    required this.isCategoryOpen,
    required this.showSavingConfirmation,
    required this.onToggleCategory,
    required this.onSelectCategory,
    required this.onCancelSavingCategory,
    required this.onConfirmSavingCategory,
    super.key,
  });

  final PaymentCategoryData selectedCategory;
  final List<PaymentCategoryData> categories;
  final int selectedIndex;
  final bool isCategoryOpen;
  final bool showSavingConfirmation;
  final VoidCallback onToggleCategory;
  final ValueChanged<int> onSelectCategory;
  final VoidCallback onCancelSavingCategory;
  final VoidCallback onConfirmSavingCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: PaymentConfirmationColors.sectionBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB9DCE2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kategori Transaksi',
                style: TextStyle(
                  fontSize: 35 / 2,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Text(
                '(AI Rekomendasi)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          PaymentCategoryTile(
            title: selectedCategory.name,
            subtitle: selectedCategory.subtitle,
            amount: formatPaymentCurrency(selectedCategory.remainingAmount),
            icon: selectedCategory.icon,
            highlightColor: selectedCategory.isSaving
                ? PaymentConfirmationColors.savingCategoryBg
                : null,
          ),
          const SizedBox(height: 8),
          if (showSavingConfirmation) ...[
            const SizedBox(height: 6),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SavingCategoryConfirmation(
                  onCancel: onCancelSavingCategory,
                  onContinue: onConfirmSavingCategory,
                ),
              ),
            ),
          ] else ...[
            Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onToggleCategory,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.drive_file_rename_outline, size: 17, color: PaymentConfirmationColors.paymentMethodText),
                      SizedBox(width: 3),
                      Text(
                        'Ubah Kategori',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: PaymentConfirmationColors.paymentMethodText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            if (isCategoryOpen)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    primary: false,
                    itemCount: categories.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final item = categories[index];
                      final isSelected = index == selectedIndex;
                      Color? fillColor;
                      if (item.isSaving) {
                        fillColor = PaymentConfirmationColors.savingCategoryBg;
                      } else if (isSelected) {
                        fillColor = PaymentConfirmationColors.selectedCategoryBg;
                      }

                      return PaymentCategoryTile(
                        title: item.name,
                        subtitle: item.subtitle,
                        amount: formatPaymentCurrency(item.remainingAmount),
                        icon: item.icon,
                        highlightColor: fillColor,
                        onTap: () => onSelectCategory(index),
                      );
                    },
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class SavingCategoryConfirmation extends StatelessWidget {
  const SavingCategoryConfirmation({
    required this.onCancel,
    required this.onContinue,
    super.key,
  });

  final VoidCallback onCancel;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: PaymentConfirmationColors.savingConfirmationBg,
        border: Border.all(color: const Color(0xFF6B6B6B)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Kamu akan menggunakan saldo tabungan. Pastikan ini benar-benar diperlukan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFF2323),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Kembali',
                      style: TextStyle(
                        color: Color(0xFF373737),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Lanjutkan',
                      style: TextStyle(
                        color: Color(0xFF373737),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PaymentActionButtons extends StatelessWidget {
  const PaymentActionButtons({
    required this.onCancel,
    required this.onConfirm,
    required this.confirmText,
    this.isCancelEnabled = true,
    this.isConfirmEnabled = true,
    super.key,
  });

  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final String confirmText;
  final bool isCancelEnabled;
  final bool isConfirmEnabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: isCancelEnabled ? onCancel : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PaymentConfirmationColors.buttonCancel,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: isConfirmEnabled ? onConfirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PaymentConfirmationColors.buttonPay,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: Text(
                  confirmText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
