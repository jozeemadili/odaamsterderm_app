import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/format/currency.dart';
import '../../../l10n/l10n_extension.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/order_models.dart';
import 'order_controller.dart';

String _qty(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

/// Basket grouped by pickup store; checkout places one order per store.
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key, this.embedded = false});

  /// True inside the customer shell (no back button).
  final bool embedded;

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  late final _phone = TextEditingController(
    text: ref.read(authControllerProvider).user?.phone,
  );
  final _note = TextEditingController();
  bool _placing = false;

  @override
  void dispose() {
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.fieldError('quantity') ?? e.fieldError('cart') ?? e.message,
            ),
          ),
        );
      }
    }
  }

  Future<void> _checkout() async {
    setState(() => _placing = true);
    await _run(() async {
      final orders = await ref
          .read(cartControllerProvider.notifier)
          .checkout(
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          );
      ref.invalidate(myOrdersProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.orderPlaced)));
      context.push(
        orders.length == 1 ? '/my-orders/${orders.first.id}' : '/my-orders',
      );
    });
    if (mounted) setState(() => _placing = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cart = ref.watch(cartControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cartTitle),
        automaticallyImplyLeading: !widget.embedded,
      ),
      body: cart.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (data) => data.stores.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.cartEmpty,
                      style: const TextStyle(color: DukaColors.muted),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.go('/market'),
                      child: Text(l10n.marketBrowse),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(cartControllerProvider.notifier).refresh(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final group in data.stores)
                      _StoreGroup(group: group, run: _run),
                    const SizedBox(height: 8),
                    if (data.stores.length > 1)
                      Text(
                        l10n.cartManyStores(data.stores.length),
                        style: const TextStyle(
                          fontSize: 12,
                          color: DukaColors.muted,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.cartTotalAtPickup),
                        Text(
                          formatTzs(data.total),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(labelText: l10n.cartPhone),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _note,
                      decoration: InputDecoration(labelText: l10n.cartNote),
                    ),
                    const SizedBox(height: 16),
                    if (data.hasProblems)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          l10n.cartFixProblems,
                          style: const TextStyle(color: DukaColors.rose),
                        ),
                      ),
                    FilledButton(
                      onPressed: _placing || data.hasProblems
                          ? null
                          : _checkout,
                      child: _placing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.cartPlaceOrder),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _StoreGroup extends ConsumerWidget {
  const _StoreGroup({required this.group, required this.run});

  final CartStoreGroup group;
  final Future<void> Function(Future<void> Function()) run;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final cart = ref.read(cartControllerProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.cartPickupAt(group.store.name),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              [
                group.store.sellerName,
                group.store.addressLine,
              ].whereType<String>().where((s) => s.isNotEmpty).join(' · '),
              style: const TextStyle(fontSize: 12, color: DukaColors.muted),
            ),
            const Divider(),
            for (final line in group.lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            line.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${formatTzs(line.unitPrice)} / ${line.unit ?? ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: DukaColors.muted,
                            ),
                          ),
                          if (line.problem != null)
                            Text(
                              line.problem!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: DukaColors.rose,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => run(
                        () => cart.setQuantity(line.offerId, line.quantity - 1),
                      ),
                    ),
                    Text(
                      _qty(line.quantity),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: line.quantity + 1 > line.availableQuantity
                          ? null
                          : () => run(
                              () => cart.setQuantity(
                                line.offerId,
                                line.quantity + 1,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                formatTzs(group.total),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
