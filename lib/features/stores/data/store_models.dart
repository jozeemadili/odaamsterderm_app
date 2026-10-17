import '../../inventory/data/inventory_models.dart';

class Store {
  Store({
    required this.id,
    required this.name,
    this.address,
    this.phone,
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
  final bool isPrimary;
  final int productCount;
  final double stockValue;
  final double sellingValue;
  final double expectedProfit;
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
