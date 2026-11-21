/// A catalogue product an agent can pick into stock, with its pack sizes.
class PickProduct {
  const PickProduct({
    required this.id,
    required this.name,
    this.producer,
    this.category,
    this.imageUrl,
    this.agentsCount = 0,
    this.variants = const [],
  });

  factory PickProduct.fromJson(Map<String, dynamic> json) => PickProduct(
    id: json['id'] as int,
    name: json['name'] as String,
    producer: json['producer'] as String?,
    category: json['category'] as String?,
    imageUrl: json['image_url'] as String?,
    agentsCount: (json['agents_count'] as num?)?.toInt() ?? 0,
    variants: [
      for (final v in (json['variants'] as List? ?? const []))
        PickVariant.fromJson(v as Map<String, dynamic>),
    ],
  );

  final int id;
  final String name;
  final String? producer;
  final String? category;
  final String? imageUrl;
  final int agentsCount;
  final List<PickVariant> variants;
}

/// One pack size; [stocked] when the agent already has it in a store.
class PickVariant {
  const PickVariant({
    required this.id,
    required this.name,
    this.sellingUnit,
    this.stocked = false,
  });

  factory PickVariant.fromJson(Map<String, dynamic> json) => PickVariant(
    id: json['id'] as int,
    name: json['name'] as String,
    sellingUnit: json['selling_unit'] as String?,
    stocked: json['stocked'] == true,
  );

  final int id;
  final String name;
  final String? sellingUnit;
  final bool stocked;
}

/// A company with products in the catalogue ("which companies do you buy from?").
class PickProducer {
  const PickProducer({
    required this.id,
    required this.name,
    this.productsCount = 0,
  });

  factory PickProducer.fromJson(Map<String, dynamic> json) => PickProducer(
    id: json['id'] as int,
    name: json['name'] as String,
    productsCount: (json['products_count'] as num?)?.toInt() ?? 0,
  );

  final int id;
  final String name;
  final int productsCount;
}

/// What an agent picked: one pack size with their price and quantity.
class PickLine {
  const PickLine({
    required this.variantId,
    required this.unitPrice,
    required this.quantity,
  });

  final int variantId;
  final double unitPrice;
  final double quantity;
}

class AddToStockResult {
  const AddToStockResult({
    required this.added,
    required this.skipped,
    required this.listed,
  });

  factory AddToStockResult.fromJson(Map<String, dynamic> json) =>
      AddToStockResult(
        added: (json['added'] as num?)?.toInt() ?? 0,
        skipped: (json['skipped'] as num?)?.toInt() ?? 0,
        listed: (json['listed'] as num?)?.toInt() ?? 0,
      );

  final int added;
  final int skipped;
  final int listed;
}

/// A product the agent asked the catalogue team to add.
class ProductRequestInfo {
  const ProductRequestInfo({
    required this.id,
    required this.name,
    required this.status,
    required this.statusLabel,
    this.producer,
    this.packSize,
    this.reviewNotes,
    this.productName,
    this.frontUrl,
  });

  factory ProductRequestInfo.fromJson(Map<String, dynamic> json) =>
      ProductRequestInfo(
        id: json['id'] as int,
        name: json['name'] as String,
        status: json['status'] as String? ?? 'pending',
        statusLabel: json['status_label'] as String? ?? '',
        producer: json['producer'] as String?,
        packSize: json['pack_size'] as String?,
        reviewNotes: json['review_notes'] as String?,
        productName:
            (json['product'] as Map<String, dynamic>?)?['name'] as String?,
        frontUrl: json['front_url'] as String?,
      );

  final int id;
  final String name;
  final String status;
  final String statusLabel;
  final String? producer;
  final String? packSize;
  final String? reviewNotes;
  final String? productName;
  final String? frontUrl;

  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
}
