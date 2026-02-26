import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'about_page.dart';
import 'account_management_page.dart';
import 'categories_tags_page.dart';
import 'data_backup_recovery_page.dart';
import 'display_security_page.dart';
import 'export_reports_page.dart';
import 'recurring_transactions_page.dart';
import 'reminders_page.dart';
import 'security_privacy_page.dart';
import 'storage_cleanup_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Row(
            children: [
              const Icon(Symbols.arrow_back, size: 20),
              const SizedBox(width: 8),
              Text(strings.settings,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Symbols.help, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ProfileCard(),
          const SizedBox(height: 16),
          _SectionTitle(title: strings.financeManagement),
          _SettingsGroup(children: [
            _SettingsItem(
              icon: Symbols.account_balance_wallet,
              color: const Color(0xFF3B82F6),
              title: strings.accounts,
              subtitle: strings.accountsSubtitle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AccountManagementPage()),
                );
              },
            ),
            _SettingsItem(
              icon: Symbols.category,
              color: const Color(0xFF8B5CF6),
              title: strings.categoriesTags,
              subtitle: strings.categoriesTagsSubtitle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CategoriesTagsPage(),
                  ),
                );
              },
            ),
            _SettingsItem(
              icon: Symbols.update,
              color: const Color(0xFFF59E0B),
              title: strings.recurring,
              subtitle: strings.recurringSubtitle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RecurringTransactionsPage(),
                  ),
                );
              },
            ),
          ]),
          const SizedBox(height: 16),
          _SectionTitle(title: strings.appPreferences),
          _SettingsGroup(children: [
            _SettingsItem(
              icon: Symbols.notifications_active,
              color: const Color(0xFFF43F5E),
              title: strings.reminders,
              subtitle: strings.remindersSubtitle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RemindersPage(),
                  ),
                );
              },
            ),
            _SettingsItem(
              icon: Symbols.palette,
              color: const Color(0xFF14B8A6),
              title: strings.displayLocalization,
              subtitle: strings.displaySecuritySubtitle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DisplaySecurityPage(),
                  ),
                );
              },
            ),
          ]),
          const SizedBox(height: 16),
          _SectionTitle(title: strings.dataSecurity),
          _SettingsGroup(children: [
            _SettingsItem(
              icon: Symbols.cloud_download,
              color: const Color(0xFF6366F1),
              title: strings.backupRestore,
              subtitle: strings.backupRestoreSubtitle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DataBackupRecoveryPage(),
                  ),
                );
              },
            ),
            _SettingsItem(
              icon: Symbols.ios_share,
              color: const Color(0xFF10B981),
              title: strings.exportData,
              subtitle: strings.exportDataSubtitle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ExportReportsPage(),
                  ),
                );
              },
            ),
            _SettingsItem(
              icon: Symbols.shield_lock,
              color: const Color(0xFF0EA5E9),
              title: strings.securityPrivacy,
              subtitle: strings.securityPrivacySubtitle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SecurityPrivacyPage(),
                  ),
                );
              },
            ),
            _SettingsItem(
              icon: Symbols.storage,
              color: const Color(0xFFF97316),
              title: strings.storageCleanup,
              subtitle: strings.storageCleanupSubtitle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const StorageCleanupPage(),
                  ),
                );
              },
            ),
          ]),
          const SizedBox(height: 16),
          _SectionTitle(title: strings.support),
          _SettingsGroup(children: [
            _SettingsItem(
              icon: Symbols.info,
              color: const Color(0xFF64748B),
              title: strings.about,
              subtitle: strings.aboutSubtitle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AboutPage(),
                  ),
                );
              },
            ),
          ]),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Symbols.logout, color: Colors.red),
            label: Text(strings.signOut, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1B2632),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xFF334155),
            child: Icon(Symbols.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sarah Connor', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text('sarah.c@skynet.com', style: TextStyle(color: AppTheme.textMuted)),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Symbols.edit))
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1B2632),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textMuted)),
      trailing: const Icon(Symbols.chevron_right, color: AppTheme.textMuted),
      onTap: onTap,
    );
  }
}
