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
        .where((a) => a.nature == AccountNature.bank)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final creditAccounts = appState.accounts
        .where((a) => a.nature == AccountNature.credit)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final loanAccounts = appState.accounts
        .where((a) => a.nature == AccountNature.loan)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final assetAccounts = appState.accounts
        .where((a) => a.nature == AccountNature.asset)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final liabilityAccounts = appState.accounts
        .where((a) => a.nature == AccountNature.liability)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _HeaderBar(
              title: strings.accounts,
              onBack: () => Navigator.of(context).pop(),
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
                    onEdit: (account) => _showAccountEditor(
                        context, appState, strings,
                        account: account),
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(title: strings.accountNatureCredit),
                  const SizedBox(height: 8),
                  _AccountList(
                    accounts: creditAccounts,
                    reorderMode: _reorderMode,
                    onReorder: (next) => appState.updateAccountOrder(next),
                    onEdit: (account) => _showAccountEditor(
                        context, appState, strings,
                        account: account),
                  ),
                  if (loanAccounts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SectionTitle(title: strings.accountNatureLoan),
                    const SizedBox(height: 8),
                    _AccountList(
                      accounts: loanAccounts,
                      reorderMode: _reorderMode,
                      onReorder: (next) => appState.updateAccountOrder(next),
                      onEdit: (account) => _showAccountEditor(
                        context,
                        appState,
                        strings,
                        account: account,
                      ),
                    ),
                  ],
                  if (assetAccounts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SectionTitle(title: strings.accountNatureAsset),
                    const SizedBox(height: 8),
                    _AccountList(
                      accounts: assetAccounts,
                      reorderMode: _reorderMode,
                      onReorder: (next) => appState.updateAccountOrder(next),
                      onEdit: (account) => _showAccountEditor(
                        context,
                        appState,
                        strings,
                        account: account,
                      ),
                    ),
                  ],
                  if (liabilityAccounts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SectionTitle(title: strings.accountNatureLiability),
                    const SizedBox(height: 8),
                    _AccountList(
                      accounts: liabilityAccounts,
                      reorderMode: _reorderMode,
                      onReorder: (next) => appState.updateAccountOrder(next),
                      onEdit: (account) => _showAccountEditor(
                        context,
                        appState,
                        strings,
                        account: account,
                      ),
                    ),
                  ],
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
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () => _showAccountEditor(context, appState, strings),
          icon: const Icon(Symbols.add_circle, size: 22),
          label: Text(
            strings.addNewAccount,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
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
    final accountTypes = appState.accountTypes;
    AccountTypeOption? selectedType =
        appState.accountTypeById(account?.customType);
    if (selectedType == null && accountTypes.isNotEmpty) {
      selectedType = accountTypes.firstWhere(
        (item) => item.nature == account?.nature,
        orElse: () => accountTypes.first,
      );
    }
    final cardNumberController =
        TextEditingController(text: account?.cardNumber ?? '');
    final billingDayController = TextEditingController(
      text: account?.billingDay?.toString() ?? '',
    );
    final repaymentDayController = TextEditingController(
      text: account?.repaymentDay?.toString() ?? '',
    );
    int? iconCode =
        account?.iconCode ?? Symbols.account_balance_wallet.codePoint;
    final isEdit = account != null;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF16202A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isEdit ? strings.editAccount : strings.addNewAccount,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                _LabeledField(
                  label: strings.accountName,
                  controller: nameController,
                  hintText: strings.accountNameHint,
                ),
                const SizedBox(height: 12),
                _LabeledField(
                  label: strings.openingBalance,
                  controller: balanceController,
                  hintText: '0.00',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _AccountTypePicker(
                  value: selectedType,
                  options: accountTypes,
                  onChanged: (value) {
                    setModalState(() => selectedType = value);
                  },
                ),
                const SizedBox(height: 12),
                if (selectedType?.nature == AccountNature.credit) ...[
                  _LabeledField(
                    label: strings.cardNumber,
                    controller: cardNumberController,
                    hintText: strings.cardNumberHint,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _LabeledField(
                          label: strings.billingDay,
                          controller: billingDayController,
                          hintText: strings.billingDayHint,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _LabeledField(
                          label: strings.repaymentDay,
                          controller: repaymentDayController,
                          hintText: strings.repaymentDayHint,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ] else if (selectedType?.nature == AccountNature.bank) ...[
                  _LabeledField(
                    label: strings.cardNumber,
                    controller: cardNumberController,
                    hintText: strings.cardNumberHint,
                    keyboardType: TextInputType.number,
                  ),
                ],
                const SizedBox(height: 12),
                _LabeledField(
                  label: strings.accountNote,
                  controller: noteController,
                  hintText: strings.accountNoteHint,
                ),
                const SizedBox(height: 12),
                _IconPicker(
                  title: strings.accountIcon,
                  selected: iconCode,
                  onChanged: (value) => setModalState(() => iconCode = value),
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
                          if (selectedType == null) return;
                          final balance =
                              double.tryParse(balanceController.text) ?? 0.0;
                          if (selectedType!.nature == AccountNature.credit &&
                              cardNumberController.text.trim().isEmpty) {
                            return;
                          }
                          if (selectedType!.nature == AccountNature.bank &&
                              cardNumberController.text.trim().isEmpty) {
                            return;
                          }
                          final billingDay =
                              int.tryParse(billingDayController.text);
                          final repaymentDay =
                              int.tryParse(repaymentDayController.text);
                          if (selectedType!.nature == AccountNature.credit &&
                              (billingDay == null ||
                                  billingDay < 1 ||
                                  billingDay > 31 ||
                                  repaymentDay == null ||
                                  repaymentDay < 1 ||
                                  repaymentDay > 31)) {
                            return;
                          }
                          if (account == null) {
                            await appState.addAccount(
                              name: name,
                              nature: selectedType!.nature,
                              accountTypeId: selectedType!.id,
                              openingBalance: balance,
                              note: noteController.text.trim().isEmpty
                                  ? null
                                  : noteController.text.trim(),
                              iconCode: iconCode,
                              cardNumber:
                                  cardNumberController.text.trim().isEmpty
                                      ? null
                                      : cardNumberController.text.trim(),
                              billingDay: billingDay,
                              repaymentDay: repaymentDay,
                            );
                          } else {
                            await appState.updateAccount(Account(
                              id: account.id,
                              name: name,
                              type:
                                  _mapNatureToAccountType(selectedType!.nature),
                              nature: selectedType!.nature,
                              openingBalance: balance,
                              note: noteController.text.trim().isEmpty
                                  ? null
                                  : noteController.text.trim(),
                              enabled: account.enabled,
                              sortOrder: account.sortOrder,
                              iconCode: iconCode,
                              customType: selectedType!.id,
                              cardNumber:
                                  cardNumberController.text.trim().isEmpty
                                      ? null
                                      : cardNumberController.text.trim(),
                              billingDay: billingDay,
                              repaymentDay: repaymentDay,
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
        ),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 48),
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
    required this.onEdit,
  });

  final List<Account> accounts;
  final bool reorderMode;
  final ValueChanged<List<Account>> onReorder;
  final ValueChanged<Account> onEdit;

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
          onEdit: onEdit,
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
    required this.onEdit,
  });

  final Account account;
  final int index;
  final bool reorderMode;
  final ValueChanged<Account> onEdit;

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
              IconData(
                account.iconCode ??
                    (account.nature == AccountNature.credit
                        ? Symbols.credit_card.codePoint
                        : account.nature == AccountNature.loan
                            ? Symbols.payments.codePoint
                            : account.nature == AccountNature.asset
                                ? Symbols.account_balance_wallet.codePoint
                                : account.nature == AccountNature.liability
                                    ? Symbols.payments.codePoint
                                    : Symbols.account_balance.codePoint),
                fontFamily: 'MaterialSymbolsOutlined',
                fontPackage: 'material_symbols_icons',
              ),
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
                  '${_subtitle(context, account, strings)} • ${Formatters.money(
                    balance,
                    locale: locale,
                    currencyCode: appState.currencyCode,
                    decimalDigits: appState.decimalPlaces,
                  )}',
                  style:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: account.enabled,
            onChanged: (value) =>
                appState.toggleAccountEnabled(account.id, value),
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
              onEdit(account);
            },
          ),
          ListTile(
            leading: const Icon(Symbols.sync_alt),
            title: Text(strings.accountMigration),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AccountMigrationPage(
                    initialSourceId: account.id,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading:
                const Icon(Symbols.delete_forever, color: Colors.redAccent),
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

  String _subtitle(BuildContext context, Account account, AppLocalizations strings) {
    final appState = context.read<AppState>();
    final typeLabel = _accountTypeLabel(account, appState, strings);
    if (account.nature == AccountNature.credit) {
      final masked = _maskCard(account.cardNumber);
      if (account.billingDay != null && account.repaymentDay != null) {
        final details =
            '$masked • ${strings.billingDay}${account.billingDay} • ${strings.repaymentDay}${account.repaymentDay}';
        return typeLabel.isEmpty ? details : '$typeLabel • $details';
      }
      if (masked.isNotEmpty) {
        return typeLabel.isEmpty ? masked : '$typeLabel • $masked';
      }
      return typeLabel.isEmpty ? strings.accountNoteEmpty : typeLabel;
    }
    if (account.nature == AccountNature.bank) {
      final masked = _maskCard(account.cardNumber);
      if (masked.isNotEmpty) {
        return typeLabel.isEmpty ? masked : '$typeLabel • $masked';
      }
    }
    return typeLabel.isNotEmpty
        ? typeLabel
        : (account.note ?? strings.accountNoteEmpty);
  }

  String _maskCard(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final digits = raw.replaceAll(RegExp(r'\\s+'), '');
    if (digits.length <= 4) return '**** $digits';
    return '**** ${digits.substring(digits.length - 4)}';
  }

  String _accountTypeLabel(
    Account account,
    AppState appState,
    AppLocalizations strings,
  ) {
    final option = appState.accountTypeById(account.customType);
    if (option != null) return option.name;
    if (account.customType != null && account.customType!.isNotEmpty) {
      return account.customType!;
    }
    switch (account.nature) {
      case AccountNature.bank:
        return strings.accountNatureBank;
      case AccountNature.credit:
        return strings.accountNatureCredit;
      case AccountNature.loan:
        return strings.accountNatureLoan;
      case AccountNature.asset:
        return strings.accountNatureAsset;
      case AccountNature.liability:
        return strings.accountNatureLiability;
    }
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
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12),
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

class _AccountTypePicker extends StatelessWidget {
  const _AccountTypePicker({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final AccountTypeOption? value;
  final List<AccountTypeOption> options;
  final ValueChanged<AccountTypeOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.accountType,
            style: const TextStyle(color: AppTheme.textMuted)),
        const SizedBox(height: 8),
        if (options.isEmpty)
          Text(
            strings.noAccountTypes,
            style: const TextStyle(color: AppTheme.textMuted),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final selected = option.id == value?.id;
              return ChoiceChip(
                label: Text(option.name),
                selected: selected,
                onSelected: (_) => onChanged(option),
                selectedColor: AppTheme.primary.withOpacity(0.2),
              );
            }).toList(),
          ),
      ],
    );
  }
}

AccountType _mapNatureToAccountType(AccountNature nature) {
  switch (nature) {
    case AccountNature.bank:
      return AccountType.bank;
    case AccountNature.credit:
      return AccountType.creditCard;
    case AccountNature.loan:
      return AccountType.other;
    case AccountNature.asset:
      return AccountType.other;
    case AccountNature.liability:
      return AccountType.other;
  }
}

class _IconPicker extends StatelessWidget {
  const _IconPicker({
    required this.title,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final int? selected;
  final ValueChanged<int> onChanged;

  static const _icons = [
    Symbols.account_balance_wallet,
    Symbols.account_balance,
    Symbols.credit_card,
    Symbols.savings,
    Symbols.payments,
    Symbols.wallet,
    Symbols.attach_money,
    Symbols.money,
    Symbols.store,
    Symbols.directions_car,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppTheme.textMuted)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _icons.map((icon) {
            final code = icon.codePoint;
            final isSelected = code == selected;
            return GestureDetector(
              onTap: () => onChanged(code),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withOpacity(0.2)
                      : const Color(0xFF0F1820),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Icon(
                  IconData(
                    code,
                    fontFamily: 'MaterialSymbolsOutlined',
                    fontPackage: 'material_symbols_icons',
                  ),
                  color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
