import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/widgets/category_list_item.dart';
import 'package:catat_cuan/presentation/screens/category_form_screen.dart';
import 'package:catat_cuan/presentation/widgets/deactivate_category_dialog.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/utils/app_colors.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/entities/category_with_count_entity.dart';

/// Screen untuk manajemen kategori
/// Menampilkan daftar kategori dengan tab Pemasukan/Pengeluaran/Tidak Aktif
class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState
    extends ConsumerState<CategoryManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      final tab = CategoryManagementTab.values[_tabController.index];
      ref.read(categoryManagementProvider.notifier).switchTab(tab);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryManagementProvider);

    return Scaffold(
      appBar: _buildAppBar(state),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _buildContent(state),
          ),
        ],
      ),
      floatingActionButton: AppGlassFab(
        onPressed: () => _navigateToAddCategory(context, state),
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(CategoryManagementState state) {
    return AppBar(
      title: _isSearching ? _buildSearchField() : const Text('Kelola Kategori'),
      actions: [
        if (!_isSearching)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => _isSearching = true),
          )
        else
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() => _isSearching = false);
              _searchController.clear();
              ref
                  .read(categoryManagementProvider.notifier)
                  .setSearchQuery('');
            },
          ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, state),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 12),
                  Text('Refresh'),
                ],
              ),
            ),
          ],
        ),
      ],
      bottom: _isSearching
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: _buildTabBar(),
            ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Cari kategori...',
        border: InputBorder.none,
      ),
      style: const TextStyle(fontSize: 16),
      onChanged: (value) {
        ref.read(categoryManagementProvider.notifier).setSearchQuery(value);
      },
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Pemasukan'),
        Tab(text: 'Pengeluaran'),
        Tab(text: 'Tidak Aktif'),
      ],
      onTap: (index) {
        final tab = CategoryManagementTab.values[index];
        ref.read(categoryManagementProvider.notifier).switchTab(tab);
      },
    );
  }

  Widget _buildContent(CategoryManagementState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return _buildErrorState(state.error!);
    }

    return _buildCategoryList(state.displayedCategories);
  }

  Widget _buildCategoryList(List<dynamic> categories) {
    if (categories.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(categoryManagementProvider.notifier).refresh(),
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return CategoryListItem(
            categoryWithCount: categories[index],
            onTap: () => _navigateToEditCategory(
              context,
              categories[index].category,
            ),
            onEdit: () => _navigateToEditCategory(
              context,
              categories[index].category,
            ),
            onDelete: () => _showDeleteDialog(
              context,
              categories[index],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppGlassContainer.glassPill(
              width: 100,
              height: 100,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              child: const Icon(
                Icons.category_outlined,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tidak Ada Kategori',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tekan tombol + untuk menambah kategori baru',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppGlassContainer.glassPill(
              width: 80,
              height: 80,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Terjadi Kesalahan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(categoryManagementProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, CategoryManagementState state) {
    switch (action) {
      case 'refresh':
        ref.read(categoryManagementProvider.notifier).refresh();
        break;
    }
  }

  void _navigateToAddCategory(
    BuildContext context,
    CategoryManagementState state,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryFormScreen(
          initialType: state.selectedTab == CategoryManagementTab.income
              ? CategoryType.income
              : CategoryType.expense,
        ),
      ),
    );

    if (result == true) {
      ref.read(categoryManagementProvider.notifier).refresh();
    }
  }

  void _navigateToEditCategory(
    BuildContext context,
    CategoryEntity category,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryFormScreen(
          categoryToEdit: category,
        ),
      ),
    );

    if (result == true) {
      ref.read(categoryManagementProvider.notifier).refresh();
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    CategoryWithCountEntity categoryWithCount,
  ) async {
    final category = categoryWithCount.category;
    final transactionCount = categoryWithCount.transactionCount;

    // Show confirmation dialog using DeactivateCategoryDialog
    final result = await DeactivateCategoryDialog.show(
      context: context,
      categoryName: category.name,
      transactionCount: transactionCount,
    );

    if (result == true && transactionCount == 0) {
      final success = await ref
          .read(categoryManagementProvider.notifier)
          .deactivateCategory(category.id!);

      if (context.mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menonaktifkan kategori'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
