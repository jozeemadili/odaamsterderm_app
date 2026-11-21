import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import 'agent_catalog_models.dart';
import 'catalog_models.dart';

class CatalogRepository {
  CatalogRepository(this._client);

  final ApiClient _client;

  /// Approved products plus this seller's own pending proposals.
  Future<List<CatalogProduct>> products({
    String? search,
    int? animalTypeId,
    int page = 1,
  }) async {
    final response = await _client.guard(
      () => _client.dio.get(
        '/catalog/products',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (animalTypeId != null) 'animal_type_id': animalTypeId,
          'page': page,
          'per_page': 30,
        },
      ),
    );
    return ((response.data as Map<String, dynamic>)['data'] as List)
        .map((e) => CatalogProduct.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CatalogNode>> animalTypes() async {
    final response = await _client.guard(
      () => _client.dio.get('/catalog/animal-types'),
    );
    return ((response.data as Map<String, dynamic>)['data'] as List)
        .map((e) => CatalogNode.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CatalogNode>> categories({int? animalTypeId}) async {
    final response = await _client.guard(
      () => _client.dio.get(
        '/catalog/categories',
        queryParameters: {
          if (animalTypeId != null) 'animal_type_id': animalTypeId,
        },
      ),
    );
    return ((response.data as Map<String, dynamic>)['data'] as List)
        .map((e) => CatalogNode.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProducerInfo>> producers() async {
    final response = await _client.guard(
      () => _client.dio.get('/catalog/producers'),
    );
    return ((response.data as Map<String, dynamic>)['data'] as List)
        .map((e) => ProducerInfo.fromJson(e)!)
        .toList();
  }

  /// Products to pick into stock: by search (incl. Kiswahili), companies or
  /// animal; most-stocked first. Pack sizes the agent has are marked.
  Future<List<PickProduct>> pick({
    String? search,
    List<int> producerIds = const [],
    int? animalTypeId,
  }) async {
    final response = await _client.guard(
      () => _client.dio.get(
        '/catalog/pick',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'q': search,
          if (producerIds.isNotEmpty) 'producer_ids[]': producerIds,
          'animal_type_id': ?animalTypeId,
        },
      ),
    );
    return ((response.data as Map<String, dynamic>)['data'] as List)
        .map((e) => PickProduct.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PickProducer>> pickProducers() async {
    final response = await _client.guard(
      () => _client.dio.get('/catalog/pick/producers'),
    );
    return ((response.data as Map<String, dynamic>)['data'] as List)
        .map((e) => PickProducer.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AddToStockResult> addFromCatalogue({
    required int branchId,
    required List<PickLine> lines,
    bool listOnline = true,
  }) async {
    final response = await _client.guard(
      () => _client.dio.post(
        '/inventory/from-catalogue',
        data: {
          'branch_id': branchId,
          'lines': [
            for (final l in lines)
              {
                'product_variant_id': l.variantId,
                'unit_price': l.unitPrice,
                'quantity': l.quantity,
                'list_online': listOnline,
              },
          ],
        },
      ),
    );
    return AddToStockResult.fromJson(response.data as Map<String, dynamic>);
  }

  /// Catalogue products close to [name] ("Is it one of these?").
  Future<List<PickProduct>> similar(String name, {int? producerId}) async {
    final response = await _client.guard(
      () => _client.dio.get(
        '/catalog/similar',
        queryParameters: {'name': name, 'producer_id': ?producerId},
      ),
    );
    return ((response.data as Map<String, dynamic>)['data'] as List)
        .map((e) => PickProduct.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProductRequestInfo>> productRequests() async {
    final response = await _client.guard(
      () => _client.dio.get('/product-requests'),
    );
    return ((response.data as Map<String, dynamic>)['data'] as List)
        .map((e) => ProductRequestInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Asks the catalogue team to add a product, with front and back label
  /// photos. With [branchId], the item is also stocked for in-shop sale.
  Future<ProductRequestInfo> requestProduct({
    required String name,
    int? producerId,
    String? producerName,
    required String packSize,
    String? notes,
    required List<int> front,
    required List<int> back,
    int? branchId,
    double? unitPrice,
    double? quantity,
  }) async {
    final form = FormData.fromMap({
      'name': name,
      'producer_id': ?producerId,
      if (producerId == null) 'producer_name': producerName,
      'pack_size': packSize,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      'front': MultipartFile.fromBytes(front, filename: 'front.jpg'),
      'back': MultipartFile.fromBytes(back, filename: 'back.jpg'),
      if (branchId != null) ...{
        'branch_id': branchId,
        'unit_price': unitPrice,
        'quantity': quantity,
      },
    });
    final response = await _client.guard(
      () => _client.dio.post('/product-requests', data: form),
    );
    return ProductRequestInfo.fromJson(response.data as Map<String, dynamic>);
  }
}
