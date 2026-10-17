import 'package:flutter_test/flutter_test.dart';
import 'package:odaamsterderm_app/features/dashboard/data/dashboard_models.dart';
import 'package:odaamsterderm_app/features/inventory/data/inventory_models.dart';
import 'package:odaamsterderm_app/features/stores/data/store_models.dart';

void main() {
  test('InventoryItem parses catalog product and marketplace info', () {
    final item = InventoryItem.fromJson({
      'id': 1,
      'name': 'Chicken Starter 25KG',
      'unit': 'bag',
      'quantity_on_hand': 100,
      'reorder_level': 20,
      'is_low_stock': false,
      'is_expiring_soon': false,
      'is_expired': false,
      'product_id': 7,
      'product': {
        'id': 7,
        'name': 'Chicken Starter',
        'display_name': 'Chicken Starter 25KG',
        'unit': 'bag',
        'status': 'approved',
        'animal_type': {'id': 2, 'name': 'Chicken'},
        'category': {'id': 3, 'name': 'Feed › Starter'},
      },
      'marketplace': {
        'is_visible': true,
        'quantity': 30,
        'reserved_quantity': 0,
        'available_quantity': 100,
        'status': 'active',
        'blockers': <String>[],
      },
    });

    expect(item.product!.displayName, 'Chicken Starter 25KG');
    expect(item.product!.categoryName, 'Feed › Starter');
    expect(item.marketplace.quantity, 30);
    expect(item.marketplace.isListed, isTrue);
    expect(item.marketplace.blockers, isEmpty);
  });

  test('InventoryItem without marketplace data defaults to hidden', () {
    final item = InventoryItem.fromJson({
      'id': 1,
      'name': 'Soap',
      'quantity_on_hand': 5,
      'reorder_level': 1,
      'is_low_stock': false,
      'is_expiring_soon': false,
      'is_expired': false,
    });

    expect(item.marketplace.isVisible, isFalse);
    expect(item.marketplace.statusLabel, 'Inactive');
  });

  test('Store parses location and opening hours with closed days', () {
    final store = Store.fromJson({
      'id': 1,
      'name': 'Mwenge',
      'is_primary': true,
      'product_count': 6,
      'stock_value': 1000,
      'selling_value': 1200,
      'expected_profit': 200,
      'latitude': -6.77,
      'longitude': 39.229,
      'opening_hours': {
        'mon': {'open': '08:00', 'close': '18:00'},
        'sun': null,
      },
      'is_marketplace_enabled': true,
      'status': 'active',
    });

    expect(store.hasLocation, isTrue);
    expect(store.openingHours!['mon']!.close, '18:00');
    expect(store.openingHours!['sun'], isNull);
    expect(store.openingHours!.length, 7);
  });

  test('DashboardMarketplace parses seller marketplace metrics', () {
    final m = DashboardMarketplace.fromJson({
      'approved': true,
      'listed_count': 5,
      'units_exposed': 101,
      'out_of_stock_count': 0,
      'hidden_count': 1,
    });

    expect(m.listedCount, 5);
    expect(m.unitsExposed, 101);
  });
}
