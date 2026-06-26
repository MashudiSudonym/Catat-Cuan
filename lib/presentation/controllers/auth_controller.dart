import 'package:catat_cuan/data/services/shared_preferences_service.dart';
import 'package:catat_cuan/domain/entities/backup/auth_user.dart';
import 'package:catat_cuan/presentation/providers/repositories/repository_providers.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

/// Auth state — `AsyncValue<AuthUser?>`.
///
/// - [AsyncLoading] while checking for an existing session or signing in.
/// - [AsyncData] with `null` user when not connected.
/// - [AsyncData] with an [AuthUser] when connected.
/// - [AsyncError] when a sign-in attempt failed (message already mapped to
///   Indonesian via [ErrorMessageMapper], never technical text).
typedef AuthState = AsyncValue<AuthUser?>;

/// Controller for Google Sign-In state, kept separate from backup progress.
///
/// Per AGENTS.md: initialize in [build], NOT in a constructor. On build it
/// checks for an existing signed-in user (e.g. on app restart after a prior
/// successful sign-in). Sign-in persists the connected email to
/// SharedPreferences; sign-out clears backup metadata.
@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() {
    _checkExistingUser();
    return const AsyncValue.loading();
  }

  /// Check for an existing signed-in user (token may still be valid).
  Future<void> _checkExistingUser() async {
    final result = await ref.read(authRepositoryProvider).getSignedInUser();
    if (result.isSuccess) {
      state = AsyncValue.data(result.data);
    } else {
      state = const AsyncValue.data(null);
    }
  }

  /// Start Google Sign-In. On success, persists the connected email.
  /// On failure, surfaces a user-friendly Indonesian error (per BKP-07).
  Future<void> signIn() async {
    state = const AsyncValue.loading();
    final result = await ref.read(authRepositoryProvider).signIn();
    if (result.isSuccess && result.data != null) {
      final prefs = SharedPreferencesService();
      await prefs.setConnectedAccountEmail(result.data!.email);
      state = AsyncValue.data(result.data);
    } else if (result.isFailure) {
      state = AsyncValue.error(
        ErrorMessageMapper.getUserMessage(result.failure),
        StackTrace.current,
      );
    } else {
      // Success with null user (e.g. user dismissed without selecting) —
      // stay disconnected, surface as idle not-connected state.
      state = const AsyncValue.data(null);
    }
  }

  /// Sign out and clear persisted backup metadata (email + last backup date).
  Future<void> signOut() async {
    final result = await ref.read(authRepositoryProvider).signOut();
    if (result.isSuccess) {
      final prefs = SharedPreferencesService();
      await prefs.clearBackupMetadata();
      state = const AsyncValue.data(null);
    }
  }
}
