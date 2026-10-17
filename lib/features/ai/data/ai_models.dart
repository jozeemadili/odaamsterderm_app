import '../../market/data/market_models.dart';

double _d(Object? v) => (v as num?)?.toDouble() ?? 0;

/// Which AI buttons to show — follows the admin switches.
class AiConfig {
  const AiConfig({
    required this.searchEnabled,
    required this.searchGuests,
    required this.orderEnabled,
  });

  factory AiConfig.fromJson(Map<String, dynamic> json) => AiConfig(
    searchEnabled: json['search_enabled'] as bool? ?? false,
    searchGuests: json['search_guests'] as bool? ?? false,
    orderEnabled: json['order_enabled'] as bool? ?? false,
  );

  static const off = AiConfig(
    searchEnabled: false,
    searchGuests: false,
    orderEnabled: false,
  );

  final bool searchEnabled;
  final bool searchGuests;
  final bool orderEnabled;
}

/// Ask AI search: the AI's note plus products with live prices.
class AiSearchResult {
  AiSearchResult({
    required this.status,
    required this.summary,
    required this.fallback,
    required this.products,
  });

  factory AiSearchResult.fromJson(Map<String, dynamic> json) {
    final ai = json['ai'] as Map<String, dynamic>? ?? const {};
    return AiSearchResult(
      status: ai['status'] as String? ?? 'ok',
      summary: ai['summary'] as String? ?? '',
      fallback: ai['fallback'] as bool? ?? false,
      products: (json['data'] as List)
          .map((e) => MarketProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// ok | off_topic | refused | unavailable | limited
  final String status;
  final String summary;

  /// True when the AI didn't answer and these are keyword results.
  final bool fallback;
  final List<MarketProduct> products;
}

/// One proposed basket line (an offer: product at one store).
class AiBasketLine {
  AiBasketLine({
    required this.offerId,
    required this.name,
    required this.store,
    required this.seller,
    required this.unit,
    required this.unitPrice,
    required this.quantity,
    required this.available,
    this.distance,
    this.note,
  });

  factory AiBasketLine.fromJson(Map<String, dynamic> json) => AiBasketLine(
    offerId: json['offer_id'] as int,
    name: json['name'] as String,
    store: json['store'] as String,
    seller: json['seller'] as String? ?? '',
    unit: json['unit'] as String? ?? '',
    unitPrice: _d(json['unit_price']),
    quantity: _d(json['quantity']),
    available: _d(json['available']),
    distance: json['distance'] as String?,
    note: json['note'] as String?,
  );

  final int offerId;
  final String name;
  final String store;
  final String seller;
  final String unit;
  final double unitPrice;
  final double quantity;
  final double available;
  final String? distance;
  final String? note;
}

/// A chat message. Assistant turns keep the server's [memo] so the
/// assistant remembers the basket it proposed.
class AiChatMessage {
  const AiChatMessage({
    required this.role,
    required this.content,
    this.memo = '',
  });

  /// user | assistant | notice (notices are local only)
  final String role;
  final String content;
  final String memo;

  Map<String, dynamic> toJson() => {'role': role, 'content': content + memo};
}

class AiOrderReply {
  AiOrderReply({
    required this.status,
    required this.reply,
    required this.basket,
    required this.memo,
  });

  factory AiOrderReply.fromJson(Map<String, dynamic> json) => AiOrderReply(
    status: json['status'] as String? ?? 'unavailable',
    reply: json['reply'] as String? ?? '',
    basket: ((json['basket'] as List?) ?? const [])
        .map((e) => AiBasketLine.fromJson(e as Map<String, dynamic>))
        .toList(),
    memo: json['memo'] as String? ?? '',
  );

  final String status;
  final String reply;
  final List<AiBasketLine> basket;
  final String memo;
}
