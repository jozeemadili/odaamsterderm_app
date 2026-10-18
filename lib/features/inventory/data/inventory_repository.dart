import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/api/api_client.dart';
import 'inventory_models.dart';

/// A page of inventory items plus whether another page exists, mirroring
/// Laravel's paginator meta (`meta.current_page` / `meta.last_page`).
class InventoryPage {
  InventoryPage({required this.items, required this.hasMore});

  final List<InventoryItem> items;
  final bool hasMore;
}

class InventoryRepository {
  InventoryRepository(this._client);

  final ApiClient _client;

  Future<InventoryPage> list({
    String? search,
    int? categoryId,
    int? branchId,
    String? marketplace,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _client.guard(
      () => _client.dio.get(
        '/inventory',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (categoryId != null) 'category_id': categoryId,
          if (branchId != null) 'branch_id': branchId,
          // listed, hidden or out_of_stock
          if (marketplace != null) 'marketplace': marketplace,
          'page': page,
          'per_page': perPage,
        },
      ),
    );

    final data = response.data as Map<String, dynamic>;
    final items = (data['data'] as List)
        .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = data['meta'] as Map<String, dynamic>?;
    final hasMore =
        meta != null &&
        (meta['current_page'] as int) < (meta['last_page'] as int);

    return InventoryPage(items: items, hasMore: hasMore);
  }

  Future<List<InventoryCategory>> categories() async {
    final response = await _client.guard(
      () => _client.dio.get('/inventory/categories'),
    );
    return (response.data as List)
        .map((e) => InventoryCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<InventoryCategory> createCategory({required String name}) async {
    final response = await _client.guard(
      () => _client.dio.post('/inventory/categories', data: {'name': name}),
    );
    return InventoryCategory.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Branch>> branches() async {
    final response = await _client.guard(() => _client.dio.get('/branches'));
    return ((response.data as Map<String, dynamic>)['data'] as List)
        .map((e) => Branch.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Branch> createBranch({
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
    return Branch.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  Future<InventoryItem> get(int id) async {
    final response = await _client.guard(
      () => _client.dio.get('/inventory/$id'),
    );
    return InventoryItem.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  /// Returns null (not an error) when no product matches — the caller
  /// offers "add new product" pre-filled with the scanned code.
  Future<InventoryItem?> lookupBarcode(String code) async {
    try {
      final response = await _client.guard(
        () => _client.dio.get('/inventory/lookup-barcode/$code'),
      );
      return InventoryItem.fromJson(
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<InventoryItem> create({
    required String name,
    String? sku,
    String? barcode,
    int? categoryId,
    int? branchId,
    String? unit,
    double? reorderLevel,
    double? unitCost,
    double? unitPrice,
    double? quantityOnHand,
    String? expiryDate,
    int? productId,
  }) async {
    final response = await _client.guard(
      () => _client.dio.post(
        '/inventory',
        data: {
          'name': name,
          'product_id': productId,
          'sku': sku,
          'barcode': barcode,
          'category_id': categoryId,
          'branch_id': branchId,
          'unit': unit,
          'reorder_level': reorderLevel,
          'unit_cost': unitCost,
          'unit_price': unitPrice,
          'quantity_on_hand': quantityOnHand,
          'expiry_date': expiryDate,
        },
      ),
    );
    return InventoryItem.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  Future<InventoryItem> update(
    int id, {
    String? name,
    String? sku,
    String? barcode,
    int? categoryId,
    int? branchId,
    String? unit,
    double? reorderLevel,
    double? unitCost,
    double? unitPrice,
    String? expiryDate,
  }) async {
    final response = await _client.guard(
      () => _client.dio.patch(
        '/inventory/$id',
        data: {
          if (name != null) 'name': name,
          'sku': sku,
          'barcode': barcode,
          'category_id': categoryId,
          'branch_id': branchId,
          'unit': unit,
          'reorder_level': reorderLevel,
          'unit_cost': unitCost,
          'unit_price': unitPrice,
          'expiry_date': expiryDate,
        },
      ),
    );
    return InventoryItem.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  Future<void> delete(int id) =>
      _client.guard(() => _client.dio.delete('/inventory/$id'));

  Future<InventoryItem> removeImage(int id) async {
    final response = await _client.guard(
      () => _client.dio.delete('/inventory/$id/image'),
    );
    return InventoryItem.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  Future<InventoryItem> uploadImage(int id, File imageFile) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path),
    });
    final response = await _client.guard(
      () => _client.dio.post('/inventory/$id/image', data: formData),
    );
    return InventoryItem.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  Future<InventoryItem> generateBarcode(int id) async {
    final response = await _client.guard(
      () => _client.dio.post('/inventory/$id/barcode'),
    );
    return InventoryItem.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  /// For type "adjustment", [quantity] is the counted stock level and a
  /// [reason] is required.
  Future<InventoryItem> stockMovement(
    int id, {
    required String type,
    required double quantity,
    String? reason,
  }) async {
    final response = await _client.guard(
      () => _client.dio.post(
        '/inventory/$id/stock-movement',
        data: {
          'type': type,
          'quantity': quantity,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      ),
    );
    return InventoryItem.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  /// Links (or with null, unlinks) the item to a catalog product.
  Future<InventoryItem> linkCatalogProduct(int id, int? productId) async {
    final response = await _client.guard(
      () =>
          _client.dio.patch('/inventory/$id', data: {'product_id': productId}),
    );
    return InventoryItem.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  Future<InventoryItem> updateMarketplace(
    int id, {
    required bool visible,
    required double quantity,
    bool active = true,
  }) async {
    final response = await _client.guard(
      () => _client.dio.patch(
        '/inventory/$id/marketplace',
        data: {
          'is_marketplace_visible': visible,
          'marketplace_quantity': quantity,
          'active': active,
        },
      ),
    );
    return InventoryItem.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  /// Downloads a printable barcode-label sheet (3-up, name/price optional)
  /// for the given products to a local temp file and returns its path,
  /// ready to hand to a share sheet — same PDF the web portal generates.
  Future<String> downloadBarcodeLabelsPdf({
    required List<int> itemIds,
    required bool showProductName,
    required bool showPrice,
    int copies = 1,
  }) async {
    final response = await _client.guard(
      () => _client.dio.post<List<int>>(
        '/inventory/barcode-labels',
        data: {
          'item_ids': itemIds,
          'show_product_name': showProductName,
          'show_price': showPrice,
          'copies': copies,
        },
        options: Options(responseType: ResponseType.bytes),
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/barcode-labels.pdf');
    await file.writeAsBytes(response.data as List<int>);
    return file.path;
  }
}
