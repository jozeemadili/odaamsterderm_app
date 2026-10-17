/// A product in the shared, admin-curated catalog. Inventory items link to
/// one so customers can compare the same product across sellers.
class CatalogProduct {
  CatalogProduct({
    required this.id,
    required this.name,
    required this.displayName,
    required this.unit,
    required this.status,
    this.packSize,
    this.brand,
    this.description,
    this.imageUrl,
    this.animalTypeName,
    this.categoryName,
    this.reviewNotes,
  });

  factory CatalogProduct.fromJson(Map<String, dynamic> json) => CatalogProduct(
    id: json['id'] as int,
    name: json['name'] as String,
    displayName: json['display_name'] as String,
    unit: json['unit'] as String,
    status: json['status'] as String,
    packSize: json['pack_size'] as String?,
    brand: json['brand'] as String?,
    description: json['description'] as String?,
    imageUrl: json['image_url'] as String?,
    animalTypeName:
        (json['animal_type'] as Map<String, dynamic>?)?['name'] as String?,
    categoryName:
        (json['category'] as Map<String, dynamic>?)?['name'] as String?,
    reviewNotes: json['review_notes'] as String?,
  );

  final int id;
  final String name;
  final String displayName;
  final String unit;

  /// pending, approved or rejected
  final String status;
  final String? packSize;
  final String? brand;
  final String? description;
  final String? imageUrl;
  final String? animalTypeName;
  final String? categoryName;
  final String? reviewNotes;

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
}

/// One node of the animal-type or category tree (one level of children).
class CatalogNode {
  CatalogNode({required this.id, required this.name, this.children = const []});

  factory CatalogNode.fromJson(Map<String, dynamic> json) => CatalogNode(
    id: json['id'] as int,
    name: json['name'] as String,
    children: ((json['children'] as List?) ?? const [])
        .map((e) => CatalogNode.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final int id;
  final String name;
  final List<CatalogNode> children;
}

/// Units a catalog product can be sold in — mirrors Product::UNITS.
const catalogUnits = [
  'bag',
  'kg',
  'g',
  'litre',
  'ml',
  'bottle',
  'sachet',
  'box',
  'vial',
  'tin',
  'piece',
  'pack',
  'dose',
];
