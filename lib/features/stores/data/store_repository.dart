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
    final response =
        await _client.guard(() => _client.dio.get('/branches/$id'));
    return StoreDetail.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Store> create(
      {required String name, String? address, String? phone}) async {
    final response = await _client.guard(() => _client.dio.post('/branches',
        data: {'name': name, 'address': address, 'phone': phone}));
    return Store.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }
}
