import '../../data/app_state.dart';
import '../../data/models.dart';

class AccountManagementController {
  const AccountManagementController(this._appState);

  final AppState _appState;

  List<Account> accountsByNature(AccountNature nature) {
    final list = _appState.accounts.where((item) => item.nature == nature).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  double get totalAssets => _appState.totalAssets();

  Future<void> updateAccountOrder(List<Account> ordered) {
    return _appState.updateAccountOrder(ordered);
  }

  Future<void> toggleAccountEnabled(String id, bool enabled) {
    return _appState.toggleAccountEnabled(id, enabled);
  }

  Future<bool> deleteAccount(String id) {
    return _appState.deleteAccount(id);
  }

  Future<void> addAccount({
    required String name,
    required AccountNature nature,
    required String accountTypeId,
    required double openingBalance,
    String? note,
    int? iconCode,
    String? cardNumber,
    int? billingDay,
    int? repaymentDay,
  }) {
    return _appState.addAccount(
      name: name,
      nature: nature,
      accountTypeId: accountTypeId,
      openingBalance: openingBalance,
      note: note,
      iconCode: iconCode,
      cardNumber: cardNumber,
      billingDay: billingDay,
      repaymentDay: repaymentDay,
    );
  }

  Future<void> updateAccount({
    required Account source,
    required String name,
    required AccountNature nature,
    required String accountTypeId,
    required double openingBalance,
    String? note,
    int? iconCode,
    String? cardNumber,
    int? billingDay,
    int? repaymentDay,
  }) {
    return _appState.updateAccount(Account(
      id: source.id,
      name: name,
      type: _mapNatureToAccountType(nature),
      nature: nature,
      openingBalance: openingBalance,
      note: note,
      enabled: source.enabled,
      sortOrder: source.sortOrder,
      iconCode: iconCode,
      customType: accountTypeId,
      cardNumber: cardNumber,
      billingDay: billingDay,
      repaymentDay: repaymentDay,
    ));
  }

  AccountType _mapNatureToAccountType(AccountNature nature) {
    switch (nature) {
      case AccountNature.bank:
        return AccountType.bank;
      case AccountNature.credit:
        return AccountType.creditCard;
      case AccountNature.loan:
        return AccountType.other;
      case AccountNature.asset:
        return AccountType.other;
      case AccountNature.liability:
        return AccountType.other;
    }
  }
}
