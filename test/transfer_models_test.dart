import 'package:flutter_test/flutter_test.dart';
import 'package:odaamsterderm_app/features/transfers/data/transfer_models.dart';

void main() {
  test('transfer parses stores, lines and actions', () {
    final t = StockTransfer.fromJson({
      'id': 4,
      'number': 'TRF-00004',
      'status': 'sent',
      'from_store': {'id': 1, 'name': 'Mwenge'},
      'to_store': {'id': 2, 'name': 'Tegeta'},
      'sent_at': '2026-10-19T08:00:00+03:00',
      'items': [
        {'id': 1, 'inventory_item_id': 9, 'name': 'Layers Mash', 'unit': 'bag', 'quantity': 5},
      ],
      'can_receive': true,
      'can_cancel': false,
      'note_url': 'https://example.test/note',
    });

    expect(t.isOnTheWay, isTrue);
    expect(t.toStore.name, 'Tegeta');
    expect(t.items.single.quantity, 5);
    expect(t.canReceive, isTrue);
    expect(formatQty(2.5), '2.5');
    expect(formatQty(5), '5');
  });
}
