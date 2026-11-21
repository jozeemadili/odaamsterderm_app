double? _d(Object? v) => (v as num?)?.toDouble();

/// Text in the app's language: Kiswahili when there is one.
String _pick(String lang, String? en, String? sw) =>
    lang == 'sw' && (sw?.isNotEmpty ?? false) ? sw! : (en ?? '');

/// One hatch date of one hatchery: chicks left in whole boxes.
class HatchDate {
  HatchDate({
    required this.id,
    required this.hatchDate,
    required this.orderCutoffDate,
    required this.boxesAvailable,
    required this.status,
    required this.statusLabel,
    this.statusLabelSw,
    this.pricePerBox,
    this.notes,
  });

  factory HatchDate.fromJson(Map<String, dynamic> json) => HatchDate(
    id: json['id'] as int,
    hatchDate: DateTime.parse(json['hatch_date'] as String),
    orderCutoffDate: DateTime.parse(json['order_cutoff_date'] as String),
    boxesAvailable: json['boxes_available'] as int,
    status: json['status'] as String,
    statusLabel: json['status_label'] as String,
    statusLabelSw: json['status_label_sw'] as String?,
    pricePerBox: _d(json['price_per_box']),
    notes: json['notes'] as String?,
  );

  final int id;
  final DateTime hatchDate;
  final DateTime orderCutoffDate;
  final int boxesAvailable;
  final String status;
  final String statusLabel;
  final String? statusLabelSw;

  /// Null while prices are hidden on the marketplace.
  final double? pricePerBox;
  final String? notes;

  bool get isOpen => status == 'open';

  String statusFor(String lang) => _pick(lang, statusLabel, statusLabelSw);
}

/// A hatchery producing one chick type, with its bookable dates.
class Hatchery {
  Hatchery({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
    this.location,
    this.description,
    required this.boxesAvailable,
    this.nextHatchDate,
    required this.dates,
  });

  factory Hatchery.fromJson(Map<String, dynamic> json) => Hatchery(
    id: json['id'] as int,
    name: json['name'] as String,
    slug: json['slug'] as String,
    logoUrl: json['logo_url'] as String?,
    location: json['location'] as String?,
    description: json['description'] as String?,
    boxesAvailable: json['boxes_available'] as int,
    nextHatchDate: json['next_hatch_date'] != null
        ? DateTime.parse(json['next_hatch_date'] as String)
        : null,
    dates: [
      for (final d in (json['dates'] as List?) ?? const [])
        HatchDate.fromJson(d as Map<String, dynamic>),
    ],
  );

  final int id;
  final String name;
  final String slug;
  final String? logoUrl;
  final String? location;
  final String? description;
  final int boxesAvailable;
  final DateTime? nextHatchDate;
  final List<HatchDate> dates;
}

/// Broiler, Layers, Sasso or Tanbro, with the hatcheries that make it.
class ChickTypeInfo {
  ChickTypeInfo({
    required this.code,
    required this.name,
    this.nameSw,
    required this.purposeLabel,
    this.purposeLabelSw,
    this.summary,
    this.summarySw,
    this.description,
    this.descriptionSw,
    required this.boxesAvailable,
    required this.hatcheries,
  });

  factory ChickTypeInfo.fromJson(Map<String, dynamic> json) => ChickTypeInfo(
    code: json['code'] as String,
    name: json['name'] as String,
    nameSw: json['name_sw'] as String?,
    purposeLabel: json['purpose_label'] as String,
    purposeLabelSw: json['purpose_label_sw'] as String?,
    summary: json['summary'] as String?,
    summarySw: json['summary_sw'] as String?,
    description: json['description'] as String?,
    descriptionSw: json['description_sw'] as String?,
    boxesAvailable: json['boxes_available'] as int,
    hatcheries: [
      for (final h in (json['hatcheries'] as List?) ?? const [])
        Hatchery.fromJson(h as Map<String, dynamic>),
    ],
  );

  final String code;
  final String name;
  final String? nameSw;
  final String purposeLabel;
  final String? purposeLabelSw;
  final String? summary;
  final String? summarySw;
  final String? description;
  final String? descriptionSw;
  final int boxesAvailable;
  final List<Hatchery> hatcheries;

  String subtitleFor(String lang) => lang == 'sw' ? (nameSw ?? name) : name;
  String purposeFor(String lang) => _pick(lang, purposeLabel, purposeLabelSw);
  String summaryFor(String lang) => _pick(lang, summary, summarySw);
  String descriptionFor(String lang) => _pick(lang, description, descriptionSw);
}

/// A store where booked chicks are collected.
class ChickPickupStore {
  ChickPickupStore({required this.id, required this.name, this.address});

  factory ChickPickupStore.fromJson(Map<String, dynamic> json) =>
      ChickPickupStore(
        id: json['id'] as int,
        name: json['name'] as String,
        address: json['address'] as String?,
      );

  final int id;
  final String name;
  final String? address;
}

/// Everything the chick screens need, from GET /market/chicks.
class ChickCatalogue {
  ChickCatalogue({
    required this.boxSize,
    required this.showPrices,
    required this.types,
    required this.pickupStores,
  });

  factory ChickCatalogue.fromJson(Map<String, dynamic> json) => ChickCatalogue(
    boxSize: json['box_size'] as int,
    showPrices: json['show_prices'] == true,
    types: [
      for (final t in (json['types'] as List?) ?? const [])
        ChickTypeInfo.fromJson(t as Map<String, dynamic>),
    ],
    pickupStores: [
      for (final s in (json['pickup_stores'] as List?) ?? const [])
        ChickPickupStore.fromJson(s as Map<String, dynamic>),
    ],
  );

  final int boxSize;
  final bool showPrices;
  final List<ChickTypeInfo> types;
  final List<ChickPickupStore> pickupStores;

  ChickTypeInfo? type(String code) =>
      types.where((t) => t.code == code).firstOrNull;
}
