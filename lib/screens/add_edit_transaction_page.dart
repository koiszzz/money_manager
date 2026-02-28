import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../controllers/add_edit_transaction/add_edit_transaction_controller.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class AddEditTransactionPage extends ConsumerStatefulWidget {
  const AddEditTransactionPage({super.key, this.record, this.isCopy = false});

  final TransactionRecord? record;
  final bool isCopy;

  @override
  ConsumerState<AddEditTransactionPage> createState() =>
      _AddEditTransactionPageState();
}

class _AddEditTransactionPageState
    extends ConsumerState<AddEditTransactionPage> {
  final TextEditingController _noteController = TextEditingController();
  late final AddEditTransactionArgs _args;

  AddEditTransactionState get _state =>
      ref.watch(addEditTransactionControllerProvider(_args));
  AddEditTransactionController get _controller =>
      ref.read(addEditTransactionControllerProvider(_args).notifier);

  @override
  void initState() {
    super.initState();
    _args =
        AddEditTransactionArgs(record: widget.record, isCopy: widget.isCopy);
    _noteController.text = widget.record?.note ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _state.occurredAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      _controller.setOccurredAt(selected);
    }
  }

  void _save({required bool keepAdding}) {
    final strings = AppLocalizations.of(context);
    final result =
        _controller.save(note: _noteController.text, keepAdding: keepAdding);
    if (result == SaveTransactionResult.invalid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.select)),
      );
      return;
    }
    if (result == SaveTransactionResult.savedAndContinue) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.save)));
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final state = _state;
    final appState = ref.watch(appStateProvider);
    final allCategories = appState.categoriesByType(
      state.type == TransactionType.income
          ? TransactionType.income
          : TransactionType.expense,
    );
    final recentCategories =
        _controller.recentCategories(allCategories, limit: 4);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.addTransaction),
        actions: [
          IconButton(
            onPressed: _controller.toggleKeypad,
            icon: Icon(
                state.showKeypad ? Symbols.keyboard_hide : Symbols.keyboard),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding:
                EdgeInsets.fromLTRB(16, 12, 16, state.showKeypad ? 240 : 16),
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    if (!state.showKeypad) {
                      _controller.toggleKeypad();
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    child: Column(
                      children: [
                        Text(strings.amount,
                            style:
                                TextStyle(color: AppTheme.mutedText(context))),
                        const SizedBox(height: 6),
                        Text(
                          Formatters.money(
                            state.type == TransactionType.expense
                                ? -state.amountValue
                                : state.amountValue,
                            showSign: state.type != TransactionType.transfer,
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
                type: state.type,
                onChanged: _controller.setType,
                strings: strings,
              ),
              const SizedBox(height: 16),
              if (state.type != TransactionType.transfer) ...[
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
                  selectedId: state.categoryId,
                  onSelected: _controller.setCategory,
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
                          backgroundColor: AppTheme.surface(context, level: 0),
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
                          _controller.setAccount(result);
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
                                      (e) => e.id == state.accountId,
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
                            Formatters.dateLabel(state.occurredAt,
                                locale: locale),
                          ),
                          const Icon(Symbols.calendar_month, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (state.type == TransactionType.transfer) ...[
                const SizedBox(height: 12),
                _FormBox(
                  label: strings.account.toUpperCase(),
                  onTap: () async {
                    final accounts = appState.accounts
                        .where((acc) => acc.id != state.accountId)
                        .toList();

                    final result = await showModalBottomSheet<String>(
                      context: context,
                      backgroundColor: AppTheme.surface(context, level: 0),
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
                      _controller.setTransferInAccount(result);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.transferInAccountId == null ||
                                appState.accounts.isEmpty
                            ? AppLocalizations.of(context).select
                            : appState.accounts
                                .firstWhere(
                                    (e) => e.id == state.transferInAccountId)
                                .name,
                      ),
                      const Icon(Symbols.expand_more, size: 18),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(strings.note.toUpperCase(),
                  style: TextStyle(
                    color: AppTheme.mutedText(context),
                    fontSize: 12,
                  )),
              const SizedBox(height: 6),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: strings.tapToAdd,
                  filled: true,
                  fillColor: AppTheme.surface(context, level: 1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.outline(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.outline(context)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(strings.tags.toUpperCase(),
                  style: TextStyle(
                    color: AppTheme.mutedText(context),
                    fontSize: 12,
                  )),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TagAddChip(
                    label: strings.add,
                    onTap: () => _showTagPicker(strings, appState.tags),
                  ),
                  ...state.selectedTags.map(
                    (tag) => Chip(
                      label: Text('#$tag'),
                      deleteIcon: const Icon(Symbols.close, size: 16),
                      onDeleted: () => _controller.removeTag(tag),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _controller.canSave
                          ? () => _save(keepAdding: true)
                          : null,
                      child: Text(strings.saveAndAdd),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _controller.canSave
                          ? () => _save(keepAdding: false)
                          : null,
                      child: Text(strings.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (state.showKeypad)
            Align(
              alignment: Alignment.bottomCenter,
              child: _Keypad(
                onKeyTap: _controller.appendAmount,
                onBackspace: _controller.backspace,
                onSubmit: _controller.canSave
                    ? () {
                        _save(keepAdding: false);
                        _controller.hideKeypad();
                      }
                    : null,
                onHide: _controller.toggleKeypad,
                onClear: _controller.clearAmount,
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
      backgroundColor: AppTheme.surface(context, level: 0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TagPickerSheet(
        tags: tags,
        selected: _state.selectedTags,
        title: strings.tags,
        confirmLabel: strings.confirm,
        cancelLabel: strings.cancel,
      ),
    );
    if (result != null) {
      _controller.setTags(result);
    }
  }

  Future<void> _showCategoryPicker(
    AppLocalizations strings,
    List<Category> categories,
  ) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.surface(context, level: 0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CategoryPickerSheet(
        categories: categories,
        selectedId: _state.categoryId,
        title: strings.category,
      ),
    );
    if (result != null) {
      _controller.setCategory(result);
    }
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
                color:
                    selected ? AppTheme.primary : AppTheme.mutedText(context),
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
                      backgroundColor: selected
                          ? AppTheme.primary
                          : AppTheme.surface(context, level: 1),
                      child: Icon(
                        IconData(
                          cat.icon == 0 ? Symbols.category.codePoint : cat.icon,
                          fontFamily: 'MaterialSymbolsOutlined',
                          fontPackage: 'material_symbols_icons',
                        ),
                        color: selected
                            ? Colors.white
                            : AppTheme.mutedText(context),
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
                        color: selected
                            ? AppTheme.primary
                            : AppTheme.mutedText(context),
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
          color: AppTheme.surface(context, level: 1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.outline(context)),
          boxShadow: AppTheme.cardShadow(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.mutedText(context),
              ),
            ),
            const SizedBox(height: 2),
            DefaultTextStyle(
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
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
    final panelColor = AppTheme.surface(context, level: 1);
    return SizedBox(
      height: _rowHeight * 4, // 固定总高度
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
        decoration: BoxDecoration(
          color: panelColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outline(context)),
          boxShadow: AppTheme.cardShadow(context),
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
    final baseColor = AppTheme.surface(context, level: 2);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: highlighted ? const Color(0xFF00C853) : baseColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.outline(context)),
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
