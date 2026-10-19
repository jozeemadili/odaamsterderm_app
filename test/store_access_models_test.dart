import 'package:flutter_test/flutter_test.dart';
import 'package:odaamsterderm_app/features/auth/data/auth_models.dart';

void main() {
  test('seller staff user parses the stores they work in', () {
    final user = DukaUser.fromJson({
      'id': 7,
      'name': 'Asha',
      'email': 'asha@example.com',
      'user_type': 'merchant',
      'role': 'merchant_sales',
      'merchant_id': 3,
      'all_stores': false,
      'stores': [
        {'id': 4, 'name': 'Tegeta'},
      ],
    });

    expect(user.allStores, isFalse);
    expect(user.stores.single.name, 'Tegeta');
  });

  test('older API responses without stores still parse', () {
    final user = DukaUser.fromJson({
      'id': 1,
      'name': 'Owner',
      'email': 'o@example.com',
      'user_type': 'merchant',
    });

    expect(user.stores, isEmpty);
  });
}
