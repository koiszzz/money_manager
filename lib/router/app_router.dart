import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_providers.dart';
import '../screens/account_management_page.dart';
import '../screens/account_migration_page.dart';
import '../screens/about_page.dart';
import '../screens/add_edit_transaction_page.dart';
import '../screens/budget_page.dart';
import '../screens/categories_tags_page.dart';
import '../screens/data_backup_recovery_page.dart';
import '../screens/display_security_page.dart';
import '../screens/export_reports_page.dart';
import '../screens/main_page.dart';
import '../screens/pin_lock_page.dart';
import '../screens/recurring_transactions_page.dart';
import '../screens/reminders_page.dart';
import '../screens/security_privacy_page.dart';
import '../screens/storage_cleanup_page.dart';
import '../screens/startup_page.dart';

class AppRoutes {
  static const startup = '/startup';
  static const pinLock = '/pin-lock';
  static const main = '/main';
  static const addTransaction = '/transaction/new';
  static const editTransaction = '/transaction/:id/edit';
  static const accountManagement = '/account-management';
  static const accountMigration = '/account-migration';
  static const categoriesTags = '/categories-tags';
  static const recurring = '/recurring';
  static const reminders = '/reminders';
  static const displayLocalization = '/display-localization';
  static const backupRestore = '/backup-restore';
  static const exportData = '/export-data';
  static const securityPrivacy = '/security-privacy';
  static const storageCleanup = '/storage-cleanup';
  static const about = '/about';
  static const budget = '/budget';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.startup,
    routes: [
      GoRoute(
        path: AppRoutes.startup,
        builder: (context, state) => const StartupPage(),
      ),
      GoRoute(
        path: AppRoutes.pinLock,
        builder: (context, state) => const PinLockPage(),
      ),
      GoRoute(
        path: AppRoutes.main,
        builder: (context, state) => const MainPage(),
      ),
      GoRoute(
        path: AppRoutes.addTransaction,
        builder: (context, state) => const AddEditTransactionPage(),
      ),
      GoRoute(
        path: AppRoutes.editTransaction,
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final appState =
              ProviderScope.containerOf(context).read(appStateProvider);
          final record =
              appState.records.where((item) => item.id == id).toList();
          if (record.isEmpty) {
            return const _NotFoundPage();
          }
          return AddEditTransactionPage(record: record.first);
        },
      ),
      GoRoute(
        path: AppRoutes.accountManagement,
        builder: (context, state) => const AccountManagementPage(),
      ),
      GoRoute(
        path: AppRoutes.accountMigration,
        builder: (context, state) {
          final sourceId = state.uri.queryParameters['sourceId'];
          final targetId = state.uri.queryParameters['targetId'];
          return AccountMigrationPage(
            initialSourceId: sourceId,
            initialTargetId: targetId,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.categoriesTags,
        builder: (context, state) => const CategoriesTagsPage(),
      ),
      GoRoute(
        path: AppRoutes.recurring,
        builder: (context, state) => const RecurringTransactionsPage(),
      ),
      GoRoute(
        path: AppRoutes.reminders,
        builder: (context, state) => const RemindersPage(),
      ),
      GoRoute(
        path: AppRoutes.displayLocalization,
        builder: (context, state) => const DisplaySecurityPage(),
      ),
      GoRoute(
        path: AppRoutes.backupRestore,
        builder: (context, state) => const DataBackupRecoveryPage(),
      ),
      GoRoute(
        path: AppRoutes.exportData,
        builder: (context, state) => const ExportReportsPage(),
      ),
      GoRoute(
        path: AppRoutes.securityPrivacy,
        builder: (context, state) => const SecurityPrivacyPage(),
      ),
      GoRoute(
        path: AppRoutes.storageCleanup,
        builder: (context, state) => const StorageCleanupPage(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: AppRoutes.budget,
        builder: (context, state) => const BudgetPage(),
      ),
    ],
  );
});

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Not found')),
    );
  }
}
