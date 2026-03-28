import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:catat_cuan/presentation/navigation/routes/app_router.dart';
import 'package:catat_cuan/presentation/providers/onboarding/category_seeding_provider.dart';

/// Riverpod provider for GoRouter
/// Following SOLID principles:
/// - SRP: Single responsibility for providing GoRouter instance
/// - DIP: Depends on abstraction (Ref) for reactive redirects
///
/// This provider watches the category seeding state to trigger redirects
/// when the seeding status changes (categories exist or not).
final routerProvider = Provider<GoRouter>((ref) {
  // Watch category seeding state to trigger router rebuild on state change
  // This enables reactive redirects based on whether categories exist
  ref.watch(categorySeedingProvider);

  // Create and return GoRouter with current ref
  return createGoRouter(ref);
});
