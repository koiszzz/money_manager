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
      }
    });
  }

  void _appendAmount(String value) {
    setState(() {
      if (value == '.') {
        if (_amountInput.contains('.')) return;
        _amountInput = _amountInput.isEmpty ? '0.' : '$_amountInput.';
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
    final categories = appState.categoriesByType(_type == TransactionType.income
        ? TransactionType.income
        : TransactionType.expense);

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
                child: Column(
                  children: [
                    Text(strings.amount,
                        style: const TextStyle(color: AppTheme.textMuted)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Formatters.money(
                            _type == TransactionType.expense
                                ? -_amountValue
                                : _amountValue,
                            showSign: _type != TransactionType.transfer,
                            locale: locale,
                          ),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _toggleKeypad,
                          icon: Icon(
                            _showKeypad ? Symbols.keyboard_hide : Symbols.edit,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _TypeTabs(
                type: _type,
                onChanged: _setType,
                strings: strings,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(strings.category,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () {},
                    child: Text(strings.edit),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _CategoryGrid(
                categories: categories,
                selectedId: _categoryId,
                onSelected: (id) => setState(() => _categoryId = id),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DropdownField(
                      label: strings.account.toUpperCase(),
                      value: _accountId,
                      items: appState.accounts,
                      onChanged: (id) => setState(() => _accountId = id),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: strings.time.toUpperCase(),
                      value: Formatters.dateLabel(_occurredAt, locale: locale),
                      onTap: _pickDate,
                    ),
                  ),
                ],
              ),
              if (_type == TransactionType.transfer) ...[
                const SizedBox(height: 12),
                _DropdownField(
                  label: strings.account.toUpperCase(),
                  value: _transferInAccountId,
                  items: appState.accounts
                      .where((acc) => acc.id != _accountId)
                      .toList(),
                  onChanged: (id) => setState(() => _transferInAccountId = id),
                ),
              ],
              const SizedBox(height: 12),
              Text(strings.note.toUpperCase(),
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
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
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
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
                      onPressed: _canSave ? () => _save(keepAdding: true) : null,
                      child: Text(strings.saveAndAdd),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canSave ? () => _save(keepAdding: false) : null,
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
              ),
            ),
        ],
      ),
    );
  }

  void _showTagPicker(AppLocalizations strings, List<String> tags) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _TagPickerSheet(
        tags: tags,
        selected: _selectedTags,
        onChanged: (next) => setState(() => _selectedTags = next),
      ),
    );
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
  });

  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: categories.length > 8 ? 8 : categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final selected = cat.id == selectedId;
        return InkWell(
          onTap: () => onSelected(cat.id),
          child: Column(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: selected
                    ? AppTheme.primary
                    : const Color(0xFF1B2632),
                child: Icon(
                  IconData(cat.icon, fontFamily: 'MaterialSymbolsOutlined'),
                  color: selected ? Colors.white : AppTheme.textMuted,
                  size: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(cat.name,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
        );
      },
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<Account> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF141E2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(AppLocalizations.of(context).select),
          items: items
              .map(
                (acc) => DropdownMenuItem(
                  value: acc.id,
                  child: Text(acc.name),
                ),
              )
              .toList(),
          onChanged: (id) {
            if (id != null) onChanged(id);
          },
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
          filled: true,
          fillColor: const Color(0xFF141E2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value),
            const Icon(Symbols.calendar_month, size: 18),
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

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.onKeyTap,
    required this.onBackspace,
    required this.onSubmit,
    required this.onHide,
  });

  final ValueChanged<String> onKeyTap;
  final VoidCallback onBackspace;
  final VoidCallback? onSubmit;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', '00'];
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF111A25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onHide,
              icon: const Icon(Symbols.keyboard_hide, size: 18),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 1,
              crossAxisSpacing: 1,
              childAspectRatio: 1.2,
            ),
            itemCount: 16,
            itemBuilder: (context, index) {
              if (index == 3) {
                return _KeyButton(
                  child: const Icon(Symbols.backspace, size: 20),
                  onTap: onBackspace,
                );
              }
              if (index == 7) {
                return _KeyButton(
                  child: const Text('C'),
                  onTap: onBackspace,
                );
              }
              if (index == 11) {
                return _KeyButton(
                  child: const Icon(Symbols.check, size: 20),
                  onTap: onSubmit,
                  highlighted: true,
                );
              }
              final keyIndex = index < 3
                  ? index
                  : index < 7
                      ? index - 1
                      : index < 11
                          ? index - 2
                          : index - 3;
              if (keyIndex < 0 || keyIndex >= keys.length) {
                return const SizedBox.shrink();
              }
              final label = keys[keyIndex];
              return _KeyButton(
                child: Text(label),
                onTap: () => onKeyTap(label),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.child,
    required this.onTap,
    this.highlighted = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlighted ? AppTheme.primary : const Color(0xFF141E2A),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: DefaultTextStyle(
            style: TextStyle(
              color: highlighted ? Colors.white : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _TagPickerSheet extends StatelessWidget {
  const _TagPickerSheet({
    required this.tags,
    required this.selected,
    required this.onChanged,
  });

  final List<String> tags;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final current = selected.toSet();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tags.map((tag) {
          final isSelected = current.contains(tag);
          return FilterChip(
            label: Text(tag),
            selected: isSelected,
            onSelected: (value) {
              final next = Set<String>.from(current);
              if (value) {
                next.add(tag);
              } else {
                next.remove(tag);
              }
              onChanged(next.toList());
            },
          );
        }).toList(),
      ),
    );
  }
}
