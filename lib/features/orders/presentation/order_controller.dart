import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/order_models.dart';
import '../data/order_repository.dart';

final orderRepositoryProvider = Provider(
  (ref) => OrderRepository(ref.watch(apiClientProvider)),
);

/// The customer's cart; screens update it with the cart returned by the API.
class CartController extends StateNotifier<AsyncValue<CartData>> {
  CartController(this._repo) : super(const AsyncValue.loading()) {
    refresh();
  }

  final OrderRepository _repo;

  Future<void> refresh() async {
    state = await AsyncValue.guard(_repo.cart);
  }

  Future<void> add(int offerId, double quantity) async {
    state = AsyncValue.data(await _repo.addToCart(offerId, quantity));
  }

  Future<void> setQuantity(int offerId, double quantity) async {
    state = AsyncValue.data(await _repo.setCartQuantity(offerId, quantity));
  }

  Future<List<MarketOrder>> checkout({String? note, String? phone}) async {
    final orders = await _repo.checkout(note: note, phone: phone);
    await refresh();
    return orders;
  }
}

final cartControllerProvider =
    StateNotifierProvider.autoDispose<CartController, AsyncValue<CartData>>(
      (ref) => CartController(ref.watch(orderRepositoryProvider)),
    );

final myOrdersProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(orderRepositoryProvider).myOrders(),
);

final myOrderProvider = FutureProvider.autoDispose.family(
  (ref, int id) => ref.watch(orderRepositoryProvider).myOrder(id),
);

final sellerOrdersProvider = FutureProvider.autoDispose.family(
  (ref, String status) =>
      ref.watch(orderRepositoryProvider).sellerOrders(status: status),
);

final sellerOrderProvider = FutureProvider.autoDispose.family(
  (ref, int id) => ref.watch(orderRepositoryProvider).sellerOrder(id),
);

final userNotificationsProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(orderRepositoryProvider).notifications(),
);
