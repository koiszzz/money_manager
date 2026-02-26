import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final appState = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: Text(strings.reminders)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _Card(
            child: ListTile(
              leading: const Icon(Symbols.schedule),
              title: Text(strings.reminderTimeLabel),
              subtitle: Text(appState.reminderTime),
              trailing: const Icon(Symbols.chevron_right),
              onTap: () => _pickTime(context, appState),
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            child: SwitchListTile(
              title: Text(strings.budgetWarningLabel),
              subtitle: Text(strings.budgetWarningDesc),
              value: appState.budgetWarningEnabled,
              onChanged: (value) => appState.toggleBudgetWarning(value),
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            child: SwitchListTile(
              title: Text(strings.recurringReminderLabel),
              subtitle: Text(strings.recurringReminderDesc),
              value: appState.recurringReminderEnabled,
              onChanged: (value) => appState.toggleRecurringReminder(value),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(BuildContext context, AppState appState) async {
    final parts = appState.reminderTime.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 20,
      minute: int.tryParse(parts.last) ?? 0,
    );
    final selected = await showTimePicker(context: context, initialTime: initial);
    if (selected != null) {
      final value =
          '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
      await appState.updateReminderTime(value);
    }
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B2632),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
