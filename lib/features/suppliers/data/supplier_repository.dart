import '../../../core/api/api_client.dart';
import 'supplier_models.dart';

class SupplierPage {
  SupplierPage({required this.items, required this.hasMore});

  final List<Supplier> items;
  final bool hasMore;
}

class SupplierRepository {
  SupplierRepository(this._client);

  final ApiClient _client;

  /// The backend doesn't support a `search` filter on this endpoint, so
  /// every caller — the directory list and the picker sheet alike — pages
  /// through the same plain, name-ordered list.
  Future<SupplierPage> list({int page = 1}) async {
    final response = await _client.guard(
        () => _client.dio.get('/suppliers', queryParameters: {'page': page}));
    final data = response.data as Map<String, dynamic>;
    final items = (data['data'] as List)
        .map((e) => Supplier.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = data['meta'] as Map<String, dynamic>?;
    final hasMore = meta != null &&
        (meta['current_page'] as int) < (meta['last_page'] as int);
    return SupplierPage(items: items, hasMore: hasMore);
  }

  Future<Supplier> get(int id) async {
    final response =
        await _client.guard(() => _client.dio.get('/suppliers/$id'));
    return Supplier.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }

  Future<Supplier> create({
    required String name,
    String? contactPerson,
    String? phone,
    String? address,
    String? notes,
  }) async {
    final response = await _client.guard(
      () => _client.dio.post('/suppliers', data: {
        'name': name,
        'contact_person': contactPerson,
        'phone': phone,
        'address': address,
        'notes': notes,
      }),
    );
    return Supplier.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }

  Future<Supplier> update(
    int id, {
    required String name,
    String? contactPerson,
    String? phone,
    String? address,
    String? notes,
  }) async {
    final response = await _client.guard(
      () => _client.dio.patch('/suppliers/$id', data: {
        'name': name,
        'contact_person': contactPerson,
        'phone': phone,
        'address': address,
        'notes': notes,
      }),
    );
    return Supplier.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }
}
