import '../../../core/api/api_client.dart';
import 'order_models.dart';

class OrderRepository {
  OrderRepository(this._client);

  final ApiClient _client;

  MarketOrder _order(dynamic data) => MarketOrder.fromJson(
    (data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
  );

  List<MarketOrder> _orders(dynamic data) =>
      ((data as Map<String, dynamic>)['data'] as List)
          .map((e) => MarketOrder.fromJson(e as Map<String, dynamic>))
          .toList();

  // --- Customer -----------------------------------------------------------

  Future<CartData> cart() async {
    final r = await _client.guard(() => _client.dio.get('/customer/cart'));
    return CartData.fromJson(r.data as Map<String, dynamic>);
  }

  Future<CartData> addToCart(int offerId, double quantity) async {
    final r = await _client.guard(
      () => _client.dio.post(
        '/customer/cart/items',
        data: {'offer_id': offerId, 'quantity': quantity},
      ),
    );
    return CartData.fromJson(r.data as Map<String, dynamic>);
  }

  /// Quantity 0 removes the line.
  Future<CartData> setCartQuantity(int offerId, double quantity) async {
    final r = await _client.guard(
      () => _client.dio.put(
        '/customer/cart/items/$offerId',
        data: {'quantity': quantity},
      ),
    );
    return CartData.fromJson(r.data as Map<String, dynamic>);
  }

  Future<List<MarketOrder>> checkout({String? note, String? phone}) async {
    final r = await _client.guard(
      () => _client.dio.post(
        '/customer/checkout',
        data: {'note': note, 'phone': phone},
      ),
    );
    return _orders(r.data);
  }

  Future<List<MarketOrder>> myOrders() async {
    final r = await _client.guard(() => _client.dio.get('/customer/orders'));
    return _orders(r.data);
  }

  Future<MarketOrder> myOrder(int id) async {
    final r = await _client.guard(
      () => _client.dio.get('/customer/orders/$id'),
    );
    return _order(r.data);
  }

  Future<MarketOrder> cancel(int id, {String? reason}) async {
    final r = await _client.guard(
      () => _client.dio.post(
        '/customer/orders/$id/cancel',
        data: {'reason': reason},
      ),
    );
    return _order(r.data);
  }

  // --- Seller -------------------------------------------------------------

  /// [status]: open (default), pending, accepted, preparing,
  /// ready_for_pickup, completed, rejected, cancelled or all.
  Future<List<MarketOrder>> sellerOrders({String status = 'open'}) async {
    final r = await _client.guard(
      () => _client.dio.get('/orders', queryParameters: {'status': status}),
    );
    return _orders(r.data);
  }

  Future<MarketOrder> sellerOrder(int id) async {
    final r = await _client.guard(() => _client.dio.get('/orders/$id'));
    return _order(r.data);
  }

  Future<MarketOrder> advance(int id, String status, {String? reason}) async {
    final r = await _client.guard(
      () => _client.dio.post(
        '/orders/$id/status',
        data: {'status': status, if (reason != null) 'reason': reason},
      ),
    );
    return _order(r.data);
  }

  // --- Both ---------------------------------------------------------------

  Future<(int, List<AppNotification>)> notifications() async {
    final r = await _client.guard(() => _client.dio.get('/me/notifications'));
    final data = r.data as Map<String, dynamic>;
    return (
      data['unread_count'] as int,
      (data['data'] as List)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> markNotificationsRead() =>
      _client.guard(() => _client.dio.post('/me/notifications/read'));
}
