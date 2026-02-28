import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class CategoriesTagsPage extends StatefulWidget {
  const CategoriesTagsPage({super.key});

  @override
  State<CategoriesTagsPage> createState() => _CategoriesTagsPageState();
}

class _CategoriesTagsPageState extends State<CategoriesTagsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final appState = context.watch<AppState>();
    final expenseCategories = appState.categories
        .where((c) => c.type == CategoryType.expense)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final incomeCategories = appState.categories
        .where((c) => c.type == CategoryType.income)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final tabs = [
      _CategoryTabData(
        title: strings.typeExpense,
        type: CategoryType.expense,
        categories: expenseCategories,
      ),
      _CategoryTabData(
        title: strings.typeIncome,
        type: CategoryType.income,
        categories: incomeCategories,
      ),
      _CategoryTabData(
        title: strings.tags,
        type: null,
        categories: const [],
      ),
      _CategoryTabData(
        title: strings.accountTypes,
        type: null,
        categories: const [],
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _HeaderBar(
              title: strings.categoriesTags,
              onBack: () => Navigator.of(context).pop(),
              onAdd: () => _showAddDialog(context, appState, strings),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: _SearchField(
                hint: strings.searchCategoriesTags,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primary,
              tabs: [
                for (final tab in tabs) Tab(text: tab.title),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _CategoryTab(
                    data: tabs[0],
                    query: _query,
                  ),
                  _CategoryTab(
                    data: tabs[1],
                    query: _query,
                  ),
                  _TagsTab(query: _query),
                  _AccountTypesTab(query: _query),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog(
      BuildContext context, AppState appState, AppLocalizations strings) async {
    if (_tabController.index == 2) {
      final controller = TextEditingController();
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(strings.addTag),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: strings.tagName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(strings.cancel),
            ),
            TextButton(
              onPressed: () async {
                final value = controller.text.trim();
                if (value.isEmpty) return;
                await appState.addTag(value);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(strings.save),
            ),
          ],
        ),
      );
      return;
    }
    if (_tabController.index == 3) {
      final nameController = TextEditingController();
      AccountNature nature = AccountNature.bank;
      await showDialog<void>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setModalState) => AlertDialog(
            title: Text(strings.addAccountType),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration:
                      InputDecoration(hintText: strings.accountTypeName),
                ),
                const SizedBox(height: 12),
                _NaturePicker(
                  value: nature,
                  onChanged: (value) => setModalState(() => nature = value),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(strings.cancel),
              ),
              TextButton(
                onPressed: () async {
                  final value = nameController.text.trim();
                  if (value.isEmpty) return;
                  await appState.addAccountType(name: value, nature: nature);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: Text(strings.save),
              ),
            ],
          ),
        ),
      );
      return;
    }

    final nameController = TextEditingController();
    CategoryType type =
        _tabController.index == 0 ? CategoryType.expense : CategoryType.income;
    int selectedIcon = _CategoryIconPicker.icons.first.codePoint;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text(strings.addCategory),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: strings.categoryName),
              ),
              const SizedBox(height: 12),
              _CategoryIconPicker(
                selected: selectedIcon,
                onChanged: (value) => setModalState(() => selectedIcon = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(strings.cancel),
            ),
            TextButton(
              onPressed: () async {
                final value = nameController.text.trim();
                if (value.isEmpty) return;
                await appState.addCategory(
                  type,
                  value,
                  selectedIcon,
                  0xFF2B7CEE,
                );
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(strings.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({
    required this.title,
    required this.onBack,
    required this.onAdd,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Symbols.arrow_back, size: 22),
            onPressed: onBack,
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Symbols.add, size: 20),
              color: Colors.white,
              onPressed: onAdd,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Symbols.search),
        filled: true,
        fillColor: AppTheme.surface(context, level: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CategoryTabData {
  const _CategoryTabData({
    required this.title,
    required this.type,
    required this.categories,
  });

  final String title;
  final CategoryType? type;
  final List<Category> categories;
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({required this.data, required this.query});

  final _CategoryTabData data;
  final String query;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final strings = AppLocalizations.of(context);
    final filtered =
        data.categories.where((c) => c.name.contains(query)).toList();

    final frequent = _topCategories(appState, data.categories, limit: 3);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(strings.frequent,
            style: const TextStyle(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 12)),
        const SizedBox(height: 10),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              if (frequent.isEmpty) {
                return _FrequentEmpty(label: strings.noData);
              }
              final category = frequent[index];
              return _FrequentCategory(category: category);
            },
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: frequent.isEmpty ? 1 : frequent.length,
          ),
        ),
        const SizedBox(height: 20),
        Text(strings.allCategories,
            style: const TextStyle(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 12)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.8,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final category = filtered[index];
            return _CategoryCard(category: category);
          },
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            strings.swipeHint,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
        ),
      ],
    );
  }

  List<Category> _topCategories(AppState appState, List<Category> categories,
      {int limit = 3}) {
    final usage = <String, int>{};
    for (final record in appState.records) {
      if (record.categoryId == null) continue;
      usage.update(record.categoryId!, (value) => value + 1, ifAbsent: () => 1);
    }
    final sorted = [...categories]
      ..sort((a, b) => (usage[b.id] ?? 0).compareTo(usage[a.id] ?? 0));
    if (sorted.length <= limit) return sorted;
    return sorted.take(limit).toList();
  }
}

class _TagsTab extends StatelessWidget {
  const _TagsTab({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final strings = AppLocalizations.of(context);
    final tags = appState.tags
        .where((tag) => tag.contains(query))
        .toList(growable: false);
    final colors = _tagColors;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(strings.popularTags,
                style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
            TextButton(onPressed: () {}, child: Text(strings.viewAll)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < tags.length; i++)
              _TagChip(
                label: tags[i],
                color: colors[i % colors.length],
                onDelete: () => appState.removeTag(tags[i]),
              ),
          ],
        ),
      ],
    );
  }

  static const _tagColors = [
    Color(0xFFBC13FE),
    Color(0xFF00F2FF),
    Color(0xFF0AFF60),
    Color(0xFFFF9F0A),
    Color(0xFFFF2D55),
  ];
}

class _AccountTypesTab extends StatelessWidget {
  const _AccountTypesTab({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final strings = AppLocalizations.of(context);
    final types = appState.accountTypes
        .where((t) => t.name.contains(query))
        .toList(growable: false);

    if (types.isEmpty) {
      return Center(
        child: Text(
          strings.noAccountTypes,
          style: const TextStyle(color: AppTheme.textMuted),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: types.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _AccountTypeCard(option: types[index]),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  const _AccountTypeCard({required this.option});

  final AccountTypeOption option;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final appState = context.read<AppState>();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface(context, level: 0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outline(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Symbols.account_balance_wallet,
                color: AppTheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(option.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  _natureLabel(option.nature, strings),
                  style:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          PopupMenuButton<_AccountTypeAction>(
            icon: const Icon(Symbols.more_vert, size: 18),
            onSelected: (value) => _handleAction(
              context,
              appState,
              strings,
              option,
              value,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _AccountTypeAction.edit,
                child: Text(strings.edit),
              ),
              PopupMenuItem(
                value: _AccountTypeAction.delete,
                child: Text(strings.delete),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    AppState appState,
    AppLocalizations strings,
    AccountTypeOption option,
    _AccountTypeAction action,
  ) async {
    switch (action) {
      case _AccountTypeAction.edit:
        final controller = TextEditingController(text: option.name);
        AccountNature nature = option.nature;
        final result = await showDialog<_AccountTypeEditResult>(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setModalState) => AlertDialog(
              title: Text(strings.editAccountType),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: controller),
                  const SizedBox(height: 12),
                  _NaturePicker(
                    value: nature,
                    onChanged: (value) => setModalState(() => nature = value),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(strings.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(
                    _AccountTypeEditResult(
                      name: controller.text,
                      nature: nature,
                    ),
                  ),
                  child: Text(strings.save),
                ),
              ],
            ),
          ),
        );
        if (result != null && result.name.trim().isNotEmpty) {
          await appState.updateAccountType(AccountTypeOption(
            id: option.id,
            name: result.name.trim(),
            nature: result.nature,
          ));
        }
        break;
      case _AccountTypeAction.delete:
        final ok = await appState.removeAccountType(option.id);
        if (!context.mounted) return;
        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.accountTypeDeleteBlocked)),
          );
        }
        break;
    }
  }

  String _natureLabel(AccountNature nature, AppLocalizations strings) {
    switch (nature) {
      case AccountNature.bank:
        return strings.accountNatureBank;
      case AccountNature.credit:
        return strings.accountNatureCredit;
      case AccountNature.loan:
        return strings.accountNatureLoan;
      case AccountNature.asset:
        return strings.accountNatureAsset;
      case AccountNature.liability:
        return strings.accountNatureLiability;
    }
  }
}

enum _AccountTypeAction { edit, delete }

class _AccountTypeEditResult {
  const _AccountTypeEditResult({
    required this.name,
    required this.nature,
  });

  final String name;
  final AccountNature nature;
}

class _NaturePicker extends StatelessWidget {
  const _NaturePicker({required this.value, required this.onChanged});

  final AccountNature value;
  final ValueChanged<AccountNature> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _NatureChip(
          label: strings.accountNatureBank,
          selected: value == AccountNature.bank,
          onTap: () => onChanged(AccountNature.bank),
        ),
        _NatureChip(
          label: strings.accountNatureCredit,
          selected: value == AccountNature.credit,
          onTap: () => onChanged(AccountNature.credit),
        ),
        _NatureChip(
          label: strings.accountNatureLoan,
          selected: value == AccountNature.loan,
          onTap: () => onChanged(AccountNature.loan),
        ),
        _NatureChip(
          label: strings.accountNatureAsset,
          selected: value == AccountNature.asset,
          onTap: () => onChanged(AccountNature.asset),
        ),
        _NatureChip(
          label: strings.accountNatureLiability,
          selected: value == AccountNature.liability,
          onTap: () => onChanged(AccountNature.liability),
        ),
      ],
    );
  }
}

class _NatureChip extends StatelessWidget {
  const _NatureChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primary.withOpacity(0.2),
    );
  }
}

class _CategoryEditResult {
  const _CategoryEditResult({required this.name, required this.icon});

  final String name;
  final int icon;
}

class _CategoryIconPicker extends StatelessWidget {
  const _CategoryIconPicker({
    required this.selected,
    required this.onChanged,
  });

  final int selected;
  final ValueChanged<int> onChanged;

  static const icons = [
    Symbols.restaurant,
    Symbols.shopping_cart,
    Symbols.local_taxi,
    Symbols.movie,
    Symbols.local_cafe,
    Symbols.fastfood,
    Symbols.directions_car,
    Symbols.home,
    Symbols.school,
    Symbols.medical_services,
    Symbols.sports_soccer,
    Symbols.card_giftcard,
    Symbols.flight,
    Symbols.savings,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).selectIcon,
            style: const TextStyle(color: AppTheme.textMuted)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: icons.map((icon) {
            final code = icon.codePoint;
            final isSelected = code == selected;
            return GestureDetector(
              onTap: () => onChanged(code),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withOpacity(0.2)
                      : const Color(0xFF0F1820),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Icon(
                  IconData(
                    code,
                    fontFamily: 'MaterialSymbolsOutlined',
                    fontPackage: 'material_symbols_icons',
                  ),
                  color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _FrequentCategory extends StatelessWidget {
  const _FrequentCategory({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.surface(context, level: 0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.outline(context)),
            ),
            child: Icon(
              IconData(
                category.icon == 0 ? Symbols.category.codePoint : category.icon,
                fontFamily: 'MaterialSymbolsOutlined',
                fontPackage: 'material_symbols_icons',
              ),
              color: Color(category.colorHex),
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(category.name,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _FrequentEmpty extends StatelessWidget {
  const _FrequentEmpty({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface(context, level: 0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(label, style: const TextStyle(color: AppTheme.textMuted)),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final strings = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface(context, level: 0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outline(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(category.colorHex).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconData(
                category.icon == 0 ? Symbols.category.codePoint : category.icon,
                fontFamily: 'MaterialSymbolsOutlined',
                fontPackage: 'material_symbols_icons',
              ),
              color: Color(category.colorHex),
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '${appState.countRecordsForCategory(category.id)} ${strings.recordsLabel}',
                  style:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          PopupMenuButton<_CategoryAction>(
            icon: const Icon(Symbols.more_vert, size: 18),
            onSelected: (value) => _handleAction(context, appState, value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _CategoryAction.edit,
                child: Text(strings.edit),
              ),
              PopupMenuItem(
                value: _CategoryAction.merge,
                child: Text(strings.mergeCategory),
              ),
              PopupMenuItem(
                value: _CategoryAction.disable,
                child: Text(strings.disableCategory),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    AppState appState,
    _CategoryAction action,
  ) async {
    final strings = AppLocalizations.of(context);
    switch (action) {
      case _CategoryAction.edit:
        final controller = TextEditingController(text: category.name);
        int selectedIcon =
            category.icon == 0 ? Symbols.category.codePoint : category.icon;
        final result = await showDialog<_CategoryEditResult>(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setModalState) => AlertDialog(
              title: Text(strings.editCategory),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: controller),
                  const SizedBox(height: 12),
                  _CategoryIconPicker(
                    selected: selectedIcon,
                    onChanged: (value) =>
                        setModalState(() => selectedIcon = value),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(strings.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(
                    _CategoryEditResult(
                      name: controller.text,
                      icon: selectedIcon,
                    ),
                  ),
                  child: Text(strings.save),
                ),
              ],
            ),
          ),
        );
        if (result != null && result.name.trim().isNotEmpty) {
          await appState.updateCategory(Category(
            id: category.id,
            type: category.type,
            name: result.name.trim(),
            icon: result.icon,
            colorHex: category.colorHex,
            enabled: category.enabled,
            sortOrder: category.sortOrder,
          ));
        }
        break;
      case _CategoryAction.merge:
        final target = await _selectMergeTarget(context, appState);
        if (target != null) {
          await appState.mergeCategory(sourceId: category.id, targetId: target);
        }
        break;
      case _CategoryAction.disable:
        await appState.toggleCategoryEnabled(category.id, false);
        break;
    }
  }

  Future<String?> _selectMergeTarget(
      BuildContext context, AppState appState) async {
    final strings = AppLocalizations.of(context);
    final candidates = appState.categories
        .where((c) => c.type == category.type && c.id != category.id)
        .toList();
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.noMergeTarget)),
      );
      return null;
    }
    String? selectedId;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.mergeCategory),
        content: DropdownButtonFormField<String>(
          items: [
            for (final item in candidates)
              DropdownMenuItem(value: item.id, child: Text(item.name)),
          ],
          onChanged: (value) => selectedId = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.confirm),
          ),
        ],
      ),
    );
    return selectedId;
  }
}

enum _CategoryAction { edit, merge, disable }

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.color,
    required this.onDelete,
  });

  final String label;
  final Color color;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('#$label', style: TextStyle(color: color)),
      backgroundColor: color.withOpacity(0.12),
      deleteIcon: const Icon(Symbols.close, size: 16),
      onDeleted: onDelete,
    );
  }
}
