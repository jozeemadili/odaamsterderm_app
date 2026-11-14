import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/skeleton.dart';
import '../../../app/theme.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/format/currency.dart';
import '../../../l10n/l10n_extension.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../market/presentation/market_controller.dart';
import '../data/order_models.dart';
import 'order_controller.dart';

String _qty(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

/// Checkout: the basket grouped by pickup store, contact details, and
/// "Place order", which sends one order per store straight to the shop.
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key, this.embedded = false, this.onShopMore});

  /// True inside the customer shell (a tab, so no back arrow).
  final bool embedded;

  /// In the shell: switch to the shop tab. Otherwise the screen pops.
  final VoidCallback? onShopMore;

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
      final target = orders.length == 1
          ? '/my-orders/${orders.first.id}?placed=1'
          : '/my-orders?placed=${orders.length}';
      // Leave checkout behind: back from the order goes to the shop.
      if (widget.embedded) {
        context.push(target);
      } else {
        context.pushReplacement(target);
      }
    });
    if (mounted) setState(() => _placing = false);
  }

  void _shopMore() {
    if (widget.onShopMore != null) {
      widget.onShopMore!();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cart = ref.watch(cartControllerProvider);
    final data = cart.valueOrNull;
    final ready = data != null && data.stores.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cartCheckoutTitle),
        automaticallyImplyLeading: false,
        leading: widget.embedded
            ? null
            : IconButton(
                tooltip: l10n.cartBackToShop,
                icon: const Icon(Icons.arrow_back),
                onPressed: _shopMore,
              ),
        actions: [
          if (ready)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  l10n.cartItemsInCart(data.count),
                  style: TextStyle(fontSize: 13, color: DukaColors.muted),
                ),
              ),
            ),
        ],
      ),
      body: cart.when(
        loading: () => const SkeletonList(count: 4),
        error: (e, _) => Center(child: Text('$e')),
        data: (data) => data.stores.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 56,
                      color: DukaColors.muted,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.cartEmpty,
                      style: TextStyle(color: DukaColors.muted),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _shopMore,
                      icon: const Icon(Icons.storefront_outlined),
                      label: Text(l10n.marketBrowse),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(cartControllerProvider.notifier).refresh(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    for (final group in data.stores)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _StoreGroup(group: group, run: _run),
                      ),
                    OutlinedButton.icon(
                      onPressed: _shopMore,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.cartAddMore),
                    ),
                    const SizedBox(height: 16),
                    if (data.stores.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          l10n.cartManyStores(data.stores.length),
                          style: TextStyle(
                            fontSize: 12,
                            color: DukaColors.muted,
                          ),
                        ),
                      ),
                    TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: l10n.cartPhone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _note,
                      decoration: InputDecoration(
                        labelText: l10n.cartNote,
                        prefixIcon: const Icon(Icons.edit_note),
                      ),
                    ),
                    if (data.hasProblems)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          l10n.cartFixProblems,
                          style: const TextStyle(color: DukaColors.rose),
                        ),
                      ),
                  ],
                ),
              ),
      ),
      // Always in reach: the total and "Place order".
      bottomNavigationBar: ready
          ? Container(
              decoration: BoxDecoration(
                color: DukaColors.card,
                border: Border(top: BorderSide(color: DukaColors.line)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ref.watch(showPricesProvider)
                                  ? formatTzs(data.total)
                                  : l10n.cartPriceConfirmedByStore,
                              style: ref.watch(showPricesProvider)
                                  ? Theme.of(context).textTheme.titleLarge
                                  : const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                            ),
                            Text(
                              l10n.cartPayAtPickupNote,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: DukaColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _placing || data.hasProblems
                            ? null
                            : _checkout,
                        child: _placing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(l10n.cartPlaceOrder),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
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
              style: TextStyle(fontSize: 12, color: DukaColors.muted),
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
                          if (ref.watch(showPricesProvider))
                            Text(
                              '${formatTzs(line.unitPrice)} / ${line.unit ?? ''}',
                              style: TextStyle(
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
            if (ref.watch(showPricesProvider))
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
