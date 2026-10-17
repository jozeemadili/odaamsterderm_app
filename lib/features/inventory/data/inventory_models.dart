class InventoryCategory {
  InventoryCategory({required this.id, required this.name});

  factory InventoryCategory.fromJson(Map<String, dynamic> json) =>
      InventoryCategory(id: json['id'] as int, name: json['name'] as String);

  final int id;
  final String name;
}

/// A merchant's physical shop/location. A product can be stocked at more
/// than one branch — each branch keeps its own [InventoryItem] row (its own
/// quantity, price and barcode), linked only by sharing the same branch.
class Branch {
  Branch({required this.id, required this.name, this.address, this.phone});

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        id: json['id'] as int,
        name: json['name'] as String,
        address: json['address'] as String?,
        phone: json['phone'] as String?,
      );

  final int id;
  final String name;
  final String? address;
  final String? phone;
}

class InventoryItem {
  InventoryItem({
    required this.id,
    required this.name,
    this.sku,
    this.barcode,
    this.unit,
    required this.quantityOnHand,
    required this.reorderLevel,
    this.unitCost,
    this.unitPrice,
    this.expiryDate,
    required this.isLowStock,
    required this.isExpiringSoon,
    required this.isExpired,
    this.imageUrl,
    this.category,
    this.branch,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        id: json['id'] as int,
        name: json['name'] as String,
        sku: json['sku'] as String?,
        barcode: json['barcode'] as String?,
        unit: json['unit'] as String?,
        quantityOnHand: (json['quantity_on_hand'] as num).toDouble(),
        reorderLevel: (json['reorder_level'] as num).toDouble(),
        unitCost: json['unit_cost'] != null
            ? (json['unit_cost'] as num).toDouble()
            : null,
        unitPrice: json['unit_price'] != null
            ? (json['unit_price'] as num).toDouble()
            : null,
        expiryDate: json['expiry_date'] as String?,
        isLowStock: json['is_low_stock'] as bool,
        isExpiringSoon: json['is_expiring_soon'] as bool,
        isExpired: json['is_expired'] as bool,
        imageUrl: json['image_url'] as String?,
        category: json['category'] != null
            ? InventoryCategory.fromJson(
                json['category'] as Map<String, dynamic>)
            : null,
        branch: json['branch'] != null
            ? Branch.fromJson(json['branch'] as Map<String, dynamic>)
            : null,
      );

  final int id;
  final String name;
  final String? sku;
  final String? barcode;
  final String? unit;
  final double quantityOnHand;
  final double reorderLevel;
  final double? unitCost;
  final double? unitPrice;
  final String? expiryDate;
  final bool isLowStock;
  final bool isExpiringSoon;
  final bool isExpired;
  final String? imageUrl;
  final InventoryCategory? category;
  final Branch? branch;
}
