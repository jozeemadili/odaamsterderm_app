import '../../../core/api/api_client.dart';
import 'market_models.dart';

/// Public marketplace endpoints — work signed in or not.
class MarketRepository {
  MarketRepository(this._client);

  final ApiClient _client;

  Future<MarketFilters> filters() async {
    final response = await _client.guard(
      () => _client.dio.get('/market/filters'),
    );
    return MarketFilters.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<MarketProduct>> products({
    String? search,
    int? animalTypeId,
    int? categoryId,
    bool inStock = false,
    double? maxPrice,
    MarketSort sort = MarketSort.nearest,
    MarketLocation? from,
    int page = 1,
  }) async {
    final response = await _client.guard(
      () => _client.dio.get(
        '/market/products',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (animalTypeId != null) 'animal_type_id': animalTypeId,
          if (categoryId != null) 'category_id': categoryId,
          if (inStock) 'in_stock': 1,
          if (maxPrice != null) 'max_price': maxPrice,
          'sort': sort.key,
          if (from != null) ...from.toQuery(),
          'page': page,
        },
      ),
    );
    return ((response.data as Map<String, dynamic>)['data'] as List)
        .map((e) => MarketProduct.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MarketProductDetail> product(
    int id, {
    MarketLocation? from,
    MarketSort sort = MarketSort.nearest,
  }) async {
    final response = await _client.guard(
      () => _client.dio.get(
        '/market/products/$id',
        queryParameters: {
          'sort': sort.key,
          if (from != null) ...from.toQuery(),
        },
      ),
    );
    return MarketProductDetail.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<PublicStore>> stores({
    MarketLocation? from,
    int limit = 10,
  }) async {
    final response = await _client.guard(
      () => _client.dio.get(
        '/market/stores',
        queryParameters: {'limit': limit, if (from != null) ...from.toQuery()},
      ),
    );
    return ((response.data as Map<String, dynamic>)['data'] as List)
        .map((e) => PublicStore.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MarketStoreDetail> store(int id, {MarketLocation? from}) async {
    final response = await _client.guard(
      () => _client.dio.get(
        '/market/stores/$id',
        queryParameters: {if (from != null) ...from.toQuery()},
      ),
    );
    return MarketStoreDetail.fromJson(response.data as Map<String, dynamic>);
  }
}
