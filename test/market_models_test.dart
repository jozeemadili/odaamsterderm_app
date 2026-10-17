import 'package:flutter_test/flutter_test.dart';
import 'package:odaamsterderm_app/features/auth/data/auth_models.dart';
import 'package:odaamsterderm_app/features/market/data/market_models.dart';

Map<String, dynamic> _store({String? distance}) => {
  'id': 3,
  'name': 'Seller C Store',
  'seller': {'id': 9, 'name': 'Seller C'},
  'address': 'Mbezi Beach Road',
  'city': 'Kinondoni',
  'latitude': -6.729,
  'longitude': 39.188,
  'opening_hours_lines': {'Monday': '07:30–18:30', 'Sunday': 'Closed'},
  'distance_label': distance,
};

void main() {
  test('MarketProduct parses search result aggregates', () {
    final p = MarketProduct.fromJson({
      'id': 1,
      'display_name': 'Chicken Starter 25KG',
      'unit': 'bag',
      'animal_type': {'id': 2, 'name': 'Chicken'},
      'category': {'id': 3, 'name': 'Feed › Starter'},
      'min_price': 43500,
      'sellers_count': 3,
      'available_quantity': 55,
      'nearest_label': '1.2 km',
    });

    expect(p.minPrice, 43500);
    expect(p.sellersCount, 3);
    expect(p.nearestLabel, '1.2 km');
    expect(p.category, 'Feed › Starter');
  });

  test('Comparison parses available and out-of-stock offers', () {
    final detail = MarketProductDetail.fromJson({
      'product': {
        'id': 1,
        'display_name': 'Chicken Starter 25KG',
        'unit': 'bag',
      },
      'offers': [
        {
          'id': 10,
          'product_id': 1,
          'name': 'Chicken Starter 25KG',
          'price': 44000,
          'unit': 'bag',
          'available_quantity': 0,
          'is_available': false,
          'distance_label': '7.6 km',
          'seller': {'id': 9, 'name': 'Seller C'},
          'store': _store(distance: '7.6 km'),
        },
      ],
    });

    final offer = detail.offers.single;
    expect(offer.isAvailable, isFalse);
    expect(offer.sellerName, 'Seller C');
    expect(offer.store.addressLine, 'Mbezi Beach Road, Kinondoni');
    expect(offer.store.openingHoursLines!['Sunday'], 'Closed');
  });

  test('MarketLocation compares by value (used as a provider key)', () {
    const a = MarketLocation(
      latitude: -6.779,
      longitude: 39.235,
      label: 'Sinza',
    );
    const b = MarketLocation(
      latitude: -6.779,
      longitude: 39.235,
      label: 'Sinza',
    );
    expect(a, equals(b));
    expect(a.toQuery(), {'lat': -6.779, 'lng': 39.235});
  });

  test('Customer user parses saved location', () {
    final user = DukaUser.fromJson({
      'id': 5,
      'name': 'Juma',
      'email': 'juma@example.com',
      'user_type': 'customer',
      'location': {'latitude': -6.779, 'longitude': 39.235, 'label': 'Sinza'},
    });

    expect(user.isCustomer, isTrue);
    expect(user.locationLabel, 'Sinza');
    expect(user.latitude, -6.779);
  });
}
