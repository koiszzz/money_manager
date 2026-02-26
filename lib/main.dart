import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'base_service.dart';
import 'data/app_state.dart';
import 'l10n/app_localizations.dart';
import 'screens/startup_page.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          final mode = appState.themeMode;
          final themeMode = mode == 'light'
              ? ThemeMode.light
              : mode == 'dark'
                  ? ThemeMode.dark
                  : ThemeMode.system;
          Locale? locale;
          if (appState.appLanguage == 'zh_CN') {
            locale = const Locale('zh', 'CN');
          } else if (appState.appLanguage == 'en_US') {
            locale = const Locale('en', 'US');
          }
          return MaterialApp(
            title: 'Money Manager',
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeMode,
            locale: locale,
            builder: (context, child) {
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(textScaleFactor: appState.fontScale),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const StartupPage(),
          );
        },
      ),
    );
  }
}
