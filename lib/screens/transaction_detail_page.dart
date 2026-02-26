import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'add_edit_transaction_page.dart';

class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({super.key, required this.recordId});

  final String recordId;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final strings = AppLocalizations.of(context);
    final appState = context.watch<AppState>();
    final record = appState.records.firstWhere((item) => item.id == recordId);
    final category = appState.categoryById(record.categoryId);
    final account = appState.accountById(record.accountId);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.edit),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Center(
            child: Text(
              Formatters.money(
                record.type == TransactionType.expense
                    ? -record.amount
                    : record.amount,
                showSign: record.type != TransactionType.transfer,
                locale: locale,
                currencyCode: appState.currencyCode,
                decimalDigits: appState.decimalPlaces,
              ),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: record.type == TransactionType.expense
                    ? Colors.redAccent
                    : record.type == TransactionType.income
                        ? Colors.greenAccent
                        : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              Formatters.dateLabel(record.occurredAt, locale: locale),
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
          _EditCard(children: [
            _EditRow(
              icon: Symbols.swap_vert,
              label: strings.typeLabel.toUpperCase(),
              value: _typeLabel(strings, record.type),
              onTap: () {},
            ),
            _EditRow(
              icon: Symbols.category,
              label: strings.category.toUpperCase(),
              value: category?.name ?? strings.typeTransfer,
              onTap: () {},
            ),
            _EditRow(
              icon: Symbols.account_balance_wallet,
              label: strings.account.toUpperCase(),
              value: account.name,
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 12),
          _EditCard(children: [
            _EditRow(
              icon: Symbols.calendar_today,
              label: strings.time.toUpperCase(),
              value: Formatters.dateLabel(record.occurredAt, locale: locale),
              onTap: () {},
            ),
            _EditRow(
              icon: Symbols.notes,
              label: strings.note.toUpperCase(),
              value: record.note ?? strings.tapToAdd,
              onTap: () {},
            ),
            _EditRow(
              icon: Symbols.tag,
              label: strings.tags.toUpperCase(),
              value: record.tags.isEmpty ? strings.none : record.tags.join(' · '),
              onTap: () {},
              trailing: const Icon(Symbols.add, size: 18),
            ),
          ]),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditTransactionPage(record: record),
                ),
              );
            },
            child: Text(strings.saveChanges),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddEditTransactionPage(
                          record: record,
                          isCopy: true,
                        ),
                      ),
                    );
                  },
                  child: Text(strings.duplicate),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final strings = AppLocalizations.of(context);
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(strings.confirmDelete),
                        content: Text(strings.deleteWarning),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(strings.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(strings.delete),
                          )
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      appState.deleteRecord(record.id);
                      Navigator.of(context).pop();
                    }
                  },
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: Text(strings.delete),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  String _typeLabel(AppLocalizations strings, TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return strings.typeExpense;
      case TransactionType.income:
        return strings.typeIncome;
      case TransactionType.transfer:
        return strings.typeTransfer;
    }
  }
}

class _EditCard extends StatelessWidget {
  const _EditCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B2632),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _EditRow extends StatelessWidget {
  const _EditRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF243241),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
      title: Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: trailing ?? const Icon(Symbols.chevron_right, size: 18),
      onTap: onTap,
    );
  }
}
