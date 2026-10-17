import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme.dart';
import '../../../core/format/currency.dart';
import '../../../core/widgets/store_map.dart';
import '../../../l10n/l10n_extension.dart';
import '../../orders/presentation/add_to_cart.dart';
import '../data/market_models.dart';
import 'market_controller.dart';

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
      appBar: AppBar(title: Text(l10n.marketStores)),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (d) {
          final s = d.store;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (s.sellerName != null)
                Text(
                  s.sellerName!,
                  style: const TextStyle(fontSize: 12, color: DukaColors.muted),
                ),
              Text(s.name, style: Theme.of(context).textTheme.headlineSmall),
              if (s.addressLine.isNotEmpty) Text(s.addressLine),
              if (s.distanceLabel != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    s.distanceLabel!,
                    style: const TextStyle(
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
                          style: const TextStyle(color: DukaColors.muted),
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
              for (final o in d.offers)
                Card(
                  child: ListTile(
                    onTap: () =>
                        context.push('/market/products/${o.productId}'),
                    title: Text(o.name),
                    subtitle: Text(
                      o.isAvailable
                          ? l10n.marketAvailableQty(
                              '${_qty(o.availableQuantity)} ${o.unit}',
                            )
                          : l10n.marketOutOfStock,
                      style: TextStyle(
                        color: o.isAvailable ? Colors.green : DukaColors.rose,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          o.price != null ? formatTzs(o.price!) : '—',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        if (o.isAvailable)
                          IconButton(
                            tooltip: l10n.cartAdd,
                            icon: const Icon(Icons.add_shopping_cart),
                            onPressed: () => addOfferToCart(context, ref, o),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
