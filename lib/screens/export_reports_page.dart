import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class ExportReportsPage extends StatefulWidget {
  const ExportReportsPage({super.key});

  @override
  State<ExportReportsPage> createState() => _ExportReportsPageState();
}

class _ExportReportsPageState extends State<ExportReportsPage> {
  ExportRangeType _rangeType = ExportRangeType.custom;
  ExportFormat _format = ExportFormat.csv;
  DateTime _focusMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _rangeStart = DateTime(now.year, now.month, 1);
    _rangeEnd = now;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final appState = context.watch<AppState>();
    final locale = Localizations.localeOf(context).toString();

    final fileName =
        'ledger_${_focusMonth.year}-${_focusMonth.month.toString().padLeft(2, '0')}';

    final records = appState.records
        .where((record) {
          if (_rangeStart == null || _rangeEnd == null) return false;
          return record.occurredAt
                  .isAfter(_rangeStart!.subtract(const Duration(days: 1))) &&
              record.occurredAt
                  .isBefore(_rangeEnd!.add(const Duration(days: 1)));
        })
        .take(3)
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                _HeaderBar(
                  title: strings.exportData,
                  onBack: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 8),
                Text(strings.exportTitle,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(strings.exportSubtitle,
                    style: const TextStyle(color: AppTheme.textMuted)),
                const SizedBox(height: 16),
                _RangeSelector(
                  value: _rangeType,
                  onChanged: (value) => setState(() {
                    _rangeType = value;
                    final now = DateTime.now();
                    if (value == ExportRangeType.month) {
                      _focusMonth = DateTime(now.year, now.month, 1);
                      _rangeStart = _focusMonth;
                      _rangeEnd = DateTime(now.year, now.month + 1, 0);
                    } else if (value == ExportRangeType.year) {
                      _focusMonth = DateTime(now.year, 1, 1);
                      _rangeStart = DateTime(now.year, 1, 1);
                      _rangeEnd = DateTime(now.year, 12, 31);
                    }
                  }),
                ),
                const SizedBox(height: 16),
                _CalendarCard(
                  focusMonth: _focusMonth,
                  rangeStart: _rangeStart,
                  rangeEnd: _rangeEnd,
                  onPrev: () => setState(() => _focusMonth =
                      DateTime(_focusMonth.year, _focusMonth.month - 1, 1)),
                  onNext: () => setState(() => _focusMonth =
                      DateTime(_focusMonth.year, _focusMonth.month + 1, 1)),
                  onSelectDay: (date) {
                    setState(() {
                      if (_rangeStart == null || _rangeEnd != null) {
                        _rangeStart = date;
                        _rangeEnd = null;
                      } else {
                        if (date.isBefore(_rangeStart!)) {
                          _rangeEnd = _rangeStart;
                          _rangeStart = date;
                        } else {
                          _rangeEnd = date;
                        }
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(strings.exportSettings,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _InputField(
                  label: strings.fileName,
                  value: fileName,
                  suffix: _format.extension,
                ),
                const SizedBox(height: 12),
                _FormatSelector(
                  value: _format,
                  onChanged: (value) => setState(() => _format = value),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(strings.columnsPreview,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    TextButton(
                        onPressed: () {}, child: Text(strings.editColumns)),
                  ],
                ),
                const SizedBox(height: 8),
                _PreviewTable(
                    records: records, locale: locale, appState: appState),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark.withOpacity(0.9),
                  border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.05))),
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(strings.exportDone)));
                  },
                  icon: const Icon(Symbols.ios_share),
                  label: Text(strings.exportToFile),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ExportRangeType { month, year, custom }

enum ExportFormat { csv, pdf, xls }

extension on ExportFormat {
  String get extension {
    switch (this) {
      case ExportFormat.csv:
        return '.csv';
      case ExportFormat.pdf:
        return '.pdf';
      case ExportFormat.xls:
        return '.xls';
    }
  }

  String label(AppLocalizations strings) {
    switch (this) {
      case ExportFormat.csv:
        return 'CSV';
      case ExportFormat.pdf:
        return 'PDF';
      case ExportFormat.xls:
        return 'XLS';
    }
  }

  IconData get icon {
    switch (this) {
      case ExportFormat.csv:
        return Symbols.description;
      case ExportFormat.pdf:
        return Symbols.picture_as_pdf;
      case ExportFormat.xls:
        return Symbols.table_view;
    }
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Symbols.arrow_back, size: 22),
          onPressed: onBack,
        ),
        Expanded(
          child: Center(
            child: Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.value, required this.onChanged});

  final ExportRangeType value;
  final ValueChanged<ExportRangeType> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2933),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _RangeChip(
            label: strings.month,
            selected: value == ExportRangeType.month,
            onTap: () => onChanged(ExportRangeType.month),
          ),
          _RangeChip(
            label: strings.year,
            selected: value == ExportRangeType.year,
            onTap: () => onChanged(ExportRangeType.year),
          ),
          _RangeChip(
            label: strings.custom,
            selected: value == ExportRangeType.custom,
            onTap: () => onChanged(ExportRangeType.custom),
          ),
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2C3B47) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: selected ? AppTheme.primary : AppTheme.textMuted,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.focusMonth,
    required this.rangeStart,
    required this.rangeEnd,
    required this.onPrev,
    required this.onNext,
    required this.onSelectDay,
  });

  final DateTime focusMonth;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final firstDay = DateTime(focusMonth.year, focusMonth.month, 1);
    final daysInMonth = DateTime(focusMonth.year, focusMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // Sunday as 0

    final labels = AppLocalizations.of(context).weekLabels;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface(context, level: 2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outline(context)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: onPrev, icon: const Icon(Symbols.chevron_left)),
              Text(Formatters.monthLabel(focusMonth, locale: locale),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              IconButton(
                  onPressed: onNext, icon: const Icon(Symbols.chevron_right)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final label in labels)
                Expanded(
                  child: Center(
                    child: Text(label,
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 11)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1.1,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startWeekday) return const SizedBox.shrink();
              final day = index - startWeekday + 1;
              final date = DateTime(focusMonth.year, focusMonth.month, day);
              final selected = rangeStart != null &&
                  rangeEnd != null &&
                  date.isAfter(rangeStart!.subtract(const Duration(days: 1))) &&
                  date.isBefore(rangeEnd!.add(const Duration(days: 1)));
              final isStart =
                  rangeStart != null && _isSameDay(rangeStart!, date);
              final isEnd = rangeEnd != null && _isSameDay(rangeEnd!, date);

              return GestureDetector(
                onTap: () => onSelectDay(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primary.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: (isStart || isEnd)
                            ? AppTheme.primary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            color: (isStart || isEnd)
                                ? Colors.white
                                : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _InputField extends StatelessWidget {
  const _InputField(
      {required this.label, required this.value, required this.suffix});

  final String label;
  final String value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.surface(context, level: 2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.outline(context)),
          ),
          child: Row(
            children: [
              const Icon(Symbols.description,
                  color: AppTheme.textMuted, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(value)),
              Text(suffix, style: const TextStyle(color: AppTheme.textMuted)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FormatSelector extends StatelessWidget {
  const _FormatSelector({required this.value, required this.onChanged});

  final ExportFormat value;
  final ValueChanged<ExportFormat> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Row(
      children: [
        for (final format in ExportFormat.values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: value == format
                      ? AppTheme.primary.withOpacity(0.2)
                      : AppTheme.surface(context, level: 2),
                  foregroundColor:
                      value == format ? AppTheme.primary : AppTheme.textMuted,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => onChanged(format),
                icon: Icon(format.icon, size: 18),
                label: Text(format.label(strings)),
              ),
            ),
          ),
      ],
    );
  }
}

class _PreviewTable extends StatelessWidget {
  const _PreviewTable({
    required this.records,
    required this.locale,
    required this.appState,
  });

  final List<TransactionRecord> records;
  final String locale;
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface(context, level: 2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outline(context)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF1E2933),
            child: Row(
              children: [
                Expanded(child: Text(strings.date, style: _headerStyle)),
                Expanded(child: Text(strings.category, style: _headerStyle)),
                Expanded(child: Text(strings.note, style: _headerStyle)),
                Expanded(
                    child: Text(strings.amount,
                        style: _headerStyle, textAlign: TextAlign.end)),
              ],
            ),
          ),
          for (final record in records)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                    Formatters.dateLabel(record.occurredAt, locale: locale),
                    style: const TextStyle(fontSize: 12),
                  )),
                  Expanded(
                      child: Text(
                    appState.categoryById(record.categoryId)?.name ?? '--',
                    style: const TextStyle(fontSize: 12),
                  )),
                  Expanded(
                      child: Text(
                    record.note ?? '--',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted),
                  )),
                  Expanded(
                      child: Text(
                    Formatters.money(
                      record.type == TransactionType.expense
                          ? -record.amount
                          : record.amount,
                      showSign: true,
                      locale: locale,
                      currencyCode: appState.currencyCode,
                      decimalDigits: appState.decimalPlaces,
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: record.type == TransactionType.expense
                          ? const Color(0xFFF87171)
                          : const Color(0xFF34D399),
                    ),
                    textAlign: TextAlign.end,
                  )),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Text(strings.moreRows,
                style:
                    const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

const _headerStyle = TextStyle(color: AppTheme.textMuted, fontSize: 11);
