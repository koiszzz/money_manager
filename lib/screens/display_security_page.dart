import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class DisplaySecurityPage extends StatelessWidget {
  const DisplaySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final appState = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: Text(strings.displaySecurity)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _Card(
            child: ListTile(
              leading: const Icon(Symbols.dark_mode),
              title: Text(strings.themeModeLabel),
              subtitle: Text(_themeLabel(strings, appState.themeMode)),
              trailing: const Icon(Symbols.chevron_right),
              onTap: () => _pickTheme(context, appState, strings),
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            child: ListTile(
              leading: const Icon(Symbols.currency_exchange),
              title: Text(strings.currencyLabel),
              subtitle: Text(appState.currencyCode),
              trailing: const Icon(Symbols.chevron_right),
              onTap: () => _pickCurrency(context, appState, strings),
            ),
          ),
        ],
      ),
    );
  }

  String _themeLabel(AppLocalizations strings, String mode) {
    switch (mode) {
      case 'light':
        return strings.themeLight;
      case 'dark':
        return strings.themeDark;
      default:
        return strings.themeSystem;
    }
  }

  void _pickTheme(
      BuildContext context, AppState appState, AppLocalizations strings) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _Picker(
        title: strings.themeModeLabel,
        options: {
          'system': strings.themeSystem,
          'light': strings.themeLight,
          'dark': strings.themeDark,
        },
        onSelected: (value) => appState.updateThemeMode(value),
      ),
    );
  }

  void _pickCurrency(
      BuildContext context, AppState appState, AppLocalizations strings) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _Picker(
        title: strings.currencyLabel,
        options: {
          'CNY': 'CNY ¥',
          'USD': 'USD \$',
        },
        onSelected: (value) => appState.updateCurrency(value),
      ),
    );
  }
}

class _Picker extends StatelessWidget {
  const _Picker({
    required this.title,
    required this.options,
    required this.onSelected,
  });

  final String title;
  final Map<String, String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...options.entries.map(
            (entry) => ListTile(
              title: Text(entry.value),
              onTap: () {
                onSelected(entry.key);
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
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
