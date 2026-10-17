import '../../../core/api/api_client.dart';
import 'stock_receipt_models.dart';

class StockReceiptPage {
  StockReceiptPage({required this.items, required this.hasMore});

  final List<StockReceipt> items;
  final bool hasMore;
}

class StockReceiptRepository {
  StockReceiptRepository(this._client);

  final ApiClient _client;

  Future<StockReceiptPage> list({int page = 1}) async {
    final response = await _client.guard(() =>
        _client.dio.get('/stock-receipts', queryParameters: {'page': page}));
    final data = response.data as Map<String, dynamic>;
    final items = (data['data'] as List)
        .map((e) => StockReceipt.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = data['meta'] as Map<String, dynamic>?;
    final hasMore = meta != null &&
        (meta['current_page'] as int) < (meta['last_page'] as int);
    return StockReceiptPage(items: items, hasMore: hasMore);
  }

  Future<StockReceipt> get(int id) async {
    final response =
        await _client.guard(() => _client.dio.get('/stock-receipts/$id'));
    return StockReceipt.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }

  Future<StockReceipt> create({
    int? supplierId,
    String? referenceNo,
    required String receiptDate,
    String? notes,
  }) async {
    final response = await _client.guard(
      () => _client.dio.post('/stock-receipts', data: {
        'supplier_id': supplierId,
        'reference_no': referenceNo,
        'receipt_date': receiptDate,
        'notes': notes,
      }),
    );
    return StockReceipt.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }

  /// Either [inventoryItemId] (existing product) or [newProductName] (create
  /// one on the fly) must be given — matches the backend's
  /// `required_without` pairing.
  Future<StockReceipt> addItem(
    int receiptId, {
    int? inventoryItemId,
    String? newProductName,
    String? newProductUnit,
    double? newProductUnitPrice,
    required double quantity,
    required double unitCost,
  }) async {
    final response = await _client.guard(
      () => _client.dio.post('/stock-receipts/$receiptId/items', data: {
        'inventory_item_id': inventoryItemId,
        'new_product_name': newProductName,
        'new_product_unit': newProductUnit,
        'new_product_unit_price': newProductUnitPrice,
        'quantity': quantity,
        'unit_cost': unitCost,
      }),
    );
    return StockReceipt.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }

  Future<StockReceipt> removeItem(int receiptId, int itemId) async {
    final response = await _client.guard(
        () => _client.dio.delete('/stock-receipts/$receiptId/items/$itemId'));
    return StockReceipt.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }

  Future<StockReceipt> approve(int receiptId) async {
    final response = await _client
        .guard(() => _client.dio.post('/stock-receipts/$receiptId/approve'));
    return StockReceipt.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }

  Future<StockReceipt> reject(int receiptId) async {
    final response = await _client
        .guard(() => _client.dio.post('/stock-receipts/$receiptId/reject'));
    return StockReceipt.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }
}
