import '../../../core/api/api_client.dart';
import '../../orders/data/order_models.dart';
import 'chick_models.dart';

/// Day-old chicks: hatch dates (public) and booking boxes (customers).
class ChickRepository {
  ChickRepository(this._client);

  final ApiClient _client;

  Future<ChickCatalogue> catalogue() async {
    final r = await _client.guard(() => _client.dio.get('/market/chicks'));
    return ChickCatalogue.fromJson(r.data as Map<String, dynamic>);
  }

  Future<MarketOrder> book({
    required int hatchDateId,
    required int boxes,
    required int storeId,
    String? phone,
    String? note,
  }) async {
    final r = await _client.guard(
      () => _client.dio.post(
        '/customer/chick-orders',
        data: {
          'hatch_schedule_id': hatchDateId,
          'boxes': boxes,
          'store_id': storeId,
          'phone': phone,
          'note': note,
        },
      ),
    );
    final body = r.data as Map<String, dynamic>;
    return MarketOrder.fromJson((body['data'] ?? body) as Map<String, dynamic>);
  }
}
