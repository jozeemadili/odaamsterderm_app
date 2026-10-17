import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/l10n_extension.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../market/data/market_models.dart';
import 'order_controller.dart';

String _qty(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

/// "Add to cart" for a seller's offer. Guests go to sign-in; seller accounts
/// can't order; customers pick a quantity.
Future<void> addOfferToCart(
  BuildContext context,
  WidgetRef ref,
  Offer offer,
) async {
  final l10n = context.l10n;
  final user = ref.read(authControllerProvider).user;

  if (user == null) {
    context.push('/login');
    return;
  }
  if (!user.isCustomer) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.cartSignInToOrder)));
    return;
  }

  final quantity = await showDialog<double>(
    context: context,
    builder: (_) => _QuantityDialog(offer: offer),
  );
  if (quantity == null || !context.mounted) return;

  try {
    await ref.read(cartControllerProvider.notifier).add(offer.id, quantity);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.cartAdded),
        action: SnackBarAction(
          label: l10n.cartView,
          onPressed: () => context.push('/cart'),
        ),
      ),
    );
  } on ApiException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.fieldError('quantity') ?? e.fieldError('offer') ?? e.message,
          ),
        ),
      );
    }
  }
}

class _QuantityDialog extends StatefulWidget {
  const _QuantityDialog({required this.offer});

  final Offer offer;

  @override
  State<_QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<_QuantityDialog> {
  final _controller = TextEditingController(text: '1');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final offer = widget.offer;

    return AlertDialog(
      title: Text(offer.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${offer.sellerName} · ${l10n.marketAvailableQty('${_qty(offer.availableQuantity)} ${offer.unit}')}',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: InputDecoration(
              labelText: l10n.cartQuantity,
              suffixText: offer.unit,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final q = double.tryParse(_controller.text);
            if (q == null || q <= 0) return;
            Navigator.pop(context, q);
          },
          child: Text(l10n.cartAdd),
        ),
      ],
    );
  }
}
