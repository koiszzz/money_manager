import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class StorageCleanupPage extends StatefulWidget {
  const StorageCleanupPage({super.key});

  @override
  State<StorageCleanupPage> createState() => _StorageCleanupPageState();
}

class _StorageCleanupPageState extends State<StorageCleanupPage> {
  bool _showPinPrompt = false;
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _HeaderBar(
                  title: strings.storageCleanup,
                  onBack: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 12),
                _UsageHero(),
                const SizedBox(height: 16),
                Text(strings.storageDetails,
                    style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
                const SizedBox(height: 8),
                _DetailCard(),
                const SizedBox(height: 20),
                _ActionButton(
                  label: strings.clearCache,
                  icon: Symbols.cleaning_services,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(strings.cacheCleared)));
                  },
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  label: strings.clearAll,
                  icon: Symbols.delete_forever,
                  danger: true,
                  onTap: () => setState(() => _showPinPrompt = true),
                ),
                const SizedBox(height: 8),
                Text(strings.clearAllNote,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
            if (_showPinPrompt)
              _PinOverlay(
                controller: _pinController,
                onCancel: () => setState(() => _showPinPrompt = false),
                onConfirm: () async {
                  if (_pinController.text == appState.pinCode) {
                    await appState.clearAllData();
                    if (!mounted) return;
                    setState(() => _showPinPrompt = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.clearAllDone)),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(strings.pinError)));
                  }
                },
              ),
          ],
        ),
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

class _UsageHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.surface(context, level: 0),
            shape: BoxShape.circle,
          ),
          child:
              const Icon(Symbols.database, color: AppTheme.primary, size: 40),
        ),
        const SizedBox(height: 12),
        Text(AppLocalizations.of(context).storageUsed,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(AppLocalizations.of(context).storageUsedDesc,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface(context, level: 1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outline(context)),
      ),
      child: Column(
        children: [
          _DetailRow(
            icon: Symbols.cached,
            title: strings.cache,
            subtitle: strings.cacheDesc,
            value: '12 MB',
          ),
          Divider(height: 1, color: Colors.white.withOpacity(0.05)),
          _DetailRow(
            icon: Symbols.description,
            title: strings.tempFiles,
            subtitle: strings.tempFilesDesc,
            value: '5 MB',
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    this.danger = false,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool danger;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: danger
            ? const Color(0xFFEF4444).withOpacity(0.15)
            : AppTheme.surface(context, level: 0),
        foregroundColor: danger
            ? const Color(0xFFEF4444)
            : Theme.of(context).colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _PinOverlay extends StatelessWidget {
  const _PinOverlay({
    required this.controller,
    required this.onCancel,
    required this.onConfirm,
  });

  final TextEditingController controller;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppTheme.surface(context, level: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Symbols.lock, color: Color(0xFFEF4444), size: 32),
              const SizedBox(height: 12),
              Text(strings.confirmIdentity,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(strings.confirmIdentityDesc,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFF0F1820),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      child: Text(strings.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                      ),
                      child: Text(strings.confirm),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
