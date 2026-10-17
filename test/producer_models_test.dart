import 'package:flutter_test/flutter_test.dart';
import 'package:odaamsterderm_app/features/catalog/data/catalog_models.dart';
import 'package:odaamsterderm_app/features/market/data/market_models.dart';

void main() {
  test('market product parses its producer and logo', () {
    final p = MarketProduct.fromJson({
      'id': 2,
      'display_name': 'Chicken Grower 25KG',
      'unit': 'bag',
      'brand': 'Silverlands',
      'producer': {
        'id': 1,
        'name': 'Silverlands',
        'logo_url': 'https://example.test/logo.png',
        'country': 'Tanzania',
      },
      'sellers_count': 2,
      'available_quantity': 60,
    });

    expect(p.producer?.name, 'Silverlands');
    expect(p.producer?.logoUrl, 'https://example.test/logo.png');
  });

  test('catalog product falls back to the free-text brand', () {
    final p = CatalogProduct.fromJson({
      'id': 9,
      'name': 'Dewormer',
      'display_name': 'Dewormer 1L',
      'unit': 'bottle',
      'status': 'approved',
      'brand': 'Local Vet Co',
      'producer': null,
    });

    expect(p.producer, isNull);
    expect(p.makerName, 'Local Vet Co');
  });
}
