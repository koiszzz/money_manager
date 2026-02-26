import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _HeaderBar(
              title: strings.reminders,
              onBack: () => Navigator.of(context).pop(),
            ),
            _PermissionCard(
              enabled: appState.systemNotificationsEnabled,
              onChanged: (value) => appState.toggleSystemNotifications(value),
            ),
            const SizedBox(height: 20),
            Text(strings.alertsReminders,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _ToggleTile(
              icon: Symbols.calendar_today,
              title: strings.dailyReminders,
              subtitle: strings.dailyRemindersDesc,
              color: const Color(0xFF60A5FA),
              value: appState.dailyReminderEnabled,
              onChanged: (value) => appState.toggleDailyReminder(value),
            ),
            _ToggleTile(
              icon: Symbols.warning,
              title: strings.budgetWarningLabel,
              subtitle: strings.budgetWarningDesc,
              color: const Color(0xFFF59E0B),
              value: appState.budgetWarningEnabled,
              onChanged: (value) => appState.toggleBudgetWarning(value),
            ),
            _ToggleTile(
              icon: Symbols.event_repeat,
              title: strings.recurringReminderLabel,
              subtitle: strings.recurringReminderDesc,
              color: const Color(0xFF34D399),
              value: appState.recurringReminderEnabled,
              onChanged: (value) => appState.toggleRecurringReminder(value),
            ),
            const SizedBox(height: 20),
            Text(strings.schedule,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _ReminderTimeCard(
              time: appState.reminderTime,
              onTap: () => _pickTime(context, appState, target: _TimeTarget.reminder),
            ),
            const SizedBox(height: 12),
            _DndCard(
              enabled: appState.dndEnabled,
              from: appState.dndFrom,
              to: appState.dndTo,
              onToggle: (value) => appState.updateDndEnabled(value),
              onPickFrom: () => _pickTime(context, appState, target: _TimeTarget.dndFrom),
              onPickTo: () => _pickTime(context, appState, target: _TimeTarget.dndTo),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    AppState appState, {
    required _TimeTarget target,
  }) async {
    final now = TimeOfDay.now();
    final result = await showTimePicker(context: context, initialTime: now);
    if (result == null) return;
    final time = Formatters.timeLabel(
      DateTime(2026, 1, 1, result.hour, result.minute),
      locale: Localizations.localeOf(context).toString(),
    );
    switch (target) {
      case _TimeTarget.reminder:
        await appState.updateReminderTime(time);
        break;
      case _TimeTarget.dndFrom:
        await appState.updateDndFrom(time);
        break;
      case _TimeTarget.dndTo:
        await appState.updateDndTo(time);
        break;
    }
  }
}

enum _TimeTarget { reminder, dndFrom, dndTo }

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
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2630),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Symbols.notifications_active, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.systemPermissions,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  enabled ? strings.statusEnabled : strings.statusDisabled,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(value: enabled, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2630),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ReminderTimeCard extends StatelessWidget {
  const _ReminderTimeCard({required this.time, required this.onTap});

  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2630),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Symbols.schedule, color: AppTheme.textMuted),
                  const SizedBox(width: 6),
                  Text(strings.reminderTimeLabel,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(time,
                      style: const TextStyle(
                          color: AppTheme.primary, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.35,
            backgroundColor: Colors.white.withOpacity(0.05),
            color: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

class _DndCard extends StatelessWidget {
  const _DndCard({
    required this.enabled,
    required this.from,
    required this.to,
    required this.onToggle,
    required this.onPickFrom,
    required this.onPickTo,
  });

  final bool enabled;
  final String from;
  final String to;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2630),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Symbols.do_not_disturb_on, color: AppTheme.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings.dndTitle,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(strings.dndSubtitle,
                        style:
                            const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Switch(value: enabled, onChanged: onToggle),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TimeBox(label: strings.from, value: from, onTap: onPickFrom),
              ),
              const SizedBox(width: 8),
              const Icon(Symbols.arrow_forward, color: AppTheme.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: _TimeBox(label: strings.to, value: to, onTap: onPickTo),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.backgroundDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
