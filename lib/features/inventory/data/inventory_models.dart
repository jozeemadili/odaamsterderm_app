import '../../catalog/data/catalog_models.dart';

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
    this.backImageUrl,
    this.category,
    this.branch,
    this.productId,
    this.product,
    required this.marketplace,
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
    backImageUrl: json['back_image_url'] as String?,
    category: json['category'] != null
        ? InventoryCategory.fromJson(json['category'] as Map<String, dynamic>)
        : null,
    branch: json['branch'] != null
        ? Branch.fromJson(json['branch'] as Map<String, dynamic>)
        : null,
    productId: json['product_id'] as int?,
    product: json['product'] != null
        ? CatalogProduct.fromJson(json['product'] as Map<String, dynamic>)
        : null,
    marketplace: json['marketplace'] != null
        ? MarketplaceInfo.fromJson(json['marketplace'] as Map<String, dynamic>)
        : MarketplaceInfo.hidden(),
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

  /// Photo of the back of the pack (ingredients, dosage, expiry).
  final String? backImageUrl;
  final InventoryCategory? category;
  final Branch? branch;

  /// Linked catalog product — required before the item can be listed.
  final int? productId;
  final CatalogProduct? product;
  final MarketplaceInfo marketplace;
}

/// What customers can see of an item. [quantity] is what is exposed online;
/// [InventoryItem.quantityOnHand] stays the seller-only physical stock.
class MarketplaceInfo {
  MarketplaceInfo({
    required this.isVisible,
    required this.quantity,
    required this.reservedQuantity,
    required this.availableQuantity,
    required this.status,
    this.blockers,
  });

  factory MarketplaceInfo.fromJson(Map<String, dynamic> json) =>
      MarketplaceInfo(
        isVisible: json['is_visible'] as bool,
        quantity: (json['quantity'] as num).toDouble(),
        reservedQuantity: (json['reserved_quantity'] as num).toDouble(),
        availableQuantity: (json['available_quantity'] as num).toDouble(),
        status: json['status'] as String,
        blockers: (json['blockers'] as List?)?.cast<String>(),
      );

  factory MarketplaceInfo.hidden() => MarketplaceInfo(
    isVisible: false,
    quantity: 0,
    reservedQuantity: 0,
    availableQuantity: 0,
    status: 'inactive',
  );

  final bool isVisible;
  final double quantity;
  final double reservedQuantity;

  /// Physical stock not held for open orders — the most that can be exposed.
  final double availableQuantity;

  /// active, out_of_stock or inactive
  final String status;

  /// Why the item can't be listed; null when the API didn't compute it.
  final List<String>? blockers;

  bool get isListed => isVisible && status == 'active' && quantity > 0;

  String get statusLabel => switch (status) {
    'active' => 'Active',
    'out_of_stock' => 'Out of stock',
    _ => 'Inactive',
  };
}
