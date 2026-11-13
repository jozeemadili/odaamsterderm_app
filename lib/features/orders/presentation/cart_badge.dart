import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import 'order_controller.dart';

/// A cart icon with the number of items in the cart on a small badge.
class CartBadgeIcon extends ConsumerWidget {
  const CartBadgeIcon({
    super.key,
    this.icon = Icons.shopping_cart_outlined,
    this.size,
  });

  final IconData icon;
  final double? size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartCountProvider);
    return Badge(
      isLabelVisible: count > 0,
      backgroundColor: DukaColors.leaf,
      textColor: const Color(0xFF1B2A0A),
      label: Text(count > 99 ? '99+' : '$count'),
      child: Icon(icon, size: size),
    );
  }
}
