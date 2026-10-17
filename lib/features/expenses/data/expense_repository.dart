import '../../../core/api/api_client.dart';
import 'expense_models.dart';

class ExpensePage {
  ExpensePage({required this.items, required this.hasMore});

  final List<Expense> items;
  final bool hasMore;
}

class ExpenseRepository {
  ExpenseRepository(this._client);

  final ApiClient _client;

  Future<ExpensePage> list({int page = 1}) async {
    final response = await _client.guard(
        () => _client.dio.get('/expenses', queryParameters: {'page': page}));
    final data = response.data as Map<String, dynamic>;
    final items = (data['data'] as List)
        .map((e) => Expense.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = data['meta'] as Map<String, dynamic>?;
    final hasMore = meta != null &&
        (meta['current_page'] as int) < (meta['last_page'] as int);
    return ExpensePage(items: items, hasMore: hasMore);
  }

  Future<Expense> create({
    required String category,
    required double amount,
    String? description,
    required String expenseDate,
  }) async {
    final response = await _client.guard(
      () => _client.dio.post('/expenses', data: {
        'category': category,
        'amount': amount,
        'description': description,
        'expense_date': expenseDate,
      }),
    );
    return Expense.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }
}
