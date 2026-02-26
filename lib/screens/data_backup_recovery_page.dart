import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class DataBackupRecoveryPage extends StatelessWidget {
  const DataBackupRecoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final appState = context.watch<AppState>();
    final locale = Localizations.localeOf(context).toString();
    final lastBackupAt = appState.lastBackupAt == null
        ? strings.never
        : Formatters.dateLabel(
            DateTime.parse(appState.lastBackupAt!),
            locale: locale,
          );

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _HeaderBar(
              title: strings.backupRestore,
              onBack: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 8),
            Text(strings.backupStatus,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _StatusCard(
              icon: Symbols.cloud_done,
              title: strings.lastBackup,
              subtitle: lastBackupAt,
              success: true,
            ),
            const SizedBox(height: 10),
            _StatusCard(
              icon: Symbols.schedule,
              title: strings.nextScheduled,
              subtitle: strings.backupNextTime,
              success: false,
            ),
            const SizedBox(height: 20),
            Text(strings.quickActions,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Symbols.upload,
                    label: strings.exportBackup,
                    primary: true,
                    onTap: () async {
                      await appState.updateLastBackupAt(DateTime.now());
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(strings.exportDone)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Symbols.download,
                    label: strings.importBackup,
                    onTap: () => _showImportDialog(context, strings),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoCard(message: strings.backupFormatInfo),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(strings.localBackups,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                TextButton(onPressed: () {}, child: Text(strings.viewAll)),
              ],
            ),
            const SizedBox(height: 8),
            _BackupListItem(
              name: 'backup_2026_02_25.json',
              subtitle: strings.backupItemSubtitle('2026-02-25', '2.4 MB'),
            ),
            _BackupListItem(
              name: 'backup_2026_02_10.json',
              subtitle: strings.backupItemSubtitle('2026-02-10', '2.3 MB'),
            ),
            _BackupListItem(
              name: 'auto_backup_2026_01_28.csv',
              subtitle: strings.backupItemSubtitle('2026-01-28', '1.8 MB'),
            ),
            const SizedBox(height: 20),
            Text(
              strings.backupFooter,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showImportDialog(BuildContext context, AppLocalizations strings) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.confirmImport),
        content: Text(strings.importWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.confirm),
          ),
        ],
      ),
    );
  }
}

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

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.success,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool success;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF19232C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primary),
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
          if (success)
            const Icon(Symbols.check_circle, color: Color(0xFF34D399))
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    this.primary = false,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: primary ? AppTheme.primary : const Color(0xFF19232C),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: primary ? AppTheme.primary : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: primary ? Colors.white : AppTheme.primary),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: primary ? Colors.white : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF151F28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Symbols.info, color: AppTheme.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackupListItem extends StatelessWidget {
  const _BackupListItem({required this.name, required this.subtitle});

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF19232C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2A36),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Symbols.folder_zip, color: AppTheme.textMuted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Symbols.more_vert, color: AppTheme.textMuted),
        ],
      ),
    );
  }
}
