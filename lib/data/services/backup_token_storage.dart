/// Secure token storage for Google OAuth credentials
///
/// Uses flutter_secure_storage to encrypt tokens at rest using
/// platform Keychain (iOS) / EncryptedSharedPreferences (Android).
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages secure storage of Google OAuth authentication headers
class BackupTokenStorage {
  static const _authHeadersKey = 'backup_auth_headers';
  static const _accessTokenKey = 'backup_access_token';
  static const _tokenExpiryKey = 'backup_token_expiry';

  final FlutterSecureStorage _secureStorage;

  BackupTokenStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Saves authentication headers from Google Sign-In
  Future<void> saveAuthHeaders(Map<String, String> headers) async {
    // Store each header as a separate key for reliability
    for (final entry in headers.entries) {
      await _secureStorage.write(
        key: '${_authHeadersKey}_${entry.key}',
        value: entry.value,
      );
    }
  }

  /// Retrieves stored authentication headers
  ///
  /// Returns null if no headers are stored.
  Future<Map<String, String>?> getAuthHeaders() async {
    final authHeader = await _secureStorage.read(
      key: '${_authHeadersKey}_Authorization',
    );
    if (authHeader == null) return null;

    final authUserHeader = await _secureStorage.read(
      key: '${_authHeadersKey}_X-Goog-AuthUser',
    );

    return {
      'Authorization': authHeader,
      if (authUserHeader != null) 'X-Goog-AuthUser': authUserHeader,
    };
  }

  /// Synchronous access to auth headers (cached from last signIn)
  ///
  /// This is used by GoogleDriveServiceImpl which needs headers
  /// on demand without async calls in provider construction.
  Map<String, String> _cachedHeaders = {};

  /// Updates the cached headers (called after signIn/refresh)
  void updateCachedHeaders(Map<String, String> headers) {
    _cachedHeaders = Map.from(headers);
  }

  /// Gets cached auth headers synchronously
  Map<String, String> getAuthHeadersSync() {
    return _cachedHeaders;
  }

  /// Clears all stored authentication data
  Future<void> clearAuthHeaders() async {
    _cachedHeaders = {};
    await _secureStorage.delete(key: '${_authHeadersKey}_Authorization');
    await _secureStorage.delete(key: '${_authHeadersKey}_X-Goog-AuthUser');
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _tokenExpiryKey);
  }

  /// Saves the access token for easy access
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token);
  }

  /// Gets the stored access token
  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: _accessTokenKey);
  }
}
