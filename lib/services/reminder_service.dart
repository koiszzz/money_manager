import '../data/models.dart';

enum ReminderType { daily, budgetWarning, recurring }

class ReminderSignal {
  const ReminderSignal({
    required this.type,
    required this.title,
    required this.message,
    this.scheduledAt,
  });

  final ReminderType type;
  final String title;
  final String message;
  final DateTime? scheduledAt;
}

class ReminderService {
  static const String defaultReminderTime = '20:00';
  static const String defaultDndFrom = '22:00';
  static const String defaultDndTo = '07:00';

  static String toCanonicalTime(String raw, {required String fallback}) {
    final minutes = parseTimeToMinutes(raw);
    if (minutes == null) return fallback;
    return _minutesToLabel(minutes);
  }

  static int? parseTimeToMinutes(String raw) {
    final input = raw.trim();
    if (input.isEmpty) return null;

    final hourMinute =
        RegExp(r'(\d{1,2})\s*[:：]\s*(\d{1,2})').firstMatch(input.toLowerCase());
    if (hourMinute == null) return null;

    var hour = int.tryParse(hourMinute.group(1)!);
    final minute = int.tryParse(hourMinute.group(2)!);
    if (hour == null || minute == null) return null;
    if (minute < 0 || minute > 59 || hour < 0 || hour > 23) return null;

    final normalized = input.toLowerCase();
    final hasAm = normalized.contains('am') || normalized.contains('上午');
    final hasPm = normalized.contains('pm') || normalized.contains('下午');
    if (hasAm || hasPm) {
      if (hour > 12 || hour == 0) return null;
      if (hasPm && hour != 12) hour += 12;
      if (hasAm && hour == 12) hour = 0;
    }

    return hour * 60 + minute;
  }

  static bool isTimeInDndWindow({
    required String time,
    required String dndFrom,
    required String dndTo,
  }) {
    final point = parseTimeToMinutes(time);
    final from = parseTimeToMinutes(dndFrom);
    final to = parseTimeToMinutes(dndTo);
    if (point == null || from == null || to == null) return false;

    if (from == to) return true;
    if (from < to) {
      return point >= from && point < to;
    }
    return point >= from || point < to;
  }

  static bool hasReminderDndConflict({
    required bool dndEnabled,
    required String reminderTime,
    required String dndFrom,
    required String dndTo,
  }) {
    if (!dndEnabled) return false;
    return isTimeInDndWindow(
      time: reminderTime,
      dndFrom: dndFrom,
      dndTo: dndTo,
    );
  }

  static List<ReminderSignal> collectDueSignals({
    required DateTime now,
    required bool systemNotificationsEnabled,
    required bool dailyReminderEnabled,
    required String reminderTime,
    required bool dndEnabled,
    required String dndFrom,
    required String dndTo,
    required bool budgetWarningEnabled,
    required double budgetUsageRatio,
    required double budgetWarningThreshold,
    required bool recurringReminderEnabled,
    required Iterable<RecurringTask> recurringTasks,
    Duration recurringLookAhead = const Duration(hours: 24),
  }) {
    if (!systemNotificationsEnabled) return const [];

    final signals = <ReminderSignal>[];
    final nowMinutes = now.hour * 60 + now.minute;
    final reminderMinutes = parseTimeToMinutes(reminderTime);
    final from = parseTimeToMinutes(dndFrom);
    final to = parseTimeToMinutes(dndTo);

    if (dailyReminderEnabled &&
        reminderMinutes != null &&
        nowMinutes == reminderMinutes &&
        !_isMutedByDnd(
          pointMinutes: nowMinutes,
          dndEnabled: dndEnabled,
          from: from,
          to: to,
        )) {
      signals.add(
        ReminderSignal(
          type: ReminderType.daily,
          title: 'daily',
          message: 'daily reminder',
          scheduledAt:
              DateTime(now.year, now.month, now.day, now.hour, now.minute),
        ),
      );
    }

    if (budgetWarningEnabled &&
        budgetWarningThreshold > 0 &&
        budgetUsageRatio >= budgetWarningThreshold) {
      signals.add(
        ReminderSignal(
          type: ReminderType.budgetWarning,
          title: 'budget',
          message: 'budget warning',
          scheduledAt: now,
        ),
      );
    }

    if (recurringReminderEnabled) {
      final cutoff = now.add(recurringLookAhead);
      for (final task in recurringTasks) {
        if (!task.enabled || task.autoGenerate) continue;
        if (task.nextRunAt.isAfter(cutoff)) continue;
        if (_isMutedByDnd(
          pointMinutes: task.nextRunAt.hour * 60 + task.nextRunAt.minute,
          dndEnabled: dndEnabled,
          from: from,
          to: to,
        )) {
          continue;
        }
        signals.add(
          ReminderSignal(
            type: ReminderType.recurring,
            title: task.templateBill.note ?? 'recurring',
            message: task.rule,
            scheduledAt: task.nextRunAt,
          ),
        );
      }
    }

    return signals;
  }

  static bool _isMutedByDnd({
    required int pointMinutes,
    required bool dndEnabled,
    required int? from,
    required int? to,
  }) {
    if (!dndEnabled || from == null || to == null) return false;
    if (from == to) return true;
    if (from < to) return pointMinutes >= from && pointMinutes < to;
    return pointMinutes >= from || pointMinutes < to;
  }

  static String _minutesToLabel(int minutes) {
    final hour = (minutes ~/ 60).toString().padLeft(2, '0');
    final minute = (minutes % 60).toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
