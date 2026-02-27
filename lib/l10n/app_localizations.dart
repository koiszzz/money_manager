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
      'expense_breakdown': 'Expense Breakdown',
      'income_breakdown': 'Income Breakdown',
      'expense_ranking': 'Expense Ranking',
      'income_ranking': 'Income Ranking',
      'trend_income': 'Income',
      'trend_expense': 'Expense',
      'trend_net': 'Net',
      'custom_range': 'Custom Range',
      'select_year': 'Select Year',
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
      'help': 'Help',
      'date': 'Date',
      'display_localization': 'Display & Localization',
      'accounts_bank_section': 'Bank Accounts',
      'accounts_credit_section': 'Credit Cards',
      'accounts_cash_section': 'Cash',
      'add_new_account': 'Add New Account',
      'edit_account': 'Edit Account',
      'account_name': 'Account Name',
      'account_name_hint': 'e.g. Main Checking',
      'account_note': 'Account Note',
      'account_note_hint': 'e.g. **** 4521',
      'opening_balance': 'Opening balance',
      'account_type': 'Account type',
      'account_type_bank': 'Bank',
      'account_type_credit': 'Credit',
      'account_type_cash': 'Cash',
      'account_types': 'Account Types',
      'add_account_type': 'Add Account Type',
      'edit_account_type': 'Edit Account Type',
      'account_type_name': 'Type name',
      'no_account_types': 'No account types yet',
      'account_type_delete_blocked': 'This type is used by accounts.',
      'account_nature_bank': 'Bank Card',
      'account_nature_credit': 'Credit Card',
      'account_nature_loan': 'Loan',
      'account_nature_asset': 'Other Assets',
      'account_nature_liability': 'Other Liabilities',
      'select_icon': 'Select icon',
      'account_note_empty': 'No note',
      'custom_type': 'Custom type',
      'custom_type_hint': 'e.g. Crypto Wallet',
      'account_icon': 'Account icon',
      'accounts_other_section': 'Other Assets',
      'card_number': 'Card Number',
      'card_number_hint': 'e.g. 1234 5678 9012 3456',
      'billing_day': 'Billing Day',
      'billing_day_hint': '1-31',
      'repayment_day': 'Repayment Day',
      'repayment_day_hint': '1-31',
      'migration_type_mismatch': 'Only accounts of the same type can be merged.',
      'migration_history_title': 'Migration History',
      'migration_history_empty': 'No migration history yet',
      'empty_accounts': 'No accounts yet',
      'account_migration': 'Account Migration',
      'account_migration_desc': 'Move historical bills to another account',
      'account_delete_blocked_title': 'Cannot delete',
      'account_delete_blocked_body':
          'This account has transactions. Migrate or disable it first.',
      'migration_title': 'Move account data',
      'migration_subtitle':
          'Select source and destination accounts to transfer history.',
      'migration_source': 'Source Account',
      'migration_target': 'Target Account',
      'migration_summary': 'Migration Summary',
      'migration_warning':
          'Once migrated, transactions cannot be automatically restored to the original account.',
      'migration_help_title': 'Migration Help',
      'migration_help_body':
          'Choose a source and target account. Review counts before confirming.',
      'migration_confirm_body': 'Migration is irreversible. Continue?',
      'migration_done': 'Migration complete',
      'start_migration': 'Start Migration',
      'last_migration': 'Last migration',
      'never': 'Never',
      'search_categories_tags': 'Search categories & tags',
      'frequent': 'Frequent',
      'no_data': 'No data',
      'all_categories': 'All Categories',
      'swipe_hint': 'Swipe left on a category to merge or disable',
      'records_label': 'records',
      'merge_category': 'Merge category',
      'disable_category': 'Disable category',
      'edit_category': 'Edit category',
      'no_merge_target': 'No merge target available',
      'add_tag': 'Add tag',
      'tag_name': 'Tag name',
      'category_name': 'Category name',
      'popular_tags': 'Popular Tags',
      'new_tag': 'New Tag',
      'all': 'All',
      'active': 'Active',
      'paused': 'Paused',
      'pending': 'Pending',
      'pending_confirm': 'Pending Confirmation',
      'no_recurring': 'No recurring tasks yet',
      'add_recurring': 'Add recurring task',
      'recurring_placeholder':
          'Recurring task creation is available in the next step.',
      'recurring_task': 'Recurring task',
      'alerts_reminders': 'Alerts & Reminders',
      'daily_reminders': 'Daily Reminders',
      'daily_reminders_desc': 'Summary of spending',
      'schedule': 'Schedule',
      'system_permissions': 'System Permissions',
      'status_enabled': 'Status: Enabled',
      'status_disabled': 'Status: Disabled',
      'dnd_title': 'Do Not Disturb',
      'dnd_subtitle': 'Mute notifications during sleep',
      'from': 'From',
      'to': 'To',
      'appearance_label': 'Appearance',
      'formatting_label': 'Formatting',
      'live_preview': 'LIVE PREVIEW',
      'decimal_places_label': 'Decimal Places',
      'week_start_label': 'Week Starts On',
      'week_start_monday': 'Monday',
      'week_start_sunday': 'Sunday',
      'font_size_label': 'Font Size',
      'font_scale_small': 'Small',
      'font_scale_default': 'Default',
      'font_scale_large': 'Large',
      'language_label': 'Language',
      'app_language_label': 'App Language',
      'backup_status': 'Backup Status',
      'last_backup': 'Last Backup',
      'next_scheduled': 'Next Scheduled',
      'backup_next_time': 'Tomorrow, 3:00 AM',
      'quick_actions': 'Quick Actions',
      'backup_format_info':
          'Import files must be .json or .csv. Encrypted backups require a password.',
      'local_backups': 'Local Backups',
      'backup_footer': 'Backups are stored locally on your device.',
      'backup_restore_subtitle': 'Export & import local files',
      'export_data': 'Export Data',
      'export_data_subtitle': 'CSV/PDF/XLS reports',
      'export_title': 'Export Reports',
      'export_subtitle': 'Select date range and format for your report.',
      'custom': 'Custom',
      'file_name': 'File Name',
      'export_settings': 'Export Settings',
      'edit_columns': 'Edit Columns',
      'columns_preview': 'Columns Preview',
      'export_to_file': 'Export to File',
      'more_rows': '+ 45 more rows',
      'export_data_label': 'Export Data',
      'security_privacy': 'Security & Privacy',
      'security_privacy_subtitle': 'PIN, biometrics, privacy',
      'security_hero_title': 'Protect your account',
      'security_hero_subtitle':
          'Manage security preferences and privacy settings.',
      'security_level': 'Security Level',
      'security_level_high': 'High',
      'app_access': 'App Access',
      'biometric_unlock': 'Biometric Unlock',
      'biometric_unlock_desc': 'Use FaceID or TouchID',
      'content_protection': 'Content Protection',
      'screenshot_protection': 'Screenshot Protection',
      'screenshot_protection_desc': 'Prevents screen capture',
      'legal_info': 'Legal & Info',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',
      'offline_policy_note':
          'This is an offline app. Policy content is stored locally.',
      'storage_cleanup': 'Storage & Data',
      'storage_cleanup_subtitle': 'Cache and data cleanup',
      'storage_details': 'Details',
      'storage_used': '17 MB Used',
      'storage_used_desc': 'Total space used by temporary files and cache.',
      'cache': 'Cache',
      'cache_desc': 'Images and api responses',
      'temp_files': 'Temporary Files',
      'temp_files_desc': 'Logs and session data',
      'clear_cache': 'Clear Cache',
      'cache_cleared': 'Cache cleared',
      'clear_all_note': 'Clearing all data will reset the app.',
      'confirm_identity': 'Confirm Identity',
      'confirm_identity_desc': 'Enter PIN to confirm deletion of all app data.',
      'clear_all_done': 'All data cleared',
      'version': 'Version',
      'release_notes': 'Release Notes',
      'version_value': 'Final V1 (offline)',
      'release_notes_value': 'Core offline ledger features.',
      'copy_diagnostics': 'Copy diagnostic info',
      'more': 'More',
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
      'expense_breakdown': '支出分类',
      'income_breakdown': '收入分类',
      'expense_ranking': '支出排行',
      'income_ranking': '收入排行',
      'trend_income': '收入',
      'trend_expense': '支出',
      'trend_net': '净资产',
      'custom_range': '自定义区间',
      'select_year': '选择年份',
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
      'help': '帮助',
      'date': '日期',
      'display_localization': '显示与本地化',
      'accounts_bank_section': '银行卡',
      'accounts_credit_section': '信用卡',
      'accounts_cash_section': '现金',
      'add_new_account': '新增账户',
      'edit_account': '编辑账户',
      'account_name': '账户名称',
      'account_name_hint': '例如：招商储蓄',
      'account_note': '账户备注',
      'account_note_hint': '例如：**** 4829',
      'opening_balance': '初始余额',
      'account_type': '账户类型',
      'account_type_bank': '银行卡',
      'account_type_credit': '信用卡',
      'account_type_cash': '现金',
      'account_types': '账户类型',
      'add_account_type': '新增账户类型',
      'edit_account_type': '编辑账户类型',
      'account_type_name': '类型名称',
      'no_account_types': '暂无账户类型',
      'account_type_delete_blocked': '该类型已被账户使用，无法删除。',
      'account_nature_bank': '银行卡',
      'account_nature_credit': '信用卡',
      'account_nature_loan': '贷款',
      'account_nature_asset': '其他资产',
      'account_nature_liability': '其他负债',
      'select_icon': '选择图标',
      'account_note_empty': '暂无备注',
      'custom_type': '自定义类型',
      'custom_type_hint': '例如：数字钱包',
      'account_icon': '账户图标',
      'accounts_other_section': '其他资产',
      'card_number': '卡号',
      'card_number_hint': '例如：**** 4829',
      'billing_day': '账单日',
      'billing_day_hint': '1-31',
      'repayment_day': '还款日',
      'repayment_day_hint': '1-31',
      'migration_type_mismatch': '只能合并同类型账户。',
      'migration_history_title': '迁移历史',
      'migration_history_empty': '暂无迁移记录',
      'empty_accounts': '暂无账户',
      'account_migration': '账户迁移',
      'account_migration_desc': '批量迁移历史账单',
      'account_delete_blocked_title': '无法删除',
      'account_delete_blocked_body': '该账户存在账单，请先迁移或禁用。',
      'migration_title': '迁移账户数据',
      'migration_subtitle': '选择源账户与目标账户以转移历史记录。',
      'migration_source': '源账户',
      'migration_target': '目标账户',
      'migration_summary': '迁移摘要',
      'migration_warning': '迁移后不可撤销，请确认选择。',
      'migration_help_title': '迁移说明',
      'migration_help_body': '选择源与目标账户，确认影响条数后执行。',
      'migration_confirm_body': '迁移不可逆，是否继续？',
      'migration_done': '迁移完成',
      'start_migration': '开始迁移',
      'last_migration': '上次迁移',
      'never': '从未',
      'search_categories_tags': '搜索分类与标签',
      'frequent': '常用',
      'no_data': '暂无数据',
      'all_categories': '全部分类',
      'swipe_hint': '左滑分类可合并或禁用',
      'records_label': '条记录',
      'merge_category': '合并分类',
      'disable_category': '禁用分类',
      'edit_category': '编辑分类',
      'no_merge_target': '暂无可合并分类',
      'add_tag': '新增标签',
      'tag_name': '标签名称',
      'category_name': '分类名称',
      'popular_tags': '热门标签',
      'new_tag': '新标签',
      'all': '全部',
      'active': '启用中',
      'paused': '已暂停',
      'pending': '待确认',
      'pending_confirm': '待确认',
      'no_recurring': '暂无周期任务',
      'add_recurring': '新增周期任务',
      'recurring_placeholder': '周期任务创建将在下一步完善。',
      'recurring_task': '周期任务',
      'alerts_reminders': '提醒与通知',
      'daily_reminders': '每日提醒',
      'daily_reminders_desc': '每日支出摘要',
      'schedule': '时间安排',
      'system_permissions': '系统通知权限',
      'status_enabled': '状态：已开启',
      'status_disabled': '状态：未开启',
      'dnd_title': '免打扰',
      'dnd_subtitle': '睡眠时段不打扰',
      'from': '从',
      'to': '到',
      'appearance_label': '外观',
      'formatting_label': '格式',
      'live_preview': '实时预览',
      'decimal_places_label': '小数位数',
      'week_start_label': '周起始日',
      'week_start_monday': '周一',
      'week_start_sunday': '周日',
      'font_size_label': '字体大小',
      'font_scale_small': '小',
      'font_scale_default': '标准',
      'font_scale_large': '大',
      'language_label': '语言',
      'app_language_label': '应用语言',
      'backup_status': '备份状态',
      'last_backup': '最近备份',
      'next_scheduled': '下次计划',
      'backup_next_time': '明天 03:00',
      'quick_actions': '快捷操作',
      'backup_format_info': '仅支持 .json 或 .csv，若为加密备份需输入密码。',
      'local_backups': '本地备份',
      'backup_footer': '备份文件仅保存在本地设备。',
      'backup_restore_subtitle': '导出与导入本地文件',
      'export_data': '导出报表',
      'export_data_subtitle': 'CSV/PDF/XLS 报表',
      'export_title': '导出报表',
      'export_subtitle': '选择时间范围与导出格式。',
      'custom': '自定义',
      'file_name': '文件名称',
      'export_settings': '导出设置',
      'edit_columns': '编辑列',
      'columns_preview': '列预览',
      'export_to_file': '导出到文件',
      'more_rows': '+ 45 行',
      'export_data_label': '导出报表',
      'security_privacy': '安全与隐私',
      'security_privacy_subtitle': 'PIN、生物识别与隐私',
      'security_hero_title': '保护你的账户',
      'security_hero_subtitle': '管理安全偏好与隐私设置。',
      'security_level': '安全等级',
      'security_level_high': '高',
      'app_access': '应用访问',
      'biometric_unlock': '生物识别解锁',
      'biometric_unlock_desc': '使用面容或指纹解锁',
      'content_protection': '内容保护',
      'screenshot_protection': '截屏保护',
      'screenshot_protection_desc': '阻止屏幕截图',
      'legal_info': '法律与说明',
      'privacy_policy': '隐私政策',
      'terms_of_service': '服务条款',
      'offline_policy_note': '离线版本，政策内容存于本地。',
      'storage_cleanup': '存储与数据清理',
      'storage_cleanup_subtitle': '缓存与数据管理',
      'storage_details': '详情',
      'storage_used': '已使用 17 MB',
      'storage_used_desc': '临时文件与缓存占用空间。',
      'cache': '缓存',
      'cache_desc': '图片与接口响应',
      'temp_files': '临时文件',
      'temp_files_desc': '日志与会话数据',
      'clear_cache': '清理缓存',
      'cache_cleared': '缓存已清理',
      'clear_all_note': '清空数据将重置应用。',
      'confirm_identity': '确认身份',
      'confirm_identity_desc': '输入 PIN 确认清空数据。',
      'clear_all_done': '已清空所有数据',
      'version': '版本',
      'release_notes': '更新日志',
      'version_value': 'Final V1（离线版）',
      'release_notes_value': '完整离线记账能力。',
      'copy_diagnostics': '复制诊断信息',
      'more': '更多',
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
  String get expenseBreakdown => _value('expense_breakdown');
  String get incomeBreakdown => _value('income_breakdown');
  String get expenseRanking => _value('expense_ranking');
  String get incomeRanking => _value('income_ranking');
  String get trendIncome => _value('trend_income');
  String get trendExpense => _value('trend_expense');
  String get trendNet => _value('trend_net');
  String get customRange => _value('custom_range');
  String get selectYear => _value('select_year');
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
  String get help => _value('help');
  String get date => _value('date');
  String get displayLocalization => _value('display_localization');
  String get accountsBankSection => _value('accounts_bank_section');
  String get accountsCreditSection => _value('accounts_credit_section');
  String get accountsCashSection => _value('accounts_cash_section');
  String get addNewAccount => _value('add_new_account');
  String get editAccount => _value('edit_account');
  String get accountName => _value('account_name');
  String get accountNameHint => _value('account_name_hint');
  String get accountNote => _value('account_note');
  String get accountNoteHint => _value('account_note_hint');
  String get openingBalance => _value('opening_balance');
  String get accountType => _value('account_type');
  String get accountTypeBank => _value('account_type_bank');
  String get accountTypeCredit => _value('account_type_credit');
  String get accountTypeCash => _value('account_type_cash');
  String get accountTypes => _value('account_types');
  String get addAccountType => _value('add_account_type');
  String get editAccountType => _value('edit_account_type');
  String get accountTypeName => _value('account_type_name');
  String get noAccountTypes => _value('no_account_types');
  String get accountTypeDeleteBlocked => _value('account_type_delete_blocked');
  String get accountNatureBank => _value('account_nature_bank');
  String get accountNatureCredit => _value('account_nature_credit');
  String get accountNatureLoan => _value('account_nature_loan');
  String get accountNatureAsset => _value('account_nature_asset');
  String get accountNatureLiability => _value('account_nature_liability');
  String get selectIcon => _value('select_icon');
  String get accountNoteEmpty => _value('account_note_empty');
  String get customType => _value('custom_type');
  String get customTypeHint => _value('custom_type_hint');
  String get accountIcon => _value('account_icon');
  String get accountsOtherSection => _value('accounts_other_section');
  String get cardNumber => _value('card_number');
  String get cardNumberHint => _value('card_number_hint');
  String get billingDay => _value('billing_day');
  String get billingDayHint => _value('billing_day_hint');
  String get repaymentDay => _value('repayment_day');
  String get repaymentDayHint => _value('repayment_day_hint');
  String get migrationTypeMismatch => _value('migration_type_mismatch');
  String get migrationHistoryTitle => _value('migration_history_title');
  String get migrationHistoryEmpty => _value('migration_history_empty');

  String migrationHistoryItem(
    String date,
    String source,
    String target,
    String count,
  ) {
    if (locale.languageCode == 'zh') {
      return '$date：$source → $target（$count 条）';
    }
    return '$date: $source → $target ($count)';
  }
  String get emptyAccounts => _value('empty_accounts');
  String get accountMigration => _value('account_migration');
  String get accountMigrationDesc => _value('account_migration_desc');
  String get accountDeleteBlockedTitle =>
      _value('account_delete_blocked_title');
  String get accountDeleteBlockedBody => _value('account_delete_blocked_body');
  String get migrationTitle => _value('migration_title');
  String get migrationSubtitle => _value('migration_subtitle');
  String get migrationSource => _value('migration_source');
  String get migrationTarget => _value('migration_target');
  String get migrationSummary => _value('migration_summary');
  String get migrationWarning => _value('migration_warning');
  String get migrationHelpTitle => _value('migration_help_title');
  String get migrationHelpBody => _value('migration_help_body');
  String get migrationConfirmBody => _value('migration_confirm_body');
  String get migrationDone => _value('migration_done');
  String get startMigration => _value('start_migration');
  String get lastMigrationLabel => _value('last_migration');
  String get never => _value('never');
  String get searchCategoriesTags => _value('search_categories_tags');
  String get frequent => _value('frequent');
  String get noData => _value('no_data');
  String get allCategories => _value('all_categories');
  String get swipeHint => _value('swipe_hint');
  String get recordsLabel => _value('records_label');
  String get mergeCategory => _value('merge_category');
  String get disableCategory => _value('disable_category');
  String get editCategory => _value('edit_category');
  String get noMergeTarget => _value('no_merge_target');
  String get addTag => _value('add_tag');
  String get tagName => _value('tag_name');
  String get categoryName => _value('category_name');
  String get popularTags => _value('popular_tags');
  String get newTag => _value('new_tag');
  String get all => _value('all');
  String get active => _value('active');
  String get paused => _value('paused');
  String get pending => _value('pending');
  String get pendingConfirm => _value('pending_confirm');
  String get noRecurring => _value('no_recurring');
  String get addRecurring => _value('add_recurring');
  String get recurringPlaceholder => _value('recurring_placeholder');
  String get recurringTask => _value('recurring_task');
  String get alertsReminders => _value('alerts_reminders');
  String get dailyReminders => _value('daily_reminders');
  String get dailyRemindersDesc => _value('daily_reminders_desc');
  String get schedule => _value('schedule');
  String get systemPermissions => _value('system_permissions');
  String get statusEnabled => _value('status_enabled');
  String get statusDisabled => _value('status_disabled');
  String get dndTitle => _value('dnd_title');
  String get dndSubtitle => _value('dnd_subtitle');
  String get from => _value('from');
  String get to => _value('to');
  String get appearanceLabel => _value('appearance_label');
  String get formattingLabel => _value('formatting_label');
  String get livePreview => _value('live_preview');
  String get decimalPlacesLabel => _value('decimal_places_label');
  String get weekStartLabel => _value('week_start_label');
  String get weekStartMonday => _value('week_start_monday');
  String get weekStartSunday => _value('week_start_sunday');
  String get fontSizeLabel => _value('font_size_label');
  String get fontScaleSmall => _value('font_scale_small');
  String get fontScaleDefault => _value('font_scale_default');
  String get fontScaleLarge => _value('font_scale_large');
  String get languageLabel => _value('language_label');
  String get appLanguageLabel => _value('app_language_label');
  String get backupStatus => _value('backup_status');
  String get lastBackup => _value('last_backup');
  String get nextScheduled => _value('next_scheduled');
  String get backupNextTime => _value('backup_next_time');
  String get quickActions => _value('quick_actions');
  String get backupFormatInfo => _value('backup_format_info');
  String get localBackups => _value('local_backups');
  String get backupFooter => _value('backup_footer');
  String get backupRestoreSubtitle => _value('backup_restore_subtitle');
  String get exportData => _value('export_data');
  String get exportDataSubtitle => _value('export_data_subtitle');
  String get exportTitle => _value('export_title');
  String get exportSubtitle => _value('export_subtitle');
  String get custom => _value('custom');
  String get fileName => _value('file_name');
  String get exportSettings => _value('export_settings');
  String get editColumns => _value('edit_columns');
  String get columnsPreview => _value('columns_preview');
  String get exportToFile => _value('export_to_file');
  String get moreRows => _value('more_rows');
  String get securityPrivacy => _value('security_privacy');
  String get securityPrivacySubtitle => _value('security_privacy_subtitle');
  String get securityHeroTitle => _value('security_hero_title');
  String get securityHeroSubtitle => _value('security_hero_subtitle');
  String get securityLevel => _value('security_level');
  String get securityLevelHigh => _value('security_level_high');
  String get appAccess => _value('app_access');
  String get biometricUnlock => _value('biometric_unlock');
  String get biometricUnlockDesc => _value('biometric_unlock_desc');
  String get contentProtection => _value('content_protection');
  String get screenshotProtection => _value('screenshot_protection');
  String get screenshotProtectionDesc => _value('screenshot_protection_desc');
  String get legalInfo => _value('legal_info');
  String get privacyPolicy => _value('privacy_policy');
  String get termsOfService => _value('terms_of_service');
  String get offlinePolicyNote => _value('offline_policy_note');
  String get storageCleanup => _value('storage_cleanup');
  String get storageCleanupSubtitle => _value('storage_cleanup_subtitle');
  String get storageDetails => _value('storage_details');
  String get storageUsed => _value('storage_used');
  String get storageUsedDesc => _value('storage_used_desc');
  String get cache => _value('cache');
  String get cacheDesc => _value('cache_desc');
  String get tempFiles => _value('temp_files');
  String get tempFilesDesc => _value('temp_files_desc');
  String get clearCache => _value('clear_cache');
  String get cacheCleared => _value('cache_cleared');
  String get clearAllNote => _value('clear_all_note');
  String get confirmIdentity => _value('confirm_identity');
  String get confirmIdentityDesc => _value('confirm_identity_desc');
  String get clearAllDone => _value('clear_all_done');
  String get version => _value('version');
  String get releaseNotes => _value('release_notes');
  String get versionValue => _value('version_value');
  String get releaseNotesValue => _value('release_notes_value');
  String get copyDiagnostics => _value('copy_diagnostics');
  String get more => _value('more');

  String migrationSummaryBody(int count, String source, String target) {
    if (locale.languageCode == 'zh') {
      return '将 $count 条账单从 $source 迁移至 $target。';
    }
    return '$count transactions will be moved from $source to $target.';
  }

  String lastMigration(String date) {
    if (locale.languageCode == 'zh') {
      return '上次迁移：$date';
    }
    return 'Last migration: $date';
  }

  String backupItemSubtitle(String date, String size) {
    if (locale.languageCode == 'zh') {
      return '$date • $size';
    }
    return '$date • $size';
  }

  String recurringNext(String date) {
    if (locale.languageCode == 'zh') {
      return '下次：$date';
    }
    return 'Next: $date';
  }

  String decimalDigits(int digits) {
    if (locale.languageCode == 'zh') {
      return '$digits 位小数';
    }
    return '$digits Digits';
  }

  String fontScaleLabel(double value) {
    if (value <= 0.95) return fontScaleSmall;
    if (value >= 1.05) return fontScaleLarge;
    return fontScaleDefault;
  }

  String languageLabelValue(String value) {
    if (value == 'zh_CN') return '简体中文';
    if (value == 'en_US') return 'English (US)';
    return themeSystem;
  }

  List<String> get weekLabels {
    if (locale.languageCode == 'zh') {
      return const ['日', '一', '二', '三', '四', '五', '六'];
    }
    return const ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  }
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
