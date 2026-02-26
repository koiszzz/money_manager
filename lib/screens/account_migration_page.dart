import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class AccountMigrationPage extends StatefulWidget {
  const AccountMigrationPage({super.key});

  @override
  State<AccountMigrationPage> createState() => _AccountMigrationPageState();
}

class _AccountMigrationPageState extends State<AccountMigrationPage> {
  String? _sourceId;
  String? _targetId;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();

    final accounts = appState.accounts;
    final sourceAccount =
        accounts.where((a) => a.id == _sourceId).cast().toList();
    final targetAccount =
        accounts.where((a) => a.id == _targetId).cast().toList();
    final source = sourceAccount.isEmpty ? null : sourceAccount.first;
    final target = targetAccount.isEmpty ? null : targetAccount.first;

    final count = _sourceId == null
        ? 0
        : appState.countRecordsForAccount(_sourceId!);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _HeaderBar(
              title: strings.accountMigration,
              onBack: () => Navigator.of(context).pop(),
              onHelp: () => _showHelp(context, strings),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  Text(
                    strings.migrationTitle,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.migrationSubtitle,
                    style: const TextStyle(color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 20),
                  _PickerField(
                    label: strings.migrationSource,
                    value: source?.name,
                    items: accounts,
                    onChanged: (id) => setState(() => _sourceId = id),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF24303B),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Icon(Symbols.arrow_right_alt,
                          size: 18, color: AppTheme.textMuted),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PickerField(
                    label: strings.migrationTarget,
                    value: target?.name,
                    items: accounts.where((a) => a.id != _sourceId).toList(),
                    onChanged: (id) => setState(() => _targetId = id),
                  ),
                  const SizedBox(height: 20),
                  _SummaryCard(
                    count: count,
                    source: source?.name ?? '--',
                    target: target?.name ?? '--',
                  ),
                  const SizedBox(height: 12),
                  _WarningCard(message: strings.migrationWarning),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _startMigration(appState, strings),
                    icon: const Icon(Symbols.sync_alt),
                    label: Text(strings.startMigration),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.lastMigration(
                      appState.lastMigrationAt == null
                          ? strings.never
                          : Formatters.dateLabel(
                              DateTime.parse(appState.lastMigrationAt!),
                              locale: locale,
                            ),
                    ),
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showHelp(BuildContext context, AppLocalizations strings) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.migrationHelpTitle),
        content: Text(strings.migrationHelpBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.ok),
          )
        ],
      ),
    );
  }

  Future<void> _startMigration(AppState appState, AppLocalizations strings) async {
    if (_sourceId == null || _targetId == null || _sourceId == _targetId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.select)),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.confirm),
        content: Text(strings.migrationConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await appState.migrateAccount(sourceId: _sourceId!, targetId: _targetId!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.migrationDone)),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({
    required this.title,
    required this.onBack,
    required this.onHelp,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
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
          TextButton(
              onPressed: onHelp, child: Text(AppLocalizations.of(context).help)),
        ],
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1C252E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: Text(AppLocalizations.of(context).select),
              items: [
                for (final account in items)
                  DropdownMenuItem(
                    value: (account as dynamic).id as String,
                    child: Text((account as dynamic).name as String),
                  ),
              ],
              onChanged: (id) {
                if (id != null) onChanged(id);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.count,
    required this.source,
    required this.target,
  });

  final int count;
  final String source;
  final String target;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C252E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Symbols.receipt_long, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.migrationSummary,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  strings.migrationSummaryBody(count, source, target),
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x22EF4444),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x44EF4444)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Symbols.warning, color: Color(0xFFF87171)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}
