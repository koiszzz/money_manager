import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('zh', 'CN'), Locale('en', 'US')];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const _localizedValues = <String, Map<String, String>>{
    'en_US': {
      'app_title': 'Money Manager',
      'home': 'Home',
      'transactions': 'Transactions',
      'report': 'Report',
      'settings': 'Settings',
      'month_income': 'Income',
      'month_expense': 'Expense',
      'month_balance': 'Balance',
      'budget': 'Budget',
      'recent': 'Recent',
      'see_all': 'See all',
      'add_transaction': 'Add Transaction',
      'add': 'Add',
      'save': 'Save',
      'save_and_add': 'Save & Add Another',
      'amount': 'Amount',
      'category': 'Category',
      'account': 'Account',
      'time': 'Time',
      'note': 'Note',
      'tags': 'Tags',
      'type_expense': 'Expense',
      'type_income': 'Income',
      'type_transfer': 'Transfer',
      'budget_overview': 'Monthly Budget',
      'budget_used': 'Used',
      'budget_left': 'Left',
      'dashboard': 'Dashboard',
      'no_transactions': 'No transactions yet',
      'go_add': 'Add one',
      'data_security': 'Data & Security',
      'accounts': 'Accounts',
      'categories_tags': 'Categories & Tags',
      'recurring': 'Recurring',
      'reminders': 'Reminders',
      'display_security': 'Display & Security',
      'data_management': 'Data Management',
      'about': 'About',
      'pin': 'PIN',
      'forgot_pin': 'Forgot PIN?',
      'welcome_back': 'Welcome back,',
      'total_balance': 'Total Balance',
      'last_month_change': '+12% from last month',
      'monthly_budget': 'Monthly Budget',
      'spent': 'spent',
      'left': 'left',
      'used': 'Used',
      'reports_analysis': 'Reports & Analysis',
      'expense_categories': 'Expense Categories',
      'view_all': 'View All',
      'trends': 'Trends',
      'top_spending': 'Top Spending',
      'transactions_title': 'Transactions',
      'search_hint': 'Search bills, notes...',
      'all_time': 'All Time',
      'this_month': 'This Month',
      'today': 'Today',
      'yesterday': 'Yesterday',
      'sign_out': 'Sign Out',
      'net_worth': 'Net Worth',
      'secure_access': 'Secure Access',
      'enter_pin': 'Enter your 4-digit PIN to access your finances',
      'please_wait': 'Please wait before retrying',
      'type_label': 'Type',
      'edit': 'Edit',
      'delete': 'Delete',
      'duplicate': 'Duplicate',
      'save_changes': 'Save Changes',
      'tap_to_add': 'Tap to add',
      'none': 'None',
      'select': 'Select',
      'edit_budget': 'Edit Budget',
      'add_category': 'Add Category',
      'category_breakdown': 'Category Breakdown',
      'on_track': 'ON TRACK',
      'budget_limit': 'budget limit',
      'over': 'over',
      'month': 'Month',
      'year': 'Year',
      'chart_placeholder': 'Chart Placeholder',
      'finance_management': 'FINANCE MANAGEMENT',
      'app_preferences': 'APP PREFERENCES',
      'support': 'SUPPORT',
      'accounts_subtitle': 'Manage bank accounts & cash',
      'categories_tags_subtitle': 'Customize your spending types',
      'recurring_subtitle': 'Subscriptions & Salary',
      'reminders_subtitle': 'Bill alerts & daily input',
      'display_security_subtitle': 'Theme, FaceID, Currency',
      'data_management_subtitle': 'Backup, Export CSV/PDF',
      'about_subtitle': 'Version 1.0.0',
      'confirm_delete': 'Delete transaction?',
      'delete_warning': 'This action cannot be undone.',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'pin_error': 'Incorrect PIN. Try again.',
      'forgot_pin_title': 'Forgot PIN',
      'forgot_pin_body': 'Clear local data to reset PIN.',
      'ok': 'OK',
      'backup_restore': 'Backup & Restore',
      'export_backup': 'Export Backup',
      'export_backup_sub': 'Generate local JSON backup file',
      'import_backup': 'Import Backup',
      'import_backup_sub': 'Validate and overwrite local data',
      'security_settings': 'Security',
      'app_lock': 'App Lock',
      'app_lock_sub': 'Effective after next launch',
      'change_pin': 'Change PIN',
      'change_pin_sub': '4 digits',
      'danger_zone': 'Danger Zone',
      'clear_all': 'Clear All Data',
      'clear_all_sub': 'Requires confirmation and PIN',
      'confirm_import': 'Confirm Import',
      'import_warning': 'Import will overwrite current data. Continue?',
      'confirm_clear': 'Confirm Clear',
      'clear_warning': 'This action cannot be undone. Continue?',
      'done': 'Done',
      'pin_updated': 'PIN updated',
      'deleted': 'Deleted',
      'undo': 'Undo',
      'export_done': 'Backup file created',
      'my_accounts': 'My Accounts',
      'reminder_time_label': 'Daily reminder time',
      'budget_warning_label': 'Budget warning',
      'budget_warning_desc': 'Notify when budget exceeds threshold',
      'recurring_reminder_label': 'Recurring reminder',
      'recurring_reminder_desc': 'Notify before recurring bills',
      'theme_mode_label': 'Theme mode',
      'theme_system': 'System',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'currency_label': 'Currency',
    },
    'zh_CN': {
      'app_title': '记账助手',
      'home': '首页',
      'transactions': '账单',
      'report': '报表',
      'settings': '设置',
      'month_income': '本月收入',
      'month_expense': '本月支出',
      'month_balance': '结余',
      'budget': '预算',
      'recent': '最近账单',
      'see_all': '查看全部',
      'add_transaction': '记一笔',
      'add': '新增',
      'save': '保存',
      'save_and_add': '保存并再记一笔',
      'amount': '金额',
      'category': '分类',
      'account': '账户',
      'time': '时间',
      'note': '备注',
      'tags': '标签',
      'type_expense': '支出',
      'type_income': '收入',
      'type_transfer': '转账',
      'budget_overview': '本月总预算',
      'budget_used': '已用',
      'budget_left': '剩余',
      'dashboard': '首页',
      'no_transactions': '暂无账单',
      'go_add': '去记一笔',
      'data_security': '数据与安全',
      'accounts': '账户管理',
      'categories_tags': '分类与标签',
      'recurring': '周期记账',
      'reminders': '提醒设置',
      'display_security': '显示与安全',
      'data_management': '数据管理',
      'about': '关于',
      'pin': 'PIN',
      'forgot_pin': '忘记 PIN?',
      'welcome_back': '欢迎回来，',
      'total_balance': '总资产',
      'last_month_change': '较上月 +12%',
      'monthly_budget': '本月预算',
      'spent': '已用',
      'left': '剩余',
      'used': '已用',
      'reports_analysis': '报表与分析',
      'expense_categories': '支出分类',
      'view_all': '查看全部',
      'trends': '趋势',
      'top_spending': '支出排行',
      'transactions_title': '账单',
      'search_hint': '搜索账单、备注...',
      'all_time': '全部',
      'this_month': '本月',
      'today': '今天',
      'yesterday': '昨天',
      'sign_out': '退出登录',
      'net_worth': '净资产',
      'secure_access': '安全访问',
      'enter_pin': '请输入 4 位 PIN 解锁',
      'please_wait': '请稍候再试',
      'type_label': '类型',
      'edit': '编辑',
      'delete': '删除',
      'duplicate': '复制',
      'save_changes': '保存修改',
      'tap_to_add': '点击填写',
      'none': '无',
      'select': '请选择',
      'edit_budget': '编辑预算',
      'add_category': '新增分类',
      'category_breakdown': '分类预算',
      'on_track': '正常',
      'budget_limit': '预算上限',
      'over': '超支',
      'month': '月',
      'year': '年',
      'chart_placeholder': '图表占位',
      'finance_management': '财务管理',
      'app_preferences': '偏好设置',
      'support': '支持',
      'accounts_subtitle': '管理现金与银行卡',
      'categories_tags_subtitle': '自定义收支类型',
      'recurring_subtitle': '订阅与工资',
      'reminders_subtitle': '账单提醒与每日输入',
      'display_security_subtitle': '主题、面容、货币',
      'data_management_subtitle': '备份、导出 CSV/PDF',
      'about_subtitle': '版本 1.0.0',
      'confirm_delete': '删除账单?',
      'delete_warning': '删除后无法恢复。',
      'cancel': '取消',
      'confirm': '确认',
      'pin_error': 'PIN 错误，请重试',
      'forgot_pin_title': '忘记 PIN',
      'forgot_pin_body': '请清除本地数据后重置 PIN。',
      'ok': '知道了',
      'backup_restore': '备份与恢复',
      'export_backup': '导出备份',
      'export_backup_sub': '生成本地 JSON 备份文件',
      'import_backup': '导入恢复',
      'import_backup_sub': '校验格式后覆盖本地数据',
      'security_settings': '安全设置',
      'app_lock': '应用锁',
      'app_lock_sub': '下次冷启动生效',
      'change_pin': '修改 PIN',
      'change_pin_sub': '4 位数字',
      'danger_zone': '危险操作',
      'clear_all': '清空全部数据',
      'clear_all_sub': '需要二次确认与 PIN 校验',
      'confirm_import': '确认导入',
      'import_warning': '导入将覆盖当前数据，是否继续？',
      'confirm_clear': '确认清空',
      'clear_warning': '此操作不可恢复，是否继续？',
      'done': '完成',
      'pin_updated': 'PIN 已更新',
      'deleted': '已删除',
      'undo': '撤销',
      'export_done': '已生成本地备份文件',
      'my_accounts': '我的账户',
      'reminder_time_label': '每日提醒时间',
      'budget_warning_label': '预算预警',
      'budget_warning_desc': '超过阈值触发提醒',
      'recurring_reminder_label': '周期提醒',
      'recurring_reminder_desc': '到期前提醒',
      'theme_mode_label': '主题模式',
      'theme_system': '跟随系统',
      'theme_light': '浅色',
      'theme_dark': '深色',
      'currency_label': '货币单位',
    },
  };

  String _value(String key) {
    final localeKey = '${locale.languageCode}_${locale.countryCode}';
    return _localizedValues[localeKey]?[key] ??
        _localizedValues['en_US']![key] ??
        key;
  }

  String get appTitle => _value('app_title');
  String get home => _value('home');
  String get transactions => _value('transactions');
  String get report => _value('report');
  String get settings => _value('settings');
  String get monthIncome => _value('month_income');
  String get monthExpense => _value('month_expense');
  String get monthBalance => _value('month_balance');
  String get budget => _value('budget');
  String get recent => _value('recent');
  String get seeAll => _value('see_all');
  String get addTransaction => _value('add_transaction');
  String get add => _value('add');
  String get save => _value('save');
  String get saveAndAdd => _value('save_and_add');
  String get amount => _value('amount');
  String get category => _value('category');
  String get account => _value('account');
  String get time => _value('time');
  String get note => _value('note');
  String get tags => _value('tags');
  String get typeExpense => _value('type_expense');
  String get typeIncome => _value('type_income');
  String get typeTransfer => _value('type_transfer');
  String get budgetOverview => _value('budget_overview');
  String get budgetUsed => _value('budget_used');
  String get budgetLeft => _value('budget_left');
  String get dashboard => _value('dashboard');
  String get noTransactions => _value('no_transactions');
  String get goAdd => _value('go_add');
  String get dataSecurity => _value('data_security');
  String get accounts => _value('accounts');
  String get categoriesTags => _value('categories_tags');
  String get recurring => _value('recurring');
  String get reminders => _value('reminders');
  String get displaySecurity => _value('display_security');
  String get dataManagement => _value('data_management');
  String get about => _value('about');
  String get pin => _value('pin');
  String get forgotPin => _value('forgot_pin');
  String get welcomeBack => _value('welcome_back');
  String get totalBalance => _value('total_balance');
  String get lastMonthChange => _value('last_month_change');
  String get monthlyBudget => _value('monthly_budget');
  String get spent => _value('spent');
  String get left => _value('left');
  String get used => _value('used');
  String get reportsAnalysis => _value('reports_analysis');
  String get expenseCategories => _value('expense_categories');
  String get viewAll => _value('view_all');
  String get trends => _value('trends');
  String get topSpending => _value('top_spending');
  String get transactionsTitle => _value('transactions_title');
  String get searchHint => _value('search_hint');
  String get allTime => _value('all_time');
  String get thisMonth => _value('this_month');
  String get today => _value('today');
  String get yesterday => _value('yesterday');
  String get signOut => _value('sign_out');
  String get netWorth => _value('net_worth');
  String get secureAccess => _value('secure_access');
  String get enterPin => _value('enter_pin');
  String get pleaseWait => _value('please_wait');
  String get typeLabel => _value('type_label');
  String get edit => _value('edit');
  String get delete => _value('delete');
  String get duplicate => _value('duplicate');
  String get saveChanges => _value('save_changes');
  String get tapToAdd => _value('tap_to_add');
  String get none => _value('none');
  String get select => _value('select');
  String get editBudget => _value('edit_budget');
  String get addCategory => _value('add_category');
  String get categoryBreakdown => _value('category_breakdown');
  String get onTrack => _value('on_track');
  String get budgetLimit => _value('budget_limit');
  String get over => _value('over');
  String get month => _value('month');
  String get year => _value('year');
  String get chartPlaceholder => _value('chart_placeholder');
  String get financeManagement => _value('finance_management');
  String get appPreferences => _value('app_preferences');
  String get support => _value('support');
  String get accountsSubtitle => _value('accounts_subtitle');
  String get categoriesTagsSubtitle => _value('categories_tags_subtitle');
  String get recurringSubtitle => _value('recurring_subtitle');
  String get remindersSubtitle => _value('reminders_subtitle');
  String get displaySecuritySubtitle => _value('display_security_subtitle');
  String get dataManagementSubtitle => _value('data_management_subtitle');
  String get aboutSubtitle => _value('about_subtitle');
  String get confirmDelete => _value('confirm_delete');
  String get deleteWarning => _value('delete_warning');
  String get cancel => _value('cancel');
  String get confirm => _value('confirm');
  String get pinError => _value('pin_error');
  String get forgotPinTitle => _value('forgot_pin_title');
  String get forgotPinBody => _value('forgot_pin_body');
  String get ok => _value('ok');
  String get backupRestore => _value('backup_restore');
  String get exportBackup => _value('export_backup');
  String get exportBackupSub => _value('export_backup_sub');
  String get importBackup => _value('import_backup');
  String get importBackupSub => _value('import_backup_sub');
  String get securitySettings => _value('security_settings');
  String get appLock => _value('app_lock');
  String get appLockSub => _value('app_lock_sub');
  String get changePin => _value('change_pin');
  String get changePinSub => _value('change_pin_sub');
  String get dangerZone => _value('danger_zone');
  String get clearAll => _value('clear_all');
  String get clearAllSub => _value('clear_all_sub');
  String get confirmImport => _value('confirm_import');
  String get importWarning => _value('import_warning');
  String get confirmClear => _value('confirm_clear');
  String get clearWarning => _value('clear_warning');
  String get done => _value('done');
  String get pinUpdated => _value('pin_updated');
  String get deleted => _value('deleted');
  String get undo => _value('undo');
  String get exportDone => _value('export_done');
  String get myAccounts => _value('my_accounts');
  String get reminderTimeLabel => _value('reminder_time_label');
  String get budgetWarningLabel => _value('budget_warning_label');
  String get budgetWarningDesc => _value('budget_warning_desc');
  String get recurringReminderLabel => _value('recurring_reminder_label');
  String get recurringReminderDesc => _value('recurring_reminder_desc');
  String get themeModeLabel => _value('theme_mode_label');
  String get themeSystem => _value('theme_system');
  String get themeLight => _value('theme_light');
  String get themeDark => _value('theme_dark');
  String get currencyLabel => _value('currency_label');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) =>
          supported.languageCode == locale.languageCode &&
          supported.countryCode == locale.countryCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
