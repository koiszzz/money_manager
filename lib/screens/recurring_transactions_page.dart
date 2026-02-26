import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class RecurringTransactionsPage extends StatefulWidget {
  const RecurringTransactionsPage({super.key});

  @override
  State<RecurringTransactionsPage> createState() => _RecurringTransactionsPageState();
}

class _RecurringTransactionsPageState extends State<RecurringTransactionsPage> {
  RecurringFilter _filter = RecurringFilter.all;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final appState = context.watch<AppState>();
    final locale = Localizations.localeOf(context).toString();

    final tasks = appState.recurringTasks
        .where((task) => _filter.matches(task))
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecurring(context, strings),
        child: const Icon(Symbols.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _HeaderBar(
              title: strings.recurring,
              onBack: () => Navigator.of(context).pop(),
            ),
            SizedBox(
              height: 48,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  for (final filter in RecurringFilter.values)
                    _FilterChip(
                      label: filter.label(strings),
                      selected: _filter == filter,
                      onTap: () => setState(() => _filter = filter),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Text(strings.noRecurring,
                          style: const TextStyle(color: AppTheme.textMuted)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemBuilder: (context, index) => _RecurringCard(
                        task: tasks[index],
                        locale: locale,
                      ),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: tasks.length,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRecurring(BuildContext context, AppLocalizations strings) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.addRecurring),
        content: Text(strings.recurringPlaceholder),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.ok),
          )
        ],
      ),
    );
  }
}

enum RecurringFilter { all, active, paused, pending }

extension on RecurringFilter {
  String label(AppLocalizations strings) {
    switch (this) {
      case RecurringFilter.all:
        return strings.all;
      case RecurringFilter.active:
        return strings.active;
      case RecurringFilter.paused:
        return strings.paused;
      case RecurringFilter.pending:
        return strings.pending;
    }
  }

  bool matches(RecurringTask task) {
    final now = DateTime.now();
    final pending = task.nextRunAt.isBefore(now);
    switch (this) {
      case RecurringFilter.all:
        return true;
      case RecurringFilter.active:
        return task.enabled && !pending;
      case RecurringFilter.paused:
        return !task.enabled;
      case RecurringFilter.pending:
        return pending;
    }
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Symbols.arrow_back, size: 22),
            onPressed: onBack,
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.primary,
        labelStyle: TextStyle(color: selected ? Colors.white : AppTheme.textMuted),
      ),
    );
  }
}

class _RecurringCard extends StatelessWidget {
  const _RecurringCard({required this.task, required this.locale});

  final RecurringTask task;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final strings = AppLocalizations.of(context);
    final amount = Formatters.money(
      task.templateBill.amount,
      locale: locale,
      currencyCode: appState.currencyCode,
      decimalDigits: appState.decimalPlaces,
    );
    final isPending = task.nextRunAt.isBefore(DateTime.now());
    final statusLabel = !task.enabled
        ? strings.paused
        : isPending
            ? strings.pendingConfirm
            : strings.active;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C262E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Symbols.repeat, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.templateBill.note ?? strings.recurringTask,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(strings.category, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(amount,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(appState.currencyCode,
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.06)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Symbols.calendar_month, size: 16, color: AppTheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  strings.recurringNext(Formatters.dateLabel(task.nextRunAt, locale: locale)),
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ),
              if (isPending)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x22F59E0B),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(statusLabel,
                      style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 11)),
                )
              else
                Text(statusLabel,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(width: 8),
              Switch(
                value: task.enabled,
                onChanged: (value) =>
                    appState.toggleRecurringTask(task.id, value),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
