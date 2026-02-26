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

  Future<void> toggleBudgetWarning(bool enabled) async {
    await _setSetting('budget_warning', enabled ? '1' : '0');
  }

  Future<void> toggleRecurringReminder(bool enabled) async {
    await _setSetting('recurring_reminder', enabled ? '1' : '0');
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
    final category = Category(
      id: _uuid.v4(),
      type: type,
      name: name,
      icon: icon,
      colorHex: color,
      enabled: true,
    );
    _categories = [..._categories, category];
    await _db.insert('categories', category.toMap());
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
    );
    _categories[index] = updated;
    await _db.update('categories', updated.toMap(),
        where: 'id = ?', whereArgs: [categoryId]);
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
    return _categories.where((cat) => cat.type == categoryType).toList();
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
    await _db.insert('settings', {'key': 'app_lock', 'value': '0'});
    await _db.insert('settings', {'key': 'pin_code', 'value': '1234'});
    await _db.insert('settings', {'key': 'currency', 'value': 'CNY'});
    await _db.insert('settings', {'key': 'theme_mode', 'value': 'dark'});
    await _db.insert('settings', {'key': 'reminder_time', 'value': '20:00'});
    await _db.insert('settings', {'key': 'budget_warning', 'value': '1'});
    await _db.insert('settings', {'key': 'recurring_reminder', 'value': '1'});
    await _db.insert('settings', {
      'key': 'tags',
      'value': jsonEncode(['家庭', '通勤', '订阅', '旅行', '必要'])
    });
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
