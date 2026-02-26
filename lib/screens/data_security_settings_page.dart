import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class DataSecuritySettingsPage extends StatelessWidget {
  const DataSecuritySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.dataSecurity)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _SectionTitle(title: strings.backupRestore),
          _CardGroup(children: [
            _ActionTile(
              title: strings.exportBackup,
              subtitle: strings.exportBackupSub,
              icon: Symbols.file_download,
              onTap: () => _showSnack(context, strings.exportDone),
            ),
            _ActionTile(
              title: strings.importBackup,
              subtitle: strings.importBackupSub,
              icon: Symbols.file_upload,
              onTap: () => _confirm(
                context,
                title: strings.confirmImport,
                message: strings.importWarning,
              ),
            ),
          ]),
          const SizedBox(height: 16),
          _SectionTitle(title: strings.securitySettings),
          _CardGroup(children: [
            SwitchListTile(
              title: Text(strings.appLock),
              subtitle: Text(strings.appLockSub),
              value: appState.appLockEnabled,
              onChanged: (value) => appState.toggleAppLock(value),
            ),
            _ActionTile(
              title: strings.changePin,
              subtitle: strings.changePinSub,
              icon: Symbols.lock_reset,
              onTap: () => _changePin(context, appState),
            ),
          ]),
          const SizedBox(height: 16),
          _SectionTitle(title: strings.dangerZone),
          _CardGroup(children: [
            _ActionTile(
              title: strings.clearAll,
              subtitle: strings.clearAllSub,
              icon: Symbols.delete_forever,
              onTap: () => _confirm(
                context,
                title: strings.confirmClear,
                message: strings.clearWarning,
              ),
              destructive: true,
            ),
          ]),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _confirm(BuildContext context,
      {required String title, required String message}) {
    final strings = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSnack(context, strings.done);
            },
            child: Text(strings.confirm),
          )
        ],
      ),
    );
  }

  Future<void> _changePin(BuildContext context, AppState appState) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final strings = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(strings.changePin),
          content: TextField(
            controller: controller,
            maxLength: 4,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: strings.changePinSub),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(strings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: Text(strings.save),
            ),
          ],
        );
      },
    );
    if (result != null && result.length == 4) {
      await appState.updatePinCode(result);
      final strings = AppLocalizations.of(context);
      _showSnack(context, strings.pinUpdated);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _CardGroup extends StatelessWidget {
  const _CardGroup({required this.children});

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

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.destructive = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? Colors.redAccent : AppTheme.primary;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: TextStyle(color: destructive ? color : null)),
      subtitle:
          Text(subtitle, style: const TextStyle(color: AppTheme.textMuted)),
      onTap: onTap,
    );
  }
}
