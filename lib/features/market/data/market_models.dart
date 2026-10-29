import '../../catalog/data/catalog_models.dart';

double? _d(Object? v) => (v as num?)?.toDouble();

/// A product in marketplace search results.
class MarketProduct {
  MarketProduct({
    required this.id,
    required this.displayName,
    required this.unit,
    this.brand,
    this.producer,
    this.imageUrl,
    this.imageUrls = const [],
    this.animalType,
    this.category,
    this.minPrice,
    required this.sellersCount,
    required this.availableQuantity,
    this.nearestLabel,
  });

  factory MarketProduct.fromJson(Map<String, dynamic> json) => MarketProduct(
    id: json['id'] as int,
    displayName: json['display_name'] as String,
    unit: json['unit'] as String,
    brand: json['brand'] as String?,
    producer: ProducerInfo.fromJson(json['producer']),
    imageUrl: json['image_url'] as String?,
    imageUrls: ((json['image_urls'] as List?) ?? const [])
        .whereType<String>()
        .toList(),
    animalType:
        (json['animal_type'] as Map<String, dynamic>?)?['name'] as String?,
    category: (json['category'] as Map<String, dynamic>?)?['name'] as String?,
    minPrice: _d(json['min_price']),
    sellersCount: json['sellers_count'] as int,
    availableQuantity: _d(json['available_quantity']) ?? 0,
    nearestLabel: json['nearest_label'] as String?,
  );

  final int id;
  final String displayName;
  final String unit;
  final String? brand;
  final ProducerInfo? producer;
  final String? imageUrl;

  /// Front then back, for swiping on the card.
  final List<String> imageUrls;
  final String? animalType;
  final String? category;

  /// Photos to show: the front/back pair, else the single image.
  List<String> get photos => imageUrls.isNotEmpty ? imageUrls : [?imageUrl];

  /// Lowest price among sellers with stock; null when out of stock everywhere.
  final double? minPrice;
  final int sellersCount;
  final double availableQuantity;

  /// Distance to the nearest store with stock, e.g. "1.2 km".
  final String? nearestLabel;
}

/// Public store details.
class PublicStore {
  PublicStore({
    required this.id,
    required this.name,
    this.sellerName,
    this.sellerLogoUrl,
    this.brandColor,
    this.accentColor,
    this.brandTextColor,
    this.address,
    this.city,
    this.phone,
    required this.latitude,
    required this.longitude,
    this.pickupInstructions,
    this.openingHoursLines,
    this.distanceLabel,
    this.offersCount,
  });

  factory PublicStore.fromJson(Map<String, dynamic> json) => PublicStore(
    id: json['id'] as int,
    name: json['name'] as String,
    sellerName: (json['seller'] as Map<String, dynamic>?)?['name'] as String?,
    sellerLogoUrl:
        (json['seller'] as Map<String, dynamic>?)?['logo_url'] as String?,
    brandColor:
        (json['seller'] as Map<String, dynamic>?)?['brand_color'] as String?,
    accentColor:
        (json['seller'] as Map<String, dynamic>?)?['brand_accent_color']
            as String?,
    brandTextColor:
        (json['seller'] as Map<String, dynamic>?)?['brand_text_color']
            as String?,
    address: json['address'] as String?,
    city: json['city'] as String?,
    phone: json['phone'] as String?,
    latitude: _d(json['latitude'])!,
    longitude: _d(json['longitude'])!,
    pickupInstructions: json['pickup_instructions'] as String?,
    openingHoursLines: (json['opening_hours_lines'] as Map?)?.map(
      (k, v) => MapEntry(k as String, v as String),
    ),
    distanceLabel: json['distance_label'] as String?,
    offersCount: json['offers_count'] as int?,
  );

  final int id;
  final String name;
  final String? sellerName;

  /// The seller's branding, so customers recognise the store.
  final String? sellerLogoUrl;
  final String? brandColor;
  final String? accentColor;
  final String? brandTextColor;
  final String? address;
  final String? city;
  final String? phone;
  final double latitude;
  final double longitude;
  final String? pickupInstructions;

  /// Day name → "08:00–18:00" or "Closed".
  final Map<String, String>? openingHoursLines;
  final String? distanceLabel;
  final int? offersCount;

  String get addressLine =>
      [address, city].whereType<String>().where((s) => s.isNotEmpty).join(', ');
}

/// One seller's offer of a product. [availableQuantity] is the marketplace
/// quantity — sellers' physical stock is never exposed.
class Offer {
  Offer({
    required this.id,
    required this.productId,
    required this.name,
    this.price,
    required this.unit,
    required this.availableQuantity,
    required this.isAvailable,
    this.distanceLabel,
    required this.sellerName,
    required this.store,
  });

  factory Offer.fromJson(Map<String, dynamic> json) => Offer(
    id: json['id'] as int,
    productId: json['product_id'] as int,
    name: json['name'] as String,
    price: _d(json['price']),
    unit: json['unit'] as String? ?? '',
    availableQuantity: _d(json['available_quantity']) ?? 0,
    isAvailable: json['is_available'] as bool,
    distanceLabel: json['distance_label'] as String?,
    sellerName: (json['seller'] as Map<String, dynamic>)['name'] as String,
    store: PublicStore.fromJson(json['store'] as Map<String, dynamic>),
  );

  final int id;
  final int productId;
  final String name;
  final double? price;
  final String unit;
  final double availableQuantity;
  final bool isAvailable;
  final String? distanceLabel;
  final String sellerName;
  final PublicStore store;
}

class MarketProductDetail {
  MarketProductDetail({
    required this.id,
    required this.displayName,
    required this.unit,
    this.brand,
    this.producer,
    this.producerDescription,
    this.description,
    this.imageUrl,
    this.imageUrls = const [],
    this.animalType,
    this.category,
    required this.offers,
  });

  factory MarketProductDetail.fromJson(Map<String, dynamic> json) {
    final p = json['product'] as Map<String, dynamic>;
    return MarketProductDetail(
      id: p['id'] as int,
      displayName: p['display_name'] as String,
      unit: p['unit'] as String,
      brand: p['brand'] as String?,
      producer: ProducerInfo.fromJson(p['producer']),
      producerDescription: p['producer_description'] as String?,
      description: p['description'] as String?,
      imageUrl: p['image_url'] as String?,
      imageUrls: ((p['image_urls'] as List?) ?? const [])
          .map((e) => e as String)
          .toList(),
      animalType: p['animal_type'] as String?,
      category: p['category'] as String?,
      offers: (json['offers'] as List)
          .map((e) => Offer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int id;
  final String displayName;
  final String unit;
  final String? brand;
  final ProducerInfo? producer;
  final String? producerDescription;
  final String? description;
  final String? imageUrl;

  /// Front then back photo.
  final List<String> imageUrls;
  final String? animalType;
  final String? category;
  final List<Offer> offers;
}

class MarketStoreDetail {
  MarketStoreDetail({required this.store, required this.offers});

  factory MarketStoreDetail.fromJson(Map<String, dynamic> json) =>
      MarketStoreDetail(
        store: PublicStore.fromJson(json['store'] as Map<String, dynamic>),
        offers: (json['offers'] as List)
            .map((e) => Offer.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final PublicStore store;
  final List<Offer> offers;
}

class MarketFilters {
  MarketFilters({required this.animalTypes, required this.categories});

  factory MarketFilters.fromJson(Map<String, dynamic> json) => MarketFilters(
    animalTypes: (json['animal_types'] as List)
        .map((e) => CatalogNode.fromJson(e as Map<String, dynamic>))
        .toList(),
    categories: (json['categories'] as List)
        .map((e) => CatalogNode.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final List<CatalogNode> animalTypes;
  final List<CatalogNode> categories;
}

/// Where the customer is searching from.
class MarketLocation {
  const MarketLocation({
    required this.latitude,
    required this.longitude,
    this.label,
  });

  final double latitude;
  final double longitude;
  final String? label;

  Map<String, dynamic> toQuery() => {'lat': latitude, 'lng': longitude};

  @override
  bool operator ==(Object other) =>
      other is MarketLocation &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.label == label;

  @override
  int get hashCode => Object.hash(latitude, longitude, label);
}

/// Search sort keys — match MarketplaceSearch::SORTS on the backend.
enum MarketSort {
  nearest('nearest'),
  price('price'),
  availability('availability');

  const MarketSort(this.key);

  final String key;
}
