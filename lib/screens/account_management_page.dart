import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'account_migration_page.dart';

class AccountManagementPage extends StatefulWidget {
  const AccountManagementPage({super.key});

  @override
  State<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  bool _reorderMode = false;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();

    final bankAccounts = appState.accounts
        .where((a) => a.type == AccountType.bank || a.type == AccountType.debitCard)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final creditAccounts = appState.accounts
        .where((a) => a.type == AccountType.creditCard)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final cashAccounts = appState.accounts
        .where((a) => a.type == AccountType.cash || a.type == AccountType.other)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _HeaderBar(
              title: strings.accounts,
              actionLabel: strings.edit,
              onBack: () => Navigator.of(context).pop(),
              onAction: () => setState(() => _reorderMode = !_reorderMode),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                children: [
                  _NetWorthCard(
                    total: appState.totalAssets(),
                    locale: locale,
                    currencyCode: appState.currencyCode,
                    decimalDigits: appState.decimalPlaces,
                  ),
                  const SizedBox(height: 12),
                  _SectionTitle(title: strings.accountsBankSection),
                  const SizedBox(height: 8),
                  _AccountList(
                    accounts: bankAccounts,
                    reorderMode: _reorderMode,
                    onReorder: (next) => appState.updateAccountOrder(next),
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(title: strings.accountsCreditSection),
                  const SizedBox(height: 8),
                  _AccountList(
                    accounts: creditAccounts,
                    reorderMode: _reorderMode,
                    onReorder: (next) => appState.updateAccountOrder(next),
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(title: strings.accountsCashSection),
                  const SizedBox(height: 8),
                  _AccountList(
                    accounts: cashAccounts,
                    reorderMode: _reorderMode,
                    onReorder: (next) => appState.updateAccountOrder(next),
                  ),
                  const SizedBox(height: 20),
                  _MigrationCard(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AccountMigrationPage(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF101822),
              Color(0xFF101822),
              Colors.transparent,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () => _showAccountEditor(context, appState, strings),
          icon: const Icon(Symbols.add_circle, size: 22),
          label: Text(strings.addNewAccount,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Future<void> _showAccountEditor(
    BuildContext context,
    AppState appState,
    AppLocalizations strings, {
    Account? account,
  }) async {
    final nameController = TextEditingController(text: account?.name ?? '');
    final noteController = TextEditingController(text: account?.note ?? '');
    final balanceController = TextEditingController(
      text: account != null ? account.openingBalance.toStringAsFixed(2) : '',
    );
    AccountType type = account?.type ?? AccountType.bank;
    final isEdit = account != null;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF16202A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEdit ? strings.editAccount : strings.addNewAccount,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _LabeledField(
              label: strings.accountName,
              controller: nameController,
              hintText: strings.accountNameHint,
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: strings.accountNote,
              controller: noteController,
              hintText: strings.accountNoteHint,
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: strings.openingBalance,
              controller: balanceController,
              hintText: '0.00',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _TypePicker(
              value: type,
              onChanged: (value) => type = value,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(strings.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) return;
                      final balance =
                          double.tryParse(balanceController.text) ?? 0.0;
                      if (account == null) {
                        await appState.addAccount(
                          name: name,
                          type: type,
                          openingBalance: balance,
                          note: noteController.text.trim().isEmpty
                              ? null
                              : noteController.text.trim(),
                        );
                      } else {
                        await appState.updateAccount(Account(
                          id: account.id,
                          name: name,
                          type: type,
                          openingBalance: balance,
                          note: noteController.text.trim().isEmpty
                              ? null
                              : noteController.text.trim(),
                          enabled: account.enabled,
                          sortOrder: account.sortOrder,
                        ));
                      }
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: Text(strings.save),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({
    required this.title,
    required this.actionLabel,
    required this.onBack,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onBack;
  final VoidCallback onAction;

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
            onPressed: onAction,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _NetWorthCard extends StatelessWidget {
  const _NetWorthCard({
    required this.total,
    required this.locale,
    required this.currencyCode,
    required this.decimalDigits,
  });

  final double total;
  final String locale;
  final String currencyCode;
  final int decimalDigits;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2A35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).netWorth,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Formatters.money(
                        total,
                        locale: locale,
                        currencyCode: currencyCode,
                        decimalDigits: decimalDigits,
                      ),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Icon(Symbols.trending_up,
                            color: Color(0xFF34D399), size: 16),
                        SizedBox(width: 6),
                        Text(
                          '+2.4% this month',
                          style: TextStyle(
                            color: Color(0xFF34D399),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundColor: AppTheme.primary.withOpacity(0.2),
                radius: 24,
                child: const Icon(
                  Symbols.account_balance_wallet,
                  color: AppTheme.primary,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}

class _AccountList extends StatelessWidget {
  const _AccountList({
    required this.accounts,
    required this.reorderMode,
    required this.onReorder,
  });

  final List<Account> accounts;
  final bool reorderMode;
  final ValueChanged<List<Account>> onReorder;

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          AppLocalizations.of(context).emptyAccounts,
          style: const TextStyle(color: AppTheme.textMuted),
        ),
      );
    }
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: accounts.length,
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) {
        final next = [...accounts];
        if (newIndex > oldIndex) newIndex -= 1;
        final item = next.removeAt(oldIndex);
        next.insert(newIndex, item);
        onReorder(next);
      },
      itemBuilder: (context, index) {
        final account = accounts[index];
        return _AccountRow(
          key: ValueKey(account.id),
          account: account,
          index: index,
          reorderMode: reorderMode,
        );
      },
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    super.key,
    required this.account,
    required this.index,
    required this.reorderMode,
  });

  final Account account;
  final int index;
  final bool reorderMode;

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final locale = Localizations.localeOf(context).toString();
    final balance = appState.accountBalance(account.id);
    final strings = AppLocalizations.of(context);

    final content = Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF121B24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
          children: [
            if (reorderMode)
              ReorderableDragStartListener(
                index: index,
                child:
                    const Icon(Symbols.drag_indicator, color: AppTheme.textMuted),
              )
            else
              const Icon(Symbols.drag_indicator, color: AppTheme.textMuted),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF283239),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              account.type == AccountType.creditCard
                  ? Symbols.credit_card
                  : account.type == AccountType.cash
                      ? Symbols.payments
                      : Symbols.account_balance,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(account.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '${account.note ?? strings.accountNoteEmpty} • ${Formatters.money(
                    balance,
                    locale: locale,
                    currencyCode: appState.currencyCode,
                    decimalDigits: appState.decimalPlaces,
                  )}',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: account.enabled,
            onChanged: (value) => appState.toggleAccountEnabled(account.id, value),
          ),
        ],
      ),
    );

    return Opacity(
      opacity: account.enabled ? 1.0 : 0.6,
      child: GestureDetector(
        onTap: () => _showAccountActions(context, appState, account, strings),
        child: content,
      ),
    );
  }

  void _showAccountActions(
    BuildContext context,
    AppState appState,
    Account account,
    AppLocalizations strings,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF16202A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Symbols.edit),
            title: Text(strings.edit),
            onTap: () {
              Navigator.of(context).pop();
              context.findAncestorStateOfType<_AccountManagementPageState>()
                  ?._showAccountEditor(context, appState, strings, account: account);
            },
          ),
          ListTile(
            leading: const Icon(Symbols.sync_alt),
            title: Text(strings.accountMigration),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AccountMigrationPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Symbols.delete_forever, color: Colors.redAccent),
            title: Text(strings.delete,
                style: const TextStyle(color: Colors.redAccent)),
            onTap: () async {
              Navigator.of(context).pop();
              final success = await appState.deleteAccount(account.id);
              if (!context.mounted) return;
              if (!success) {
                _showUnableDelete(context, strings);
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showUnableDelete(BuildContext context, AppLocalizations strings) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.accountDeleteBlockedTitle),
        content: Text(strings.accountDeleteBlockedBody),
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

class _MigrationCard extends StatelessWidget {
  const _MigrationCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111A23),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Symbols.sync_alt, color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.accountMigration,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    strings.accountMigrationDesc,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Symbols.chevron_right, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xFF0F1820),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _TypePicker extends StatefulWidget {
  const _TypePicker({required this.value, required this.onChanged});

  final AccountType value;
  final ValueChanged<AccountType> onChanged;

  @override
  State<_TypePicker> createState() => _TypePickerState();
}

class _TypePickerState extends State<_TypePicker> {
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.accountType,
            style: const TextStyle(color: AppTheme.textMuted)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _TypeChip(
              label: strings.accountTypeBank,
              selected: widget.value == AccountType.bank ||
                  widget.value == AccountType.debitCard,
              onTap: () => widget.onChanged(AccountType.bank),
            ),
            _TypeChip(
              label: strings.accountTypeCredit,
              selected: widget.value == AccountType.creditCard,
              onTap: () => widget.onChanged(AccountType.creditCard),
            ),
            _TypeChip(
              label: strings.accountTypeCash,
              selected: widget.value == AccountType.cash,
              onTap: () => widget.onChanged(AccountType.cash),
            ),
          ],
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primary.withOpacity(0.2),
    );
  }
}
