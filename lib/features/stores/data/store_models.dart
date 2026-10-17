import '../../inventory/data/inventory_models.dart';

/// Days in the order the API keys opening hours by.
const storeDays = {
  'mon': 'Monday',
  'tue': 'Tuesday',
  'wed': 'Wednesday',
  'thu': 'Thursday',
  'fri': 'Friday',
  'sat': 'Saturday',
  'sun': 'Sunday',
};

/// One day's hours; null in [Store.openingHours] means closed that day.
class DayHours {
  const DayHours({required this.open, required this.close});

  final String open;
  final String close;

  Map<String, String> toJson() => {'open': open, 'close': close};
}

class Store {
  Store({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.email,
    this.city,
    this.regionId,
    this.latitude,
    this.longitude,
    this.pickupInstructions,
    this.openingHours,
    this.isMarketplaceEnabled = true,
    this.status = 'active',
    required this.isPrimary,
    required this.productCount,
    required this.stockValue,
    required this.sellingValue,
    required this.expectedProfit,
  });

  factory Store.fromJson(Map<String, dynamic> json) => Store(
    id: json['id'] as int,
    name: json['name'] as String,
    address: json['address'] as String?,
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    city: json['city'] as String?,
    regionId: json['region_id'] as int?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    pickupInstructions: json['pickup_instructions'] as String?,
    openingHours: _parseHours(json['opening_hours']),
    isMarketplaceEnabled: json['is_marketplace_enabled'] as bool? ?? true,
    status: json['status'] as String? ?? 'active',
    isPrimary: json['is_primary'] as bool,
    productCount: json['product_count'] as int,
    stockValue: (json['stock_value'] as num).toDouble(),
    sellingValue: (json['selling_value'] as num).toDouble(),
    expectedProfit: (json['expected_profit'] as num).toDouble(),
  );

  final int id;
  final String name;
  final String? address;
  final String? phone;
  final String? email;
  final String? city;
  final int? regionId;
  final double? latitude;
  final double? longitude;
  final String? pickupInstructions;

  /// Keyed by [storeDays]; null when hours were never set.
  final Map<String, DayHours?>? openingHours;
  final bool isMarketplaceEnabled;

  /// active or suspended (set by the platform).
  final String status;
  final bool isPrimary;
  final int productCount;
  final double stockValue;
  final double sellingValue;
  final double expectedProfit;

  bool get hasLocation => latitude != null && longitude != null;

  static Map<String, DayHours?>? _parseHours(Object? raw) {
    if (raw is! Map) return null;
    return {
      for (final day in storeDays.keys)
        day: raw[day] is Map
            ? DayHours(
                open: (raw[day] as Map)['open'] as String,
                close: (raw[day] as Map)['close'] as String,
              )
            : null,
    };
  }
}

class StoreDetail {
  StoreDetail({required this.store, required this.items});

  factory StoreDetail.fromJson(Map<String, dynamic> json) => StoreDetail(
    store: Store.fromJson(json['data'] as Map<String, dynamic>),
    items: (json['items'] as List)
        .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final Store store;
  final List<InventoryItem> items;
}
