import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Coloured pill for an order status.
class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status, required this.label});

  final String status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'pending' => Colors.orange,
      'accepted' || 'preparing' => DukaColors.indigo,
      'ready_for_pickup' || 'completed' => Colors.green,
      _ => DukaColors.rose,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
