import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';

/// Authenticated user information from Google Sign-In
///
/// Contains user profile data and authentication headers
/// needed for Google Drive API calls.
@freezed
abstract class AuthUser with _$AuthUser {
  const AuthUser._();

  const factory AuthUser({
    required String email,
    String? displayName,
    String? photoUrl,
    required Map<String, String> authHeaders,
  }) = _AuthUser;
}
