enum TransactionType { expense, income, transfer }

enum AccountType { cash, debitCard, creditCard, bank, other }

enum AccountNature { bank, credit, loan, asset, liability }

class AccountTypeOption {
  AccountTypeOption({
    required this.id,
    required this.name,
    required this.nature,
  });

  final String id;
  final String name;
  final AccountNature nature;
}

extension AccountTypeOptionMapping on AccountTypeOption {
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'nature': nature.name,
      };

  static AccountTypeOption fromMap(Map<String, dynamic> map) {
    return AccountTypeOption(
      id: map['id'] as String,
      name: map['name'] as String,
      nature: AccountNature.values.firstWhere(
        (e) => e.name == map['nature'],
        orElse: () => AccountNature.asset,
      ),
    );
  }
}

enum CategoryType { expense, income }

class Account {
  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.nature,
    required this.openingBalance,
    this.note,
    this.enabled = true,
    this.sortOrder = 0,
    this.iconCode,
    this.customType,
    this.cardNumber,
    this.billingDay,
    this.repaymentDay,
  });

  final String id;
  final String name;
  final AccountType type;
  final AccountNature nature;
  final double openingBalance;
  final String? note;
  final bool enabled;
  final int sortOrder;
  final int? iconCode;
  final String? customType;
  final String? cardNumber;
  final int? billingDay;
  final int? repaymentDay;
}

extension AccountMapping on Account {
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type.name,
        'nature': nature.name,
        'opening_balance': openingBalance,
        'note': note,
        'enabled': enabled ? 1 : 0,
        'sort_order': sortOrder,
        'icon_code': iconCode,
        'custom_type': customType,
        'card_number': cardNumber,
        'billing_day': billingDay,
        'repayment_day': repaymentDay,
      };

  static Account fromMap(Map<String, dynamic> map) {
    final accountType =
        AccountType.values.firstWhere((e) => e.name == map['type']);
    final natureName = map['nature']?.toString();
    AccountNature? nature;
    if (natureName != null) {
      for (final item in AccountNature.values) {
        if (item.name == natureName) {
          nature = item;
          break;
        }
      }
    }
    nature ??= _inferNatureFromType(accountType);
    return Account(
      id: map['id'] as String,
      name: map['name'] as String,
      type: accountType,
      nature: nature,
      openingBalance: (map['opening_balance'] as num).toDouble(),
      note: map['note'] as String?,
      enabled: (map['enabled'] as num) == 1,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
      iconCode: (map['icon_code'] as num?)?.toInt(),
      customType: map['custom_type'] as String?,
      cardNumber: map['card_number'] as String?,
      billingDay: (map['billing_day'] as num?)?.toInt(),
      repaymentDay: (map['repayment_day'] as num?)?.toInt(),
    );
  }
}

AccountNature _inferNatureFromType(AccountType type) {
  switch (type) {
    case AccountType.bank:
    case AccountType.debitCard:
      return AccountNature.bank;
    case AccountType.creditCard:
      return AccountNature.credit;
    case AccountType.cash:
      return AccountNature.asset;
    case AccountType.other:
      return AccountNature.asset;
  }
}

class Category {
  Category({
    required this.id,
    required this.type,
    required this.name,
    required this.icon,
    required this.colorHex,
    this.enabled = true,
    this.sortOrder = 0,
  });

  final String id;
  final CategoryType type;
  final String name;
  final int icon;
  final int colorHex;
  final bool enabled;
  final int sortOrder;
}

extension CategoryMapping on Category {
  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'name': name,
        'icon': icon,
        'color_hex': colorHex,
        'enabled': enabled ? 1 : 0,
        'sort_order': sortOrder,
      };

  static Category fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      type: CategoryType.values.firstWhere((e) => e.name == map['type']),
      name: map['name'] as String,
      icon: map['icon'] as int,
      colorHex: map['color_hex'] as int,
      enabled: (map['enabled'] as num) == 1,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

class TransactionRecord {
  TransactionRecord({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.accountId,
    this.transferInAccountId,
    required this.occurredAt,
    this.note,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final String? categoryId;
  final String accountId;
  final String? transferInAccountId;
  final DateTime occurredAt;
  final String? note;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionRecord copyWith({
    TransactionType? type,
    double? amount,
    String? categoryId,
    String? accountId,
    String? transferInAccountId,
    DateTime? occurredAt,
    String? note,
    List<String>? tags,
  }) {
    return TransactionRecord(
      id: id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      transferInAccountId: transferInAccountId ?? this.transferInAccountId,
      occurredAt: occurredAt ?? this.occurredAt,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

extension TransactionMapping on TransactionRecord {
  Map<String, dynamic> toMap({required String tagsJson}) => {
        'id': id,
        'type': type.name,
        'amount': amount,
        'category_id': categoryId,
        'account_id': accountId,
        'transfer_in_account_id': transferInAccountId,
        'occurred_at': occurredAt.toIso8601String(),
        'note': note,
        'tags': tagsJson,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static TransactionRecord fromMap(Map<String, dynamic> map, List<String> tags) {
    return TransactionRecord(
      id: map['id'] as String,
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['category_id'] as String?,
      accountId: map['account_id'] as String,
      transferInAccountId: map['transfer_in_account_id'] as String?,
      occurredAt: DateTime.parse(map['occurred_at'] as String),
      note: map['note'] as String?,
      tags: tags,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class Budget {
  Budget({
    required this.id,
    required this.month,
    required this.totalAmount,
    required this.warningThreshold,
  });

  final String id;
  final DateTime month;
  final double totalAmount;
  final double warningThreshold;
}

extension BudgetMapping on Budget {
  Map<String, dynamic> toMap() => {
        'id': id,
        'month': month.toIso8601String(),
        'total_amount': totalAmount,
        'warning_threshold': warningThreshold,
      };

  static Budget fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as String,
      month: DateTime.parse(map['month'] as String),
      totalAmount: (map['total_amount'] as num).toDouble(),
      warningThreshold: (map['warning_threshold'] as num).toDouble(),
    );
  }
}

class RecurringTask {
  RecurringTask({
    required this.id,
    required this.templateBill,
    required this.rule,
    required this.nextRunAt,
    required this.autoGenerate,
    required this.enabled,
  });

  final String id;
  final TransactionRecord templateBill;
  final String rule;
  final DateTime nextRunAt;
  final bool autoGenerate;
  final bool enabled;
}

extension RecurringTaskMapping on RecurringTask {
  Map<String, dynamic> toMap(String templateJson) => {
        'id': id,
        'template_json': templateJson,
        'rule': rule,
        'next_run_at': nextRunAt.toIso8601String(),
        'auto_generate': autoGenerate ? 1 : 0,
        'enabled': enabled ? 1 : 0,
      };

  static RecurringTask fromMap(
    Map<String, dynamic> map,
    TransactionRecord template,
  ) {
    return RecurringTask(
      id: map['id'] as String,
      templateBill: template,
      rule: map['rule'] as String,
      nextRunAt: DateTime.parse(map['next_run_at'] as String),
      autoGenerate: (map['auto_generate'] as num) == 1,
      enabled: (map['enabled'] as num) == 1,
    );
  }
}
