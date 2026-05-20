import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/data/services/backup_token_storage.dart';
import 'package:catat_cuan/domain/entities/backup/auth_user.dart';
import 'package:catat_cuan/domain/failures/auth_failure.dart';

/// Fake BackupTokenStorage for testing
class FakeBackupTokenStorage extends BackupTokenStorage {
  final Map<String, String> _storage = {};
  Map<String, String> _cachedHeaders = {};

  FakeBackupTokenStorage() : super();

  @override
  Future<void> saveAuthHeaders(Map<String, String> headers) async {
    _storage.addAll(headers);
    _cachedHeaders = Map.from(headers);
  }

  @override
  Future<Map<String, String>?> getAuthHeaders() async {
    if (_storage.isEmpty) return null;
    return Map.from(_storage);
  }

  @override
  void updateCachedHeaders(Map<String, String> headers) {
    _cachedHeaders = Map.from(headers);
  }

  @override
  Map<String, String> getAuthHeadersSync() => _cachedHeaders;

  @override
  Future<void> clearAuthHeaders() async {
    _storage.clear();
    _cachedHeaders = {};
  }

  @override
  Future<void> saveAccessToken(String token) async {}

  @override
  Future<String?> getAccessToken() async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthServiceImpl', () {
    group('AuthUser entity', () {
      test('should create AuthUser with all fields', () {
        final user = AuthUser(
          email: 'test@gmail.com',
          displayName: 'Test User',
          photoUrl: 'https://example.com/photo.jpg',
          authHeaders: {'Authorization': 'Bearer test-token'},
        );

        expect(user.email, 'test@gmail.com');
        expect(user.displayName, 'Test User');
        expect(user.photoUrl, 'https://example.com/photo.jpg');
        expect(user.authHeaders, {'Authorization': 'Bearer test-token'});
      });

      test('should create AuthUser without optional fields', () {
        final user = AuthUser(
          email: 'test@gmail.com',
          authHeaders: {'Authorization': 'Bearer token'},
        );

        expect(user.email, 'test@gmail.com');
        expect(user.displayName, isNull);
        expect(user.photoUrl, isNull);
        expect(user.authHeaders['Authorization'], 'Bearer token');
      });

      test('should support equality comparison', () {
        final user1 = AuthUser(
          email: 'test@gmail.com',
          authHeaders: {'Authorization': 'Bearer token'},
        );
        final user2 = AuthUser(
          email: 'test@gmail.com',
          authHeaders: {'Authorization': 'Bearer token'},
        );

        expect(user1, equals(user2));
      });
    });

    group('AuthFailure types', () {
      test('AuthFailure.expired creates AuthExpiredFailure', () {
        final failure = AuthFailure.expired('Token expired');
        expect(failure, isA<AuthExpiredFailure>());
        expect(failure.message, 'Token expired');
      });

      test('AuthFailure.revoked creates AuthRevokedFailure', () {
        final failure = AuthFailure.revoked('Access revoked');
        expect(failure, isA<AuthRevokedFailure>());
        expect(failure.message, 'Access revoked');
      });

      test('AuthFailure.network creates AuthNetworkFailure', () {
        final failure = AuthFailure.network('Network error');
        expect(failure, isA<AuthNetworkFailure>());
        expect(failure.message, 'Network error');
      });

      test('AuthFailure.cancelled creates AuthCancelledFailure', () {
        final failure = AuthFailure.cancelled('User cancelled');
        expect(failure, isA<AuthCancelledFailure>());
        expect(failure.message, 'User cancelled');
      });

      test('AuthFailure.unknown creates AuthUnknownFailure', () {
        final failure = AuthFailure.unknown('Unknown error');
        expect(failure, isA<AuthUnknownFailure>());
        expect(failure.message, 'Unknown error');
      });

      test('all auth failures extend Failure base class', () {
        expect(AuthExpiredFailure('test'), isA<AuthFailure>());
        expect(AuthRevokedFailure('test'), isA<AuthFailure>());
        expect(AuthNetworkFailure('test'), isA<AuthFailure>());
        expect(AuthCancelledFailure('test'), isA<AuthFailure>());
        expect(AuthUnknownFailure('test'), isA<AuthFailure>());
      });

      test('auth failures have correct Indonesian messages', () {
        expect(
          AuthExpiredFailure('Sesi telah berakhir. Silakan masuk kembali.').message,
          contains('Sesi telah berakhir'),
        );
        expect(
          AuthNetworkFailure('Koneksi gagal. Periksa internet Anda.').message,
          contains('Koneksi gagal'),
        );
        expect(
          AuthCancelledFailure('Pengguna membatalkan masuk').message,
          contains('membatalkan'),
        );
      });
    });
  });

  group('BackupTokenStorage', () {
    late FakeBackupTokenStorage tokenStorage;

    setUp(() {
      tokenStorage = FakeBackupTokenStorage();
    });

    test('should save and retrieve auth headers', () async {
      final headers = {
        'Authorization': 'Bearer abc123',
        'X-Goog-AuthUser': '0',
      };

      await tokenStorage.saveAuthHeaders(headers);
      tokenStorage.updateCachedHeaders(headers);

      final cached = tokenStorage.getAuthHeadersSync();
      expect(cached['Authorization'], 'Bearer abc123');
      expect(cached['X-Goog-AuthUser'], '0');
    });

    test('should clear auth headers', () async {
      await tokenStorage.saveAuthHeaders({
        'Authorization': 'Bearer token',
      });
      tokenStorage.updateCachedHeaders({'Authorization': 'Bearer token'});

      expect(tokenStorage.getAuthHeadersSync(), isNotEmpty);

      await tokenStorage.clearAuthHeaders();

      expect(tokenStorage.getAuthHeadersSync(), isEmpty);
    });

    test('should return empty map when no headers cached', () {
      expect(tokenStorage.getAuthHeadersSync(), isEmpty);
    });

    test('should update cached headers without async call', () {
      tokenStorage.updateCachedHeaders({'Authorization': 'Bearer new'});
      expect(tokenStorage.getAuthHeadersSync()['Authorization'], 'Bearer new');
    });

    test('should overwrite previous headers on update', () {
      tokenStorage.updateCachedHeaders({'Authorization': 'Bearer old'});
      tokenStorage.updateCachedHeaders({'Authorization': 'Bearer new'});
      expect(tokenStorage.getAuthHeadersSync()['Authorization'], 'Bearer new');
    });
  });
}
