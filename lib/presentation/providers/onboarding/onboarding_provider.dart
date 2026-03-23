import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:catat_cuan/data/services/shared_preferences_service.dart';

part 'onboarding_provider.g.dart';

/// Provider for managing onboarding state
/// Tracks whether user has seen onboarding using SharedPreferences
@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  Future<bool> build() async {
    final service = SharedPreferencesService();
    return await service.hasSeenOnboarding();
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    final service = SharedPreferencesService();
    await service.setOnboardingSeen();
    state = const AsyncValue.data(true);
  }

  /// Reset onboarding state (for testing/settings)
  Future<void> resetOnboarding() async {
    final service = SharedPreferencesService();
    await service.resetOnboarding();
    ref.invalidateSelf();
  }
}
