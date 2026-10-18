import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../inventory/data/inventory_models.dart';
import '../data/pos_repository.dart';

final posRepositoryProvider = Provider(
  (ref) => PosRepository(ref.watch(apiClientProvider)),
);

/// One line in the cart. Discount fields mirror the backend's own shape —
/// `percent` (of unit price) or `fixed` (a flat amount off the unit price).
class CartLine {
  CartLine({
    required this.item,
    required this.quantity,
    this.discountType,
    this.discountValue,
  });

  final InventoryItem item;
  final double quantity;
  final String? discountType;
  final double? discountValue;

  double get unitPrice => item.unitPrice ?? 0;
  double get grossAmount => unitPrice * quantity;

  double get discountAmount {
    if (discountType == null || discountValue == null || discountValue! <= 0) {
      return 0;
    }
    final perUnit = discountType == 'percent'
        ? unitPrice * (discountValue! / 100)
        : discountValue!;
    return perUnit.clamp(0, unitPrice) * quantity;
  }

  double get subtotal => grossAmount - discountAmount;

  CartLine copyWith({
    double? quantity,
    String? discountType,
    double? discountValue,
    bool clearDiscount = false,
  }) {
    return CartLine(
      item: item,
      quantity: quantity ?? this.quantity,
      discountType: clearDiscount ? null : (discountType ?? this.discountType),
      discountValue: clearDiscount
          ? null
          : (discountValue ?? this.discountValue),
    );
  }

  CartLineInput toInput() => CartLineInput(
    inventoryItemId: item.id,
    quantity: quantity,
    discountType: discountType,
    discountValue: discountValue,
  );
}

class PosCartState {
  const PosCartState({
    this.lines = const [],
    this.overallDiscountType,
    this.overallDiscountValue,
    this.paymentMethodId,
  });

  final List<CartLine> lines;
  final String? overallDiscountType;
  final double? overallDiscountValue;
  final int? paymentMethodId;

  bool get isEmpty => lines.isEmpty;
  int get lineCount => lines.length;

  double get subtotal => lines.fold(0.0, (sum, l) => sum + l.subtotal);

  double get overallDiscountAmount {
    if (overallDiscountType == null ||
        overallDiscountValue == null ||
        overallDiscountValue! <= 0) {
      return 0;
    }
    return overallDiscountType == 'percent'
        ? subtotal * (overallDiscountValue! / 100)
        : overallDiscountValue!.clamp(0, subtotal);
  }

  double get total {
    final t = subtotal - overallDiscountAmount;
    return t < 0 ? 0 : t;
  }

  PosCartState copyWith({
    List<CartLine>? lines,
    Object? overallDiscountType = _unset,
    Object? overallDiscountValue = _unset,
    Object? paymentMethodId = _unset,
  }) {
    return PosCartState(
      lines: lines ?? this.lines,
      overallDiscountType: identical(overallDiscountType, _unset)
          ? this.overallDiscountType
          : overallDiscountType as String?,
      overallDiscountValue: identical(overallDiscountValue, _unset)
          ? this.overallDiscountValue
          : overallDiscountValue as double?,
      paymentMethodId: identical(paymentMethodId, _unset)
          ? this.paymentMethodId
          : paymentMethodId as int?,
    );
  }
}

const _unset = Object();

class PosCartController extends StateNotifier<PosCartState> {
  PosCartController() : super(const PosCartState());

  void addItem(InventoryItem item, {double quantity = 1}) {
    final index = state.lines.indexWhere((l) => l.item.id == item.id);
    if (index == -1) {
      state = state.copyWith(
        lines: [
          ...state.lines,
          CartLine(item: item, quantity: quantity),
        ],
      );
    } else {
      final updated = [...state.lines];
      updated[index] = updated[index].copyWith(
        quantity: updated[index].quantity + quantity,
      );
      state = state.copyWith(lines: updated);
    }
  }

  void setQuantity(int itemId, double quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }
    state = state.copyWith(
      lines: [
        for (final l in state.lines)
          if (l.item.id == itemId) l.copyWith(quantity: quantity) else l,
      ],
    );
  }

  void removeItem(int itemId) {
    state = state.copyWith(
      lines: state.lines.where((l) => l.item.id != itemId).toList(),
    );
  }

  void setLineDiscount(int itemId, {String? type, double? value}) {
    state = state.copyWith(
      lines: [
        for (final l in state.lines)
          if (l.item.id == itemId)
            l.copyWith(
              discountType: type,
              discountValue: value,
              clearDiscount: type == null,
            )
          else
            l,
      ],
    );
  }

  void setOverallDiscount({String? type, double? value}) {
    state = state.copyWith(
      overallDiscountType: type,
      overallDiscountValue: value,
    );
  }

  void setPaymentMethod(int? id) => state = state.copyWith(paymentMethodId: id);

  void clear() => state = const PosCartState();
}

final posCartControllerProvider =
    StateNotifierProvider<PosCartController, PosCartState>(
      (ref) => PosCartController(),
    );

final paymentMethodsProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(posRepositoryProvider).paymentMethods(),
);
