import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';

import 'app_database.dart';
import 'models.dart';
import 'sample_data.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _init();
  }

  final _uuid = const Uuid();
  final AppDatabase _db = AppDatabase.instance;

  late List<TransactionRecord> _records;
  late List<Account> _accounts;
  late List<Category> _categories;
  late List<Budget> _budgets;
  late List<RecurringTask> _recurringTasks;
  List<String> _tags = [];
  Map<String, String> _settings = {};

  bool _initialized = false;
  int _tabIndex = 0;
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  TransactionType? _transactionsFilterType;

  List<TransactionRecord> get records => List.unmodifiable(_records);
  List<Account> get accounts => List.unmodifiable(_accounts);
  List<Category> get categories => List.unmodifiable(_categories);
  List<Budget> get budgets => List.unmodifiable(_budgets);
  List<RecurringTask> get recurringTasks => List.unmodifiable(_recurringTasks);
  List<String> get tags => List.unmodifiable(_tags);

  bool get initialized => _initialized;
  int get tabIndex => _tabIndex;
  DateTime get currentMonth => _currentMonth;
  TransactionType? get transactionsFilterType => _transactionsFilterType;
  bool get appLockEnabled => _settings['app_lock'] == '1';
  String get pinCode => _settings['pin_code'] ?? '1234';
  String get currencyCode => _settings['currency'] ?? 'CNY';
  String get themeMode => _settings['theme_mode'] ?? 'dark';
  String get reminderTime => _settings['reminder_time'] ?? '20:00';
  bool get budgetWarningEnabled => _settings['budget_warning'] == '1';
  bool get recurringReminderEnabled => _settings['recurring_reminder'] == '1';
  bool get dailyReminderEnabled => _settings['daily_reminder'] == '1';
  bool get systemNotificationsEnabled =>
      _settings['system_notifications'] != '0';
  bool get dndEnabled => _settings['dnd_enabled'] == '1';
  String get dndFrom => _settings['dnd_from'] ?? '22:00';
  String get dndTo => _settings['dnd_to'] ?? '07:00';
  bool get biometricEnabled => _settings['biometric_unlock'] == '1';
  bool get screenshotProtectionEnabled =>
      _settings['screenshot_protection'] == '1';
  int get decimalPlaces => int.tryParse(_settings['decimal_places'] ?? '2') ?? 2;
  String get weekStartsOn => _settings['week_start'] ?? 'Monday';
  String get appLanguage => _settings['app_language'] ?? 'system';
  double get fontScale =>
      double.tryParse(_settings['font_scale'] ?? '1.0') ?? 1.0;
  String? get lastBackupAt => _settings['last_backup_at'];
  String? get lastMigrationAt => _settings['last_migration_at'];

  set tabIndex(int value) {
    if (_tabIndex == value) return;
    _tabIndex = value;
    notifyListeners();
  }

  void setMonth(DateTime month) {
    _currentMonth = DateTime(month.year, month.month, 1);
    notifyListeners();
  }

  void setTransactionsFilterType(TransactionType? type) {
    _transactionsFilterType = type;
    notifyListeners();
  }

  Future<void> toggleAppLock(bool enabled) async {
    await _setSetting('app_lock', enabled ? '1' : '0');
  }

  Future<void> updatePinCode(String pin) async {
    await _setSetting('pin_code', pin);
  }

  Future<void> updateCurrency(String code) async {
    await _setSetting('currency', code);
  }

  Future<void> updateThemeMode(String mode) async {
    await _setSetting('theme_mode', mode);
  }

  Future<void> updateReminderTime(String time) async {
    await _setSetting('reminder_time', time);
  }

  Future<void> toggleDailyReminder(bool enabled) async {
    await _setSetting('daily_reminder', enabled ? '1' : '0');
  }

  Future<void> toggleBudgetWarning(bool enabled) async {
    await _setSetting('budget_warning', enabled ? '1' : '0');
  }

  Future<void> toggleRecurringReminder(bool enabled) async {
    await _setSetting('recurring_reminder', enabled ? '1' : '0');
  }

  Future<void> toggleSystemNotifications(bool enabled) async {
    await _setSetting('system_notifications', enabled ? '1' : '0');
  }

  Future<void> updateDndEnabled(bool enabled) async {
    await _setSetting('dnd_enabled', enabled ? '1' : '0');
  }

  Future<void> updateDndFrom(String time) async {
    await _setSetting('dnd_from', time);
  }

  Future<void> updateDndTo(String time) async {
    await _setSetting('dnd_to', time);
  }

  Future<void> toggleBiometric(bool enabled) async {
    await _setSetting('biometric_unlock', enabled ? '1' : '0');
  }

  Future<void> toggleScreenshotProtection(bool enabled) async {
    await _setSetting('screenshot_protection', enabled ? '1' : '0');
  }

  Future<void> updateDecimalPlaces(int value) async {
    await _setSetting('decimal_places', value.toString());
  }

  Future<void> updateWeekStartsOn(String value) async {
    await _setSetting('week_start', value);
  }

  Future<void> updateAppLanguage(String value) async {
    await _setSetting('app_language', value);
  }

  Future<void> updateFontScale(double value) async {
    await _setSetting('font_scale', value.toStringAsFixed(2));
  }

  Future<void> updateLastBackupAt(DateTime time) async {
    await _setSetting('last_backup_at', time.toIso8601String());
  }

  Future<void> updateLastMigrationAt(DateTime time) async {
    await _setSetting('last_migration_at', time.toIso8601String());
  }

  Future<void> addTag(String tag) async {
    if (_tags.contains(tag)) return;
    _tags = [..._tags, tag];
    await _setSetting('tags', jsonEncode(_tags));
  }

  Future<void> removeTag(String tag) async {
    _tags = _tags.where((t) => t != tag).toList();
    await _setSetting('tags', jsonEncode(_tags));
  }

  Future<void> addCategory(CategoryType type, String name, int icon, int color) async {
    final maxOrder = _categories
        .where((c) => c.type == type)
        .fold<int>(-1, (max, item) => item.sortOrder > max ? item.sortOrder : max);
    final category = Category(
      id: _uuid.v4(),
      type: type,
      name: name,
      icon: icon,
      colorHex: color,
      enabled: true,
      sortOrder: maxOrder + 1,
    );
    _categories = [..._categories, category];
    await _db.insert('categories', category.toMap());
    notifyListeners();
  }

  Future<void> addAccount({
    required String name,
    required AccountType type,
    required double openingBalance,
    String? note,
  }) async {
    final maxOrder = _accounts
        .where((a) => a.type == type)
        .fold<int>(-1, (max, item) => item.sortOrder > max ? item.sortOrder : max);
    final account = Account(
      id: _uuid.v4(),
      name: name,
      type: type,
      openingBalance: openingBalance,
      note: note,
      enabled: true,
      sortOrder: maxOrder + 1,
    );
    _accounts = [..._accounts, account];
    await _db.insert('accounts', account.toMap());
    notifyListeners();
  }

  Future<void> updateAccount(Account updated) async {
    final index = _accounts.indexWhere((a) => a.id == updated.id);
    if (index == -1) return;
    _accounts[index] = updated;
    await _db.update('accounts', updated.toMap(),
        where: 'id = ?', whereArgs: [updated.id]);
    notifyListeners();
  }

  Future<void> toggleAccountEnabled(String id, bool enabled) async {
    final index = _accounts.indexWhere((a) => a.id == id);
    if (index == -1) return;
    final current = _accounts[index];
    final updated = Account(
      id: current.id,
      name: current.name,
      type: current.type,
      openingBalance: current.openingBalance,
      note: current.note,
      enabled: enabled,
      sortOrder: current.sortOrder,
    );
    await updateAccount(updated);
  }

  Future<void> updateAccountOrder(List<Account> ordered) async {
    for (var i = 0; i < ordered.length; i++) {
      final account = ordered[i];
      final updated = Account(
        id: account.id,
        name: account.name,
        type: account.type,
        openingBalance: account.openingBalance,
        note: account.note,
        enabled: account.enabled,
        sortOrder: i,
      );
      final index = _accounts.indexWhere((a) => a.id == account.id);
      if (index != -1) {
        _accounts[index] = updated;
      }
      await _db.update('accounts', updated.toMap(),
          where: 'id = ?', whereArgs: [account.id]);
    }
    notifyListeners();
  }

  int countRecordsForAccount(String accountId) {
    return _records.where((r) => r.accountId == accountId).length +
        _records
            .where((r) => r.transferInAccountId == accountId)
            .length;
  }

  Future<bool> deleteAccount(String accountId) async {
    if (countRecordsForAccount(accountId) > 0) return false;
    _accounts = _accounts.where((a) => a.id != accountId).toList();
    await _db.delete('accounts', where: 'id = ?', whereArgs: [accountId]);
    notifyListeners();
    return true;
  }

  Future<void> migrateAccount({
    required String sourceId,
    required String targetId,
  }) async {
    if (sourceId == targetId) return;
    for (var i = 0; i < _records.length; i++) {
      final record = _records[i];
      var updated = record;
      if (record.accountId == sourceId) {
        updated = updated.copyWith(accountId: targetId);
      }
      if (record.transferInAccountId == sourceId) {
        updated = updated.copyWith(transferInAccountId: targetId);
      }
      _records[i] = updated;
    }
    final db = await _db.database;
    await db.update(
      'transactions',
      {'account_id': targetId},
      where: 'account_id = ?',
      whereArgs: [sourceId],
    );
    await db.update(
      'transactions',
      {'transfer_in_account_id': targetId},
      where: 'transfer_in_account_id = ?',
      whereArgs: [sourceId],
    );
    await updateLastMigrationAt(DateTime.now());
    notifyListeners();
  }

  Future<void> toggleCategoryEnabled(String categoryId, bool enabled) async {
    final index = _categories.indexWhere((c) => c.id == categoryId);
    if (index == -1) return;
    final current = _categories[index];
    final updated = Category(
      id: current.id,
      type: current.type,
      name: current.name,
      icon: current.icon,
      colorHex: current.colorHex,
      enabled: enabled,
      sortOrder: current.sortOrder,
    );
    _categories[index] = updated;
    await _db.update('categories', updated.toMap(),
        where: 'id = ?', whereArgs: [categoryId]);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    final db = await _db.database;
    await db.delete('transactions');
    await db.delete('accounts');
    await db.delete('categories');
    await db.delete('budgets');
    await db.delete('recurring_tasks');
    await db.delete('settings');

    _records = [];
    _budgets = [];
    _recurringTasks = [];

    final defaultAccount = Account(
      id: _uuid.v4(),
      name: 'Cash',
      type: AccountType.cash,
      openingBalance: 0,
      note: null,
      enabled: true,
      sortOrder: 0,
    );
    final defaultCategory = Category(
      id: _uuid.v4(),
      type: CategoryType.expense,
      name: 'General',
      icon: 0,
      colorHex: 0xFF2B7CEE,
      enabled: true,
      sortOrder: 0,
    );
    _accounts = [defaultAccount];
    _categories = [defaultCategory];

    await _db.insert('accounts', defaultAccount.toMap());
    await _db.insert('categories', defaultCategory.toMap());
    await _seedDefaultSettings();
    _settings = {
      'app_lock': '0',
      'pin_code': '1234',
      'currency': 'CNY',
      'theme_mode': 'dark',
      'reminder_time': '20:00',
      'daily_reminder': '1',
      'budget_warning': '1',
      'recurring_reminder': '1',
      'system_notifications': '1',
      'dnd_enabled': '1',
      'dnd_from': '22:00',
      'dnd_to': '07:00',
      'biometric_unlock': '1',
      'screenshot_protection': '0',
      'decimal_places': '2',
      'week_start': 'Monday',
      'app_language': 'system',
      'font_scale': '1.0',
    };
    _tags = _loadTags();
    notifyListeners();
  }

  Future<void> _seedDefaultSettings() async {
    await _db.insert('settings', {'key': 'app_lock', 'value': '0'});
    await _db.insert('settings', {'key': 'pin_code', 'value': '1234'});
    await _db.insert('settings', {'key': 'currency', 'value': 'CNY'});
    await _db.insert('settings', {'key': 'theme_mode', 'value': 'dark'});
    await _db.insert('settings', {'key': 'reminder_time', 'value': '20:00'});
    await _db.insert('settings', {'key': 'daily_reminder', 'value': '1'});
    await _db.insert('settings', {'key': 'budget_warning', 'value': '1'});
    await _db.insert('settings', {'key': 'recurring_reminder', 'value': '1'});
    await _db.insert('settings', {'key': 'system_notifications', 'value': '1'});
    await _db.insert('settings', {'key': 'dnd_enabled', 'value': '1'});
    await _db.insert('settings', {'key': 'dnd_from', 'value': '22:00'});
    await _db.insert('settings', {'key': 'dnd_to', 'value': '07:00'});
    await _db.insert('settings', {'key': 'biometric_unlock', 'value': '1'});
    await _db.insert('settings', {'key': 'screenshot_protection', 'value': '0'});
    await _db.insert('settings', {'key': 'decimal_places', 'value': '2'});
    await _db.insert('settings', {'key': 'week_start', 'value': 'Monday'});
    await _db.insert('settings', {'key': 'app_language', 'value': 'system'});
    await _db.insert('settings', {'key': 'font_scale', 'value': '1.0'});
    await _db.insert('settings', {
      'key': 'tags',
      'value': jsonEncode(['家庭', '通勤', '订阅', '旅行', '必要'])
    });
  }
  Future<void> updateCategory(Category updated) async {
    final index = _categories.indexWhere((c) => c.id == updated.id);
    if (index == -1) return;
    _categories[index] = updated;
    await _db.update('categories', updated.toMap(),
        where: 'id = ?', whereArgs: [updated.id]);
    notifyListeners();
  }

  Future<void> updateCategoryOrder(CategoryType type, List<Category> ordered) async {
    for (var i = 0; i < ordered.length; i++) {
      final category = ordered[i];
      if (category.type != type) continue;
      final updated = Category(
        id: category.id,
        type: category.type,
        name: category.name,
        icon: category.icon,
        colorHex: category.colorHex,
        enabled: category.enabled,
        sortOrder: i,
      );
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = updated;
      }
      await _db.update('categories', updated.toMap(),
          where: 'id = ?', whereArgs: [category.id]);
    }
    notifyListeners();
  }

  int countRecordsForCategory(String categoryId) {
    return _records.where((r) => r.categoryId == categoryId).length;
  }

  Future<void> mergeCategory({
    required String sourceId,
    required String targetId,
  }) async {
    if (sourceId == targetId) return;
    for (var i = 0; i < _records.length; i++) {
      final record = _records[i];
      if (record.categoryId == sourceId) {
        _records[i] = record.copyWith(categoryId: targetId);
      }
    }
    final db = await _db.database;
    await db.update(
      'transactions',
      {'category_id': targetId},
      where: 'category_id = ?',
      whereArgs: [sourceId],
    );
    await deleteCategory(sourceId, force: true);
  }

  Future<void> deleteCategory(String categoryId, {bool force = false}) async {
    if (!force && countRecordsForCategory(categoryId) > 0) {
      await toggleCategoryEnabled(categoryId, false);
      return;
    }
    _categories = _categories.where((c) => c.id != categoryId).toList();
    await _db.delete('categories', where: 'id = ?', whereArgs: [categoryId]);
    notifyListeners();
  }

  Future<void> addRecurringTask(RecurringTask task) async {
    _recurringTasks = [..._recurringTasks, task];
    final templateMap = task.templateBill
        .toMap(tagsJson: AppDatabase.encodeTags(task.templateBill.tags));
    await _db.insert('recurring_tasks',
        task.toMap(jsonEncode(templateMap)));
    notifyListeners();
  }

  Future<void> toggleRecurringTask(String id, bool enabled) async {
    final index = _recurringTasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final current = _recurringTasks[index];
    final updated = RecurringTask(
      id: current.id,
      templateBill: current.templateBill,
      rule: current.rule,
      nextRunAt: current.nextRunAt,
      autoGenerate: current.autoGenerate,
      enabled: enabled,
    );
    _recurringTasks[index] = updated;
    final templateMap = updated.templateBill
        .toMap(tagsJson: AppDatabase.encodeTags(updated.templateBill.tags));
    await _db.update('recurring_tasks', updated.toMap(jsonEncode(templateMap)),
        where: 'id = ?', whereArgs: [id]);
    notifyListeners();
  }

  List<TransactionRecord> recordsForMonth(DateTime month) {
    return _records
        .where((record) =>
            record.occurredAt.year == month.year &&
            record.occurredAt.month == month.month)
        .toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }

  List<TransactionRecord> filteredRecords(DateTime month) {
    final base = recordsForMonth(month);
    if (_transactionsFilterType == null) return base;
    return base
        .where((record) => record.type == _transactionsFilterType)
        .toList();
  }

  double totalIncome(DateTime month) {
    return recordsForMonth(month)
        .where((record) => record.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double totalExpense(DateTime month) {
    return recordsForMonth(month)
        .where((record) => record.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double netBalance(DateTime month) {
    return totalIncome(month) - totalExpense(month);
  }

  double accountBalance(String accountId) {
    final account = _accounts.firstWhere((acc) => acc.id == accountId);
    double balance = account.openingBalance;

    for (final record in _records) {
      if (record.type == TransactionType.transfer) {
        if (record.accountId == accountId) {
          balance -= record.amount;
        }
        if (record.transferInAccountId == accountId) {
          balance += record.amount;
        }
      } else if (record.accountId == accountId) {
        balance += record.type == TransactionType.income
            ? record.amount
            : -record.amount;
      }
    }

    return balance;
  }

  double totalAssets() {
    return _accounts.fold(0.0, (sum, account) => sum + accountBalance(account.id));
  }

  Budget budgetForMonth(DateTime month) {
    final key = _monthKey(month);
    final existing = _budgets.where((b) => _monthKey(b.month) == key).toList();
    if (existing.isNotEmpty) return existing.first;
    final budget = Budget(
      id: 'budget_$key',
      month: DateTime(month.year, month.month, 1),
      totalAmount: 5500,
      warningThreshold: 0.8,
    );
    _budgets.add(budget);
    unawaited(_db.insert('budgets', budget.toMap()));
    return budget;
  }

  TransactionRecord addRecord(TransactionRecord draft) {
    final record = TransactionRecord(
      id: _uuid.v4(),
      type: draft.type,
      amount: draft.amount,
      categoryId: draft.categoryId,
      accountId: draft.accountId,
      transferInAccountId: draft.transferInAccountId,
      occurredAt: draft.occurredAt,
      note: draft.note,
      tags: draft.tags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _records = [record, ..._records];
    unawaited(_db.insert('transactions',
        record.toMap(tagsJson: AppDatabase.encodeTags(record.tags))));
    notifyListeners();
    return record;
  }

  void restoreRecord(TransactionRecord record) {
    _records = [record, ..._records];
    unawaited(_db.insert('transactions',
        record.toMap(tagsJson: AppDatabase.encodeTags(record.tags)),
        conflictAlgorithm: ConflictAlgorithm.replace));
    notifyListeners();
  }

  void updateRecord(TransactionRecord updated) {
    final index = _records.indexWhere((item) => item.id == updated.id);
    if (index == -1) return;
    final next = updated.copyWith();
    _records[index] = next;
    unawaited(_db.update(
      'transactions',
      next.toMap(tagsJson: AppDatabase.encodeTags(next.tags)),
      where: 'id = ?',
      whereArgs: [next.id],
    ));
    notifyListeners();
  }

  void deleteRecord(String recordId) {
    _records.removeWhere((item) => item.id == recordId);
    unawaited(_db.delete('transactions', where: 'id = ?', whereArgs: [recordId]));
    notifyListeners();
  }

  Category? categoryById(String? id) {
    if (id == null) return null;
    return _categories.firstWhere((cat) => cat.id == id);
  }

  Account accountById(String id) {
    return _accounts.firstWhere((acc) => acc.id == id);
  }

  List<Category> categoriesByType(TransactionType type) {
    final categoryType = type == TransactionType.income
        ? CategoryType.income
        : CategoryType.expense;
    final list = _categories.where((cat) => cat.type == categoryType).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  List<Account> accountsForTransfer(String? excludeId) {
    return _accounts
        .where((acc) => excludeId == null || acc.id != excludeId)
        .toList();
  }

  double budgetUsed(DateTime month) {
    return totalExpense(month);
  }

  double budgetUsageRatio(DateTime month) {
    final budget = budgetForMonth(month);
    if (budget.totalAmount == 0) return 0;
    return min(1, budgetUsed(month) / budget.totalAmount);
  }

  Future<void> _init() async {
    final accountRows = await _db.queryAll('accounts');
    if (accountRows.isEmpty) {
      await _seedData();
    }

    final accounts = await _db.queryAll('accounts');
    final categories = await _db.queryAll('categories');
    final transactions = await _db.queryAll('transactions');
    final budgets = await _db.queryAll('budgets');
    final recurring = await _db.queryAll('recurring_tasks');
    final settingsRows = await _db.queryAll('settings');

    _accounts = accounts.map(AccountMapping.fromMap).toList();
    _categories = categories.map(CategoryMapping.fromMap).toList();
    _records = transactions
        .map((row) => TransactionMapping.fromMap(
              row,
              AppDatabase.decodeTags(row['tags'] as String),
            ))
        .toList();
    _budgets = budgets.map(BudgetMapping.fromMap).toList();
    _recurringTasks = recurring.map((row) {
      final templateMap = jsonDecode(row['template_json'] as String)
          as Map<String, dynamic>;
      final tags = AppDatabase.decodeTags(templateMap['tags'] as String);
      final template = TransactionMapping.fromMap(templateMap, tags);
      return RecurringTaskMapping.fromMap(row, template);
    }).toList();
    _settings = {
      for (final row in settingsRows)
        row['key'] as String: row['value'] as String,
    };
    _tags = _loadTags();

    _initialized = true;
    notifyListeners();
  }

  List<String> _loadTags() {
    final raw = _settings['tags'];
    if (raw != null) {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    }
    return ['家庭', '通勤', '订阅', '旅行', '必要'];
  }

  Future<void> _seedData() async {
    for (final account in SampleData.accounts) {
      await _db.insert('accounts', account.toMap());
    }
    for (final category in SampleData.categories) {
      await _db.insert('categories', category.toMap());
    }
    for (final record in SampleData.records) {
      await _db.insert(
        'transactions',
        record.toMap(tagsJson: AppDatabase.encodeTags(record.tags)),
      );
    }
    final budget = Budget(
      id: 'budget_${_monthKey(DateTime.now())}',
      month: DateTime(DateTime.now().year, DateTime.now().month, 1),
      totalAmount: 5500,
      warningThreshold: 0.8,
    );
    await _db.insert('budgets', budget.toMap());
    await _seedDefaultSettings();
  }

  Future<void> _setSetting(String key, String value) async {
    _settings[key] = value;
    await _db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifyListeners();
  }

  String _monthKey(DateTime month) {
    final m = month.month.toString().padLeft(2, '0');
    return '${month.year}-$m-01';
  }
}
