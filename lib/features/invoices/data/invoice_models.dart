class InvoiceCustomerRef {
  InvoiceCustomerRef({required this.id, required this.name});

  factory InvoiceCustomerRef.fromJson(Map<String, dynamic> json) =>
      InvoiceCustomerRef(id: json['id'] as int, name: json['name'] as String);

  final int id;
  final String name;
}

class InvoiceLineItem {
  InvoiceLineItem({
    required this.id,
    this.inventoryItemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.discountAmount,
    required this.subtotal,
  });

  factory InvoiceLineItem.fromJson(Map<String, dynamic> json) =>
      InvoiceLineItem(
        id: json['id'] as int,
        inventoryItemId: json['inventory_item_id'] as int?,
        itemName: json['item_name'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unitPrice: (json['unit_price'] as num).toDouble(),
        discountAmount: (json['discount_amount'] as num).toDouble(),
        subtotal: (json['subtotal'] as num).toDouble(),
      );

  final int id;
  final int? inventoryItemId;
  final String itemName;
  final double quantity;
  final double unitPrice;
  final double discountAmount;
  final double subtotal;
}

class InvoicePaymentEntry {
  InvoicePaymentEntry({
    required this.id,
    required this.amount,
    required this.paymentDate,
    this.paymentMethod,
    this.reference,
  });

  factory InvoicePaymentEntry.fromJson(Map<String, dynamic> json) =>
      InvoicePaymentEntry(
        id: json['id'] as int,
        amount: (json['amount'] as num).toDouble(),
        paymentDate: json['payment_date'] as String,
        paymentMethod: json['payment_method'] as String?,
        reference: json['reference'] as String?,
      );

  final int id;
  final double amount;
  final String paymentDate;
  final String? paymentMethod;
  final String? reference;
}

/// Mirrors the backend's `Invoice::STATUS_*` constants — a "proforma" is
/// just a draft invoice; approving it locks in stock and flips the status.
class Invoice {
  Invoice({
    required this.id,
    required this.number,
    required this.status,
    required this.statusLabel,
    required this.subtotal,
    required this.discountAmount,
    required this.total,
    required this.amountPaid,
    required this.balanceDue,
    required this.issueDate,
    this.dueDate,
    this.notes,
    this.customer,
    this.items = const [],
    this.payments = const [],
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'] as int,
        number: json['number'] as String,
        status: json['status'] as String,
        statusLabel: json['status_label'] as String,
        subtotal: (json['subtotal'] as num).toDouble(),
        discountAmount: (json['discount_amount'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        amountPaid: (json['amount_paid'] as num).toDouble(),
        balanceDue: (json['balance_due'] as num).toDouble(),
        issueDate: json['issue_date'] as String,
        dueDate: json['due_date'] as String?,
        notes: json['notes'] as String?,
        customer: json['customer'] != null
            ? InvoiceCustomerRef.fromJson(
                json['customer'] as Map<String, dynamic>)
            : null,
        items: (json['items'] as List? ?? [])
            .map((e) => InvoiceLineItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        payments: (json['payments'] as List? ?? [])
            .map((e) => InvoicePaymentEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final int id;
  final String number;
  final String status;
  final String statusLabel;
  final double subtotal;
  final double discountAmount;
  final double total;
  final double amountPaid;
  final double balanceDue;
  final String issueDate;
  final String? dueDate;
  final String? notes;
  final InvoiceCustomerRef? customer;
  final List<InvoiceLineItem> items;
  final List<InvoicePaymentEntry> payments;

  bool get isDraft => status == 'draft';
  bool get isCancelled => status == 'cancelled';
  bool get isPaid => status == 'paid';
}
