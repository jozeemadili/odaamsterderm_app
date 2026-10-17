import 'package:flutter_test/flutter_test.dart';
import 'package:odaamsterderm_app/features/orders/data/order_models.dart';

void main() {
  final store = {
    'id': 1,
    'name': 'Kilimo Bora — Mwenge',
    'seller': {'id': 1, 'name': 'Kilimo Bora Agrovet'},
    'latitude': -6.77,
    'longitude': 39.229,
  };

  test('Seller order parses customer, items, timeline and next actions', () {
    final o = MarketOrder.fromJson({
      'id': 7,
      'reference': 'OH-2610-NGPN5',
      'status': 'accepted',
      'status_label': 'Accepted',
      'total': 90000,
      'items_count': 1,
      'can_cancel': true,
      'next_statuses': [
        {'status': 'preparing', 'label': 'Being prepared'},
        {'status': 'rejected', 'label': 'Rejected by seller'},
      ],
      'store': store,
      'customer': {'name': 'Juma', 'phone': '+255700000099'},
      'items': [
        {
          'name': 'Chicken Starter 25KG',
          'unit': 'bag',
          'unit_price': 45000,
          'quantity': 2,
          'line_total': 90000,
        },
      ],
      'events': [
        {
          'status': 'pending',
          'label': 'Waiting for seller',
          'note': 'Order placed',
          'at': '2026-10-17T11:53:00+03:00',
        },
        {
          'status': 'accepted',
          'label': 'Accepted',
          'at': '2026-10-17T12:00:00+03:00',
        },
      ],
    });

    expect(o.nextStatuses.map((n) => n.status), ['preparing', 'rejected']);
    expect(o.customerName, 'Juma');
    expect(o.items.single.lineTotal, 90000);
    expect(o.events.first.note, 'Order placed');
    expect(o.store!.name, 'Kilimo Bora — Mwenge');
    expect(o.isClosed, isFalse);
  });

  test('Cart groups lines by store and flags problems', () {
    final cart = CartData.fromJson({
      'stores': [
        {
          'store': store,
          'total': 135000,
          'lines': [
            {
              'offer_id': 3,
              'name': 'Chicken Starter 25KG',
              'unit': 'bag',
              'unit_price': 45000,
              'quantity': 3,
              'available_quantity': 2,
              'line_total': 135000,
              'problem': 'Only 2 bag available.',
            },
          ],
        },
      ],
      'total': 135000,
      'count': 1,
    });

    expect(cart.stores.single.lines.single.problem, 'Only 2 bag available.');
    expect(cart.hasProblems, isTrue);
    expect(cart.total, 135000);
  });
}
