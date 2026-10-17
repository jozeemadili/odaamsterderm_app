import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider =
    Provider<ApiClient>((ref) => ApiClient(ref.watch(tokenStorageProvider)));

final authRepositoryProvider = Provider<AuthRepository>(
    (ref) => AuthRepository(ref.watch(apiClientProvider)));

/// Reference data for the registration screen's dropdowns — public
/// endpoints, so these resolve even before the user has a session.
final businessTypesProvider = FutureProvider.autoDispose(
    (ref) => ref.watch(authRepositoryProvider).businessTypes());

final regionsProvider = FutureProvider.autoDispose(
    (ref) => ref.watch(authRepositoryProvider).regions());

enum AuthStatus { unknown, authenticating, authenticated, unauthenticated }

class AuthState {
  const AuthState({required this.status, this.user, this.merchant});

  const AuthState.unknown() : this(status: AuthStatus.unknown);
  const AuthState.authenticating() : this(status: AuthStatus.authenticating);
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);
  const AuthState.authenticated(DukaUser user, DukaMerchant? merchant)
      : this(status: AuthStatus.authenticated, user: user, merchant: merchant);

  final AuthStatus status;
  final DukaUser? user;
  final DukaMerchant? merchant;
}

/// Owns the app's auth session: restores it from secure storage on boot,
/// and drives login/register/Google-sign-in/logout.
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository, this._tokenStorage)
      : super(const AuthState.unknown()) {
    _restore();
  }

  final AuthRepository _repository;
  final TokenStorage _tokenStorage;

  Future<void> _restore() async {
    try {
      final token = await _tokenStorage.read();
      if (token == null) {
        state = const AuthState.unauthenticated();
        return;
      }

      final (user, merchant) = await _repository.me();
      state = AuthState.authenticated(user, merchant);
    } catch (_) {
      // No readable token, or it's stale/revoked — fail safe to the login
      // screen rather than getting stuck on the splash screen.
      await _tokenStorage.clear().catchError((_) {});
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthState.authenticating();
    try {
      final session = await _repository.login(email: email, password: password);
      await _tokenStorage.save(session.token);
      state = AuthState.authenticated(session.user, session.merchant);
    } catch (_) {
      state = const AuthState.unauthenticated();
      rethrow;
    }
  }

  Future<void> register({
    required String businessName,
    required String ownerName,
    required String phone,
    int? businessTypeId,
    int? regionId,
    required String email,
    String? password,
    String? googleId,
  }) async {
    state = const AuthState.authenticating();
    try {
      final session = await _repository.register(
        businessName: businessName,
        ownerName: ownerName,
        phone: phone,
        businessTypeId: businessTypeId,
        regionId: regionId,
        email: email,
        password: password,
        googleId: googleId,
      );
      await _tokenStorage.save(session.token);
      state = AuthState.authenticated(session.user, session.merchant);
    } catch (_) {
      state = const AuthState.unauthenticated();
      rethrow;
    }
  }

  /// Returns null on success (state updated), or a [GoogleRegistrationRequired]
  /// the caller should hand to a "complete your business details" screen.
  Future<GoogleRegistrationRequired?> loginWithGoogle(String idToken) async {
    state = const AuthState.authenticating();
    try {
      final result = await _repository.loginWithGoogle(idToken);

      if (result is GoogleRegistrationRequired) {
        state = const AuthState.unauthenticated();
        return result;
      }

      final session = result as AuthSession;
      await _tokenStorage.save(session.token);
      state = AuthState.authenticated(session.user, session.merchant);
      return null;
    } catch (_) {
      state = const AuthState.unauthenticated();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {
      // Token may already be invalid server-side — clear locally regardless.
    }
    await _tokenStorage.clear();
    state = const AuthState.unauthenticated();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(
      ref.watch(authRepositoryProvider), ref.watch(tokenStorageProvider)),
);
