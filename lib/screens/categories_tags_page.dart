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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        .toList();
    final incomeCategories = appState.categories
        .where((c) => c.type == CategoryType.income)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.categoriesTags),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: strings.typeExpense),
            Tab(text: strings.typeIncome),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategory(context, appState),
        child: const Icon(Symbols.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoryList(categories: expenseCategories),
          _CategoryList(categories: incomeCategories),
        ],
      ),
      bottomNavigationBar: _TagEditor(tags: appState.tags),
    );
  }

  void _showAddCategory(BuildContext context, AppState appState) {
    final strings = AppLocalizations.of(context);
    final controller = TextEditingController();
    CategoryType type = _tabController.index == 0
        ? CategoryType.expense
        : CategoryType.income;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.addCategory),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: strings.category),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              await appState.addCategory(
                type,
                name,
                Symbols.category.codePoint,
                0xFF3B82F6,
              );
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(strings.confirm),
          ),
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2632),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(cat.colorHex),
                child: Icon(
                  IconData(cat.icon, fontFamily: 'MaterialSymbolsOutlined'),
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(cat.name)),
              Switch(
                value: cat.enabled,
                onChanged: (value) =>
                    appState.toggleCategoryEnabled(cat.id, value),
              )
            ],
          ),
        );
      },
    );
  }
}

class _TagEditor extends StatelessWidget {
  const _TagEditor({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final strings = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1824),
        border: Border(top: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.tags, style: const TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Symbols.add, size: 16),
                    const SizedBox(width: 4),
                    Text(strings.add),
                  ],
                ),
                onPressed: () => _showAddTag(context, appState, strings),
              ),
              ...tags.map((tag) => Chip(
                    label: Text('#$tag'),
                    deleteIcon: const Icon(Symbols.close, size: 16),
                    onDeleted: () => appState.removeTag(tag),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddTag(
      BuildContext context, AppState appState, AppLocalizations strings) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.add),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: strings.tags),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () async {
              final tag = controller.text.trim();
              if (tag.isEmpty) return;
              await appState.addTag(tag);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(strings.confirm),
          ),
        ],
      ),
    );
  }
}
