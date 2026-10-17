import 'package:flutter_test/flutter_test.dart';
import 'package:odaamsterderm_app/features/ai/data/ai_models.dart';

void main() {
  test('order reply parses the basket and memo', () {
    final r = AiOrderReply.fromJson({
      'status': 'ok',
      'reply': 'Here you go',
      'memo': '\n\n[Basket I proposed: offer 7 x 2]',
      'basket': [
        {
          'offer_id': 7,
          'name': 'Chicken Starter 25KG',
          'store': 'Seller B Store',
          'seller': 'Seller B',
          'unit': 'bag',
          'unit_price': 43500,
          'quantity': 2,
          'available': 25,
          'distance': '3.9 km',
          'note': null,
        },
      ],
    });

    expect(r.basket.single.offerId, 7);
    expect(r.basket.single.unitPrice, 43500.0);
    expect(r.basket.single.available, 25.0);

    // The assistant's turn is sent back with its memo; notices are not sent.
    final msg = AiChatMessage(role: 'assistant', content: r.reply, memo: r.memo);
    expect(msg.toJson()['content'], 'Here you go\n\n[Basket I proposed: offer 7 x 2]');
  });

  test('config defaults to off', () {
    final c = AiConfig.fromJson({'search_enabled': true});
    expect(c.searchEnabled, isTrue);
    expect(c.orderEnabled, isFalse);
  });
}
