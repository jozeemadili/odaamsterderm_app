import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../auth/data/auth_models.dart';
import 'transfer_models.dart';

class TransferRepository {
  TransferRepository(this._client);

  final ApiClient _client;

  Future<TransferList> list() async {
    final response = await _client.guard(
      () => _client.dio.get('/transfers', queryParameters: {'per_page': 50}),
    );
    final data = response.data as Map<String, dynamic>;
    List<StoreRef> stores(String key) => ((data[key] as List?) ?? const [])
        .map((e) => StoreRef.fromJson(e as Map<String, dynamic>))
        .toList();
    return TransferList(
      items: (data['data'] as List)
          .map((e) => StockTransfer.fromJson(e as Map<String, dynamic>))
          .toList(),
      canSend: data['can_send'] as bool? ?? false,
      fromStores: stores('from_stores'),
      toStores: stores('to_stores'),
    );
  }

  Future<StockTransfer> get(int id) =>
      _one(() => _client.dio.get('/transfers/$id'));

  Future<List<TransferStock>> stock(int storeId, {String? search}) async {
    final response = await _client.guard(
      () => _client.dio.get(
        '/transfers/stock',
        queryParameters: {
          'store_id': storeId,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      ),
    );
    return ((response.data as Map<String, dynamic>)['data'] as List)
        .map((e) => TransferStock.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<StockTransfer> send({
    required int fromStoreId,
    required int toStoreId,
    required Map<int, double> quantities,
    String? notes,
  }) => _one(
    () => _client.dio.post(
      '/transfers',
      data: {
        'from_store_id': fromStoreId,
        'to_store_id': toStoreId,
        'notes': notes,
        'items': [
          for (final entry in quantities.entries)
            {'inventory_item_id': entry.key, 'quantity': entry.value},
        ],
      },
    ),
  );

  Future<StockTransfer> receive(int id) =>
      _one(() => _client.dio.post('/transfers/$id/receive'));

  Future<StockTransfer> cancel(int id) =>
      _one(() => _client.dio.post('/transfers/$id/cancel'));

  Future<StockTransfer> _one(Future<Response<dynamic>> Function() call) async {
    final response = await _client.guard(call);
    return StockTransfer.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }
}
