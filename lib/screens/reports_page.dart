import 'dart:math';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  ReportRange _range = ReportRange.month;
  late DateTime _selectedMonth;
  late int _selectedYear;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    _selectedYear = now.year;
    _customRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();

    final range = _resolvedRange();
    final records =
        appState.records.where((r) => _inRange(r.occurredAt, range)).toList();

    final expenseTotals =
        _categoryTotals(records, appState, CategoryType.expense);
    final incomeTotals =
        _categoryTotals(records, appState, CategoryType.income);
    final expenseSegments = _buildSegments(expenseTotals);
    final incomeSegments = _buildSegments(incomeTotals);

    final trend = _buildTrendSeries(records, range);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Symbols.arrow_back, size: 20),
              ),
              Expanded(
                child: Text(
                  strings.reportsAnalysis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Symbols.more_vert, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _RangeSegments(
            active: _range,
            onChanged: (value) => setState(() => _range = value),
            strings: strings,
          ),
          const SizedBox(height: 12),
          _RangePickerRow(
            label: _rangeLabel(strings, locale),
            onTap: () => _pickRange(context),
          ),
          const SizedBox(height: 14),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.expenseBreakdown,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                if (expenseSegments.isEmpty)
                  _EmptyChart(label: strings.noData)
                else
                  _InteractiveDonutChart(
                    segments: expenseSegments,
                    centerLabel: strings.typeExpense,
                    onSegmentTap: (segment) {
                      _showAmount(context, segment.label, segment.value, appState,
                          locale);
                    },
                  ),
                const SizedBox(height: 12),
                _LegendGrid(
                  segments: expenseSegments,
                  locale: locale,
                  currencyCode: appState.currencyCode,
                  decimalDigits: appState.decimalPlaces,
                  onTap: (segment) => _showAmount(
                      context, segment.label, segment.value, appState, locale),
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
                if (incomeSegments.isEmpty)
                  _EmptyChart(label: strings.noData)
                else
                  _InteractiveDonutChart(
                    segments: incomeSegments,
                    centerLabel: strings.typeIncome,
                    onSegmentTap: (segment) {
                      _showAmount(context, segment.label, segment.value, appState,
                          locale);
                    },
                  ),
                const SizedBox(height: 12),
                _LegendGrid(
                  segments: incomeSegments,
                  locale: locale,
                  currencyCode: appState.currencyCode,
                  decimalDigits: appState.decimalPlaces,
                  onTap: (segment) => _showAmount(
                      context, segment.label, segment.value, appState, locale),
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
                if (trend.points.isEmpty)
                  _EmptyChart(label: strings.noData)
                else
                  _TrendChart(
                    trend: trend,
                    strings: strings,
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
                  items: _topRank(expenseTotals),
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
                  items: _topRank(incomeTotals),
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

  DateTimeRange _resolvedRange() {
    if (_range == ReportRange.month) {
      final start = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final end = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
      return DateTimeRange(start: start, end: end);
    }
    if (_range == ReportRange.year) {
      final start = DateTime(_selectedYear, 1, 1);
      final end = DateTime(_selectedYear, 12, 31);
      return DateTimeRange(start: start, end: end);
    }
    return _customRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );
  }

  bool _inRange(DateTime time, DateTimeRange range) {
    final day = DateTime(time.year, time.month, time.day);
    return !day.isBefore(DateTime(range.start.year, range.start.month, range.start.day)) &&
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
      if (type == CategoryType.income &&
          record.type != TransactionType.income) {
        continue;
      }
      final category = appState.categoryById(record.categoryId);
      if (category == null) continue;
      result.update(category, (value) => value + record.amount,
          ifAbsent: () => record.amount);
    }
    return result;
  }

  List<_PieSegment> _buildSegments(Map<Category, double> totals) {
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries
        .map(
          (e) => _PieSegment(
            label: e.key.name,
            value: e.value,
            color: Color(e.key.colorHex),
          ),
        )
        .toList();
  }

  List<_RankItem> _topRank(Map<Category, double> totals) {
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(6).toList();
    if (top.isEmpty) return [];
    final max = top.first.value <= 0 ? 1.0 : top.first.value;
    return top
        .map(
          (e) => _RankItem(
            label: e.key.name,
            amount: e.value,
            color: Color(e.key.colorHex),
            ratio: (e.value / max).clamp(0.0, 1.0),
          ),
        )
        .toList();
  }

  _TrendSeries _buildTrendSeries(
    List<TransactionRecord> records,
    DateTimeRange range,
  ) {
    final days = range.end.difference(range.start).inDays + 1;
    final isYear = days > 200;
    final bucketCount = isYear ? 12 : days;
    final income = List<double>.filled(bucketCount, 0);
    final expense = List<double>.filled(bucketCount, 0);

    for (final record in records) {
      if (record.type == TransactionType.transfer) continue;
      final index = isYear
          ? record.occurredAt.month - 1
          : record.occurredAt
              .difference(DateTime(range.start.year, range.start.month, range.start.day))
              .inDays;
      if (index < 0 || index >= bucketCount) continue;
      if (record.type == TransactionType.income) {
        income[index] += record.amount;
      } else {
        expense[index] += record.amount;
      }
    }

    final net = List<double>.filled(bucketCount, 0);
    double running = 0;
    for (var i = 0; i < bucketCount; i++) {
      running += income[i] - expense[i];
      net[i] = running;
    }

    return _TrendSeries(
      points: List.generate(bucketCount, (i) => i.toDouble()),
      income: income,
      expense: expense,
      net: net,
    );
  }

  String _rangeLabel(AppLocalizations strings, String locale) {
    if (_range == ReportRange.month) {
      return Formatters.monthLabel(_selectedMonth, locale: locale);
    }
    if (_range == ReportRange.year) {
      return _selectedYear.toString();
    }
    final range = _customRange;
    if (range == null) return strings.customRange;
    return '${Formatters.dateLabel(range.start, locale: locale)} - ${Formatters.dateLabel(range.end, locale: locale)}';
  }

  Future<void> _pickRange(BuildContext context) async {
    if (_range == ReportRange.month) {
      final picked = await showDatePicker(
        context: context,
        initialDate: _selectedMonth,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        setState(() => _selectedMonth = DateTime(picked.year, picked.month, 1));
      }
      return;
    }
    if (_range == ReportRange.year) {
      final picked = await showDialog<int>(
        context: context,
        builder: (context) => _YearPickerDialog(initialYear: _selectedYear),
      );
      if (picked != null) {
        setState(() => _selectedYear = picked);
      }
      return;
    }
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customRange,
    );
    if (picked != null) {
      setState(() => _customRange = picked);
    }
  }

  void _showAmount(
    BuildContext context,
    String label,
    double value,
    AppState appState,
    String locale,
  ) {
    final amount = Formatters.money(
      value,
      locale: locale,
      currencyCode: appState.currencyCode,
      decimalDigits: appState.decimalPlaces,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label：$amount')),
    );
  }
}

enum ReportRange { month, year, custom }

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
        color: const Color(0xFF1B2632),
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
          color: selected ? const Color(0xFF101822) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? AppTheme.primary : AppTheme.textMuted,
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
          color: const Color(0xFF1B2632),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Symbols.calendar_month, size: 18, color: AppTheme.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            const Icon(Symbols.expand_more, color: AppTheme.textMuted),
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
        color: const Color(0xFF1B2632),
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
        color: const Color(0xFF141E2A),
      ),
      child: Center(
        child: Text(label, style: const TextStyle(color: AppTheme.textMuted)),
      ),
    );
  }
}

class _PieSegment {
  const _PieSegment({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class _InteractiveDonutChart extends StatefulWidget {
  const _InteractiveDonutChart({
    required this.segments,
    required this.centerLabel,
    required this.onSegmentTap,
  });

  final List<_PieSegment> segments;
  final String centerLabel;
  final ValueChanged<_PieSegment> onSegmentTap;

  @override
  State<_InteractiveDonutChart> createState() => _InteractiveDonutChartState();
}

class _InteractiveDonutChartState extends State<_InteractiveDonutChart> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final local = box.globalToLocal(details.globalPosition);
        final center = Offset(box.size.width / 2, 70);
        final dx = local.dx - center.dx;
        final dy = local.dy - center.dy;
        final radius = sqrt(dx * dx + dy * dy);
        if (radius < 34 || radius > 70) return;
        final angle = (atan2(dy, dx) + pi / 2 + 2 * pi) % (2 * pi);
        final total =
            widget.segments.fold<double>(0, (sum, item) => sum + item.value);
        if (total <= 0) return;
        double start = 0;
        for (final seg in widget.segments) {
          final sweep = (seg.value / total) * 2 * pi;
          if (angle >= start && angle <= start + sweep) {
            widget.onSegmentTap(seg);
            return;
          }
          start += sweep;
        }
      },
      child: SizedBox(
        height: 170,
        child: CustomPaint(
          painter: _DonutPainter(segments: widget.segments),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.centerLabel,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments});

  final List<_PieSegment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<double>(0, (sum, item) => sum + item.value);
    final center = Offset(size.width / 2, 70);
    final rect = Rect.fromCircle(center: center, radius: 70);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    double start = -pi / 2;
    for (final seg in segments) {
      if (total <= 0) break;
      final sweep = (seg.value / total) * 2 * pi;
      paint.color = seg.color;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}

class _LegendGrid extends StatelessWidget {
  const _LegendGrid({
    required this.segments,
    required this.locale,
    required this.currencyCode,
    required this.decimalDigits,
    required this.onTap,
  });

  final List<_PieSegment> segments;
  final String locale;
  final String currencyCode;
  final int decimalDigits;
  final ValueChanged<_PieSegment> onTap;

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: segments.map((seg) {
        return InkWell(
          onTap: () => onTap(seg),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF141E2A),
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
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
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
          ),
        );
      }).toList(),
    );
  }
}

class _TrendSeries {
  const _TrendSeries({
    required this.points,
    required this.income,
    required this.expense,
    required this.net,
  });

  final List<double> points;
  final List<double> income;
  final List<double> expense;
  final List<double> net;
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.trend, required this.strings});

  final _TrendSeries trend;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: CustomPaint(
            painter: _TrendPainter(trend: trend),
            child: Container(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: const Color(0xFF34D399), label: strings.trendIncome),
            const SizedBox(width: 12),
            _LegendDot(color: const Color(0xFFF87171), label: strings.trendExpense),
            const SizedBox(width: 12),
            _LegendDot(color: const Color(0xFF60A5FA), label: strings.trendNet),
          ],
        ),
      ],
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({required this.trend});

  final _TrendSeries trend;

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = [
      ...trend.income.map((e) => e.abs()),
      ...trend.expense.map((e) => e.abs()),
      ...trend.net.map((e) => e.abs()),
    ].fold<double>(0, max);
    final scale = maxValue <= 0 ? 1.0 : maxValue;

    final padding = 12.0;
    final width = size.width - padding * 2;
    final height = size.height - padding * 2;
    final count = trend.points.length;
    if (count <= 1) return;

    final dx = width / (count - 1);

    Offset pointFor(List<double> data, int i) {
      final x = padding + dx * i;
      final y = padding + height - (data[i] / scale) * height;
      return Offset(x, y);
    }

    void drawLine(List<double> data, Color color) {
      final path = Path();
      for (var i = 0; i < data.length; i++) {
        final p = pointFor(data, i);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color;
      canvas.drawPath(path, paint);
    }

    drawLine(trend.income, const Color(0xFF34D399));
    drawLine(trend.expense, const Color(0xFFF87171));
    drawLine(trend.net, const Color(0xFF60A5FA));
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.trend != trend;
  }
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
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
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

  final List<_RankItem> items;
  final String locale;
  final String currencyCode;
  final int decimalDigits;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(AppLocalizations.of(context).noData,
          style: const TextStyle(color: AppTheme.textMuted));
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
                        backgroundColor: const Color(0xFF263241),
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

class _RankItem {
  const _RankItem({
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
