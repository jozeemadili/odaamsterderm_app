import '../../auth/data/auth_models.dart';

/// Stock moved between two stores of the same seller.
class StockTransfer {
  StockTransfer({
    required this.id,
    required this.number,
    required this.status,
    required this.fromStore,
    required this.toStore,
    this.notes,
    this.sentBy,
    this.sentAt,
    this.receivedBy,
    this.receivedAt,
    this.itemsCount,
    this.items = const [],
    this.canReceive = false,
    this.canCancel = false,
    this.noteUrl,
  });

  factory StockTransfer.fromJson(Map<String, dynamic> json) => StockTransfer(
    id: json['id'] as int,
    number: json['number'] as String,
    status: json['status'] as String,
    fromStore: StoreRef.fromJson(json['from_store'] as Map<String, dynamic>),
    toStore: StoreRef.fromJson(json['to_store'] as Map<String, dynamic>),
    notes: json['notes'] as String?,
    sentBy: json['sent_by'] as String?,
    sentAt: DateTime.tryParse(json['sent_at'] as String? ?? '')?.toLocal(),
    receivedBy: json['received_by'] as String?,
    receivedAt: DateTime.tryParse(
      json['received_at'] as String? ?? '',
    )?.toLocal(),
    itemsCount: json['items_count'] as int?,
    items: ((json['items'] as List?) ?? const [])
        .map((e) => TransferLine.fromJson(e as Map<String, dynamic>))
        .toList(),
    canReceive: json['can_receive'] as bool? ?? false,
    canCancel: json['can_cancel'] as bool? ?? false,
    noteUrl: json['note_url'] as String?,
  );

  final int id;
  final String number;
  final String status;
  final StoreRef fromStore;
  final StoreRef toStore;
  final String? notes;
  final String? sentBy;
  final DateTime? sentAt;
  final String? receivedBy;
  final DateTime? receivedAt;
  final int? itemsCount;
  final List<TransferLine> items;
  final bool canReceive;
  final bool canCancel;
  final String? noteUrl;

  bool get isOnTheWay => status == 'sent';
}

class TransferLine {
  TransferLine({required this.name, this.unit, required this.quantity});

  factory TransferLine.fromJson(Map<String, dynamic> json) => TransferLine(
    name: json['name'] as String,
    unit: json['unit'] as String?,
    quantity: (json['quantity'] as num).toDouble(),
  );

  final String name;
  final String? unit;
  final double quantity;
}

/// A product that can be sent from a store, with what is free to send.
class TransferStock {
  TransferStock({
    required this.id,
    required this.name,
    this.unit,
    required this.available,
  });

  factory TransferStock.fromJson(Map<String, dynamic> json) => TransferStock(
    id: json['id'] as int,
    name: json['name'] as String,
    unit: json['unit'] as String?,
    available: (json['available'] as num).toDouble(),
  );

  final int id;
  final String name;
  final String? unit;
  final double available;
}

class TransferList {
  TransferList({
    required this.items,
    required this.canSend,
    required this.fromStores,
    required this.toStores,
  });

  final List<StockTransfer> items;
  final bool canSend;
  final List<StoreRef> fromStores;
  final List<StoreRef> toStores;
}

String formatQty(double value) =>
    value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';
