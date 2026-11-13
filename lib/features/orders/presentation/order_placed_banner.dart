import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n_extension.dart';
import '../../market/presentation/customer_shell.dart';

/// "Order sent to the shop": shown once, right after checkout.
class OrderPlacedBanner extends ConsumerWidget {
  const OrderPlacedBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DukaColors.leafTint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DukaColors.leaf.withValues(alpha: .5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: DukaColors.leaf,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Color(0xFF1B2A0A)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.orderSentTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(message),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              ref.read(customerTabProvider.notifier).state = 0;
              context.go('/home');
            },
            icon: const Icon(Icons.storefront_outlined),
            label: Text(l10n.orderContinueShopping),
          ),
        ],
      ),
    );
  }
}
