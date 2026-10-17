import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/api/api_client.dart';
import 'invoice_models.dart';

class InvoicePage {
  InvoicePage({required this.items, required this.hasMore});

  final List<Invoice> items;
  final bool hasMore;
}

class InvoiceRepository {
  InvoiceRepository(this._client);

  final ApiClient _client;

  Future<InvoicePage> list({String? status, int page = 1}) async {
    final response = await _client.guard(
      () => _client.dio.get('/invoices', queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        'page': page,
      }),
    );

    final data = response.data as Map<String, dynamic>;
    final items = (data['data'] as List)
        .map((e) => Invoice.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = data['meta'] as Map<String, dynamic>?;
    final hasMore = meta != null &&
        (meta['current_page'] as int) < (meta['last_page'] as int);

    return InvoicePage(items: items, hasMore: hasMore);
  }

  Future<Invoice> get(int id) async {
    final response =
        await _client.guard(() => _client.dio.get('/invoices/$id'));
    return Invoice.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }

  Future<Invoice> create({
    required int customerId,
    required String issueDate,
    String? dueDate,
    String? notes,
  }) async {
    final response = await _client.guard(
      () => _client.dio.post('/invoices', data: {
        'customer_id': customerId,
        'issue_date': issueDate,
        'due_date': dueDate,
        'notes': notes,
      }),
    );
    return Invoice.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }

  Future<Invoice> addItem(
    int invoiceId, {
    required int inventoryItemId,
    required double quantity,
    required double unitPrice,
    String? discountType,
    double? discountValue,
  }) async {
    final response = await _client.guard(
      () => _client.dio.post('/invoices/$invoiceId/items', data: {
        'inventory_item_id': inventoryItemId,
        'quantity': quantity,
        'unit_price': unitPrice,
        if (discountType != null) 'discount_type': discountType,
        if (discountValue != null) 'discount_value': discountValue,
      }),
    );
    return Invoice.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }

  Future<Invoice> removeItem(int invoiceId, int itemId) async {
    final response = await _client
        .guard(() => _client.dio.delete('/invoices/$invoiceId/items/$itemId'));
    return Invoice.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }

  Future<Invoice> setDiscount(int invoiceId,
      {String? type, double? value}) async {
    final response = await _client.guard(
      () => _client.dio.patch('/invoices/$invoiceId/discount', data: {
        'discount_type': type,
        'discount_value': value,
      }),
    );
    return Invoice.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }

  Future<Invoice> approve(int invoiceId) async {
    final response = await _client
        .guard(() => _client.dio.post('/invoices/$invoiceId/approve'));
    return Invoice.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }

  Future<Invoice> cancel(int invoiceId) async {
    final response = await _client
        .guard(() => _client.dio.post('/invoices/$invoiceId/cancel'));
    return Invoice.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }

  Future<Invoice> recordPayment(
    int invoiceId, {
    required double amount,
    int? paymentMethodId,
    required String paymentDate,
    String? reference,
  }) async {
    final response = await _client.guard(
      () => _client.dio.post('/invoices/$invoiceId/payments', data: {
        'amount': amount,
        'payment_method_id': paymentMethodId,
        'payment_date': paymentDate,
        'reference': reference,
      }),
    );
    return Invoice.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }

  /// Downloads the invoice/proforma PDF to a local temp file and returns its
  /// path, ready to hand to a share sheet — the backend endpoint is
  /// Sanctum-authenticated, so it can't just be opened as a plain URL.
  Future<String> downloadPdf(int invoiceId, String filename) async {
    final response = await _client.guard(
      () => _client.dio.get<List<int>>(
        '/invoices/$invoiceId/pdf',
        options: Options(responseType: ResponseType.bytes),
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(response.data as List<int>);
    return file.path;
  }
}
