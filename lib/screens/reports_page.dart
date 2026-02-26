import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final month = appState.currentMonth;
    final expense = appState.totalExpense(month);
    final categories = appState.categories
        .where((cat) => cat.type == CategoryType.expense)
        .toList();

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
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2632),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _Segment(label: strings.month, selected: true),
                ),
                Expanded(
                  child: _Segment(label: strings.year, selected: false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(strings.expenseCategories,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(strings.viewAll,
                        style: const TextStyle(
                            color: AppTheme.primary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 170,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        height: 140,
                        width: 140,
                        child: CircularProgressIndicator(
                          value: 0.75,
                          strokeWidth: 14,
                          backgroundColor: const Color(0xFF263241),
                          color: AppTheme.primary,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('TOTAL',
                              style: TextStyle(
                                  color: AppTheme.textMuted, fontSize: 12)),
                          Text(
                            Formatters.money(
                              expense,
                              locale: locale,
                              currencyCode: appState.currencyCode,
                              decimalDigits: appState.decimalPlaces,
                            ),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: categories
                      .take(4)
                      .map(
                        (cat) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Color(cat.colorHex),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(cat.name,
                                style: const TextStyle(
                                    color: AppTheme.textMuted, fontSize: 12)),
                          ],
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () => appState.tabIndex = 1,
                  icon: const Icon(Symbols.swap_horiz, size: 18),
                  label: Text(strings.transactions),
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
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF141E2A),
                  ),
                  child: Center(
                    child: Text(strings.chartPlaceholder,
                        style: const TextStyle(color: AppTheme.textMuted)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.topSpending,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                ...categories.take(4).map(
                      (cat) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Color(cat.colorHex),
                          child: Icon(
                            IconData(
                              cat.icon == 0
                                  ? Symbols.category.codePoint
                                  : cat.icon,
                              fontFamily: 'MaterialSymbolsOutlined',
                            ),
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(cat.name),
                        subtitle: LinearProgressIndicator(
                          value: 0.5,
                          minHeight: 6,
                          backgroundColor: const Color(0xFF263241),
                          color: AppTheme.primary,
                        ),
                        trailing: Text(
                          Formatters.money(
                            350,
                            locale: locale,
                            currencyCode: appState.currencyCode,
                            decimalDigits: appState.decimalPlaces,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
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
