import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'add_edit_transaction_page.dart';
import 'transaction_detail_page.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final month = appState.currentMonth;
    final records = appState.filteredRecords(month)
        .where((record) => _matchSearch(appState, record))
        .toList();

    return SafeArea(
      child: Column(
        children: [
          _Header(
            controller: _searchController,
            title: strings.transactionsTitle,
            searchHint: strings.searchHint,
            onMoreTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddEditTransactionPage()),
              );
            },
          ),
          _FilterChips(
            activeType: appState.transactionsFilterType,
            onSelected: appState.setTransactionsFilterType,
            strings: strings,
          ),
          Expanded(
            child: records.isEmpty
                ? _EmptyList(
                    label: strings.noTransactions,
                    actionLabel: strings.goAdd,
                    onAdd: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddEditTransactionPage(),
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      final groupLabel = _groupLabel(strings, record.occurredAt);
                      final showHeader = index == 0 ||
                          _groupLabel(strings, records[index - 1].occurredAt) != groupLabel;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showHeader)
                            _GroupHeader(
                              label: groupLabel,
                              records: records,
                              record: record,
                              locale: locale,
                              currencyCode: appState.currencyCode,
                              decimalDigits: appState.decimalPlaces,
                            ),
                          _TransactionTile(
                            record: record,
                            locale: locale,
                            currencyCode: appState.currencyCode,
                            decimalDigits: appState.decimalPlaces,
                          ),
                        ],
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  bool _matchSearch(AppState appState, TransactionRecord record) {
    final query = _searchController.text.trim();
    if (query.isEmpty) return true;
    final category = appState.categoryById(record.categoryId);
    final account = appState.accountById(record.accountId);
    final note = record.note ?? '';
    return note.contains(query) ||
        category?.name.contains(query) == true ||
        account.name.contains(query) ||
        record.amount.toString().contains(query);
  }

  String _groupLabel(AppLocalizations strings, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    if (target == today) {
      return strings.today;
    }
    if (target == today.subtract(const Duration(days: 1))) {
      return strings.yesterday;
    }
    return '${date.month}/${date.day}';
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.controller,
    required this.onMoreTap,
    required this.title,
    required this.searchHint,
  });

  final TextEditingController controller;
  final VoidCallback onMoreTap;
  final String title;
  final String searchHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF101822),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Symbols.arrow_back, size: 20),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                onPressed: onMoreTap,
                icon: const Icon(Symbols.more_vert, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: searchHint,
                    prefixIcon: const Icon(Symbols.search, size: 18),
                    filled: true,
                    fillColor: const Color(0xFF141E2A),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF141E2A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Symbols.filter_list, size: 18),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.activeType,
    required this.onSelected,
    required this.strings,
  });

  final TransactionType? activeType;
  final ValueChanged<TransactionType?> onSelected;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _Chip(
            label: strings.allTime,
            selected: activeType == null,
            onTap: () => onSelected(null),
          ),
          _Chip(
            label: strings.thisMonth,
            selected: false,
            onTap: () => onSelected(null),
          ),
          _Chip(
            label: strings.typeIncome,
            selected: activeType == TransactionType.income,
            onTap: () => onSelected(TransactionType.income),
          ),
          _Chip(
            label: strings.typeExpense,
            selected: activeType == TransactionType.expense,
            onTap: () => onSelected(TransactionType.expense),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.primary : const Color(0xFF1F2A36);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => onTap(),
        label: Text(label),
        selectedColor: AppTheme.primary,
        backgroundColor: const Color(0xFF1B2632),
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppTheme.textMuted,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.label,
    required this.records,
    required this.record,
    required this.locale,
    required this.currencyCode,
    required this.decimalDigits,
  });

  final String label;
  final List<TransactionRecord> records;
  final TransactionRecord record;
  final String locale;
  final String currencyCode;
  final int decimalDigits;

  @override
  Widget build(BuildContext context) {
    final total = records
        .where((item) =>
            item.occurredAt.year == record.occurredAt.year &&
            item.occurredAt.month == record.occurredAt.month &&
            item.occurredAt.day == record.occurredAt.day)
        .fold<double>(0, (sum, item) {
      if (item.type == TransactionType.income) return sum + item.amount;
      if (item.type == TransactionType.expense) return sum - item.amount;
      return sum;
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF111B26),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted)),
          Text(
            Formatters.money(
              total,
              showSign: true,
              locale: locale,
              currencyCode: currencyCode,
              decimalDigits: decimalDigits,
            ),
            style: TextStyle(
              color: total >= 0 ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
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

    return Dismissible(
      key: ValueKey(record.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(AppLocalizations.of(context).confirmDelete),
                content: Text(AppLocalizations.of(context).deleteWarning),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(AppLocalizations.of(context).cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(AppLocalizations.of(context).delete),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) {
        appState.deleteRecord(record.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).deleted),
            action: SnackBarAction(
              label: AppLocalizations.of(context).undo,
              onPressed: () {
                appState.restoreRecord(record);
              },
            ),
          ),
        );
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Symbols.delete, color: Colors.white),
      ),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TransactionDetailPage(recordId: record.id),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: Color(category?.colorHex ?? 0xFF334155),
          child: Icon(
            IconData(
              (category?.icon ?? 0) == 0
                  ? Symbols.swap_horiz.codePoint
                  : category!.icon,
              fontFamily: 'MaterialSymbolsOutlined',
            ),
            color: Colors.white,
            size: 18,
          ),
        ),
        title: Text(category?.name ?? '转账'),
        subtitle: Text(
            '${account.name} • ${Formatters.timeLabel(record.occurredAt, locale: locale)}',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        trailing: Text(
          Formatters.money(
            record.type == TransactionType.expense ? -record.amount : record.amount,
            showSign: record.type != TransactionType.transfer,
            locale: locale,
            currencyCode: currencyCode,
            decimalDigits: decimalDigits,
          ),
          style: TextStyle(fontWeight: FontWeight.w600, color: color),
        ),
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList({
    required this.label,
    required this.actionLabel,
    required this.onAdd,
  });

  final String label;
  final String actionLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Symbols.add),
            label: Text(actionLabel),
          )
        ],
      ),
    );
  }
}
