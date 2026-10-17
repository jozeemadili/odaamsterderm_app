import '../../inventory/data/inventory_models.dart';

class DamageReport {
  DamageReport({
    required this.id,
    required this.inventoryItemId,
    this.productName,
    required this.quantity,
    this.description,
    this.photoUrl,
    this.branchName,
    this.reportedBy,
    this.reportedAt,
  });

  factory DamageReport.fromJson(Map<String, dynamic> json) => DamageReport(
        id: json['id'] as int,
        inventoryItemId: json['inventory_item_id'] as int,
        productName: json['product_name'] as String?,
        quantity: (json['quantity'] as num).toDouble(),
        description: json['description'] as String?,
        photoUrl: json['photo_url'] as String?,
        branchName: json['branch'] != null
            ? (json['branch'] as Map<String, dynamic>)['name'] as String?
            : null,
        reportedBy: json['reported_by'] as String?,
        reportedAt: json['reported_at'] as String?,
      );

  final int id;
  final int inventoryItemId;
  final String? productName;
  final double quantity;
  final String? description;
  final String? photoUrl;
  final String? branchName;
  final String? reportedBy;
  final String? reportedAt;
}

class NotificationsFeed {
  NotificationsFeed({
    required this.count,
    required this.lowStockItems,
    required this.expiringSoonItems,
    required this.damagedItems,
  });

  factory NotificationsFeed.fromJson(Map<String, dynamic> json) =>
      NotificationsFeed(
        count: json['count'] as int,
        lowStockItems: (json['low_stock_items'] as List)
            .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        expiringSoonItems: (json['expiring_soon_items'] as List)
            .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        damagedItems: (json['damaged_items'] as List)
            .map((e) => DamageReport.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final int count;
  final List<InventoryItem> lowStockItems;
  final List<InventoryItem> expiringSoonItems;
  final List<DamageReport> damagedItems;
}
