import '../../../core/api/api_client.dart';
import '../../invoices/data/invoice_models.dart';
import '../../pos/data/pos_models.dart';
import 'customer_models.dart';

class CustomerPage {
  CustomerPage({required this.items, required this.hasMore});

  final List<Customer> items;
  final bool hasMore;
}

class CustomerDetail {
  CustomerDetail(
      {required this.customer, required this.sales, required this.invoices});

  final Customer customer;
  final List<SaleResult> sales;
  final List<Invoice> invoices;
}

class CustomerRepository {
  CustomerRepository(this._client);

  final ApiClient _client;

  /// Unpaginated typeahead used by the customer picker sheet.
  Future<List<Customer>> search(String query) async {
    final response = await _client.guard(
      () => _client.dio.get('/customers',
          queryParameters: {if (query.isNotEmpty) 'search': query}),
    );
    final data = (response.data as Map<String, dynamic>)['data'] as List;
    return data
        .map((e) => Customer.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CustomerPage> list({String? search, int page = 1}) async {
    final response = await _client.guard(
      () => _client.dio.get('/customers', queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
      }),
    );
    final data = response.data as Map<String, dynamic>;
    final items = (data['data'] as List)
        .map((e) => Customer.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = data['meta'] as Map<String, dynamic>?;
    final hasMore = meta != null &&
        (meta['current_page'] as int) < (meta['last_page'] as int);
    return CustomerPage(items: items, hasMore: hasMore);
  }

  Future<CustomerDetail> get(int id) async {
    final response =
        await _client.guard(() => _client.dio.get('/customers/$id'));
    final data = response.data as Map<String, dynamic>;
    return CustomerDetail(
      customer: Customer.fromJson(data['data'] as Map<String, dynamic>),
      sales: (data['sales'] as List? ?? [])
          .map((e) => SaleResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      invoices: (data['invoices'] as List? ?? [])
          .map((e) => Invoice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Customer> create({
    required String name,
    String? phone,
    String? email,
    String? address,
  }) async {
    final response = await _client.guard(
      () => _client.dio.post('/customers', data: {
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
      }),
    );
    return Customer.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }

  Future<Customer> update(
    int id, {
    required String name,
    String? phone,
    String? email,
    String? address,
  }) async {
    final response = await _client.guard(
      () => _client.dio.patch('/customers/$id', data: {
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
      }),
    );
    return Customer.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }
}
