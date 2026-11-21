import '../../../core/api/api_client.dart';
import '../../market/data/market_models.dart';
import '../../orders/data/order_models.dart';
import 'chick_models.dart';

/// Day-old chicks: agents and order days (public), booking boxes
/// (customers), and an agent's own contracts and order days.
class ChickRepository {
  ChickRepository(this._client);

  final ApiClient _client;

  Future<ChickCatalogue> catalogue({MarketLocation? from}) async {
    final r = await _client.guard(
      () => _client.dio.get('/market/chicks', queryParameters: from?.toQuery()),
    );
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

  // --- Agent ---------------------------------------------------------------

  Future<AgentChickSetup> setup() async {
    final r = await _client.guard(() => _client.dio.get('/chicks'));
    return AgentChickSetup.fromJson(r.data as Map<String, dynamic>);
  }

  /// Creates a contract, or updates it when [id] is given.
  Future<void> saveContract(Map<String, dynamic> data, {int? id}) =>
      _client.guard(
        () => id == null
            ? _client.dio.post('/chicks/contracts', data: data)
            : _client.dio.put('/chicks/contracts/$id', data: data),
      );

  Future<void> addDay(Map<String, dynamic> data) =>
      _client.guard(() => _client.dio.post('/chicks/days', data: data));

  Future<void> updateDay(int id, Map<String, dynamic> data) =>
      _client.guard(() => _client.dio.patch('/chicks/days/$id', data: data));

  Future<void> deleteDay(int id) =>
      _client.guard(() => _client.dio.delete('/chicks/days/$id'));

  Future<List<ChickBooking>> bookings(int dayId) async {
    final r = await _client.guard(
      () => _client.dio.get('/chicks/days/$dayId/bookings'),
    );
    return [
      for (final b in r.data as List)
        ChickBooking.fromJson(b as Map<String, dynamic>),
    ];
  }
}
