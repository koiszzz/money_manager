import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class AccountManagementPage extends StatelessWidget {
  const AccountManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final accounts = appState.accounts;
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.myAccounts),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Symbols.add)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _NetWorthCard(
            total: appState.totalAssets(),
            locale: locale,
            title: strings.netWorth,
          ),
          const SizedBox(height: 16),
          _AccountSection(
            title: 'CASH & WALLET',
            accounts: accounts.where((acc) => acc.type == AccountType.cash).toList(),
            locale: locale,
          ),
          _AccountSection(
            title: 'BANK ACCOUNTS',
            accounts: accounts.where((acc) => acc.type == AccountType.bank).toList(),
            locale: locale,
          ),
          _AccountSection(
            title: 'LIABILITIES & CREDIT',
            accounts:
                accounts.where((acc) => acc.type == AccountType.creditCard).toList(),
            locale: locale,
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
    required this.title,
  });

  final double total;
  final String locale;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF2B7CEE), Color(0xFF3B82F6)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            Formatters.money(total, locale: locale),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Symbols.trending_up, color: Colors.white70, size: 16),
              SizedBox(width: 6),
              Text('+2.4% this month', style: TextStyle(color: Colors.white70)),
            ],
          )
        ],
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({
    required this.title,
    required this.accounts,
    required this.locale,
  });

  final String title;
  final List<Account> accounts;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
        ),
        ...accounts.map((account) => _AccountTile(account: account, locale: locale)),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.account, required this.locale});

  final Account account;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final balance = appState.accountBalance(account.id);
    final isDebt = balance < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2632),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isDebt ? Colors.red.shade800 : Colors.blue.shade800,
            child: Icon(
              isDebt ? Symbols.credit_card : Symbols.account_balance_wallet,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(account.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(account.note ?? '',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Text(
            Formatters.money(balance, showSign: true, locale: locale),
            style: TextStyle(
              color: isDebt ? Colors.redAccent : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Symbols.chevron_right, size: 18, color: AppTheme.textMuted),
        ],
      ),
    );
  }
}
