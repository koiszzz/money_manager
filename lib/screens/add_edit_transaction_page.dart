import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class AddEditTransactionPage extends StatefulWidget {
  const AddEditTransactionPage({super.key, this.record, this.isCopy = false});

  final TransactionRecord? record;
  final bool isCopy;

  @override
  State<AddEditTransactionPage> createState() => _AddEditTransactionPageState();
}

class _AddEditTransactionPageState extends State<AddEditTransactionPage> {
  late TransactionType _type;
  String _amountInput = '';
  bool _showKeypad = true;
  final TextEditingController _noteController = TextEditingController();
  DateTime _occurredAt = DateTime.now();
  String? _categoryId;
  String? _accountId;
  String? _transferInAccountId;
  List<String> _selectedTags = [];
  bool _defaultsApplied = false;

  @override
  void initState() {
    super.initState();
    _type = widget.record?.type ?? TransactionType.expense;

    if (widget.record != null) {
      final record = widget.record!;
      _amountInput = record.amount.toStringAsFixed(2);
      _noteController.text = record.note ?? '';
      _occurredAt = record.occurredAt;
      _categoryId = record.categoryId;
      _accountId = record.accountId;
      _transferInAccountId = record.transferInAccountId;
      _selectedTags = List.of(record.tags);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_defaultsApplied) return;
    final appState = context.read<AppState>();
    if (_accountId == null && appState.accounts.isNotEmpty) {
      _accountId = appState.accounts.first.id;
    }
    if (_type == TransactionType.transfer &&
        _transferInAccountId == null &&
        appState.accounts.length > 1) {
      final target = appState.accounts
          .firstWhere((acc) => acc.id != _accountId, orElse: () => appState.accounts.first);
      if (target.id != _accountId) {
        _transferInAccountId = target.id;
      }
    }
    _defaultsApplied = true;
  }

  double get _amountValue => double.tryParse(_amountInput) ?? 0;

  bool get _canSave {
    if (_amountValue <= 0) return false;
    if (_type == TransactionType.transfer) {
      return _accountId != null &&
          _transferInAccountId != null &&
          _accountId != _transferInAccountId;
    }
    return _accountId != null && _categoryId != null;
  }

  void _setType(TransactionType type) {
    setState(() {
      _type = type;
      if (_type == TransactionType.transfer) {
        _categoryId = null;
        final appState = context.read<AppState>();
        if (_transferInAccountId == null ||
            _transferInAccountId == _accountId) {
          final target = appState.accounts.firstWhere(
            (acc) => acc.id != _accountId,
            orElse: () => appState.accounts.first,
          );
          if (target.id != _accountId) {
            _transferInAccountId = target.id;
          }
        }
      }
    });
  }

  void _appendAmount(String value) {
    setState(() {
      if (value == '.') {
        if (_amountInput.contains('.')) {
          _amountInput = _amountValue.toStringAsFixed(0);
        }
        _amountInput = _amountInput.isEmpty ? '0.' : '$_amountInput.';
        return;
      }
      if (RegExp(r'^\d+\.\d{2}$').hasMatch(_amountInput)) {
        // 已有两位小数，不能再输入数字
        return;
      }
      if (value == '00') {
        if (_amountInput.isEmpty) return;
        _amountInput += '00';
        return;
      }
      if (_amountInput == '0') {
        _amountInput = value;
      } else {
        _amountInput += value;
      }
    });
  }

  void _backspace() {
    setState(() {
      if (_amountInput.isEmpty) return;
      _amountInput = _amountInput.substring(0, _amountInput.length - 1);
    });
  }

  void _toggleKeypad() {
    setState(() => _showKeypad = !_showKeypad);
  }

  void _clearAmount() {
    setState(() {
      _amountInput = '0';
    });
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() => _occurredAt = selected);
    }
  }

  void _save({required bool keepAdding}) {
    final strings = AppLocalizations.of(context);
    if (!_canSave) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.select)),
      );
      return;
    }
    final appState = context.read<AppState>();
    final draft = TransactionRecord(
      id: widget.record?.id ?? 'draft',
      type: _type,
      amount: _amountValue,
      categoryId: _type == TransactionType.transfer ? null : _categoryId,
      accountId: _accountId!,
      transferInAccountId:
          _type == TransactionType.transfer ? _transferInAccountId : null,
      occurredAt: _occurredAt,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      tags: _selectedTags,
      createdAt: widget.record?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.record == null || widget.isCopy) {
      appState.addRecord(draft);
    } else {
      appState.updateRecord(draft);
    }

    if (keepAdding) {
      setState(() {
        _amountInput = '';
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.save)));
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final appState = context.watch<AppState>();
    final allCategories = appState.categoriesByType(
      _type == TransactionType.income
          ? TransactionType.income
          : TransactionType.expense,
    );
    final recentCategories = _recentCategories(
      appState,
      allCategories,
      selectedId: _categoryId,
      limit: 4,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.addTransaction),
        actions: [
          IconButton(
            onPressed: _toggleKeypad,
            icon: Icon(_showKeypad ? Symbols.keyboard_hide : Symbols.keyboard),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(16, 12, 16, _showKeypad ? 240 : 16),
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    if (!_showKeypad) {
                      setState(() => _showKeypad = true);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    child: Column(
                      children: [
                        Text(strings.amount,
                            style: const TextStyle(color: AppTheme.textMuted)),
                        const SizedBox(height: 6),
                        Text(
                          Formatters.money(
                            _type == TransactionType.expense
                                ? -_amountValue
                                : _amountValue,
                            showSign: _type != TransactionType.transfer,
                            locale: locale,
                            currencyCode: appState.currencyCode,
                            decimalDigits: appState.decimalPlaces,
                          ),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _TypeTabs(
                type: _type,
                onChanged: _setType,
                strings: strings,
              ),
              const SizedBox(height: 16),
              if (_type != TransactionType.transfer) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(strings.category,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    TextButton(
                      onPressed: () =>
                          _showCategoryPicker(strings, allCategories),
                      child: Text(strings.more),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _CategoryGrid(
                  categories: recentCategories,
                  selectedId: _categoryId,
                  onSelected: (id) => setState(() => _categoryId = id),
                  limit: 4,
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: _FormBox(
                      label: strings.account.toUpperCase(),
                      onTap: () async {
                        final result = await showModalBottomSheet<String>(
                          context: context,
                          backgroundColor: const Color(0xFF16202A),
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (_) {
                            return ListView(
                              shrinkWrap: true,
                              children: appState.accounts.map((acc) {
                                return ListTile(
                                  title: Text(acc.name),
                                  onTap: () => Navigator.pop(context, acc.id),
                                );
                              }).toList(),
                            );
                          },
                        );

                        if (result != null) {
                          setState(() => _accountId = result);
                          if (_type == TransactionType.transfer &&
                              _transferInAccountId == result) {
                            final fallback = appState.accounts.firstWhere(
                              (acc) => acc.id != result,
                              orElse: () => appState.accounts.first,
                            );
                            if (fallback.id != result) {
                              _transferInAccountId = fallback.id;
                            }
                          }
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            appState.accounts.isEmpty
                                ? ''
                                : appState.accounts
                                    .firstWhere(
                                      (e) => e.id == _accountId,
                                      orElse: () => appState.accounts.first,
                                    )
                                    .name,
                          ),
                          const Icon(Symbols.expand_more, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FormBox(
                      label: strings.time.toUpperCase(),
                      onTap: _pickDate,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Formatters.dateLabel(_occurredAt, locale: locale),
                          ),
                          const Icon(Symbols.calendar_month, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_type == TransactionType.transfer) ...[
                const SizedBox(height: 12),
                _FormBox(
                  label: strings.account.toUpperCase(),
                  onTap: () async {
                    final accounts = appState.accounts
                        .where((acc) => acc.id != _accountId)
                        .toList();

                    final result = await showModalBottomSheet<String>(
                      context: context,
                      backgroundColor: const Color(0xFF16202A),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (_) {
                        return ListView(
                          shrinkWrap: true,
                          children: accounts.map((acc) {
                            return ListTile(
                              title: Text(acc.name),
                              onTap: () => Navigator.pop(context, acc.id),
                            );
                          }).toList(),
                        );
                      },
                    );

                    if (result != null) {
                      setState(() => _transferInAccountId = result);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _transferInAccountId == null ||
                                appState.accounts.isEmpty
                            ? AppLocalizations.of(context).select
                            : appState.accounts
                                .firstWhere((e) => e.id == _transferInAccountId)
                                .name,
                      ),
                      const Icon(Symbols.expand_more, size: 18),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(strings.note.toUpperCase(),
                  style:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: strings.tapToAdd,
                  filled: true,
                  fillColor: const Color(0xFF141E2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(strings.tags.toUpperCase(),
                  style:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TagAddChip(
                    label: strings.add,
                    onTap: () => _showTagPicker(strings, appState.tags),
                  ),
                  ..._selectedTags.map(
                    (tag) => Chip(
                      label: Text('#$tag'),
                      deleteIcon: const Icon(Symbols.close, size: 16),
                      onDeleted: () =>
                          setState(() => _selectedTags.remove(tag)),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _canSave ? () => _save(keepAdding: true) : null,
                      child: Text(strings.saveAndAdd),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _canSave ? () => _save(keepAdding: false) : null,
                      child: Text(strings.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_showKeypad)
            Align(
              alignment: Alignment.bottomCenter,
              child: _Keypad(
                onKeyTap: _appendAmount,
                onBackspace: _backspace,
                onSubmit: _canSave
                    ? () {
                        _save(keepAdding: false);
                        setState(() => _showKeypad = false);
                      }
                    : null,
                onHide: _toggleKeypad,
                onClear: _clearAmount,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showTagPicker(
      AppLocalizations strings, List<String> tags) async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: const Color(0xFF16202A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TagPickerSheet(
        tags: tags,
        selected: _selectedTags,
        title: strings.tags,
        confirmLabel: strings.confirm,
        cancelLabel: strings.cancel,
      ),
    );
    if (result != null) {
      setState(() => _selectedTags = result);
    }
  }

  Future<void> _showCategoryPicker(
    AppLocalizations strings,
    List<Category> categories,
  ) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF16202A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CategoryPickerSheet(
        categories: categories,
        selectedId: _categoryId,
        title: strings.category,
      ),
    );
    if (result != null) {
      setState(() => _categoryId = result);
    }
  }

  List<Category> _recentCategories(
    AppState appState,
    List<Category> categories, {
    required String? selectedId,
    int limit = 4,
  }) {
    final lastUsed = <String, DateTime>{};
    for (final record in appState.records) {
      if (record.categoryId == null) continue;
      if (_type == TransactionType.income &&
          record.type != TransactionType.income) {
        continue;
      }
      if (_type == TransactionType.expense &&
          record.type != TransactionType.expense) {
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
    if (selectedId != null &&
        !trimmed.any((c) => c.id == selectedId)) {
      final selected = categories.firstWhere(
        (c) => c.id == selectedId,
        orElse: () => trimmed.first,
      );
      if (!trimmed.any((c) => c.id == selected.id)) {
        trimmed.removeLast();
        trimmed.add(selected);
      }
    }
    return trimmed;
  }
}

class _TypeTabs extends StatelessWidget {
  const _TypeTabs({
    required this.type,
    required this.onChanged,
    required this.strings,
  });

  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabItem(
          label: strings.typeExpense,
          selected: type == TransactionType.expense,
          onTap: () => onChanged(TransactionType.expense),
        ),
        _TabItem(
          label: strings.typeIncome,
          selected: type == TransactionType.income,
          onTap: () => onChanged(TransactionType.income),
        ),
        _TabItem(
          label: strings.typeTransfer,
          selected: type == TransactionType.transfer,
          onTap: () => onChanged(TransactionType.transfer),
        ),
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? AppTheme.primary : AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: 60,
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    this.limit,
    this.scrollable = false,
  });

  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final int? limit;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final display = limit == null || categories.length <= limit!
        ? categories
        : categories.take(limit!).toList();
    return GridView.builder(
      shrinkWrap: !scrollable,
      physics: scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: display.length,
      itemBuilder: (context, index) {
        final cat = display[index];
        final selected = cat.id == selectedId;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: AppTheme.primary.withValues(alpha: 0.15),
            highlightColor: AppTheme.primary.withValues(alpha: 0.05),
            onTap: () => onSelected(cat.id),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: selected
                    ? AppTheme.primary.withValues(alpha: 0.08)
                    : Colors.transparent,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor:
                          selected ? AppTheme.primary : const Color(0xFF1B2632),
                      child: Icon(
                        IconData(
                          cat.icon == 0 ? Symbols.category.codePoint : cat.icon,
                          fontFamily: 'MaterialSymbolsOutlined',
                          fontPackage: 'material_symbols_icons',
                        ),
                        color: selected ? Colors.white : AppTheme.textMuted,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected ? AppTheme.primary : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FormBox extends StatelessWidget {
  const _FormBox({
    required this.label,
    required this.child,
    this.onTap,
  });

  final String label;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF141E2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            DefaultTextStyle(
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _TagAddChip extends StatelessWidget {
  const _TagAddChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Symbols.add, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onPressed: onTap,
    );
  }
}

class _CategoryPickerSheet extends StatelessWidget {
  const _CategoryPickerSheet({
    required this.categories,
    required this.selectedId,
    required this.title,
  });

  final List<Category> categories;
  final String? selectedId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(
            height: 320,
            child: _CategoryGrid(
              categories: categories,
              selectedId: selectedId,
              onSelected: (id) => Navigator.of(context).pop(id),
              scrollable: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  final void Function(String) onKeyTap;
  final VoidCallback onBackspace;
  final VoidCallback? onSubmit;
  final VoidCallback onHide;
  final VoidCallback onClear;

  const _Keypad({
    required this.onKeyTap,
    required this.onBackspace,
    required this.onSubmit,
    required this.onHide,
    required this.onClear,
  });

  static const double _rowHeight = 58;

  @override
  Widget build(BuildContext context) {
    const dividerColor = Color(0xFF1F2A36);

    return SizedBox(
      height: _rowHeight * 4, // 固定总高度
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
        decoration: BoxDecoration(
          color: const Color(0xFF111A25),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            /// 左侧数字区
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(child: _buildNumberRow(["7", "8", "9"])),
                  Expanded(child: _buildNumberRow(["4", "5", "6"])),
                  Expanded(child: _buildNumberRow(["1", "2", "3"])),
                  Expanded(child: _buildNumberRow([".", "0", "00"])),
                ],
              ),
            ),

            const SizedBox(width: 8),

            /// 右侧功能区
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(
                    child: _KeyCell(
                      child: const Text("C"),
                      onTap: onClear,
                    ),
                  ),
                  Expanded(
                    child: _KeyCell(
                      child: const Icon(Icons.backspace_outlined, size: 20),
                      onTap: onBackspace,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _KeyCell(
                      highlighted: true,
                      child: const Icon(Icons.check, size: 22),
                      onTap: onHide,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberRow(List<String> values) {
    return Row(
      children: values.map((v) {
        return Expanded(
          child: _KeyCell(
            child: Text(v, style: const TextStyle(fontSize: 18)),
            onTap: () => onKeyTap(v),
          ),
        );
      }).toList(),
    );
  }
}

class _KeyRow extends StatelessWidget {
  const _KeyRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        children: children.map((child) {
          return Expanded(child: child);
        }).toList(),
      ),
    );
  }
}

class _KeyCell extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool highlighted;

  const _KeyCell({
    required this.child,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color:
              highlighted ? const Color(0xFF00C853) : const Color(0xFF1B2633),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}

class _TagPickerSheet extends StatefulWidget {
  const _TagPickerSheet({
    required this.tags,
    required this.selected,
    required this.title,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final List<String> tags;
  final List<String> selected;
  final String title;
  final String confirmLabel;
  final String cancelLabel;

  @override
  State<_TagPickerSheet> createState() => _TagPickerSheetState();
}

class _TagPickerSheetState extends State<_TagPickerSheet> {
  late final Set<String> _current;

  @override
  void initState() {
    super.initState();
    _current = widget.selected.toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.tags.map((tag) {
              final isSelected = _current.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _current.add(tag);
                    } else {
                      _current.remove(tag);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(widget.cancelLabel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_current.toList()),
                  child: Text(widget.confirmLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
