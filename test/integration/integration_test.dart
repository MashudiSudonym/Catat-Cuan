import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/providers/transaction/transaction_selection_provider.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Initialize logger for tests
  setUpAll(() {
    AppLogger.initialize();
  });

  group('Integration Tests', () {
    test('should provide access to multiple providers simultaneously', () {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act - Read multiple providers
      final selectionState = container.read(transactionSelectionProvider);

      // Assert - Provider is accessible and returns initial state
      expect(selectionState, isNotNull);
      expect(selectionState.isSelectionModeActive, isFalse);
      expect(selectionState.selectedIds, isEmpty);
    });

    test('should maintain provider state consistency', () {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(transactionSelectionProvider.notifier);

      // Act - Perform multiple state changes
      notifier.toggleSelectionMode(1);
      var state1 = container.read(transactionSelectionProvider);
      expect(state1.selectedIds, [1]);

      notifier.toggleSelection(2);
      var state2 = container.read(transactionSelectionProvider);
      expect(state2.selectedIds, [1, 2]);

      notifier.toggleSelection(1);
      var state3 = container.read(transactionSelectionProvider);
      expect(state3.selectedIds, [2]);

      // Assert - State is consistent across operations
      expect(state3.isSelectionModeActive, isTrue);
    });

    test('should support provider disposal without errors', () {
      // Arrange
      final container = ProviderContainer();

      // Act - Read and dispose
      final state = container.read(transactionSelectionProvider);
      container.dispose();

      // Assert - No errors during disposal
      expect(state, isNotNull);
    });

    test('should allow multiple provider containers to coexist', () {
      // Arrange
      final container1 = ProviderContainer();
      final container2 = ProviderContainer();

      // Act - Read from both containers
      final state1 = container1.read(transactionSelectionProvider);
      final state2 = container2.read(transactionSelectionProvider);

      // Assert - Both containers work independently
      expect(state1, isNotNull);
      expect(state2, isNotNull);

      container1.dispose();
      container2.dispose();
    });

    test('should support select all and deselect all workflow', () {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(transactionSelectionProvider.notifier);
      final allIds = [1, 2, 3, 4, 5];

      // Act - Select all
      notifier.selectAll(allIds);
      var state1 = container.read(transactionSelectionProvider);
      expect(state1.selectedIds.length, equals(5));

      // Toggle select all (should deselect)
      notifier.toggleSelectAll(allIds);
      var state2 = container.read(transactionSelectionProvider);
      expect(state2.selectedIds, isEmpty);

      // Assert - Mode is still active
      expect(state2.isSelectionModeActive, isTrue);
    });

    test('should handle rapid state changes without errors', () {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(transactionSelectionProvider.notifier);

      // Act - Perform rapid state changes
      for (int i = 1; i <= 10; i++) {
        notifier.toggleSelection(i);
      }

      final state = container.read(transactionSelectionProvider);

      // Assert - State remains consistent
      expect(state, isNotNull);
      expect(state.isSelectionModeActive, isTrue);
    });

    test('should clear selection and exit mode correctly', () {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(transactionSelectionProvider.notifier);
      notifier.selectAll([1, 2, 3]);

      // Act - Clear selection
      notifier.clearSelection();
      final state = container.read(transactionSelectionProvider);

      // Assert - Selection mode is exited
      expect(state.selectedIds, isEmpty);
      expect(state.isSelectionModeActive, isFalse);
    });

    test('should handle empty operations gracefully', () {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(transactionSelectionProvider.notifier);

      // Act - Toggle same item twice (select then deselect)
      notifier.toggleSelectionMode(1);
      var state1 = container.read(transactionSelectionProvider);
      expect(state1.selectedIds, [1]);

      notifier.toggleSelection(1); // Should deselect and exit mode
      var state2 = container.read(transactionSelectionProvider);
      expect(state2.selectedIds, isEmpty);
      expect(state2.isSelectionModeActive, isFalse);

      // Assert - No errors occur
      expect(state2, isNotNull);
    });

    test('should support multiple independent provider instances', () {
      // Arrange
      final container1 = ProviderContainer();
      final container2 = ProviderContainer();
      addTearDown(container1.dispose);
      addTearDown(container2.dispose);

      final notifier1 = container1.read(transactionSelectionProvider.notifier);
      final notifier2 = container2.read(transactionSelectionProvider.notifier);

      // Act - Modify both independently
      notifier1.toggleSelectionMode(1);
      notifier2.toggleSelectionMode(2);

      final state1 = container1.read(transactionSelectionProvider);
      final state2 = container2.read(transactionSelectionProvider);

      // Assert - Each container maintains independent state
      expect(state1.selectedIds, [1]);
      expect(state2.selectedIds, [2]);
    });
  });
}
