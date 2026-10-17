class StockReceiptSupplierRef {
  StockReceiptSupplierRef({required this.id, required this.name});

  factory StockReceiptSupplierRef.fromJson(Map<String, dynamic> json) =>
      StockReceiptSupplierRef(
          id: json['id'] as int, name: json['name'] as String);

  final int id;
  final String name;
}

class StockReceiptLineItem {
  StockReceiptLineItem({
    required this.id,
    this.inventoryItemId,
    this.productName,
    required this.quantity,
    required this.unitCost,
    required this.subtotal,
  });

  factory StockReceiptLineItem.fromJson(Map<String, dynamic> json) =>
      StockReceiptLineItem(
        id: json['id'] as int,
        inventoryItemId: json['inventory_item_id'] as int?,
        productName: json['product_name'] as String?,
        quantity: (json['quantity'] as num).toDouble(),
        unitCost: (json['unit_cost'] as num).toDouble(),
        subtotal: (json['subtotal'] as num).toDouble(),
      );

  final int id;
  final int? inventoryItemId;
  final String? productName;
  final double quantity;
  final double unitCost;
  final double subtotal;
}

/// Mirrors `StockReceipt::STATUS_*` — pending receipts are editable drafts;
/// approving posts stock in and (if there's a supplier) a purchase
/// transaction against them, both irreversible.
class StockReceipt {
  StockReceipt({
    required this.id,
    this.referenceNo,
    required this.status,
    required this.totalAmount,
    required this.receiptDate,
    this.notes,
    this.supplier,
    this.items = const [],
  });

  factory StockReceipt.fromJson(Map<String, dynamic> json) => StockReceipt(
        id: json['id'] as int,
        referenceNo: json['reference_no'] as String?,
        status: json['status'] as String,
        totalAmount: (json['total_amount'] as num).toDouble(),
        receiptDate: json['receipt_date'] as String,
        notes: json['notes'] as String?,
        supplier: json['supplier'] != null
            ? StockReceiptSupplierRef.fromJson(
                json['supplier'] as Map<String, dynamic>)
            : null,
        items: (json['items'] as List? ?? [])
            .map(
                (e) => StockReceiptLineItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final int id;
  final String? referenceNo;
  final String status;
  final double totalAmount;
  final String receiptDate;
  final String? notes;
  final StockReceiptSupplierRef? supplier;
  final List<StockReceiptLineItem> items;

  bool get isPending => status == 'pending';

  String get statusLabel => switch (status) {
        'pending' => 'Pending',
        'approved' => 'Approved',
        'rejected' => 'Rejected',
        _ => status,
      };
}
