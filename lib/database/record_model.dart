class RecordModel {
  RecordModel(
      {this.id,
      this.date,
      this.amount = 0.00,
      this.type = '',
      this.typeId = '',
      this.account = '',
      this.accountId = '',
      this.parentTypeId = '',
      this.involves = const [],
      this.toAccount = '',
      this.toAccountId = '',
      this.project = '',
      this.desc = '',
      this.merchant = '',
      this.merchantId = ''}) {
    date ??= DateTime.now();
  }
  String? id;
  double? amount;
  DateTime? date;
  String? account;
  String? accountId;
  String? type;
  String? typeId;
  String? parentTypeId;
  List<String>? involves;
  String? toAccount;
  String? toAccountId;
  String? project;
  String? desc;
  String? merchant;
  String? merchantId;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['amount'] = amount;
    map['date'] = date;
    map['account'] = account;
    map['accountId'] = accountId;
    map['type'] = type;
    map['typeId'] = typeId;
    map['parentTypeId'] = parentTypeId;
    map['involves'] = involves?.join(',');
    map['toAccount'] = toAccount;
    map['toAccountId'] = toAccountId;
    map['project'] = project;
    map['desc'] = desc;
    map['merchant'] = merchant;
    map['merchantId'] = merchantId;
    return map;
  }

  RecordModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    amount = double.parse(
        map['amount'].toString() == 'null' ? '0.0' : map['amount'].toString());
    // date = DateTime.tryParse(
    //         map['date'].toString() == 'null' ? '' : map['date'].toString()) ??
    //     DateTime.now();
    account = map['account'] ?? '';
    accountId = map['accountId'] ?? '';
    type = map['type'] ?? '';
    typeId = map['typeId'] ?? '';
    parentTypeId = map['parentTypeId'] ?? '';
    involves = (map['involves'] ?? '')?.split(',');
    toAccount = map['toAccount'] ?? '';
    toAccountId = map['toAccountId'] ?? '';
    project = map['project'] ?? '';
    desc = map['desc'] ?? '';
    merchant = map['merchant'] ?? '';
    merchantId = map['merchantId'] ?? '';
  }

  update(Map<String, dynamic> map) {
    id = map['id'] ?? id;
    amount = double.tryParse(map['amount']) ?? amount;
    date = DateTime.tryParse(map['date']) ?? date;
    account = map['account'] ?? account;
    accountId = map['accountId'] ?? accountId;
    type = map['type'] ?? type;
    typeId = map['typeId'] ?? typeId;
    parentTypeId = map['parentTypeId'] ?? parentTypeId;
    involves = map['involves'].toString().isEmpty
        ? map['involves'].split(',')
        : <String>[];
    toAccount = map['toAccount'] ?? toAccount;
    toAccountId = map['toAccountId'] ?? toAccountId;
    project = map['project'] ?? project;
    desc = map['desc'] ?? desc;
    merchant = map['merchant'] ?? merchant;
    merchantId = map['merchantId'] ?? merchantId;
  }
}
