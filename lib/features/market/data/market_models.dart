import '../../catalog/data/catalog_models.dart';

double? _d(Object? v) => (v as num?)?.toDouble();

/// Marketplace-wide switches set by the admin.
class MarketSettings {
  const MarketSettings({this.showPrices = false});

  factory MarketSettings.fromJson(Map<String, dynamic> json) =>
      MarketSettings(showPrices: json['show_prices'] == true);

  /// Product prices are shown to customers (off while sellers set them).
  final bool showPrices;
}

/// What a product is used for / treats ("Coccidiosis" / "Kuhara damu").
class UseTag {
  const UseTag({required this.code, required this.label, this.labelSw});

  factory UseTag.fromJson(Map<String, dynamic> json) => UseTag(
    code: json['code'] as String,
    label: json['label'] as String,
    labelSw: json['label_sw'] as String?,
  );

  static List<UseTag> listFrom(Object? json) => [
    for (final e in (json as List?) ?? const [])
      if (e is Map<String, dynamic>) UseTag.fromJson(e),
  ];

  final String code;
  final String label;
  final String? labelSw;

  /// The label in the app's language ("sw" → Kiswahili when there is one).
  String labelFor(String languageCode) =>
      languageCode == 'sw' && (labelSw?.isNotEmpty ?? false) ? labelSw! : label;
}

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
    this.packNames = const [],
    this.slug,
    this.uses = const [],
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
    packNames: [
      for (final v in (json['variants'] as List?) ?? const [])
        if (v is Map && v['name'] is String) v['name'] as String,
    ],
    slug: json['slug'] as String?,
    uses: UseTag.listFrom(json['uses']),
  );

  /// What it is used for / treats.
  final List<UseTag> uses;

  /// URL-friendly name, used for the shareable website link.
  final String? slug;

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

  /// Pack sizes on sale ("30 g sachet", "1 kg sachet"…), smallest first.
  final List<String> packNames;

  /// "30 g – 1 kg" (smallest to largest), the only pack's name, or null.
  String? get packRange {
    if (packNames.isEmpty) return null;
    if (packNames.length == 1) return packNames.first;

    final sizes = [
      for (final name in packNames)
        if (_packSize(name) case final size?) size,
    ]..sort((a, b) => a.amount.compareTo(b.amount));
    if (sizes.length < 2) return '${packNames.length} sizes';
    return '${sizes.first.label} – ${sizes.last.label}';
  }

  /// "25 kg bag" → (amount: 25000, label: "25 kg"); null when unreadable.
  static ({double amount, String label})? _packSize(String name) {
    final m = RegExp(
      r'^([\d.,]+)\s*(g|kg|ml|l)\b',
      caseSensitive: false,
    ).firstMatch(name.trim());
    if (m == null) return null;
    final value = double.tryParse(m[1]!.replaceAll(',', ''));
    if (value == null) return null;
    final unit = m[2]!.toLowerCase();
    final factor = unit == 'kg' || unit == 'l' ? 1000 : 1;
    return (amount: value * factor, label: '${m[1]} ${m[2]}');
  }
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
    this.photos = const [],
    this.producer,
    this.packName,
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
    photos: [
      ...((json['image_urls'] as List?) ?? const []).whereType<String>(),
    ].ifEmpty([if (json['image_url'] is String) json['image_url'] as String]),
    producer: ProducerInfo.fromJson(json['producer']),
    packName: (json['variant'] as Map<String, dynamic>?)?['name'] as String?,
  );

  /// Front then back of the pack, for the store page's posts.
  final List<String> photos;

  /// Who makes it (Amsterdam Group, Silverlands…); null when unknown.
  final ProducerInfo? producer;

  /// The pack on sale, e.g. "50 kg bag".
  final String? packName;

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
    this.verified = false,
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
      verified: p['verified'] == true,
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

  /// Details checked against the real label or the producer's own data.
  final bool verified;
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
  MarketFilters({
    required this.animalTypes,
    required this.categories,
    this.uses = const [],
  });

  factory MarketFilters.fromJson(Map<String, dynamic> json) => MarketFilters(
    animalTypes: (json['animal_types'] as List)
        .map((e) => CatalogNode.fromJson(e as Map<String, dynamic>))
        .toList(),
    categories: (json['categories'] as List)
        .map((e) => CatalogNode.fromJson(e as Map<String, dynamic>))
        .toList(),
    uses: UseTag.listFrom(json['uses']),
  );

  final List<CatalogNode> animalTypes;
  final List<CatalogNode> categories;

  /// Uses / conditions products on the marketplace cover, for the filter.
  final List<UseTag> uses;
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

extension<T> on List<T> {
  /// This list, or [fallback] when it is empty.
  List<T> ifEmpty(List<T> fallback) => isEmpty ? fallback : this;
}
