import '../../../core/api/api_client.dart';
import 'auth_models.dart';

class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.guard(
      () => _client.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      ),
    );
    return AuthSession.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthSession> register({
    required String businessName,
    required String ownerName,
    required String phone,
    int? businessTypeId,
    int? regionId,
    required String email,
    String? password,
    String? googleId,
  }) async {
    final response = await _client.guard(
      () => _client.dio.post(
        '/auth/register',
        data: {
          'business_name': businessName,
          'owner_name': ownerName,
          'phone': phone,
          'business_type_id': businessTypeId,
          'region_id': regionId,
          'email': email,
          'password': password,
          'google_id': googleId,
        },
      ),
    );
    return AuthSession.fromJson(response.data as Map<String, dynamic>);
  }

  /// Marketplace customer sign-up.
  Future<AuthSession> registerCustomer({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final response = await _client.guard(
      () => _client.dio.post(
        '/auth/register-customer',
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
        },
      ),
    );
    return AuthSession.fromJson(response.data as Map<String, dynamic>);
  }

  /// Saves a customer's profile / default marketplace location.
  Future<DukaUser> updateCustomerProfile({
    String? name,
    String? phone,
    double? latitude,
    double? longitude,
    String? locationLabel,
  }) async {
    final response = await _client.guard(
      () => _client.dio.patch(
        '/customer/profile',
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (locationLabel != null) 'location_label': locationLabel,
        },
      ),
    );
    return DukaUser.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  Future<List<BusinessTypeOption>> businessTypes() async {
    final response = await _client.guard(
      () => _client.dio.get('/business-types'),
    );
    return ((response.data as Map<String, dynamic>)['data'] as List)
        .map((e) => BusinessTypeOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RegionOption>> regions() async {
    final response = await _client.guard(() => _client.dio.get('/regions'));
    return ((response.data as Map<String, dynamic>)['data'] as List)
        .map((e) => RegionOption.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Verifies a Google ID token. Returns [AuthSession] if the account
  /// already exists, or [GoogleRegistrationRequired] if the caller should
  /// show the "complete your business details" form next.
  ///
  /// With [asCustomer], a new Google account becomes a marketplace customer
  /// straight away instead of needing business details.
  Future<Object> loginWithGoogle(
    String idToken, {
    bool asCustomer = false,
  }) async {
    final response = await _client.guard(
      () => _client.dio.post(
        '/auth/google',
        data: {'id_token': idToken, if (asCustomer) 'account_type': 'customer'},
      ),
    );
    final data = response.data as Map<String, dynamic>;

    if (data['needs_registration'] == true) {
      return GoogleRegistrationRequired.fromJson(data);
    }
    return AuthSession.fromJson(data);
  }

  Future<void> logout() =>
      _client.guard(() => _client.dio.post('/auth/logout'));

  Future<(DukaUser, DukaMerchant?)> me() async {
    final response = await _client.guard(() => _client.dio.get('/auth/me'));
    final data = response.data as Map<String, dynamic>;
    return (
      DukaUser.fromJson(data['user'] as Map<String, dynamic>),
      data['merchant'] != null
          ? DukaMerchant.fromJson(data['merchant'] as Map<String, dynamic>)
          : null,
    );
  }
}
