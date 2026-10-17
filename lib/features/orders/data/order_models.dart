import '../../market/data/market_models.dart';

double _d(Object? v) => (v as num?)?.toDouble() ?? 0;

class OrderItemLine {
  OrderItemLine({
    required this.name,
    this.unit,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });

  factory OrderItemLine.fromJson(Map<String, dynamic> json) => OrderItemLine(
    name: json['name'] as String,
    unit: json['unit'] as String?,
    unitPrice: _d(json['unit_price']),
    quantity: _d(json['quantity']),
    lineTotal: _d(json['line_total']),
  );

  final String name;
  final String? unit;
  final double unitPrice;
  final double quantity;
  final double lineTotal;
}

class OrderEvent {
  OrderEvent({required this.status, required this.label, this.note, this.at});

  factory OrderEvent.fromJson(Map<String, dynamic> json) => OrderEvent(
    status: json['status'] as String,
    label: json['label'] as String,
    note: json['note'] as String?,
    at: json['at'] != null ? DateTime.tryParse(json['at'] as String) : null,
  );

  final String status;
  final String label;
  final String? note;
  final DateTime? at;
}

/// A marketplace pickup order (customer or seller view).
class MarketOrder {
  MarketOrder({
    required this.id,
    required this.reference,
    required this.status,
    required this.statusLabel,
    this.statusReason,
    required this.total,
    required this.itemsCount,
    this.customerNote,
    this.createdAt,
    required this.canCancel,
    required this.nextStatuses,
    this.sellerName,
    this.store,
    this.customerName,
    this.customerPhone,
    this.items = const [],
    this.events = const [],
  });

  factory MarketOrder.fromJson(Map<String, dynamic> json) => MarketOrder(
    id: json['id'] as int,
    reference: json['reference'] as String,
    status: json['status'] as String,
    statusLabel: json['status_label'] as String,
    statusReason: json['status_reason'] as String?,
    total: _d(json['total']),
    itemsCount: json['items_count'] as int,
    customerNote: json['customer_note'] as String?,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'] as String)
        : null,
    canCancel: json['can_cancel'] as bool? ?? false,
    nextStatuses: ((json['next_statuses'] as List?) ?? const [])
        .map(
          (e) => (
            status: (e as Map<String, dynamic>)['status'] as String,
            label: e['label'] as String,
          ),
        )
        .toList(),
    sellerName: (json['seller'] as Map<String, dynamic>?)?['name'] as String?,
    store: json['store'] != null
        ? PublicStore.fromJson(json['store'] as Map<String, dynamic>)
        : null,
    customerName:
        (json['customer'] as Map<String, dynamic>?)?['name'] as String?,
    customerPhone:
        (json['customer'] as Map<String, dynamic>?)?['phone'] as String?,
    items: ((json['items'] as List?) ?? const [])
        .map((e) => OrderItemLine.fromJson(e as Map<String, dynamic>))
        .toList(),
    events: ((json['events'] as List?) ?? const [])
        .map((e) => OrderEvent.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final int id;
  final String reference;

  /// pending, accepted, preparing, ready_for_pickup, completed, rejected, cancelled
  final String status;
  final String statusLabel;
  final String? statusReason;
  final double total;
  final int itemsCount;
  final String? customerNote;
  final DateTime? createdAt;
  final bool canCancel;

  /// Seller actions available now (empty for customers).
  final List<({String status, String label})> nextStatuses;
  final String? sellerName;
  final PublicStore? store;
  final String? customerName;
  final String? customerPhone;
  final List<OrderItemLine> items;
  final List<OrderEvent> events;

  bool get isClosed => status == 'rejected' || status == 'cancelled';
}

class CartLine {
  CartLine({
    required this.offerId,
    required this.name,
    this.unit,
    required this.unitPrice,
    required this.quantity,
    required this.availableQuantity,
    required this.lineTotal,
    this.problem,
  });

  factory CartLine.fromJson(Map<String, dynamic> json) => CartLine(
    offerId: json['offer_id'] as int,
    name: json['name'] as String,
    unit: json['unit'] as String?,
    unitPrice: _d(json['unit_price']),
    quantity: _d(json['quantity']),
    availableQuantity: _d(json['available_quantity']),
    lineTotal: _d(json['line_total']),
    problem: json['problem'] as String?,
  );

  final int offerId;
  final String name;
  final String? unit;
  final double unitPrice;
  final double quantity;
  final double availableQuantity;
  final double lineTotal;

  /// Why this line can't be ordered as-is (sold out, too many).
  final String? problem;
}

class CartStoreGroup {
  CartStoreGroup({
    required this.store,
    required this.total,
    required this.lines,
  });

  factory CartStoreGroup.fromJson(Map<String, dynamic> json) => CartStoreGroup(
    store: PublicStore.fromJson(json['store'] as Map<String, dynamic>),
    total: _d(json['total']),
    lines: (json['lines'] as List)
        .map((e) => CartLine.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final PublicStore store;
  final double total;
  final List<CartLine> lines;
}

/// The customer's basket, grouped by pickup store.
class CartData {
  CartData({required this.stores, required this.total, required this.count});

  factory CartData.fromJson(Map<String, dynamic> json) => CartData(
    stores: (json['stores'] as List)
        .map((e) => CartStoreGroup.fromJson(e as Map<String, dynamic>))
        .toList(),
    total: _d(json['total']),
    count: json['count'] as int,
  );

  final List<CartStoreGroup> stores;
  final double total;
  final int count;

  bool get hasProblems =>
      stores.any((s) => s.lines.any((l) => l.problem != null));
}

class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.read,
    this.orderId,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        read: json['read'] as bool? ?? false,
        orderId: json['order_id'] as int?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  final String id;
  final String title;
  final String message;
  final bool read;
  final int? orderId;
  final DateTime? createdAt;
}
