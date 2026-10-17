import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps the device keychain/keystore for the Sanctum bearer token.
class TokenStorage {
  TokenStorage() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _tokenKey = 'dukaflow_token';

  Future<String?> read() => _storage.read(key: _tokenKey);

  Future<void> save(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clear() => _storage.delete(key: _tokenKey);
}
