import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;

import 'base_service.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_providers.dart';
import 'router/app_router.dart';
import 'services/local_notification_service.dart';
import 'services/reminder_coordinator.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  ReminderCoordinator? _reminderCoordinator;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startReminderCoordinator();
    });
  }

  Future<void> _startReminderCoordinator() async {
    if (_reminderCoordinator != null) return;
    final appState = ref.read(appStateProvider);
    final notifications = getIt<LocalNotificationService>();
    final coordinator = ReminderCoordinator(
      appState: appState,
      notificationService: notifications,
    );
    _reminderCoordinator = coordinator;
    await coordinator.start();
  }

  @override
  void dispose() {
    _reminderCoordinator?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            data: media.copyWith(
              textScaler: TextScaler.linear(appState.fontScale),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
