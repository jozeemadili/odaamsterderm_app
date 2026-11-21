import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/skeleton.dart';
import '../../../app/theme.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/format/currency.dart';
import '../../../l10n/l10n_extension.dart';
import '../../auth/presentation/customer_google.dart';
import '../../chicks/presentation/chick_screens.dart';
import '../../market/presentation/market_controller.dart';
import '../data/order_models.dart';
import 'order_controller.dart';
import 'live_store_distance.dart';
import 'order_placed_banner.dart';
import 'order_status_chip.dart';

String _qty(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

/// Order detail for customers ([seller] false) and sellers ([seller] true):
/// items, pickup store, timeline, and the actions each side may take.
class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({
    super.key,
    required this.id,
    this.seller = false,
    this.justPlaced = false,
  });

  final int id;
  final bool seller;

  /// Opened right after checkout: show the "sent to the shop" confirmation.
  final bool justPlaced;

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _busy = false;

  void _refresh() {
    ref.invalidate(
      widget.seller
          ? sellerOrderProvider(widget.id)
          : myOrderProvider(widget.id),
    );
    ref.invalidate(widget.seller ? sellerOrdersProvider : myOrdersProvider);
  }

  Future<void> _act(Future<MarketOrder> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      _refresh();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.fieldError('reason') ??
                  e.fieldError('status') ??
                  e.fieldError('quantity') ??
                  e.message,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _askReason(String label, {required bool required}) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (required && controller.text.trim().isEmpty) return;
              Navigator.pop(context, controller.text.trim());
            },
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _sellerAction(MarketOrder order, String status) async {
    final l10n = context.l10n;
    final repo = ref.read(orderRepositoryProvider);

    if (status == 'rejected') {
      final reason = await _askReason(l10n.orderRejectReason, required: true);
      if (reason == null) return;
      await _act(() => repo.advance(order.id, status, reason: reason));
      return;
    }

    if (status == 'completed') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(l10n.orderCompleteConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.confirm),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    await _act(() => repo.advance(order.id, status));
  }

  String _actionLabel(String status) => switch (status) {
    'accepted' => context.l10n.orderActionAccept,
    'preparing' => context.l10n.orderActionPrepare,
    'ready_for_pickup' => context.l10n.orderActionReady,
    'completed' => context.l10n.orderActionComplete,
    _ => context.l10n.orderActionReject,
  };

  @override
  Widget build(BuildContext context) {
    // Sellers always see prices; customers only once they are published.
    final prices = widget.seller || ref.watch(showPricesProvider);
    final l10n = context.l10n;
    final order = ref.watch(
      widget.seller
          ? sellerOrderProvider(widget.id)
          : myOrderProvider(widget.id),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderReference)),
      body: order.when(
        loading: () => const SkeletonDetail(),
        error: (e, _) => Center(child: Text('$e')),
        data: (o) => AbsorbPointer(
          absorbing: _busy,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (widget.justPlaced && !widget.seller)
                OrderPlacedBanner(
                  message: l10n.orderSentBody(o.store?.name ?? '', o.reference),
                ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      o.reference,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  OrderStatusChip(status: o.status, label: o.statusLabel),
                ],
              ),
              if (o.createdAt != null)
                Text(
                  DateFormat.yMMMd().add_Hm().format(o.createdAt!.toLocal()),
                  style: TextStyle(color: DukaColors.muted),
                ),
              if (!widget.seller && o.status == 'ready_for_pickup')
                Card(
                  color: Colors.green.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      l10n.orderReadyBanner(o.reference),
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (o.isClosed && o.statusReason != null)
                Card(
                  color: DukaColors.rose.withValues(alpha: 0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      '${o.statusLabel}: ${o.statusReason}',
                      style: const TextStyle(color: DukaColors.rose),
                    ),
                  ),
                ),
              if (widget.seller && o.customerName != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(o.customerName!),
                    subtitle: Text(
                      [
                        o.customerPhone,
                        o.customerNote,
                      ].whereType<String>().join('\n'),
                    ),
                    trailing: o.customerPhone == null
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.call),
                            onPressed: () =>
                                launchUrl(Uri.parse('tel:${o.customerPhone}')),
                          ),
                  ),
                ),
              // Once the seller has accepted: how far the store is right now.
              if (!widget.seller &&
                  o.store != null &&
                  const [
                    'accepted',
                    'preparing',
                    'ready_for_pickup',
                  ].contains(o.status))
                LiveStoreDistance(
                  storeLatitude: o.store!.latitude,
                  storeLongitude: o.store!.longitude,
                ),
              if (o.store != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.storefront_outlined),
                    title: Text(l10n.cartPickupAt(o.store!.name)),
                    subtitle: Text(
                      [o.store!.addressLine, o.store!.pickupInstructions]
                          .whereType<String>()
                          .where((s) => s.isNotEmpty)
                          .join('\n'),
                    ),
                    trailing: widget.seller
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.directions),
                            onPressed: () => launchUrl(
                              Uri.parse(
                                'https://www.google.com/maps/dir/?api=1&destination=${o.store!.latitude},${o.store!.longitude}',
                              ),
                              mode: LaunchMode.externalApplication,
                            ),
                          ),
                  ),
                ),
              if (o.receiptUrl != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(o.receiptUrl!),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: Text(l10n.receiptOpen),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                l10n.orderItems,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Card(
                child: Column(
                  children: [
                    for (final i in o.items)
                      ListTile(
                        dense: true,
                        title: Text(i.name),
                        subtitle: Text(
                          i.boxes != null
                              ? l10n.chicksBoxesOf(i.boxes!, i.quantity.round())
                              : prices
                              ? '${_qty(i.quantity)} × ${formatTzs(i.unitPrice)}'
                              : _qty(i.quantity),
                        ),
                        trailing: prices ? Text(formatTzs(i.lineTotal)) : null,
                      ),
                    ListTile(
                      title: Text(
                        l10n.orderTotalPickup,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      trailing: prices
                          ? Text(
                              formatTzs(o.total),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : null,
                      subtitle: prices
                          ? null
                          : Text(l10n.cartPriceConfirmedByStore),
                    ),
                  ],
                ),
              ),
              // A chick booking without add-ons: what the chicks will need first.
              if (!widget.seller && o.items.any((i) => i.boxes != null))
                _ChickAddOns(orderId: o.id),
              const SizedBox(height: 8),
              Text(
                l10n.orderTimeline,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              for (final e in o.events)
                ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.circle,
                    size: 10,
                    color: DukaColors.gold,
                  ),
                  title: Text(e.label),
                  subtitle: Text(
                    [
                      if (e.at != null)
                        DateFormat.MMMd().add_Hm().format(e.at!.toLocal()),
                      e.note,
                    ].whereType<String>().join(' · '),
                  ),
                ),
              const SizedBox(height: 12),
              if (widget.seller)
                for (final next in o.nextStatuses)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: next.status == 'rejected'
                        ? OutlinedButton(
                            onPressed: () => _sellerAction(o, next.status),
                            child: Text(_actionLabel(next.status)),
                          )
                        : FilledButton(
                            onPressed: () => _sellerAction(o, next.status),
                            child: Text(_actionLabel(next.status)),
                          ),
                  )
              else if (o.canCancel) ...[
                OutlinedButton(
                  onPressed: () async {
                    final reason = await _askReason(
                      l10n.orderCancelReason,
                      required: false,
                    );
                    if (reason == null) return;
                    await _act(
                      () => ref
                          .read(orderRepositoryProvider)
                          .cancel(o.id, reason: reason.isEmpty ? null : reason),
                    );
                  },
                  child: Text(l10n.orderCancel),
                ),
                Text(
                  l10n.orderCancelHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: DukaColors.muted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

final _orderSuggestionsProvider = FutureProvider.autoDispose.family(
  (ref, int orderId) =>
      ref.watch(chickRepositoryProvider).orderSuggestions(orderId),
);

/// Quiet card: sized feed, vitamins or vaccines from the same store, each
/// added to the cart only if the customer taps it.
class _ChickAddOns extends ConsumerStatefulWidget {
  const _ChickAddOns({required this.orderId});

  final int orderId;

  @override
  ConsumerState<_ChickAddOns> createState() => _ChickAddOnsState();
}

class _ChickAddOnsState extends ConsumerState<_ChickAddOns> {
  final Set<int> _added = {};

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final list =
        ref.watch(_orderSuggestionsProvider(widget.orderId)).valueOrNull ??
        const [];
    if (list.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Card(
        key: const Key('order-chick-addons'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.chicksWantReady,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              for (final s in list)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text('${s.quantity} × ${s.name}'),
                  subtitle: Text([s.reasonFor(lang), ?s.amount].join(' · ')),
                  trailing: _added.contains(s.offerId)
                      ? Icon(Icons.check_circle, color: DukaColors.leafDeep)
                      : TextButton(
                          onPressed: () async {
                            try {
                              await ref
                                  .read(cartControllerProvider.notifier)
                                  .add(s.offerId, s.quantity.toDouble());
                              setState(() => _added.add(s.offerId));
                              if (context.mounted) {
                                showAuthToast(context, l10n.chicksAddedToCart);
                              }
                            } on ApiException catch (e) {
                              if (context.mounted) {
                                showAuthToast(context, e.message, error: true);
                              }
                            }
                          },
                          child: Text(l10n.chicksAddToCart),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
