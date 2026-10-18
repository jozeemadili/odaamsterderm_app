import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps the device keychain/keystore for the Sanctum bearer token.
class TokenStorage {
  TokenStorage()
    : _storage = const FlutterSecureStorage(
        // If Android's keystore no longer matches the saved data (e.g. after
        // a reinstall or backup restore), start fresh instead of failing.
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
          resetOnError: true,
        ),
      );

  final FlutterSecureStorage _storage;
  static const _tokenKey = 'odaamsterderm_token';

  Future<String?> read() => _storage.read(key: _tokenKey);

  Future<void> save(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clear() => _storage.delete(key: _tokenKey);
}
