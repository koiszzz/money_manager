import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final month = appState.currentMonth;
    final budget = appState.budgetForMonth(month);
    final used = appState.budgetUsed(month);
    final ratio = appState.budgetUsageRatio(month);

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
                  strings.budget,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => appState.setMonth(DateTime(month.year, month.month - 1, 1)),
                icon: const Icon(Symbols.chevron_left, size: 18),
              ),
              Text(Formatters.monthLabel(month, locale: locale),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              IconButton(
                onPressed: () => appState.setMonth(DateTime(month.year, month.month + 1, 1)),
                icon: const Icon(Symbols.chevron_right, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2632),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(strings.budgetUsed, style: const TextStyle(color: AppTheme.textMuted)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2A36),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(strings.onTrack, style: const TextStyle(fontSize: 10)),
                    )
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  Formatters.money(used, locale: locale),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${strings.budgetLimit} ${Formatters.money(budget.totalAmount, locale: locale)}',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                    backgroundColor: const Color(0xFF263241),
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${(ratio * 100).toStringAsFixed(0)}% ${strings.used}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    Text(
                      '${Formatters.money(budget.totalAmount - used, locale: locale)} ${strings.left}',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Symbols.edit),
                  label: Text(strings.editBudget),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Symbols.add),
                  label: Text(strings.addCategory),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(strings.categoryBreakdown,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(strings.viewAll,
                  style: const TextStyle(color: AppTheme.primary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(4, (index) {
            return _CategoryBudgetTile(
              name: 'Category ${index + 1}',
              spent: 350 + index * 40,
              limit: 500 + index * 100,
              progress: 0.6,
              leftLabel: strings.left,
              overLabel: strings.over,
            );
          }),
        ],
      ),
    );
  }
}

class _CategoryBudgetTile extends StatelessWidget {
  const _CategoryBudgetTile({
    required this.name,
    required this.spent,
    required this.limit,
    required this.progress,
    required this.leftLabel,
    required this.overLabel,
  });

  final String name;
  final double spent;
  final double limit;
  final double progress;
  final String leftLabel;
  final String overLabel;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final remaining = limit - spent;
    final over = remaining < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2632),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF263241),
                child: const Icon(Symbols.restaurant, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text(
                '${Formatters.money(spent, locale: locale)} / ${Formatters.money(limit, locale: locale)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFF263241),
              color: over ? Colors.redAccent : AppTheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            over
                ? '${Formatters.money(remaining, locale: locale)} $overLabel'
                : '${Formatters.money(remaining, locale: locale)} $leftLabel',
            style: TextStyle(
              color: over ? Colors.redAccent : AppTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
