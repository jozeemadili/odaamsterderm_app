import '../../../core/api/api_client.dart';
import 'store_models.dart';

class StoreRepository {
  StoreRepository(this._client);

  final ApiClient _client;

  Future<List<Store>> list() async {
    final response = await _client.guard(() => _client.dio.get('/branches'));
    return ((response.data as Map<String, dynamic>)['data'] as List)
        .map((e) => Store.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<StoreDetail> get(int id) async {
    final response = await _client.guard(
      () => _client.dio.get('/branches/$id'),
    );
    return StoreDetail.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Store> create({
    required String name,
    String? address,
    String? phone,
  }) async {
    final response = await _client.guard(
      () => _client.dio.post(
        '/branches',
        data: {'name': name, 'address': address, 'phone': phone},
      ),
    );
    return Store.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  Future<Store> update(
    int id, {
    required String name,
    String? phone,
    String? email,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
    String? pickupInstructions,
    required Map<String, DayHours?> openingHours,
    required bool isMarketplaceEnabled,
  }) async {
    final response = await _client.guard(
      () => _client.dio.patch(
        '/branches/$id',
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'address': address,
          'city': city,
          'latitude': latitude,
          'longitude': longitude,
          'pickup_instructions': pickupInstructions,
          'opening_hours': {
            for (final e in openingHours.entries) e.key: e.value?.toJson(),
          },
          'is_marketplace_enabled': isMarketplaceEnabled,
        },
      ),
    );
    return Store.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }
}
