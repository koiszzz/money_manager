import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;

import 'base_service.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final router = ref.watch(appRouterProvider);

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

    return provider_pkg.ChangeNotifierProvider.value(
      value: appState,
      child: MaterialApp.router(
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
        routerConfig: router,
        builder: (context, child) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(textScaleFactor: appState.fontScale),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
