import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import 'payment_models.dart';

class PaymentPage {
  PaymentPage({required this.items, required this.hasMore});

  final List<PaymentRecord> items;
  final bool hasMore;
}

class PaymentRepository {
  PaymentRepository(this._client);

  final ApiClient _client;

  Future<PaymentPage> list({int page = 1}) async {
    final response = await _client.guard(
        () => _client.dio.get('/payments', queryParameters: {'page': page}));
    final data = response.data as Map<String, dynamic>;
    final items = (data['data'] as List)
        .map((e) => PaymentRecord.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = data['meta'] as Map<String, dynamic>?;
    final hasMore = meta != null &&
        (meta['current_page'] as int) < (meta['last_page'] as int);
    return PaymentPage(items: items, hasMore: hasMore);
  }

  Future<PaymentRecord> create({
    required double amount,
    required String payerName,
    required String paymentDate,
    String? notes,
    File? proofOfPayment,
  }) async {
    final formData = FormData.fromMap({
      'amount': amount,
      'payer_name': payerName,
      'payment_date': paymentDate,
      if (notes != null) 'notes': notes,
      if (proofOfPayment != null)
        'proof_of_payment': await MultipartFile.fromFile(proofOfPayment.path),
    });
    final response = await _client
        .guard(() => _client.dio.post('/payments', data: formData));
    return PaymentRecord.fromJson((response.data
        as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }
}
