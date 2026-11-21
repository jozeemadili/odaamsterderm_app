double? _d(Object? v) => (v as num?)?.toDouble();

/// Text in the app's language: Kiswahili when there is one.
String _pick(String lang, String? en, String? sw) =>
    lang == 'sw' && (sw?.isNotEmpty ?? false) ? sw! : (en ?? '');

DateTime? _date(Object? v) => v is String ? DateTime.parse(v) : null;

/// One order day: the day an agent's chicks arrive, with boxes left.
class HatchDate {
  HatchDate({
    required this.id,
    required this.hatchDate,
    required this.capBoxes,
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
    capBoxes: (json['cap_boxes'] as int?) ?? 0,
    boxesAvailable: json['boxes_available'] as int,
    status: json['status'] as String,
    statusLabel: json['status_label'] as String,
    statusLabelSw: json['status_label_sw'] as String?,
    pricePerBox: _d(json['price_per_box']),
    notes: json['notes'] as String?,
  );

  final int id;
  final DateTime hatchDate;
  final int capBoxes;
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

/// A store where an agent's chicks arrive for pickup.
class ChickPickupStore {
  ChickPickupStore({
    required this.id,
    required this.name,
    this.address,
    this.distanceKm,
  });

  factory ChickPickupStore.fromJson(Map<String, dynamic> json) =>
      ChickPickupStore(
        id: json['id'] as int,
        name: json['name'] as String,
        address: json['address'] as String?,
        distanceKm: _d(json['distance_km']),
      );

  final int id;
  final String name;
  final String? address;
  final double? distanceKm;
}

/// A hatchery an agent sells for, with its pickup stores and order days.
class Hatchery {
  Hatchery({
    required this.id,
    required this.name,
    this.logoUrl,
    this.description,
    required this.boxesAvailable,
    required this.pickupStores,
    required this.dates,
  });

  factory Hatchery.fromJson(Map<String, dynamic> json) => Hatchery(
    id: json['id'] as int,
    name: json['name'] as String,
    logoUrl: json['logo_url'] as String?,
    description: json['description'] as String?,
    boxesAvailable: json['boxes_available'] as int,
    pickupStores: [
      for (final s in (json['pickup_stores'] as List?) ?? const [])
        ChickPickupStore.fromJson(s as Map<String, dynamic>),
    ],
    dates: [
      for (final d in (json['dates'] as List?) ?? const [])
        HatchDate.fromJson(d as Map<String, dynamic>),
    ],
  );

  final int id;
  final String name;
  final String? logoUrl;
  final String? description;
  final int boxesAvailable;
  final List<ChickPickupStore> pickupStores;
  final List<HatchDate> dates;
}

/// An agent selling one chick type: nearest store, next arrival, hatcheries.
class ChickAgent {
  ChickAgent({
    required this.id,
    required this.name,
    this.logoUrl,
    this.nearestKm,
    this.nearestStore,
    required this.storesCount,
    required this.boxesAvailable,
    this.nextDate,
    required this.hatcheries,
  });

  factory ChickAgent.fromJson(Map<String, dynamic> json) => ChickAgent(
    id: json['id'] as int,
    name: json['name'] as String,
    logoUrl: json['logo_url'] as String?,
    nearestKm: _d(json['nearest_km']),
    nearestStore: json['nearest_store'] as String?,
    storesCount: (json['stores_count'] as int?) ?? 0,
    boxesAvailable: json['boxes_available'] as int,
    nextDate: _date(json['next_date']),
    hatcheries: [
      for (final h in (json['hatcheries'] as List?) ?? const [])
        Hatchery.fromJson(h as Map<String, dynamic>),
    ],
  );

  final int id;
  final String name;
  final String? logoUrl;
  final double? nearestKm;
  final String? nearestStore;
  final int storesCount;
  final int boxesAvailable;
  final DateTime? nextDate;
  final List<Hatchery> hatcheries;
}

/// Broiler, Layers, Sasso or Tanbro, with the agents selling it.
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
    required this.agents,
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
    agents: [
      for (final a in (json['agents'] as List?) ?? const [])
        ChickAgent.fromJson(a as Map<String, dynamic>),
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
  final List<ChickAgent> agents;

  String subtitleFor(String lang) => lang == 'sw' ? (nameSw ?? name) : name;
  String purposeFor(String lang) => _pick(lang, purposeLabel, purposeLabelSw);
  String summaryFor(String lang) => _pick(lang, summary, summarySw);
  String descriptionFor(String lang) => _pick(lang, description, descriptionSw);

  ChickAgent? agent(int id) => agents.where((a) => a.id == id).firstOrNull;
}

/// Everything the chick screens need, from GET /market/chicks.
class ChickCatalogue {
  ChickCatalogue({
    required this.boxSize,
    required this.showPrices,
    required this.types,
  });

  factory ChickCatalogue.fromJson(Map<String, dynamic> json) => ChickCatalogue(
    boxSize: json['box_size'] as int,
    showPrices: json['show_prices'] == true,
    types: [
      for (final t in (json['types'] as List?) ?? const [])
        ChickTypeInfo.fromJson(t as Map<String, dynamic>),
    ],
  );

  final int boxSize;
  final bool showPrices;
  final List<ChickTypeInfo> types;

  ChickTypeInfo? type(String code) =>
      types.where((t) => t.code == code).firstOrNull;
}

// --- The agent's own chick sales -------------------------------------------

/// An agent's contract with a hatchery for one chick type.
class ChickContractInfo {
  ChickContractInfo({
    required this.id,
    required this.producerId,
    required this.producerName,
    required this.chickTypeId,
    required this.chickTypeName,
    required this.branchIds,
    required this.weekdays,
    required this.capBoxes,
    this.pricePerChick,
    required this.isActive,
    required this.isSample,
  });

  factory ChickContractInfo.fromJson(Map<String, dynamic> json) {
    final producer = json['producer'] as Map<String, dynamic>;
    final type = json['chick_type'] as Map<String, dynamic>;
    return ChickContractInfo(
      id: json['id'] as int,
      producerId: producer['id'] as int,
      producerName: producer['name'] as String,
      chickTypeId: type['id'] as int,
      chickTypeName: type['name'] as String,
      branchIds: [
        for (final b in (json['branch_ids'] as List?) ?? []) b as int,
      ],
      weekdays: [for (final d in (json['weekdays'] as List?) ?? []) d as int],
      capBoxes: json['cap_boxes'] as int,
      pricePerChick: _d(json['price_per_chick']),
      isActive: json['is_active'] == true,
      isSample: json['is_sample'] == true,
    );
  }

  final int id;
  final int producerId;
  final String producerName;
  final int chickTypeId;
  final String chickTypeName;
  final List<int> branchIds;
  final List<int> weekdays;
  final int capBoxes;
  final double? pricePerChick;
  final bool isActive;
  final bool isSample;
}

/// One of the agent's order days, with bookings so far.
class AgentOrderDay {
  AgentOrderDay({
    required this.id,
    this.contractId,
    required this.hatchDate,
    required this.producer,
    required this.chickType,
    required this.capBoxes,
    required this.bookedBoxes,
    required this.boxesAvailable,
    this.pricePerChick,
    required this.status,
    required this.statusLabel,
    required this.isClosed,
    this.notes,
  });

  factory AgentOrderDay.fromJson(Map<String, dynamic> json) => AgentOrderDay(
    id: json['id'] as int,
    contractId: json['chick_contract_id'] as int?,
    hatchDate: DateTime.parse(json['hatch_date'] as String),
    producer: json['producer'] as String,
    chickType: json['chick_type'] as String,
    capBoxes: json['cap_boxes'] as int,
    bookedBoxes: json['booked_boxes'] as int,
    boxesAvailable: json['boxes_available'] as int,
    pricePerChick: _d(json['price_per_chick']),
    status: json['status'] as String,
    statusLabel: json['status_label'] as String,
    isClosed: json['is_closed'] == true,
    notes: json['notes'] as String?,
  );

  final int id;
  final int? contractId;
  final DateTime hatchDate;
  final String producer;
  final String chickType;
  final int capBoxes;
  final int bookedBoxes;
  final int boxesAvailable;
  final double? pricePerChick;
  final String status;
  final String statusLabel;
  final bool isClosed;
  final String? notes;
}

class IdName {
  IdName(this.id, this.name);

  factory IdName.fromJson(Map<String, dynamic> json) =>
      IdName(json['id'] as int, json['name'] as String);

  final int id;
  final String name;
}

/// A booking on one of the agent's order days.
class ChickBooking {
  ChickBooking({
    required this.orderId,
    required this.reference,
    required this.statusLabel,
    required this.customerName,
    this.customerPhone,
    required this.boxes,
    this.store,
  });

  factory ChickBooking.fromJson(Map<String, dynamic> json) => ChickBooking(
    orderId: json['order_id'] as int,
    reference: json['reference'] as String,
    statusLabel: json['status_label'] as String,
    customerName: json['customer_name'] as String,
    customerPhone: json['customer_phone'] as String?,
    boxes: json['boxes'] as int,
    store: json['store'] as String?,
  );

  final int orderId;
  final String reference;
  final String statusLabel;
  final String customerName;
  final String? customerPhone;
  final int boxes;
  final String? store;
}

/// GET /chicks for an agent: contracts, upcoming days and form choices.
class AgentChickSetup {
  AgentChickSetup({
    required this.boxSize,
    required this.contracts,
    required this.days,
    required this.hatcheries,
    required this.chickTypes,
    required this.stores,
  });

  factory AgentChickSetup.fromJson(Map<String, dynamic> json) =>
      AgentChickSetup(
        boxSize: json['box_size'] as int,
        contracts: [
          for (final c in (json['contracts'] as List?) ?? const [])
            ChickContractInfo.fromJson(c as Map<String, dynamic>),
        ],
        days: [
          for (final d in (json['days'] as List?) ?? const [])
            AgentOrderDay.fromJson(d as Map<String, dynamic>),
        ],
        hatcheries: [
          for (final h in (json['hatcheries'] as List?) ?? const [])
            IdName.fromJson(h as Map<String, dynamic>),
        ],
        chickTypes: [
          for (final t in (json['chick_types'] as List?) ?? const [])
            IdName.fromJson(t as Map<String, dynamic>),
        ],
        stores: [
          for (final s in (json['stores'] as List?) ?? const [])
            if ((s as Map<String, dynamic>)['on_marketplace'] == true)
              IdName.fromJson(s),
        ],
      );

  final int boxSize;
  final List<ChickContractInfo> contracts;
  final List<AgentOrderDay> days;
  final List<IdName> hatcheries;
  final List<IdName> chickTypes;
  final List<IdName> stores;
}

/// Something the chicks being booked will need first, sized to the boxes
/// and taken from the pickup store's shelf.
class CareSuggestion {
  CareSuggestion({
    required this.offerId,
    required this.name,
    required this.quantity,
    required this.reason,
    this.reasonSw,
    this.amount,
    this.lineTotal,
  });

  factory CareSuggestion.fromJson(Map<String, dynamic> json) => CareSuggestion(
    offerId: json['offer_id'] as int,
    name: json['name'] as String,
    quantity: (json['quantity'] as num).toInt(),
    reason: json['reason'] as String,
    reasonSw: json['reason_sw'] as String?,
    amount: json['amount'] as String?,
    lineTotal: _d(json['line_total']),
  );

  final int offerId;
  final String name;
  final int quantity;
  final String reason;
  final String? reasonSw;
  final String? amount;

  /// Null while prices are hidden on the marketplace.
  final double? lineTotal;

  String reasonFor(String lang) => _pick(lang, reason, reasonSw);
}
