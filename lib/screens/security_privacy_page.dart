import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class SecurityPrivacyPage extends StatelessWidget {
  const SecurityPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _HeaderBar(
              title: strings.securityPrivacy,
              onBack: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 8),
            Text(strings.securityHeroTitle,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(strings.securityHeroSubtitle,
                style: const TextStyle(color: AppTheme.textMuted)),
            const SizedBox(height: 16),
            _SecurityLevelCard(level: strings.securityLevelHigh),
            const SizedBox(height: 20),
            _GroupTitle(title: strings.appAccess),
            const SizedBox(height: 8),
            _GroupCard(children: [
              _SwitchTile(
                icon: Symbols.lock,
                title: strings.appLock,
                subtitle: strings.appLockSub,
                value: appState.appLockEnabled,
                onChanged: (value) => appState.toggleAppLock(value),
              ),
              _SwitchTile(
                icon: Symbols.fingerprint,
                title: strings.biometricUnlock,
                subtitle: strings.biometricUnlockDesc,
                value: appState.biometricEnabled,
                onChanged: (value) => appState.toggleBiometric(value),
              ),
              _ActionTile(
                icon: Symbols.pin,
                title: strings.changePin,
                subtitle: strings.changePinSub,
                onTap: () => _changePin(context, appState, strings),
              ),
            ]),
            const SizedBox(height: 16),
            _GroupTitle(title: strings.contentProtection),
            const SizedBox(height: 8),
            _GroupCard(children: [
              _SwitchTile(
                icon: Symbols.visibility_off,
                title: strings.screenshotProtection,
                subtitle: strings.screenshotProtectionDesc,
                value: appState.screenshotProtectionEnabled,
                onChanged: (value) => appState.toggleScreenshotProtection(value),
              ),
            ]),
            const SizedBox(height: 16),
            _GroupTitle(title: strings.legalInfo),
            const SizedBox(height: 8),
            _GroupCard(children: [
              _ActionTile(
                icon: Symbols.policy,
                title: strings.privacyPolicy,
                onTap: () => _showInfo(context, strings.privacyPolicy),
              ),
              _ActionTile(
                icon: Symbols.description,
                title: strings.termsOfService,
                onTap: () => _showInfo(context, strings.termsOfService),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context, String title) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(AppLocalizations.of(context).offlinePolicyNote),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).ok),
          )
        ],
      ),
    );
  }

  Future<void> _changePin(
      BuildContext context, AppState appState, AppLocalizations strings) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );
    if (result != null && result.length == 4) {
      await appState.updatePinCode(result);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.pinUpdated)),
      );
    }
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

class _SecurityLevelCard extends StatelessWidget {
  const _SecurityLevelCard({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).securityLevel,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 6),
                Text(level,
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Symbols.shield_lock, color: AppTheme.primary, size: 30),
          ),
        ],
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C262E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF2B3440),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textMuted)),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF2B3440),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title),
      subtitle:
          subtitle == null ? null : Text(subtitle!, style: const TextStyle(color: AppTheme.textMuted)),
      trailing: const Icon(Symbols.chevron_right, color: AppTheme.textMuted),
      onTap: onTap,
    );
  }
}
