import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class DisplaySecurityPage extends StatelessWidget {
  const DisplaySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final appState = context.watch<AppState>();
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _HeaderBar(
              title: strings.displayLocalization,
              onBack: () => Navigator.of(context).pop(),
            ),
            _PreviewCard(
              value: Formatters.money(
                1234.56,
                locale: locale,
                currencyCode: appState.currencyCode,
                decimalDigits: appState.decimalPlaces,
              ),
              expense: Formatters.money(
                -42.0,
                showSign: true,
                locale: locale,
                currencyCode: appState.currencyCode,
                decimalDigits: appState.decimalPlaces,
              ),
              income: Formatters.money(
                128.5,
                showSign: true,
                locale: locale,
                currencyCode: appState.currencyCode,
                decimalDigits: appState.decimalPlaces,
              ),
            ),
            const SizedBox(height: 16),
            Text(strings.appearanceLabel,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                _ThemeCard(
                  label: strings.themeSystem,
                  icon: Symbols.settings_brightness,
                  selected: appState.themeMode == 'system',
                  onTap: () => appState.updateThemeMode('system'),
                ),
                const SizedBox(width: 8),
                _ThemeCard(
                  label: strings.themeLight,
                  icon: Symbols.light_mode,
                  selected: appState.themeMode == 'light',
                  onTap: () => appState.updateThemeMode('light'),
                ),
                const SizedBox(width: 8),
                _ThemeCard(
                  label: strings.themeDark,
                  icon: Symbols.dark_mode,
                  selected: appState.themeMode == 'dark',
                  onTap: () => appState.updateThemeMode('dark'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(strings.formattingLabel,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _SettingTile(
              icon: Symbols.attach_money,
              title: strings.currencyLabel,
              value: appState.currencyCode,
              onTap: () => _pickCurrency(context, appState, strings),
            ),
            _SettingTile(
              icon: Symbols.exposure_plus_1,
              title: strings.decimalPlacesLabel,
              value: strings.decimalDigits(appState.decimalPlaces),
              onTap: () => _pickDecimalPlaces(context, appState, strings),
            ),
            _SettingTile(
              icon: Symbols.calendar_today,
              title: strings.weekStartLabel,
              value: appState.weekStartsOn,
              onTap: () => _pickWeekStart(context, appState, strings),
            ),
            _SettingTile(
              icon: Symbols.text_fields,
              title: strings.fontSizeLabel,
              value: strings.fontScaleLabel(appState.fontScale),
              onTap: () => _pickFontScale(context, appState, strings),
            ),
            const SizedBox(height: 20),
            Text(strings.languageLabel,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _SettingTile(
              icon: Symbols.translate,
              title: strings.appLanguageLabel,
              value: strings.languageLabelValue(appState.appLanguage),
              onTap: () => _pickLanguage(context, appState, strings),
            ),
          ],
        ),
      ),
    );
  }

  void _pickCurrency(
      BuildContext context, AppState appState, AppLocalizations strings) {
    _showPicker(
        context,
        strings.currencyLabel,
        {
          'CNY': 'CNY ¥',
          'USD': 'USD \$',
          'EUR': 'EUR €',
        },
        (value) => appState.updateCurrency(value));
  }

  void _pickDecimalPlaces(
      BuildContext context, AppState appState, AppLocalizations strings) {
    _showPicker(
        context,
        strings.decimalPlacesLabel,
        {
          '0': strings.decimalDigits(0),
          '1': strings.decimalDigits(1),
          '2': strings.decimalDigits(2),
        },
        (value) => appState.updateDecimalPlaces(int.parse(value)));
  }

  void _pickWeekStart(
      BuildContext context, AppState appState, AppLocalizations strings) {
    _showPicker(
        context,
        strings.weekStartLabel,
        {
          'Monday': strings.weekStartMonday,
          'Sunday': strings.weekStartSunday,
        },
        (value) => appState.updateWeekStartsOn(value));
  }

  void _pickFontScale(
      BuildContext context, AppState appState, AppLocalizations strings) {
    _showPicker(
        context,
        strings.fontSizeLabel,
        {
          '0.9': strings.fontScaleSmall,
          '1.0': strings.fontScaleDefault,
          '1.1': strings.fontScaleLarge,
        },
        (value) => appState.updateFontScale(double.parse(value)));
  }

  void _pickLanguage(
      BuildContext context, AppState appState, AppLocalizations strings) {
    _showPicker(
        context,
        strings.appLanguageLabel,
        {
          'system': strings.themeSystem,
          'zh_CN': '简体中文',
          'en_US': 'English (US)',
        },
        (value) => appState.updateAppLanguage(value));
  }

  void _showPicker(BuildContext context, String title,
      Map<String, String> options, ValueChanged<String> onSelected) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF16202A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _Picker(
        title: title,
        options: options,
        onSelected: onSelected,
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

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.value,
    required this.expense,
    required this.income,
  });

  final String value;
  final String expense;
  final String income;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2630),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Text(AppLocalizations.of(context).livePreview,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PreviewChip(label: expense, color: Colors.redAccent),
              const SizedBox(width: 8),
              _PreviewChip(label: income, color: Colors.greenAccent),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
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
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2630),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppTheme.primary : Colors.transparent,
              width: 1.4,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected ? AppTheme.primary : AppTheme.textMuted),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.white : AppTheme.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF161F28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1A2630),
          child: Icon(icon, color: AppTheme.textMuted),
        ),
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: const TextStyle(color: AppTheme.textMuted)),
            const SizedBox(width: 4),
            const Icon(Symbols.chevron_right, size: 18),
          ],
        ),
        onTap: onTap,
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          for (final entry in options.entries)
            ListTile(
              title: Text(entry.value),
              onTap: () {
                onSelected(entry.key);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}
