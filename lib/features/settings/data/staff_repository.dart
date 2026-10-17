import '../../../core/api/api_client.dart';
import '../../auth/data/auth_models.dart';

class StaffRepository {
  StaffRepository(this._client);

  final ApiClient _client;

  /// Role value -> display label, matching StaffController::ROLES on the API.
  static const roles = {
    'merchant_manager': 'Manager',
    'merchant_supervisor': 'Supervisor',
    'merchant_sales': 'Sales',
    'merchant_accountant': 'Accountant',
  };

  Future<List<DukaUser>> list() async {
    final response = await _client.guard(() => _client.dio.get('/staff'));
    final data = (response.data as Map<String, dynamic>)['data'] as List;
    return data
        .map((e) => DukaUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DukaUser> create({
    required String name,
    required String email,
    String? phone,
    required String role,
  }) async {
    final response = await _client.guard(
      () => _client.dio.post('/staff', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
      }),
    );
    return DukaUser.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }
}
