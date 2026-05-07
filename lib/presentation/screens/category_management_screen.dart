import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/widgets/category_list_item.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/navigation/routes/app_routes.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:go_router/go_router.dart';
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
  bool _isReorderMode = false;

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
      floatingActionButton: _isReorderMode
          ? AppGlassFab(
              onPressed: () => setState(() => _isReorderMode = false),
              backgroundColor: AppColors.success,
              child: const Icon(Icons.check),
            )
          : AppGlassFab(
              onPressed: () => _navigateToAddCategory(context, state),
              child: const Icon(Icons.add),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(CategoryManagementState state) {
    return AppBar(
      title: _isSearching ? _buildSearchField() : const Text('Kelola Kategori'),
      actions: [
        if (!_isSearching) ...[
          // Reorder button (only for active tabs, not inactive tab)
          if (state.selectedTab != CategoryManagementTab.inactive)
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: () => setState(() => _isReorderMode = true),
              tooltip: 'Urutkan Kategori',
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => _isSearching = true),
          ),
        ] else
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
                  AppSpacingWidget.horizontalMD(),
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

    if (_isReorderMode) {
      return _buildReorderableList(categories);
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

  Widget _buildReorderableList(List<dynamic> categories) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      itemCount: categories.length,
      onReorder: (oldIndex, newIndex) => _handleReorder(
        categories,
        oldIndex,
        newIndex,
      ),
      itemBuilder: (context, index) {
        final item = categories[index];
        return CategoryListItem(
          key: ValueKey(item.category.id),
          categoryWithCount: item,
          showReorderHandle: true,
          reorderIndex: index,
          onTap: () {}, // Disabled in reorder mode
        );
      },
    );
  }

  Future<void> _handleReorder(
    List<dynamic> categories,
    int oldIndex,
    int newIndex,
  ) async {
    final controller = ref.read(categoryManagementControllerProvider);
    final List<CategoryEntity> categoryEntities =
        categories.cast<CategoryWithCountEntity>().map((c) => c.category).toList();

    final success = await controller.handleReorder(
      oldIndex,
      newIndex,
      categoryEntities,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengurutkan kategori'),
          backgroundColor: AppColors.error,
        ),
      );
    } else {
      // Refresh the list
      ref.read(categoryManagementProvider.notifier).refresh();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppSpacing.xxxlAll,
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
            const AppSpacingWidget.verticalXL(),
            Text(
              'Tidak Ada Kategori',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const AppSpacingWidget.verticalSM(),
            Text(
              'Tekan tombol + untuk menambah kategori baru',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    // Log the technical error for debugging
    AppLogger.e('Category management error: $error');

    // Map to user-friendly message
    final userMessage = ErrorMessageMapper.getUserMessage(error);

    return Center(
      child: Padding(
        padding: AppSpacing.xxlAll,
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
            const AppSpacingWidget.verticalXL(),
            Text(
              'Terjadi Kesalahan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const AppSpacingWidget.verticalSM(),
            Text(
              userMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
              textAlign: TextAlign.center,
            ),
            const AppSpacingWidget.verticalLG(),
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
    final result = await context.push<bool>(AppRoutes.addCategory);

    if (result == true) {
      ref.read(categoryManagementProvider.notifier).refresh();
    }
  }

  void _navigateToEditCategory(
    BuildContext context,
    CategoryEntity category,
  ) async {
    final result = await context.push<bool>(AppRoutes.editCategoryPath(category.id!));

    if (result == true) {
      ref.read(categoryManagementProvider.notifier).refresh();
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    CategoryWithCountEntity categoryWithCount,
  ) async {
    final controller = ref.read(categoryManagementControllerProvider);
    final category = categoryWithCount.category;

    final success = await controller.showDeleteConfirmation(
      context,
      category,
    );

    if (context.mounted) {
      if (success) {
        // Refresh the list
        ref.read(categoryManagementProvider.notifier).refresh();
      } else {
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
