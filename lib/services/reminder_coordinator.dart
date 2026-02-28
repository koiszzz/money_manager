import 'dart:async';

import '../data/app_state.dart';
import '../data/models.dart';
import 'local_notification_service.dart';
import 'reminder_service.dart';

class ReminderCoordinator {
  ReminderCoordinator({
    required this.appState,
    required this.notificationService,
  });

  final AppState appState;
  final LocalNotificationService notificationService;

  bool _started = false;
  bool _syncing = false;
  String _lastFingerprint = '';

  Future<void> start() async {
    if (_started) return;
    _started = true;
    appState.addListener(_handleStateChanged);
    await syncNow(force: true);
  }

  void dispose() {
    if (!_started) return;
    appState.removeListener(_handleStateChanged);
    _started = false;
  }

  void _handleStateChanged() {
    unawaited(syncNow());
  }

  Future<void> syncNow({bool force = false}) async {
    if (_syncing || !appState.initialized) return;
    final nextFingerprint = _fingerprint();
    if (!force && nextFingerprint == _lastFingerprint) return;

    _syncing = true;
    try {
      _lastFingerprint = nextFingerprint;
      await notificationService.cancelManagedNotifications();

      if (!appState.systemNotificationsEnabled) return;
      await _syncDailyReminder();
      await _syncRecurringReminders();
      await _triggerBudgetWarningIfNeeded();
    } finally {
      _syncing = false;
    }
  }

  Future<void> _syncDailyReminder() async {
    if (!appState.dailyReminderEnabled) return;
    final minutes = ReminderService.parseTimeToMinutes(appState.reminderTime);
    if (minutes == null) return;

    await notificationService.scheduleDailyReminder(
      hour: minutes ~/ 60,
      minute: minutes % 60,
      title: _isChinese ? '每日记账提醒' : 'Daily money reminder',
      body: _isChinese
          ? '记得记录今天的收支。'
          : 'Remember to record today\'s income and expenses.',
    );
  }

  Future<void> _syncRecurringReminders() async {
    if (!appState.recurringReminderEnabled) return;
    final now = DateTime.now();
    final dndFrom = appState.dndFrom;
    final dndTo = appState.dndTo;

    for (final task in appState.recurringTasks) {
      if (!task.enabled || task.autoGenerate) continue;
      if (!task.nextRunAt.isAfter(now)) continue;

      final runTime = _toHHmm(task.nextRunAt);
      if (appState.dndEnabled &&
          ReminderService.isTimeInDndWindow(
            time: runTime,
            dndFrom: dndFrom,
            dndTo: dndTo,
          )) {
        continue;
      }

      await notificationService.scheduleOneTime(
        id: _recurringId(task),
        at: task.nextRunAt,
        title: _isChinese ? '周期账单提醒' : 'Recurring bill reminder',
        body: _recurringBody(task),
        payload: 'recurring:${task.id}',
      );
    }
  }

  Future<void> _triggerBudgetWarningIfNeeded() async {
    if (!appState.budgetWarningEnabled) return;
    final now = DateTime.now();
    final month = DateTime(now.year, now.month, 1);
    final budget = appState.budgetForMonth(month);
    final ratio = appState.budgetUsageRatio(month);

    if (budget.warningThreshold <= 0 || ratio < budget.warningThreshold) {
      return;
    }
    if (appState.dndEnabled &&
        ReminderService.isTimeInDndWindow(
          time: _toHHmm(now),
          dndFrom: appState.dndFrom,
          dndTo: appState.dndTo,
        )) {
      return;
    }

    final warningKey =
        '${month.year}-${month.month}-${ratio.toStringAsFixed(2)}';
    if (appState.budgetWarningLastSentKey == warningKey) return;

    await notificationService.showNow(
      id: LocalNotificationService.budgetWarningId,
      title: _isChinese ? '预算预警' : 'Budget warning',
      body: _isChinese
          ? '本月预算已达到 ${(ratio * 100).toStringAsFixed(0)}%。'
          : 'This month budget has reached ${(ratio * 100).toStringAsFixed(0)}%.',
      payload: 'budget_warning',
    );
    await appState.updateBudgetWarningLastSentKey(warningKey);
  }

  bool get _isChinese {
    final language = appState.appLanguage;
    if (language == 'zh_CN') return true;
    if (language == 'en_US') return false;
    return true;
  }

  int _recurringId(RecurringTask task) {
    final raw = '${task.id}:${task.nextRunAt.toIso8601String()}';
    final offset = raw.hashCode.abs() %
        (LocalNotificationService.recurringMaxId -
            LocalNotificationService.recurringMinId);
    return LocalNotificationService.recurringMinId + offset;
  }

  String _toHHmm(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _recurringBody(RecurringTask task) {
    final note = task.templateBill.note;
    if (note != null && note.trim().isNotEmpty) return note.trim();
    return _isChinese ? '有一笔周期账单即将到期。' : 'A recurring bill is coming due.';
  }

  String _fingerprint() {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month, 1);
    final ratio = appState.budgetUsageRatio(month).toStringAsFixed(4);
    final recurring = appState.recurringTasks
        .map((task) =>
            '${task.id}:${task.enabled}:${task.autoGenerate}:${task.nextRunAt.toIso8601String()}')
        .join('|');

    return [
      appState.systemNotificationsEnabled,
      appState.dailyReminderEnabled,
      appState.reminderTime,
      appState.dndEnabled,
      appState.dndFrom,
      appState.dndTo,
      appState.budgetWarningEnabled,
      appState.budgetWarningLastSentKey ?? '',
      ratio,
      appState.recurringReminderEnabled,
      recurring,
      appState.appLanguage,
    ].join('::');
  }
}
