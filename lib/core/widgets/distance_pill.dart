import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// "📍 1.2 km" — how far a store is from the customer's location.
class DistancePill extends StatelessWidget {
  const DistancePill({super.key, required this.label, this.prefix});

  /// e.g. "1.2 km"
  final String label;

  /// Optional lead-in, e.g. "Nearest".
  final String? prefix;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: DukaColors.gold.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.near_me, size: 13, color: DukaColors.ink),
        const SizedBox(width: 4),
        Text(
          prefix == null ? label : '$prefix $label',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: DukaColors.ink,
          ),
        ),
      ],
    ),
  );
}
