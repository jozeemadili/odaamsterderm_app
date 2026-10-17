import '../../../core/api/api_client.dart';
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

  Future<List<CatalogProduct>> proposals() async {
    final response = await _client.guard(
      () => _client.dio.get('/catalog/proposals'),
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

  Future<CatalogProduct> propose({
    required String name,
    String? packSize,
    required String unit,
    String? brand,
    int? producerId,
    required int animalTypeId,
    required int categoryId,
    String? description,
  }) async {
    final response = await _client.guard(
      () => _client.dio.post(
        '/catalog/products',
        data: {
          'name': name,
          'pack_size': packSize,
          'unit': unit,
          'brand': brand,
          'producer_id': ?producerId,
          'animal_type_id': animalTypeId,
          'product_category_id': categoryId,
          'description': description,
        },
      ),
    );
    return CatalogProduct.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }
}
