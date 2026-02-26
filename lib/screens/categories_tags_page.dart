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
    _tabController = TabController(length: 3, vsync: this);
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
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
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

    final nameController = TextEditingController();
    CategoryType type =
        _tabController.index == 0 ? CategoryType.expense : CategoryType.income;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.addCategory),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(hintText: strings.categoryName),
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
                Symbols.category.codePoint,
                0xFF2B7CEE,
              );
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(strings.save),
          ),
        ],
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
        fillColor: const Color(0xFF1C252E),
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
    final filtered = data.categories
        .where((c) => c.name.contains(query))
        .toList();

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
      usage.update(record.categoryId!, (value) => value + 1,
          ifAbsent: () => 1);
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
            _TagAddChip(label: strings.newTag),
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
              color: const Color(0xFF1C252E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Icon(
              IconData(
                category.icon == 0
                    ? Symbols.category.codePoint
                    : category.icon,
                fontFamily: 'MaterialSymbolsOutlined',
              ),
              color: Color(category.colorHex),
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(category.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
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
        color: const Color(0xFF1C252E),
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
        color: const Color(0xFF1C252E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
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
                category.icon == 0
                    ? Symbols.category.codePoint
                    : category.icon,
                fontFamily: 'MaterialSymbolsOutlined',
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
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
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
        final newName = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(strings.editCategory),
            content: TextField(controller: controller),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(strings.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(controller.text),
                child: Text(strings.save),
              ),
            ],
          ),
        );
        if (newName != null && newName.trim().isNotEmpty) {
          await appState.updateCategory(Category(
            id: category.id,
            type: category.type,
            name: newName.trim(),
            icon: category.icon,
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

class _TagAddChip extends StatelessWidget {
  const _TagAddChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Symbols.add, size: 14),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}
