import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_kusaku/Navigation/History_Kusaku/history_models.dart';
import 'package:frontend_kusaku/Navigation/History_Kusaku/history_utils.dart';
import 'package:frontend_kusaku/Widgets/history_widgets.dart';
import 'dart:async';
import '../../config/api_config.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  HistoryTab _selectedTab = HistoryTab.all;
  bool _showFilterOverlay = false;
  late HistoryFilterDraft _appliedFilter;
  late HistoryFilterDraft _filterDraft;

  bool _isLoading = true;
  String? _error;
  List<HistoryTransaction> _transactions = [];

  bool _isPolling = false;
  Timer? _pollTimer;

  List<HistorySection> get _visibleSections => buildHistorySections(
        transactions: _transactions,
        selectedTab: _selectedTab,
        startDate: _appliedFilter.startDate,
        endDate: _appliedFilter.endDate,
      );

  DateTime get _latestTransactionDate {
    if (_transactions.isEmpty) return DateTime.now();
    final sorted = [..._transactions]
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return sorted.first.occurredAt;
  }

@override
  void initState() {
    super.initState();
    // keep filter init here, just remove _fetchTransactions()
    final initialFilter = HistoryFilterDraft.initial(now: DateTime.now());
    _appliedFilter = initialFilter;
    _filterDraft = initialFilter;
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _pollData());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        setState(() {
          _error = 'Sesi tidak ditemukan, silakan login ulang';
          _isLoading = false;
        });
        return;
      }

      final results = await Future.wait([
        http.get(Uri.parse('${ApiConfig.baseUrl}expenses/$userId/')),
        http.get(Uri.parse('${ApiConfig.baseUrl}incomes/$userId/')),
      ]);

      for (final r in results) {
        if (r.statusCode != 200) {
          setState(() {
            _error = 'Gagal memuat data (${r.statusCode})';
            _isLoading = false;
          });
          return;
        }
      }

      final expenses = (jsonDecode(results[0].body) as List).map((e) {
        return HistoryTransaction(
          id: e['id'].toString(),
          title: e['receiver'] ?? e['category_name'] ?? 'Pengeluaran',
          amount: (double.tryParse(e['total_payment'].toString()) ?? 0).round(),
          occurredAt: DateTime.parse(e['date']),
          type: HistoryTransactionType.expense,
          category: e['category_name'], // used for icon lookup
        );
      }).toList();

      final incomes = (jsonDecode(results[1].body) as List).map((e) {
        return HistoryTransaction(
          id: e['id'].toString(),
          title: e['title'] ?? 'Pemasukan',
          amount: (double.tryParse(e['amount'].toString()) ?? 0).round(),
          occurredAt: DateTime.parse(e['date']),
          type: HistoryTransactionType.income,
          category: null,
        );
      }).toList();

      final all = [...expenses, ...incomes]
        ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

      setState(() {
        _transactions = all;
        _isLoading = false;
        // Reset filter range to match actual data
        final initialFilter = HistoryFilterDraft.initial(now: _latestTransactionDate);
        _appliedFilter = initialFilter;
        _filterDraft = initialFilter;
      });
    } catch (e) {
      setState(() {
        _error = 'Koneksi gagal: $e';
        _isLoading = false;
      });
    }
  }

  void _handleTabChange(HistoryTab tab) {
    setState(() {
      _selectedTab = tab;
      _appliedFilter = _appliedFilter.copyWith(category: tab);
    });
  }

  void _openFilter() {
    setState(() {
      _filterDraft = _appliedFilter.copyWith(
        category: _selectedTab,
        activePicker: ActiveDatePicker.none,
      );
      _showFilterOverlay = true;
    });
  }

  void _closeFilter() {
    setState(() {
      _showFilterOverlay = false;
      _filterDraft = _appliedFilter.copyWith(activePicker: ActiveDatePicker.none);
    });
  }

  void _selectCategory(HistoryTab tab) {
    setState(() {
      _filterDraft = _filterDraft.copyWith(category: tab);
    });
  }

  void _openDatePicker(ActiveDatePicker picker) {
    setState(() {
      final selectedDate = picker == ActiveDatePicker.end
          ? _filterDraft.endDate
          : _filterDraft.startDate;
      _filterDraft = _filterDraft.copyWith(
        activePicker: picker,
        focusedMonth: DateTime(selectedDate.year, selectedDate.month),
      );
    });
  }

  void _changeCalendarMonth(int delta) {
    setState(() {
      _filterDraft = _filterDraft.copyWith(
        focusedMonth: DateTime(
          _filterDraft.focusedMonth.year,
          _filterDraft.focusedMonth.month + delta,
          1,
        ),
      );
    });
  }

  void _selectCalendarDay(DateTime day) {
    setState(() {
      final normalizedDay = DateTime(day.year, day.month, day.day);
      if (_filterDraft.activePicker == ActiveDatePicker.start) {
        final nextEndDate = normalizedDay.isAfter(_filterDraft.endDate)
            ? normalizedDay
            : _filterDraft.endDate;
        _filterDraft = _filterDraft.copyWith(
          startDate: normalizedDay,
          endDate: nextEndDate,
        );
      } else if (_filterDraft.activePicker == ActiveDatePicker.end) {
        final nextStartDate = normalizedDay.isBefore(_filterDraft.startDate)
            ? normalizedDay
            : _filterDraft.startDate;
        _filterDraft = _filterDraft.copyWith(
          startDate: nextStartDate,
          endDate: normalizedDay,
        );
      }
    });
  }

  void _cancelDatePicker() {
    setState(() {
      _filterDraft = _filterDraft.copyWith(activePicker: ActiveDatePicker.none);
    });
  }

  void _applyFilter() {
    setState(() {
      _selectedTab = _filterDraft.category;
      _appliedFilter = _filterDraft.copyWith(
        activePicker: ActiveDatePicker.none,
      );
      _showFilterOverlay = false;
      _filterDraft = _appliedFilter;
    });
  }

@override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF3F4F6),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1D4ED8)),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: RefreshIndicator(
          onRefresh: _fetchTransactions,
          child: ListView(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.4),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 48, color: Color(0xFF9CA3AF)),
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: const TextStyle(color: Color(0xFF6B7280))),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _fetchTransactions,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.4),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: RefreshIndicator(
        onRefresh: _fetchTransactions,
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  HistoryTopSection(
                    onFilterPressed: _openFilter,
                  ),
                  Expanded(
                    child: HistoryTransactionList(
                      sections: _visibleSections,
                      isDimmed: _showFilterOverlay,
                      selectedTab: _selectedTab,
                      onTabSelected: _handleTabChange,
                    ),
                  ),
                ],
              ),
              if (_showFilterOverlay)
                Positioned.fill(
                  child: HistoryFilterOverlay(
                    draft: _filterDraft,
                    onClose: _closeFilter,
                    onSubmit: _applyFilter,
                    onCategorySelected: _selectCategory,
                    onDateFieldTap: _openDatePicker,
                    onDatePickerCancelled: _cancelDatePicker,
                    onMonthChanged: _changeCalendarMonth,
                    onDaySelected: _selectCalendarDay,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pollData() async {
    if (_isPolling) return;
    _isPolling = true;
    try {
      await _fetchTransactions();
    } finally {
      _isPolling = false;
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
