import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'add_edit_transaction_page.dart';
import 'dashboard_page.dart';
import 'reports_page.dart';
import 'settings_page.dart';
import 'transactions_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (!appState.initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final pages = const [
      DashboardPage(),
      TransactionsPage(),
      ReportsPage(),
      SettingsPage(),
    ];

    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(index: appState.tabIndex, children: pages),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditTransactionPage()),
          );
        },
        child: const Icon(Symbols.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF0F1824),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              _NavItem(
                label: strings.home,
                icon: Symbols.home,
                selected: appState.tabIndex == 0,
                onTap: () => appState.tabIndex = 0,
              ),
              _NavItem(
                label: strings.transactions,
                icon: Symbols.receipt_long,
                selected: appState.tabIndex == 1,
                onTap: () => appState.tabIndex = 1,
              ),
              const SizedBox(width: 72),
              _NavItem(
                label: strings.report,
                icon: Symbols.pie_chart,
                selected: appState.tabIndex == 2,
                onTap: () => appState.tabIndex = 2,
              ),
              _NavItem(
                label: strings.settings,
                icon: Symbols.settings,
                selected: appState.tabIndex == 3,
                onTap: () => appState.tabIndex = 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.primary : const Color(0xFF6B7280);
    return Expanded(
      child: InkResponse(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
