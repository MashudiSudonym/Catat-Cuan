import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:catat_cuan/presentation/providers/repositories/repository_providers.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

part 'category_seeding_provider.g.dart';

/// Provider for managing category seeding state
///
/// Checks if categories exist in the database and provides
/// a method to seed default categories after onboarding.
///
/// State: `true` = categories exist (no seeding needed),
///        `false` = categories don't exist (seeding needed)
@riverpod
class CategorySeedingNotifier extends _$CategorySeedingNotifier {
  @override
  Future<bool> build() async {
    final repository = ref.read(categorySeedingRepositoryProvider);
    final result = await repository.needsSeed();

    if (result.isSuccess) {
      // needsSeed returns true when seeding IS needed, so invert
      return !(result.data ?? true);
    } else {
      AppLogger.e('Failed to check seeding status: ${result.failure}');
      return false; // Assume seeding needed on error
    }
  }

  /// Seed default categories to the database
  ///
  /// Updates state to `true` on success, throws on failure.
  Future<void> seedCategories() async {
    final repository = ref.read(categorySeedingRepositoryProvider);
    final result = await repository.seedDefaultCategories();

    if (result.isSuccess) {
      state = const AsyncValue.data(true);
    } else {
      AppLogger.e('Failed to seed categories: ${result.failure}');
      throw Exception(result.failure?.message ?? 'Failed to seed categories');
    }
  }
}
