class PaymentMethod {
  PaymentMethod({
    required this.id,
    required this.name,
    required this.slug,
    required this.type,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
    id: json['id'] as int,
    name: json['name'] as String,
    slug: json['slug'] as String,
    type: json['type'] as String,
  );

  final int id;
  final String name;
  final String slug;
  final String type;
}

class SaleItem {
  SaleItem({
    required this.id,
    required this.inventoryItemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    this.discountType,
    this.discountValue,
    required this.discountAmount,
    required this.subtotal,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) => SaleItem(
    id: json['id'] as int,
    inventoryItemId: json['inventory_item_id'] as int,
    itemName: json['item_name'] as String,
    quantity: (json['quantity'] as num).toDouble(),
    unitPrice: (json['unit_price'] as num).toDouble(),
    discountType: json['discount_type'] as String?,
    discountValue: json['discount_value'] != null
        ? (json['discount_value'] as num).toDouble()
        : null,
    discountAmount: (json['discount_amount'] as num).toDouble(),
    subtotal: (json['subtotal'] as num).toDouble(),
  );

  final int id;
  final int inventoryItemId;
  final String itemName;
  final double quantity;
  final double unitPrice;
  final String? discountType;
  final double? discountValue;
  final double discountAmount;
  final double subtotal;
}

class SaleResult {
  SaleResult({
    required this.id,
    required this.saleDate,
    required this.amount,
    this.subtotal,
    required this.discountAmount,
    this.paymentMethod,
    this.amountTendered,
    this.changeDue,
    this.itemsCount,
    this.customerName,
    required this.items,
    this.receiptUrl,
  });

  factory SaleResult.fromJson(Map<String, dynamic> json) => SaleResult(
    id: json['id'] as int,
    saleDate: json['sale_date'] as String,
    amount: (json['amount'] as num).toDouble(),
    subtotal: json['subtotal'] != null
        ? (json['subtotal'] as num).toDouble()
        : null,
    discountAmount: (json['discount_amount'] as num).toDouble(),
    paymentMethod: json['payment_method'] as String?,
    amountTendered: json['amount_tendered'] != null
        ? (json['amount_tendered'] as num).toDouble()
        : null,
    changeDue: json['change_due'] != null
        ? (json['change_due'] as num).toDouble()
        : null,
    itemsCount: json['items_count'] != null
        ? (json['items_count'] as num).toDouble()
        : null,
    customerName: json['customer'] != null
        ? (json['customer'] as Map<String, dynamic>)['name'] as String?
        : null,
    items: (json['items'] as List? ?? [])
        .map((e) => SaleItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    receiptUrl: json['receipt_url'] as String?,
  );

  final int id;
  final String saleDate;
  final double amount;
  final double? subtotal;
  final double discountAmount;
  final String? paymentMethod;
  final double? amountTendered;
  final double? changeDue;
  final double? itemsCount;
  final String? customerName;
  final List<SaleItem> items;

  /// Branded receipt the cashier can open, print or share with the customer.
  final String? receiptUrl;
}

/// The backend's checkout endpoint returns either a completed sale, or a
/// 422 asking for a supervisor's credentials when the discount exceeds the
/// current user's approval limit — this mirrors that as a closed union so
/// the UI can't accidentally treat one as the other.
sealed class CheckoutOutcome {}

class CheckoutSuccess extends CheckoutOutcome {
  CheckoutSuccess(this.sale);
  final SaleResult sale;
}

class CheckoutNeedsApproval extends CheckoutOutcome {
  CheckoutNeedsApproval({
    required this.message,
    required this.effectivePercent,
    required this.myLimitPercent,
  });
  final String message;
  final double effectivePercent;
  final double myLimitPercent;
}
