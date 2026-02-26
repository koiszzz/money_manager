import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class RecurringTransactionsPage extends StatelessWidget {
  const RecurringTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final appState = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: Text(strings.recurring)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, appState, strings),
        child: const Icon(Symbols.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: appState.recurringTasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final task = appState.recurringTasks[index];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2632),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF263241),
                  child: Icon(
                    Symbols.update,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.templateBill.note ?? strings.recurring,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('Next: ${task.nextRunAt.toString().split(' ').first}',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                Switch(
                  value: task.enabled,
                  onChanged: (value) => appState.toggleRecurringTask(task.id, value),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddDialog(
      BuildContext context, AppState appState, AppLocalizations strings) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final uuid = const Uuid();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.recurring),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: strings.amount),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              decoration: InputDecoration(hintText: strings.note),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount <= 0) return;
              final template = TransactionRecord(
                id: uuid.v4(),
                type: TransactionType.expense,
                amount: amount,
                categoryId: appState.categories.first.id,
                accountId: appState.accounts.first.id,
                occurredAt: DateTime.now(),
                note: noteController.text.trim().isEmpty
                    ? strings.recurring
                    : noteController.text.trim(),
                tags: const [],
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              final task = RecurringTask(
                id: uuid.v4(),
                templateBill: template,
                rule: 'monthly',
                nextRunAt: DateTime.now().add(const Duration(days: 30)),
                autoGenerate: true,
                enabled: true,
              );
              await appState.addRecurringTask(task);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(strings.confirm),
          ),
        ],
      ),
    );
  }
}
