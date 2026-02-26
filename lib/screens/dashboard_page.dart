import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'add_edit_transaction_page.dart';
import 'budget_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final month = appState.currentMonth;
    final income = appState.totalIncome(month);
    final expense = appState.totalExpense(month);
    final balance = appState.netBalance(month);
    final budget = appState.budgetForMonth(month);
    final budgetUsed = appState.budgetUsed(month);
    final budgetRatio = appState.budgetUsageRatio(month);
    final recentRecords = appState.recordsForMonth(month).take(6).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF334155),
                child: Text('S', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.welcomeBack,
                      style: const TextStyle(color: AppTheme.textMuted)),
                  const Text(
                    'Sarah Jenkins',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Symbols.notifications, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MonthSwitcher(
            month: month,
            locale: locale,
            onPrev: () =>
                appState.setMonth(DateTime(month.year, month.month - 1, 1)),
            onNext: () =>
                appState.setMonth(DateTime(month.year, month.month + 1, 1)),
          ),
          const SizedBox(height: 16),
          _BalanceCard(
            amount: balance,
            locale: locale,
            currencyCode: appState.currencyCode,
            decimalDigits: appState.decimalPlaces,
            title: strings.totalBalance,
            changeLabel: strings.lastMonthChange,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: strings.monthIncome,
                  value: Formatters.money(
                    income,
                    locale: locale,
                    currencyCode: appState.currencyCode,
                    decimalDigits: appState.decimalPlaces,
                  ),
                  icon: Symbols.south_west,
                  iconColor: Colors.greenAccent.shade200,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: strings.monthExpense,
                  value: Formatters.money(
                    expense,
                    locale: locale,
                    currencyCode: appState.currencyCode,
                    decimalDigits: appState.decimalPlaces,
                  ),
                  icon: Symbols.north_east,
                  iconColor: Colors.redAccent.shade200,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _BudgetCard(
            total: budget.totalAmount,
            used: budgetUsed,
            ratio: budgetRatio,
            locale: locale,
            currencyCode: appState.currencyCode,
            decimalDigits: appState.decimalPlaces,
            title: strings.monthlyBudget,
            usedLabel: strings.spent,
            leftLabel: strings.left,
            percentLabel: strings.used,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BudgetPage()),
              );
            },
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(strings.recent,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton(
                onPressed: () => appState.tabIndex = 1,
                child: Text(strings.seeAll),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (recentRecords.isEmpty)
            _EmptyState(
              label: strings.noTransactions,
              actionLabel: strings.goAdd,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const AddEditTransactionPage()),
                );
              },
            )
          else
            ...recentRecords.map(
              (record) => _RecentItem(
                record: record,
                locale: locale,
                currencyCode: appState.currencyCode,
                decimalDigits: appState.decimalPlaces,
              ),
            ),
        ],
      ),
    );
  }
}

class _MonthSwitcher extends StatelessWidget {
  const _MonthSwitcher({
    required this.month,
    required this.locale,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final String locale;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF16202B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Symbols.chevron_left),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Symbols.calendar_month, size: 18),
              const SizedBox(width: 8),
              Text(Formatters.monthLabel(month, locale: locale),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Symbols.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.amount,
    required this.locale,
    required this.currencyCode,
    required this.decimalDigits,
    required this.title,
    required this.changeLabel,
  });

  final double amount;
  final String locale;
  final String currencyCode;
  final int decimalDigits;
  final String title;
  final String changeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF2B7CEE), Color(0xFF3B82F6)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B7CEE).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            Formatters.money(
              amount,
              locale: locale,
              currencyCode: currencyCode,
              decimalDigits: decimalDigits,
            ),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Symbols.trending_up, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Text(changeLabel, style: const TextStyle(color: Colors.white70)),
            ],
          )
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2632),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: iconColor.withOpacity(0.15),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.total,
    required this.used,
    required this.ratio,
    required this.locale,
    required this.currencyCode,
    required this.decimalDigits,
    required this.title,
    required this.usedLabel,
    required this.leftLabel,
    required this.percentLabel,
    required this.onTap,
  });

  final double total;
  final double used;
  final double ratio;
  final String locale;
  final String currencyCode;
  final int decimalDigits;
  final String title;
  final String usedLabel;
  final String leftLabel;
  final String percentLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2632),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Symbols.pie_chart,
                    size: 18, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
                '${Formatters.money(used, locale: locale, currencyCode: currencyCode, decimalDigits: decimalDigits)} $usedLabel',
                style:
                    const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
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
                Text(
                    '${Formatters.money(total - used, locale: locale, currencyCode: currencyCode, decimalDigits: decimalDigits)} $leftLabel',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
                Text('${(ratio * 100).toStringAsFixed(0)}% $percentLabel',
                    style:
                        const TextStyle(color: AppTheme.primary, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _RecentItem extends StatelessWidget {
  const _RecentItem({
    required this.record,
    required this.locale,
    required this.currencyCode,
    required this.decimalDigits,
  });

  final TransactionRecord record;
  final String locale;
  final String currencyCode;
  final int decimalDigits;

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final category = appState.categoryById(record.categoryId);
    final account = appState.accountById(record.accountId);
    final color = record.type == TransactionType.income
        ? Colors.greenAccent
        : record.type == TransactionType.expense
            ? Colors.redAccent
            : Colors.blueGrey;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF151F2B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Color(category?.colorHex ?? 0xFF334155),
            child: Icon(
              IconData(
                (category?.icon ?? 0) == 0
                    ? Symbols.swap_horiz.codePoint
                    : category!.icon,
                fontFamily: 'MaterialSymbolsOutlined',
              ),
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category?.name ?? '转账',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '${account.name} · ${Formatters.timeLabel(record.occurredAt, locale: locale)}',
                  style:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            Formatters.money(
              record.type == TransactionType.expense
                  ? -record.amount
                  : record.amount,
              showSign: record.type != TransactionType.transfer,
              locale: locale,
              currencyCode: currencyCode,
              decimalDigits: decimalDigits,
            ),
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.label,
    required this.actionLabel,
    required this.onTap,
  });

  final String label;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2632),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(label),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onTap,
            icon: const Icon(Symbols.add),
            label: Text(actionLabel),
          )
        ],
      ),
    );
  }
}
