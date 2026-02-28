import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../providers/app_providers.dart';

class AddEditTransactionArgs {
  const AddEditTransactionArgs({
    required this.record,
    required this.isCopy,
  });

  final TransactionRecord? record;
  final bool isCopy;

  @override
  bool operator ==(Object other) {
    return other is AddEditTransactionArgs &&
        other.record?.id == record?.id &&
        other.isCopy == isCopy;
  }

  @override
  int get hashCode => Object.hash(record?.id, isCopy);
}

class AddEditTransactionState {
  const AddEditTransactionState({
    required this.type,
    required this.amountInput,
    required this.showKeypad,
    required this.occurredAt,
    required this.categoryId,
    required this.accountId,
    required this.transferInAccountId,
    required this.selectedTags,
    required this.defaultsApplied,
  });

  factory AddEditTransactionState.initial(TransactionRecord? record) {
    return AddEditTransactionState(
      type: record?.type ?? TransactionType.expense,
      amountInput: record == null ? '' : record.amount.toStringAsFixed(2),
      showKeypad: true,
      occurredAt: record?.occurredAt ?? DateTime.now(),
      categoryId: record?.categoryId,
      accountId: record?.accountId,
      transferInAccountId: record?.transferInAccountId,
      selectedTags: record == null ? const [] : List.of(record.tags),
      defaultsApplied: false,
    );
  }

  final TransactionType type;
  final String amountInput;
  final bool showKeypad;
  final DateTime occurredAt;
  final String? categoryId;
  final String? accountId;
  final String? transferInAccountId;
  final List<String> selectedTags;
  final bool defaultsApplied;

  double get amountValue => double.tryParse(amountInput) ?? 0;

  AddEditTransactionState copyWith({
    TransactionType? type,
    String? amountInput,
    bool? showKeypad,
    DateTime? occurredAt,
    Object? categoryId = _sentinel,
    Object? accountId = _sentinel,
    Object? transferInAccountId = _sentinel,
    List<String>? selectedTags,
    bool? defaultsApplied,
  }) {
    return AddEditTransactionState(
      type: type ?? this.type,
      amountInput: amountInput ?? this.amountInput,
      showKeypad: showKeypad ?? this.showKeypad,
      occurredAt: occurredAt ?? this.occurredAt,
      categoryId: categoryId == _sentinel ? this.categoryId : categoryId as String?,
      accountId: accountId == _sentinel ? this.accountId : accountId as String?,
      transferInAccountId: transferInAccountId == _sentinel
          ? this.transferInAccountId
          : transferInAccountId as String?,
      selectedTags: selectedTags ?? this.selectedTags,
      defaultsApplied: defaultsApplied ?? this.defaultsApplied,
    );
  }
}

const _sentinel = Object();

enum SaveTransactionResult {
  invalid,
  savedAndContinue,
  savedAndClose,
}

class AddEditTransactionController extends StateNotifier<AddEditTransactionState> {
  AddEditTransactionController({
    required Ref ref,
    required this.args,
  })  : _ref = ref,
        super(AddEditTransactionState.initial(args.record)) {
    _applyDefaults();
  }

  final Ref _ref;
  final AddEditTransactionArgs args;

  AppState get _appState => _ref.read(appStateProvider);

  bool get canSave {
    if (state.amountValue <= 0) return false;
    if (state.type == TransactionType.transfer) {
      return state.accountId != null &&
          state.transferInAccountId != null &&
          state.accountId != state.transferInAccountId;
    }
    return state.accountId != null && state.categoryId != null;
  }

  void _applyDefaults() {
    if (state.defaultsApplied) return;
    final accounts = _appState.accounts;
    var next = state;
    if (next.accountId == null && accounts.isNotEmpty) {
      next = next.copyWith(accountId: accounts.first.id);
    }
    if (next.type == TransactionType.transfer &&
        next.transferInAccountId == null &&
        accounts.length > 1) {
      final target = accounts.firstWhere(
        (acc) => acc.id != next.accountId,
        orElse: () => accounts.first,
      );
      if (target.id != next.accountId) {
        next = next.copyWith(transferInAccountId: target.id);
      }
    }
    state = next.copyWith(defaultsApplied: true);
  }

  void setType(TransactionType type) {
    var next = state.copyWith(type: type);
    if (type == TransactionType.transfer) {
      next = next.copyWith(categoryId: null);
      final accounts = _appState.accounts;
      if (accounts.isNotEmpty &&
          (next.transferInAccountId == null || next.transferInAccountId == next.accountId)) {
        final target = accounts.firstWhere(
          (acc) => acc.id != next.accountId,
          orElse: () => accounts.first,
        );
        if (target.id != next.accountId) {
          next = next.copyWith(transferInAccountId: target.id);
        }
      }
    }
    state = next;
  }

  void appendAmount(String value) {
    var amountInput = state.amountInput;
    if (value == '.') {
      if (amountInput.contains('.')) {
        amountInput = state.amountValue.toStringAsFixed(0);
      }
      amountInput = amountInput.isEmpty ? '0.' : '$amountInput.';
      state = state.copyWith(amountInput: amountInput);
      return;
    }
    if (RegExp(r'^\d+\.\d{2}$').hasMatch(amountInput)) {
      return;
    }
    if (value == '00') {
      if (amountInput.isEmpty) return;
      amountInput += '00';
      state = state.copyWith(amountInput: amountInput);
      return;
    }
    if (amountInput == '0') {
      amountInput = value;
    } else {
      amountInput += value;
    }
    state = state.copyWith(amountInput: amountInput);
  }

  void backspace() {
    final amountInput = state.amountInput;
    if (amountInput.isEmpty) return;
    state = state.copyWith(amountInput: amountInput.substring(0, amountInput.length - 1));
  }

  void toggleKeypad() {
    state = state.copyWith(showKeypad: !state.showKeypad);
  }

  void hideKeypad() {
    state = state.copyWith(showKeypad: false);
  }

  void clearAmount() {
    state = state.copyWith(amountInput: '0');
  }

  void setOccurredAt(DateTime value) {
    state = state.copyWith(occurredAt: value);
  }

  void setCategory(String value) {
    state = state.copyWith(categoryId: value);
  }

  void setAccount(String value) {
    var next = state.copyWith(accountId: value);
    if (next.type == TransactionType.transfer && next.transferInAccountId == value) {
      final accounts = _appState.accounts;
      if (accounts.isEmpty) {
        state = next;
        return;
      }
      final fallback = accounts.firstWhere(
        (acc) => acc.id != value,
        orElse: () => accounts.first,
      );
      if (fallback.id != value) {
        next = next.copyWith(transferInAccountId: fallback.id);
      }
    }
    state = next;
  }

  void setTransferInAccount(String value) {
    state = state.copyWith(transferInAccountId: value);
  }

  void setTags(List<String> tags) {
    state = state.copyWith(selectedTags: tags);
  }

  void removeTag(String tag) {
    final next = [...state.selectedTags]..remove(tag);
    state = state.copyWith(selectedTags: next);
  }

  List<Category> recentCategories(List<Category> categories, {int limit = 4}) {
    final lastUsed = <String, DateTime>{};
    for (final record in _appState.records) {
      if (record.categoryId == null) continue;
      if (state.type == TransactionType.income && record.type != TransactionType.income) {
        continue;
      }
      if (state.type == TransactionType.expense && record.type != TransactionType.expense) {
        continue;
      }
      lastUsed[record.categoryId!] = record.occurredAt;
    }

    final sorted = [...categories];
    sorted.sort((a, b) {
      final aDate = lastUsed[a.id];
      final bDate = lastUsed[b.id];
      if (aDate == null && bDate == null) {
        return a.sortOrder.compareTo(b.sortOrder);
      }
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    if (sorted.length <= limit) return sorted;
    final trimmed = sorted.take(limit).toList();
    if (state.categoryId != null && !trimmed.any((c) => c.id == state.categoryId)) {
      final selected = categories.firstWhere(
        (c) => c.id == state.categoryId,
        orElse: () => trimmed.first,
      );
      if (!trimmed.any((c) => c.id == selected.id)) {
        trimmed.removeLast();
        trimmed.add(selected);
      }
    }
    return trimmed;
  }

  SaveTransactionResult save({required String note, required bool keepAdding}) {
    if (!canSave) return SaveTransactionResult.invalid;

    final draft = TransactionRecord(
      id: args.record?.id ?? 'draft',
      type: state.type,
      amount: state.amountValue,
      categoryId: state.type == TransactionType.transfer ? null : state.categoryId,
      accountId: state.accountId!,
      transferInAccountId: state.type == TransactionType.transfer ? state.transferInAccountId : null,
      occurredAt: state.occurredAt,
      note: note.trim().isEmpty ? null : note.trim(),
      tags: state.selectedTags,
      createdAt: args.record?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (args.record == null || args.isCopy) {
      _appState.addRecord(draft);
    } else {
      _appState.updateRecord(draft);
    }

    if (keepAdding) {
      state = state.copyWith(amountInput: '');
      return SaveTransactionResult.savedAndContinue;
    }
    return SaveTransactionResult.savedAndClose;
  }
}

final addEditTransactionControllerProvider = StateNotifierProvider.autoDispose
    .family<AddEditTransactionController, AddEditTransactionState, AddEditTransactionArgs>(
  (ref, args) => AddEditTransactionController(ref: ref, args: args),
);

const addEditAccountIcons = [
  Symbols.account_balance_wallet,
  Symbols.account_balance,
  Symbols.credit_card,
  Symbols.savings,
  Symbols.payments,
];
