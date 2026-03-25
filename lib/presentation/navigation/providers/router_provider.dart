import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:catat_cuan/presentation/navigation/routes/app_router.dart';
import 'package:catat_cuan/presentation/providers/onboarding/onboarding_provider.dart';

/// Riverpod provider for GoRouter
/// Following SOLID principles:
/// - SRP: Single responsibility for providing GoRouter instance
/// - DIP: Depends on abstraction (Ref) for reactive redirects
///
/// This provider watches the onboarding state to trigger redirects
/// when the onboarding status changes.
final routerProvider = Provider<GoRouter>((ref) {
  // Watch onboarding state to trigger router rebuild on state change
  // This enables reactive redirects based on onboarding completion
  ref.watch(onboardingProvider);

  // Create and return GoRouter with current ref
  return createGoRouter(ref);
});
