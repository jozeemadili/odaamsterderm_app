import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import 'pos_models.dart';

class CartLineInput {
  CartLineInput({
    required this.inventoryItemId,
    required this.quantity,
    this.discountType,
    this.discountValue,
  });

  final int inventoryItemId;
  final double quantity;
  final String? discountType;
  final double? discountValue;

  Map<String, dynamic> toJson() => {
        'inventory_item_id': inventoryItemId,
        'quantity': quantity,
        if (discountType != null) 'discount_type': discountType,
        if (discountValue != null) 'discount_value': discountValue,
      };
}

class PosRepository {
  PosRepository(this._client);

  final ApiClient _client;

  Future<List<PaymentMethod>> paymentMethods() async {
    final response =
        await _client.guard(() => _client.dio.get('/payment-methods'));
    final data = (response.data as Map<String, dynamic>)['data'] as List;
    return data
        .map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Prices are always recomputed server-side from the current inventory
  /// record, so nothing here is trusted beyond "what the cashier selected".
  Future<CheckoutOutcome> checkout({
    required List<CartLineInput> items,
    int? customerId,
    String? overallDiscountType,
    double? overallDiscountValue,
    int? paymentMethodId,
    double? amountTendered,
    String? approverEmail,
    String? approverPassword,
  }) async {
    try {
      final response = await _client.dio.post('/pos/checkout', data: {
        'items': items.map((i) => i.toJson()).toList(),
        'customer_id': customerId,
        'overall_discount_type': overallDiscountType,
        'overall_discount_value': overallDiscountValue,
        'payment_method_id': paymentMethodId,
        'amount_tendered': amountTendered,
        'approver_email': approverEmail,
        'approver_password': approverPassword,
      });
      return CheckoutSuccess(SaleResult.fromJson((response.data
          as Map<String, dynamic>)['data'] as Map<String, dynamic>));
    } on DioException catch (e) {
      final data = e.response?.data;
      if (e.response?.statusCode == 422 &&
          data is Map &&
          data['needs_approval'] == true) {
        return CheckoutNeedsApproval(
          message: data['message'] as String,
          effectivePercent:
              (data['effective_discount_percent'] as num).toDouble(),
          myLimitPercent: (data['my_limit_percent'] as num).toDouble(),
        );
      }
      throw _client.toApiException(e);
    }
  }
}
