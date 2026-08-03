import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'token_store.g.dart';

@Riverpod(keepAlive: true)
TokenStore tokenStore(Ref ref) =>
    SecureTokenStore(const FlutterSecureStorage());

/// Contract first, so tests never touch the platform keychain.
abstract interface class TokenStore {
  Future<String?> accessToken();
  Future<String?> refreshToken();
  Future<void> save({required String access, required String refresh});
  Future<void> clear();
  Future<String?> exchange(String refreshToken);
}

class SecureTokenStore implements TokenStore {
  const SecureTokenStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessKey = 'auth.access';
  static const _refreshKey = 'auth.refresh';

  @override
  Future<String?> accessToken() => _storage.read(key: _accessKey);

  @override
  Future<String?> refreshToken() => _storage.read(key: _refreshKey);

  @override
  Future<void> save({required String access, required String refresh}) async {
    // Tokens go in the keychain, never in SharedPreferences. On Android,
    // preferences are plain XML readable by anything with root.
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }

  @override
  Future<String?> exchange(String refreshToken) async {
    // Implemented by the auth feature's data layer and injected in di.dart.
    // Kept off this interface's happy path so the token store stays a
    // storage concern rather than a network one.
    throw UnimplementedError('Bound in app/di.dart to AuthRepository');
  }
}
