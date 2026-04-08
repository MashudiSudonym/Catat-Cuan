import 'package:catat_cuan/presentation/providers/transaction/transaction_selection_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionSelectionNotifier', () {
    test('should toggle item in selection mode', () {
      // Arrange
      final container = ProviderContainer();
      final notifier = container.read(transactionSelectionProvider.notifier);
      addTearDown(container.dispose);

      // Act
      notifier.toggleSelectionMode(1);

      // Assert
      final state = container.read(transactionSelectionProvider);
      expect(state.isSelectionModeActive, isTrue);
      expect(state.selectedIds, [1]);
    });

    test('should auto-exit selection mode when last item deselected', () {
      // Arrange
      final container = ProviderContainer();
      final notifier = container.read(transactionSelectionProvider.notifier);
      addTearDown(container.dispose);
      notifier.toggleSelectionMode(1);

      // Act
      notifier.toggleSelection(1); // Remove only item

      // Assert - Should exit selection mode
      final state = container.read(transactionSelectionProvider);
      expect(state.isSelectionModeActive, isFalse);
      expect(state.selectedIds, isEmpty);
    });

    test('should select multiple items', () {
      // Arrange
      final container = ProviderContainer();
      final notifier = container.read(transactionSelectionProvider.notifier);
      addTearDown(container.dispose);

      // Act
      notifier.selectMultiple([1, 2, 3]);

      // Assert
      final state = container.read(transactionSelectionProvider);
      expect(state.isSelectionModeActive, isTrue);
      expect(state.selectedIds, [1, 2, 3]);
    });

    test('should select all items from available list', () {
      // Arrange
      final container = ProviderContainer();
      final notifier = container.read(transactionSelectionProvider.notifier);
      addTearDown(container.dispose);

      // Act
      notifier.selectAll([1, 2, 3, 4, 5]);

      // Assert
      final state = container.read(transactionSelectionProvider);
      expect(state.isSelectionModeActive, isTrue);
      expect(state.selectedIds.length, equals(5));
      expect(state.selectedIds, containsAll([1, 2, 3, 4, 5]));
    });

    test('should deselect all while keeping selection mode active', () {
      // Arrange
      final container = ProviderContainer();
      final notifier = container.read(transactionSelectionProvider.notifier);
      addTearDown(container.dispose);
      notifier.selectAll([1, 2, 3]);

      // Act
      notifier.deselectAll();

      // Assert
      final state = container.read(transactionSelectionProvider);
      expect(state.isSelectionModeActive, isTrue);
      expect(state.selectedIds, isEmpty);
    });

    test('should toggle select all / deselect all', () {
      // Arrange
      final container = ProviderContainer();
      final notifier = container.read(transactionSelectionProvider.notifier);
      addTearDown(container.dispose);
      final allIds = [1, 2, 3, 4, 5];

      // Act - First toggle should select all
      notifier.toggleSelectAll(allIds);
      var state = container.read(transactionSelectionProvider);
      expect(state.selectedIds.length, equals(5));

      // Act - Second toggle should deselect all
      notifier.toggleSelectAll(allIds);

      // Assert
      state = container.read(transactionSelectionProvider);
      expect(state.isSelectionModeActive, isTrue);
      expect(state.selectedIds, isEmpty);
    });

    test('should clear selection and exit selection mode', () {
      // Arrange
      final container = ProviderContainer();
      final notifier = container.read(transactionSelectionProvider.notifier);
      addTearDown(container.dispose);
      notifier.selectAll([1, 2, 3]);

      // Act
      notifier.clearSelection();

      // Assert
      final state = container.read(transactionSelectionProvider);
      expect(state.isSelectionModeActive, isFalse);
      expect(state.selectedIds, isEmpty);
    });

    test('should add to selection when toggling different items', () {
      // Arrange
      final container = ProviderContainer();
      final notifier = container.read(transactionSelectionProvider.notifier);
      addTearDown(container.dispose);
      notifier.toggleSelectionMode(1);

      // Act
      notifier.toggleSelection(2);
      notifier.toggleSelection(3);

      // Assert
      final state = container.read(transactionSelectionProvider);
      expect(state.isSelectionModeActive, isTrue);
      expect(state.selectedIds, [1, 2, 3]);
    });

    test('should remove from selection when toggling selected item', () {
      // Arrange
      final container = ProviderContainer();
      final notifier = container.read(transactionSelectionProvider.notifier);
      addTearDown(container.dispose);
      notifier.toggleSelectionMode(1);
      notifier.toggleSelection(2);
      notifier.toggleSelection(3);

      // Act
      notifier.toggleSelection(2);

      // Assert
      final state = container.read(transactionSelectionProvider);
      expect(state.isSelectionModeActive, isTrue);
      expect(state.selectedIds, [1, 3]);
    });

    test('should not select duplicate items', () {
      // Arrange
      final container = ProviderContainer();
      final notifier = container.read(transactionSelectionProvider.notifier);
      addTearDown(container.dispose);

      // Act - Try to add the same item multiple times
      // toggleSelection removes item if already selected (toggle behavior)
      notifier.toggleSelectionMode(1);
      notifier.toggleSelection(1);

      // Assert - Second toggle removes the item and exits selection mode
      final state = container.read(transactionSelectionProvider);
      expect(state.selectedIds, isEmpty);
      expect(state.isSelectionModeActive, isFalse);
    });
  });
}
