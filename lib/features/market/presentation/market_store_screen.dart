import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/skeleton.dart';
import '../../../app/theme.dart';
import '../../../core/format/currency.dart';
import '../../../core/widgets/store_map.dart';
import '../../../core/widgets/store_brand_header.dart';
import '../../../l10n/l10n_extension.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../orders/presentation/add_to_cart.dart';
import '../../orders/presentation/cart_badge.dart';
import '../data/market_models.dart';
import 'ask_ai_fab.dart';
import 'market_controller.dart';
import 'product_post.dart';

final _storeProvider = FutureProvider.autoDispose.family(
  (ref, (int, MarketLocation?) key) =>
      ref.watch(marketRepositoryProvider).store(key.$1, from: key.$2),
);

String _qty(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

/// Public store page: where it is, pickup point, hours and its products.
class MarketStoreScreen extends ConsumerWidget {
  const MarketStoreScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final from = ref.watch(marketLocationProvider);
    final detail = ref.watch(_storeProvider((id, from)));

    return Scaffold(
      floatingActionButton: const AskAiFab(),
      appBar: AppBar(
        title: Text(l10n.marketStores),
        actions: [
          if (ref.watch(
            authControllerProvider.select((a) => a.user?.isCustomer ?? false),
          ))
            IconButton(
              tooltip: l10n.navCart,
              onPressed: () => context.push('/cart'),
              icon: const CartBadgeIcon(),
            ),
        ],
      ),
      body: detail.when(
        loading: () => const SkeletonDetail(),
        error: (e, _) => Center(child: Text('$e')),
        data: (d) {
          final s = d.store;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: StoreBrandHeader(store: s, large: true),
              ),
              const SizedBox(height: 10),
              if (s.addressLine.isNotEmpty) Text(s.addressLine),
              if (s.distanceLabel != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    s.distanceLabel!,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: DukaColors.indigo,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              MultiStoreMap(
                pins: [MapPin(latitude: s.latitude, longitude: s.longitude)],
                me: from == null ? null : LatLng(from.latitude, from.longitude),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse(
                          'https://www.google.com/maps/dir/?api=1&destination=${s.latitude},${s.longitude}',
                        ),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.directions),
                      label: Text(l10n.marketDirections),
                    ),
                  ),
                  if (s.phone != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => launchUrl(Uri.parse('tel:${s.phone}')),
                        icon: const Icon(Icons.call),
                        label: Text(l10n.marketCall),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.storeOpeningHoursTitle,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      if (s.openingHoursLines == null)
                        Text(
                          l10n.notSet,
                          style: TextStyle(color: DukaColors.muted),
                        )
                      else
                        for (final e in s.openingHoursLines!.entries)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text(e.key), Text(e.value)],
                          ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.marketPickupPoint,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(s.pickupInstructions ?? l10n.notSet),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.marketProductsInStore,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (d.offers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DukaColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: DukaColors.line),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, color: DukaColors.muted),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.marketStoreNoProducts,
                          style: TextStyle(color: DukaColors.muted),
                        ),
                      ),
                    ],
                  ),
                ),
              // Products as the same posts as the marketplace feed.
              for (final o in d.offers)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProductPost(
                    makerName: o.producer?.name ?? o.sellerName,
                    makerLogoUrl: o.producer?.logoUrl,
                    subtitle: o.packName,
                    showAvailable: o.isAvailable,
                    photos: o.photos,
                    price: o.price != null && ref.watch(showPricesProvider)
                        ? formatTzs(o.price!)
                        : null,
                    noPriceText: o.isAvailable
                        ? l10n.marketAvailable
                        : l10n.marketOutOfStock,
                    noPriceIsProblem: !o.isAvailable,
                    noPriceIsGood: o.isAvailable,
                    name: o.name,
                    detail: o.isAvailable
                        ? l10n.marketAvailableQty(
                            '${_qty(o.availableQuantity)} ${o.unit}',
                          )
                        : l10n.marketOutOfStock,
                    onOpen: () =>
                        context.push('/market/products/${o.productId}'),
                    onAskAi: () => context.push(
                      '/market/ai-order?q=${Uri.encodeQueryComponent(l10n.marketAskAboutQuery(o.name))}',
                    ),
                    actionLabel: o.isAvailable
                        ? l10n.cartAdd
                        : l10n.marketFeedView,
                    actionIcon: o.isAvailable ? Icons.add_shopping_cart : null,
                    onAction: o.isAvailable
                        ? () => addOfferToCart(context, ref, o)
                        : () => context.push('/market/products/${o.productId}'),
                  ),
                ),
              // Room so the floating Ask AI button never covers a button.
              const SizedBox(height: 72),
            ],
          );
        },
      ),
    );
  }
}
