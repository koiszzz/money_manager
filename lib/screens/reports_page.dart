import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../controllers/reports/reports_controller.dart';
import '../providers/app_providers.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final filter = ref.watch(reportsControllerProvider);
    final controller = ref.read(reportsControllerProvider.notifier);
    final model = ref.watch(reportsViewModelProvider);
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.reportsAnalysis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _RangeSegments(
            active: filter.range,
            onChanged: controller.setRange,
            strings: strings,
          ),
          const SizedBox(height: 12),
          _RangePickerRow(
            label: _rangeLabel(strings, locale, filter),
            onTap: () => _pickRange(context, filter, controller),
          ),
          const SizedBox(height: 14),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.expenseBreakdown,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                if (model.expenseSegments.isEmpty)
                  _EmptyChart(label: strings.noData)
                else
                  _DonutChart(
                    segments: model.expenseSegments,
                    centerLabel: strings.typeExpense,
                    touchedIndex: filter.expenseTouchedIndex,
                    onTouched: controller.setExpenseTouchedIndex,
                  ),
                const SizedBox(height: 18),
                _LegendGrid(
                  segments: model.expenseSegments,
                  locale: locale,
                  currencyCode: appState.currencyCode,
                  decimalDigits: appState.decimalPlaces,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.incomeBreakdown,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                if (model.incomeSegments.isEmpty)
                  _EmptyChart(label: strings.noData)
                else
                  _DonutChart(
                    segments: model.incomeSegments,
                    centerLabel: strings.typeIncome,
                    touchedIndex: filter.incomeTouchedIndex,
                    onTouched: controller.setIncomeTouchedIndex,
                  ),
                const SizedBox(height: 18),
                _LegendGrid(
                  segments: model.incomeSegments,
                  locale: locale,
                  currencyCode: appState.currencyCode,
                  decimalDigits: appState.decimalPlaces,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.trends,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                if (model.trend.points.isEmpty)
                  _EmptyChart(label: strings.noData)
                else
                  _TrendChart(
                    trend: model.trend,
                    strings: strings,
                    locale: locale,
                    currencyCode: appState.currencyCode,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.expenseRanking,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _RankingList(
                  items: model.expenseRanking,
                  locale: locale,
                  currencyCode: appState.currencyCode,
                  decimalDigits: appState.decimalPlaces,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.incomeRanking,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _RankingList(
                  items: model.incomeRanking,
                  locale: locale,
                  currencyCode: appState.currencyCode,
                  decimalDigits: appState.decimalPlaces,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _rangeLabel(
      AppLocalizations strings, String locale, ReportsFilterState filter) {
    if (filter.range == ReportRange.month) {
      return Formatters.monthLabel(filter.selectedMonth, locale: locale);
    }
    if (filter.range == ReportRange.year) {
      return filter.selectedYear.toString();
    }
    return '${Formatters.dateLabel(filter.customRange.start, locale: locale)} - ${Formatters.dateLabel(filter.customRange.end, locale: locale)}';
  }

  Future<void> _pickRange(
    BuildContext context,
    ReportsFilterState filter,
    ReportsController controller,
  ) async {
    if (filter.range == ReportRange.month) {
      final picked = await showDatePicker(
        context: context,
        initialDate: filter.selectedMonth,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        controller.setMonth(picked);
      }
      return;
    }

    if (filter.range == ReportRange.year) {
      final picked = await showDialog<int>(
        context: context,
        builder: (context) =>
            _YearPickerDialog(initialYear: filter.selectedYear),
      );
      if (picked != null) {
        controller.setYear(picked);
      }
      return;
    }

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: filter.customRange,
    );
    if (picked != null) {
      controller.setCustomRange(picked);
    }
  }
}

class _RangeSegments extends StatelessWidget {
  const _RangeSegments({
    required this.active,
    required this.onChanged,
    required this.strings,
  });

  final ReportRange active;
  final ValueChanged<ReportRange> onChanged;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface(context, level: 0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              label: strings.month,
              selected: active == ReportRange.month,
              onTap: () => onChanged(ReportRange.month),
            ),
          ),
          Expanded(
            child: _Segment(
              label: strings.year,
              selected: active == ReportRange.year,
              onTap: () => onChanged(ReportRange.year),
            ),
          ),
          Expanded(
            child: _Segment(
              label: strings.custom,
              selected: active == ReportRange.custom,
              onTap: () => onChanged(ReportRange.custom),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.surface(context, level: 2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? AppTheme.primary : AppTheme.mutedText(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _RangePickerRow extends StatelessWidget {
  const _RangePickerRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface(context, level: 0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Symbols.calendar_month,
                size: 18, color: AppTheme.mutedText(context)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Icon(Symbols.expand_more, color: AppTheme.mutedText(context)),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface(context, level: 0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.surface(context, level: 2),
      ),
      child: Center(
        child:
            Text(label, style: TextStyle(color: AppTheme.mutedText(context))),
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  const _DonutChart({
    required this.segments,
    required this.centerLabel,
    required this.touchedIndex,
    required this.onTouched,
  });

  final List<ChartSegment> segments;
  final String centerLabel;
  final int? touchedIndex;
  final ValueChanged<int?> onTouched;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 42,
            startDegreeOffset: -90,
            sections: [
              for (var i = 0; i < segments.length; i++)
                _pieSection(context, segments[i], i == touchedIndex),
            ],
            pieTouchData: PieTouchData(
              touchCallback: (event, response) {
                if (!event.isInterestedForInteractions ||
                    response == null ||
                    response.touchedSection == null) {
                  onTouched(null);
                  return;
                }
                final index = response.touchedSection!.touchedSectionIndex;
                onTouched(index);
              },
            ),
          ),
        ),
      ),
    );
  }

  PieChartSectionData _pieSection(
    BuildContext context,
    ChartSegment segment,
    bool highlighted,
  ) {
    return PieChartSectionData(
      color: segment.color,
      value: segment.value,
      radius: highlighted ? 72 : 62,
      showTitle: false,
      badgeWidget: highlighted
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surface(context, level: 1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.outline(context)),
              ),
              child: Text(
                segment.label,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            )
          : null,
      badgePositionPercentageOffset: 1.08,
    );
  }
}

class _LegendGrid extends StatelessWidget {
  const _LegendGrid({
    required this.segments,
    required this.locale,
    required this.currencyCode,
    required this.decimalDigits,
  });

  final List<ChartSegment> segments;
  final String locale;
  final String currencyCode;
  final int decimalDigits;

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: segments.map((seg) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.surface(context, level: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: seg.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(seg.label,
                  style: TextStyle(
                    color: AppTheme.mutedText(context),
                    fontSize: 12,
                  )),
              const SizedBox(width: 6),
              Text(
                Formatters.money(
                  seg.value,
                  locale: locale,
                  currencyCode: currencyCode,
                  decimalDigits: decimalDigits,
                ),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({
    required this.trend,
    required this.strings,
    required this.locale,
    required this.currencyCode,
  });

  final TrendSeries trend;
  final AppLocalizations strings;
  final String locale;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final spotsIncome = List.generate(
        trend.income.length, (i) => FlSpot(i.toDouble(), trend.income[i]));
    final spotsExpense = List.generate(
        trend.expense.length, (i) => FlSpot(i.toDouble(), trend.expense[i]));
    final spotsNet = List.generate(
        trend.net.length, (i) => FlSpot(i.toDouble(), trend.net[i]));
    final allValues = [...trend.income, ...trend.expense, ...trend.net];
    final minValue = allValues.isEmpty ? 0.0 : allValues.reduce(min);
    final maxValue = allValues.isEmpty ? 0.0 : allValues.reduce(max);
    final padding = (maxValue - minValue) * 0.1;
    final minY = minValue - padding;
    final maxY = maxValue + padding;
    final yInterval = _yInterval(minY, maxY);

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 64,
                    interval: yInterval,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          _compactYAxisMoney(
                            value,
                            locale: locale,
                            currencyCode: currencyCode,
                          ),
                          style: TextStyle(
                            color: AppTheme.mutedText(context),
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: _labelInterval(trend.labels.length),
                    reservedSize: 22,
                    getTitlesWidget: (value, meta) {
                      final index = value.round();
                      if (index < 0 || index >= trend.labels.length) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          trend.labels[index],
                          style: TextStyle(
                            color: AppTheme.mutedText(context),
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: const Color(0xFF111A25),
                  getTooltipItems: (touched) {
                    return touched.map((item) {
                      final label = item.barIndex == 0
                          ? strings.trendIncome
                          : item.barIndex == 1
                              ? strings.trendExpense
                              : strings.trendNet;
                      final value = item.barIndex == 2
                          ? trend.netAbsolute[item.x.toInt()]
                          : item.y;
                      return LineTooltipItem(
                        '$label: ${value.toStringAsFixed(2)}',
                        const TextStyle(color: Colors.white, fontSize: 11),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                _line(spotsIncome, const Color(0xFF34D399)),
                _line(spotsExpense, const Color(0xFFF87171)),
                _line(spotsNet, const Color(0xFF60A5FA)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(
                color: const Color(0xFF34D399), label: strings.trendIncome),
            const SizedBox(width: 12),
            _LegendDot(
                color: const Color(0xFFF87171), label: strings.trendExpense),
            const SizedBox(width: 12),
            _LegendDot(color: const Color(0xFF60A5FA), label: strings.trendNet),
          ],
        ),
      ],
    );
  }

  LineChartBarData _line(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }
}

double _labelInterval(int count) {
  if (count <= 5) return 1;
  if (count <= 8) return 2;
  if (count <= 12) return 3;
  return max(1, (count / 6).ceilToDouble());
}

double _yInterval(double minY, double maxY) {
  final range = (maxY - minY).abs();
  if (range <= 0) return 1;
  final raw = range / 4;
  final magnitude = pow(10, (log(raw) / ln10).floor()).toDouble();
  final normalized = raw / magnitude;
  final nice = normalized >= 5
      ? 5
      : normalized >= 2
          ? 2
          : 1;
  return nice * magnitude;
}

String _compactYAxisMoney(
  double value, {
  required String locale,
  required String currencyCode,
}) {
  final symbol = Formatters.currencySymbol(currencyCode, locale);
  final sign = value < 0 ? '-' : '';
  final abs = value.abs();
  if (abs >= 1000000000) {
    return '$sign$symbol${(abs / 1000000000).toStringAsFixed(1)}B';
  }
  if (abs >= 1000000) {
    return '$sign$symbol${(abs / 1000000).toStringAsFixed(1)}M';
  }
  if (abs >= 1000) {
    return '$sign$symbol${(abs / 1000).toStringAsFixed(1)}K';
  }
  return '$sign$symbol${abs.toStringAsFixed(0)}';
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(color: AppTheme.mutedText(context), fontSize: 12)),
      ],
    );
  }
}

class _RankingList extends StatelessWidget {
  const _RankingList({
    required this.items,
    required this.locale,
    required this.currencyCode,
    required this.decimalDigits,
  });

  final List<RankingItem> items;
  final String locale;
  final String currencyCode;
  final int decimalDigits;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(AppLocalizations.of(context).noData,
          style: TextStyle(color: AppTheme.mutedText(context)));
    }
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: item.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.label,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: item.ratio,
                        minHeight: 6,
                        backgroundColor: AppTheme.surface(context, level: 3),
                        color: item.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                Formatters.money(
                  item.amount,
                  locale: locale,
                  currencyCode: currencyCode,
                  decimalDigits: decimalDigits,
                ),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _YearPickerDialog extends StatefulWidget {
  const _YearPickerDialog({required this.initialYear});

  final int initialYear;

  @override
  State<_YearPickerDialog> createState() => _YearPickerDialogState();
}

class _YearPickerDialogState extends State<_YearPickerDialog> {
  late int _year;

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).selectYear),
      content: SizedBox(
        height: 220,
        width: 260,
        child: YearPicker(
          firstDate: DateTime(2020),
          lastDate: DateTime(DateTime.now().year + 1),
          selectedDate: DateTime(_year),
          onChanged: (date) => setState(() => _year = date.year),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_year),
          child: Text(AppLocalizations.of(context).confirm),
        ),
      ],
    );
  }
}
