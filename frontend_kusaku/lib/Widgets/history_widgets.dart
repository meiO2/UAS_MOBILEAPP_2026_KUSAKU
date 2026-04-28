import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_kusaku/Navigation/History_Kusaku/history_models.dart';
import 'package:frontend_kusaku/Navigation/History_Kusaku/history_utils.dart';

class HistoryTopSection extends StatelessWidget {
  final VoidCallback onFilterPressed;

  const HistoryTopSection({
    super.key,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF29459B),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Row(
          children: [
            const SizedBox(width: 36),
            Expanded(
              child: Text(
                'Mutasi KUSAKU',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onFilterPressed,
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryTabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const HistoryTabChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFF2273F6) : const Color(0xFFDDEBFF),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HistoryTransactionList extends StatelessWidget {
  final List<HistorySection> sections;
  final bool isDimmed;
  final HistoryTab selectedTab;
  final ValueChanged<HistoryTab> onTabSelected;

  const HistoryTransactionList({
    super.key,
    required this.sections,
    required this.isDimmed,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final hasTransactions = sections.isNotEmpty;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isDimmed ? 0.4 : 1,
      child: IgnorePointer(
        ignoring: isDimmed,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
          itemCount: sections.length + 1,
          itemBuilder: (context, sectionIndex) {
            if (sectionIndex == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (int index = 0; index < HistoryTab.values.length; index++) ...[
                          Expanded(
                            child: HistoryTabChip(
                              label: tabLabel(HistoryTab.values[index]),
                              isSelected: selectedTab == HistoryTab.values[index],
                              onTap: () => onTabSelected(HistoryTab.values[index]),
                            ),
                          ),
                          if (index != HistoryTab.values.length - 1)
                            const SizedBox(width: 8),
                        ],
                      ],
                    ),
                    if (!hasTransactions)
                      Padding(
                        padding: const EdgeInsets.only(top: 28),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.receipt_long_outlined,
                              size: 34,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Belum ada transaksi pada filter ini',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }
            final section = sections[sectionIndex - 1];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  color: const Color(0xFFF5F5F5),
                  child: Text(
                    section.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
                for (final transaction in section.transactions)
                  HistoryTransactionTile(transaction: transaction),
              ],
            );
          },
        ),
      ),
    );
  }
}

class HistoryTransactionTile extends StatelessWidget {
  final HistoryTransaction transaction;

  const HistoryTransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final bool isExpense = transaction.type == HistoryTransactionType.expense;
    final amountPrefix = isExpense ? '-Rp ' : '+Rp ';
    final amountColor =
        isExpense ? const Color(0xFFFF4D4F) : const Color(0xFF2D79FF);
    final icon = resolveHistoryIcon(transaction);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE6EEFF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF2D79FF),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  formatHistoryTime(transaction.occurredAt),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$amountPrefix${formatCurrency(transaction.amount.abs())}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryFilterOverlay extends StatelessWidget {
  final HistoryFilterDraft draft;
  final VoidCallback onClose;
  final VoidCallback onSubmit;
  final VoidCallback onDatePickerCancelled;
  final ValueChanged<HistoryTab> onCategorySelected;
  final ValueChanged<ActiveDatePicker> onDateFieldTap;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<DateTime> onDaySelected;

  const HistoryFilterOverlay({
    super.key,
    required this.draft,
    required this.onClose,
    required this.onSubmit,
    required this.onDatePickerCancelled,
    required this.onCategorySelected,
    required this.onDateFieldTap,
    required this.onMonthChanged,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: const ColoredBox(color: Color(0x66000000)),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 64, 18, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 24),
                        Expanded(
                          child: Text(
                            'Filter Transaksi',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onClose,
                          child: const Icon(
                            Icons.close_rounded,
                            size: 24,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (draft.activePicker == ActiveDatePicker.none) ...[
                      Row(
                        children: [
                          Text(
                            'Kategori',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const Spacer(),
                          CategorySelector(
                            selectedTab: draft.category,
                            onCategorySelected: onCategorySelected,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFD1D5DB),
                      ),
                      const SizedBox(height: 18),
                      _FilterSectionTitle(title: 'Tanggal'),
                      const SizedBox(height: 8),
                      FilterSelectorField(
                        label: formatHistoryDate(draft.startDate),
                        helperText: 'Dari tanggal',
                        onTap: () => onDateFieldTap(ActiveDatePicker.start),
                      ),
                      const SizedBox(height: 8),
                      FilterSelectorField(
                        label: formatHistoryDate(draft.endDate),
                        helperText: 'Sampai tanggal',
                        onTap: () => onDateFieldTap(ActiveDatePicker.end),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '* Catatan:\n- Batas mutasi yang bisa dipilih adalah 7 hari\n- Mutasi rekening maksimum 31 hari',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                          color: const Color(0xFFFF4D4F),
                        ),
                      ),
                    ] else ...[
                      CalendarHeader(
                        month: draft.focusedMonth,
                        onPrevious: () => onMonthChanged(-1),
                        onNext: () => onMonthChanged(1),
                      ),
                      const SizedBox(height: 8),
                      MiniMonthCalendar(
                        month: draft.focusedMonth,
                        selectedDate: draft.selectedPickerDate,
                        onDaySelected: onDaySelected,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CalendarActionButton(
                            label: 'Cancel',
                            backgroundColor: const Color(0xFFFCA5A5),
                            foregroundColor: const Color(0xFFDC2626),
                            onTap: onDatePickerCancelled,
                          ),
                          const SizedBox(width: 6),
                          CalendarActionButton(
                            label: 'OK',
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            onTap: () => onDateFieldTap(ActiveDatePicker.none),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (draft.activePicker == ActiveDatePicker.none)
                      Center(
                        child: SizedBox(
                          width: 110,
                          height: 38,
                          child: ElevatedButton(
                            onPressed: onSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2D79FF),
                              foregroundColor: const Color(0xFF111827),
                              padding: EdgeInsets.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: Text(
                              'Terapkan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterSectionTitle extends StatelessWidget {
  final String title;

  const _FilterSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF111827),
      ),
    );
  }
}

class FilterSelectorField extends StatelessWidget {
  final String label;
  final String? helperText;
  final VoidCallback? onTap;

  const FilterSelectorField({
    super.key,
    required this.label,
    this.helperText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (helperText != null)
                    Text(
                      helperText!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: Color(0xFF374151),
              ),
          ],
        ),
      ),
    );
  }
}

class CategorySelector extends StatelessWidget {
  final HistoryTab selectedTab;
  final ValueChanged<HistoryTab> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedTab,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<HistoryTab>(
      initialValue: selectedTab,
      onSelected: onCategorySelected,
      color: Colors.white,
      elevation: 4,
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      itemBuilder: (context) {
        return HistoryTab.values.map((tab) {
          final isSelected = tab == selectedTab;
          return PopupMenuItem<HistoryTab>(
            value: tab,
            padding: EdgeInsets.zero,
            child: Container(
              width: 122,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: isSelected ? const Color(0xFFD1D5DB) : Colors.white,
              child: Text(
                tabLabel(tab),
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
          );
        }).toList();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tabLabel(selectedTab),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.expand_more_rounded,
            size: 20,
            color: Color(0xFF111827),
          ),
        ],
      ),
    );
  }
}

class CalendarHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const CalendarHeader({
    super.key,
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF29459B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onPrevious,
            child: const Icon(Icons.chevron_left, color: Colors.white, size: 16),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${month.year} ${monthName(month.month)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onNext,
            child: const Icon(Icons.chevron_right, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }
}

class MiniMonthCalendar extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDaySelected;

  const MiniMonthCalendar({
    super.key,
    required this.month,
    required this.selectedDate,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startOffset = firstDay.weekday % 7;
    final selected = selectedDate;
    final cells = <Widget>[];

    const headers = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    for (final header in headers) {
      cells.add(
        Center(
          child: Text(
            header,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
      );
    }

    for (int i = 0; i < startOffset; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final isSelected = isSameHistoryDate(date, selected);
      cells.add(
        GestureDetector(
          onTap: () => onDaySelected(date),
          child: Center(
            child: Container(
              width: 20,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2D79FF)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF111827),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1.2,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: cells,
    );
  }
}

class CalendarActionButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const CalendarActionButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: foregroundColor,
          ),
        ),
      ),
    );
  }
}
