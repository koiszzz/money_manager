import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../providers/app_providers.dart';

enum ReportRange { month, year, custom }

class ReportsFilterState {
  const ReportsFilterState({
    required this.range,
    required this.selectedMonth,
    required this.selectedYear,
    required this.customRange,
    required this.expenseTouchedIndex,
    required this.incomeTouchedIndex,
  });

  factory ReportsFilterState.initial() {
    final now = DateTime.now();
    return ReportsFilterState(
      range: ReportRange.month,
      selectedMonth: DateTime(now.year, now.month, 1),
      selectedYear: now.year,
      customRange: DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      ),
      expenseTouchedIndex: null,
      incomeTouchedIndex: null,
    );
  }

  final ReportRange range;
  final DateTime selectedMonth;
  final int selectedYear;
  final DateTimeRange customRange;
  final int? expenseTouchedIndex;
  final int? incomeTouchedIndex;

  ReportsFilterState copyWith({
    ReportRange? range,
    DateTime? selectedMonth,
    int? selectedYear,
    DateTimeRange? customRange,
    Object? expenseTouchedIndex = _sentinel,
    Object? incomeTouchedIndex = _sentinel,
  }) {
    return ReportsFilterState(
      range: range ?? this.range,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      customRange: customRange ?? this.customRange,
      expenseTouchedIndex: expenseTouchedIndex == _sentinel
          ? this.expenseTouchedIndex
          : expenseTouchedIndex as int?,
      incomeTouchedIndex: incomeTouchedIndex == _sentinel
          ? this.incomeTouchedIndex
          : incomeTouchedIndex as int?,
    );
  }
}

const _sentinel = Object();

class ReportsController extends StateNotifier<ReportsFilterState> {
  ReportsController() : super(ReportsFilterState.initial());

  void setRange(ReportRange value) {
    state = state.copyWith(range: value);
  }

  void setMonth(DateTime value) {
    state = state.copyWith(selectedMonth: DateTime(value.year, value.month, 1));
  }

  void setYear(int value) {
    state = state.copyWith(selectedYear: value);
  }

  void setCustomRange(DateTimeRange value) {
    state = state.copyWith(customRange: value);
  }

  void setExpenseTouchedIndex(int? value) {
    state = state.copyWith(expenseTouchedIndex: value);
  }

  void setIncomeTouchedIndex(int? value) {
    state = state.copyWith(incomeTouchedIndex: value);
  }
}

class ChartSegment {
  const ChartSegment({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class RankingItem {
  const RankingItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.ratio,
  });

  final String label;
  final double amount;
  final Color color;
  final double ratio;
}

class TrendSeries {
  const TrendSeries({
    required this.points,
    required this.income,
    required this.expense,
    required this.net,
    required this.netAbsolute,
    required this.labels,
  });

  final List<double> points;
  final List<double> income;
  final List<double> expense;
  // Net asset delta from period start, used for plotting to keep readable scale.
  final List<double> net;
  // Net asset absolute value, used for accurate tooltip/summary display.
  final List<double> netAbsolute;
  final List<String> labels;
}

class ReportsViewModel {
  const ReportsViewModel({
    required this.range,
    required this.expenseSegments,
    required this.incomeSegments,
    required this.expenseRanking,
    required this.incomeRanking,
    required this.trend,
  });

  final DateTimeRange range;
  final List<ChartSegment> expenseSegments;
  final List<ChartSegment> incomeSegments;
  final List<RankingItem> expenseRanking;
  final List<RankingItem> incomeRanking;
  final TrendSeries trend;
}

final reportsControllerProvider =
    StateNotifierProvider<ReportsController, ReportsFilterState>(
  (ref) => ReportsController(),
);

final reportsViewModelProvider = Provider<ReportsViewModel>((ref) {
  final appState = ref.watch(appStateProvider);
  final filter = ref.watch(reportsControllerProvider);
  final range = _resolvedRange(filter);
  final records =
      appState.records.where((r) => _inRange(r.occurredAt, range)).toList();

  final expenseTotals =
      _categoryTotals(records, appState, CategoryType.expense);
  final incomeTotals = _categoryTotals(records, appState, CategoryType.income);

  return ReportsViewModel(
    range: range,
    expenseSegments: _buildSegments(expenseTotals),
    incomeSegments: _buildSegments(incomeTotals),
    expenseRanking: _topRank(expenseTotals),
    incomeRanking: _topRank(incomeTotals),
    trend: _buildTrendSeries(records, range, appState),
  );
});

DateTimeRange _resolvedRange(ReportsFilterState filter) {
  if (filter.range == ReportRange.month) {
    final start =
        DateTime(filter.selectedMonth.year, filter.selectedMonth.month, 1);
    final end =
        DateTime(filter.selectedMonth.year, filter.selectedMonth.month + 1, 0);
    return DateTimeRange(start: start, end: end);
  }
  if (filter.range == ReportRange.year) {
    final start = DateTime(filter.selectedYear, 1, 1);
    final end = DateTime(filter.selectedYear, 12, 31);
    return DateTimeRange(start: start, end: end);
  }
  return filter.customRange;
}

bool _inRange(DateTime time, DateTimeRange range) {
  final day = DateTime(time.year, time.month, time.day);
  return !day.isBefore(
          DateTime(range.start.year, range.start.month, range.start.day)) &&
      !day.isAfter(DateTime(range.end.year, range.end.month, range.end.day));
}

Map<Category, double> _categoryTotals(
  List<TransactionRecord> records,
  AppState appState,
  CategoryType type,
) {
  final result = <Category, double>{};
  for (final record in records) {
    if (type == CategoryType.expense &&
        record.type != TransactionType.expense) {
      continue;
    }
    if (type == CategoryType.income && record.type != TransactionType.income) {
      continue;
    }
    final category = appState.categoryById(record.categoryId);
    if (category == null) continue;
    result.update(category, (value) => value + record.amount,
        ifAbsent: () => record.amount);
  }
  return result;
}

List<ChartSegment> _buildSegments(Map<Category, double> totals) {
  final entries = totals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return entries
      .map((entry) => ChartSegment(
            label: entry.key.name,
            value: entry.value,
            color: Color(entry.key.colorHex),
          ))
      .toList();
}

List<RankingItem> _topRank(Map<Category, double> totals) {
  final entries = totals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final top = entries.take(6).toList();
  if (top.isEmpty) return const [];

  final maxValue = top.first.value <= 0 ? 1.0 : top.first.value;
  return top
      .map((entry) => RankingItem(
            label: entry.key.name,
            amount: entry.value,
            color: Color(entry.key.colorHex),
            ratio: (entry.value / maxValue).clamp(0.0, 1.0),
          ))
      .toList();
}

TrendSeries _buildTrendSeries(
  List<TransactionRecord> records,
  DateTimeRange range,
  AppState appState,
) {
  final days = range.end.difference(range.start).inDays + 1;
  final isYear = days > 200;
  final bucketCount = isYear ? 12 : days;
  final income = List<double>.filled(bucketCount, 0);
  final expense = List<double>.filled(bucketCount, 0);
  final labels = List<String>.filled(bucketCount, '');
  final baseline = _assetsBefore(appState, range.start);

  for (final record in records) {
    if (record.type == TransactionType.transfer) continue;
    final index = isYear
        ? record.occurredAt.month - 1
        : record.occurredAt
            .difference(
                DateTime(range.start.year, range.start.month, range.start.day))
            .inDays;
    if (index < 0 || index >= bucketCount) continue;
    if (record.type == TransactionType.income) {
      income[index] += record.amount;
    } else {
      expense[index] += record.amount;
    }
  }

  if (isYear) {
    for (var i = 0; i < bucketCount; i++) {
      labels[i] = '${i + 1}';
    }
  } else {
    for (var i = 0; i < bucketCount; i++) {
      final day = DateTime(range.start.year, range.start.month, range.start.day)
          .add(Duration(days: i));
      labels[i] = day.day.toString();
    }
  }

  final netAbsolute = List<double>.filled(bucketCount, 0);
  final net = List<double>.filled(bucketCount, 0);
  double running = baseline;
  for (var i = 0; i < bucketCount; i++) {
    running += income[i] - expense[i];
    netAbsolute[i] = running;
    net[i] = running - baseline;
  }

  return TrendSeries(
    points: List.generate(bucketCount, (i) => i.toDouble()),
    income: income,
    expense: expense,
    net: net,
    netAbsolute: netAbsolute,
    labels: labels,
  );
}

double _assetsBefore(AppState appState, DateTime start) {
  final startDay = DateTime(start.year, start.month, start.day);
  var assets = appState.accounts.fold<double>(
    0,
    (sum, account) => sum + account.openingBalance,
  );

  for (final record in appState.records) {
    final day = DateTime(
      record.occurredAt.year,
      record.occurredAt.month,
      record.occurredAt.day,
    );
    if (!day.isBefore(startDay)) continue;

    if (record.type == TransactionType.income) {
      assets += record.amount;
    } else if (record.type == TransactionType.expense) {
      assets -= record.amount;
    }
  }
  return assets;
}
