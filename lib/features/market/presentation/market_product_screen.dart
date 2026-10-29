import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme.dart';
import '../../../core/format/currency.dart';
import '../../../core/widgets/photo_carousel.dart';
import '../../../core/widgets/store_map.dart';
import '../../../core/widgets/producer_line.dart';
import '../../../core/widgets/distance_pill.dart';
import '../../../l10n/l10n_extension.dart';
import '../../orders/presentation/add_to_cart.dart';
import '../data/market_models.dart';
import 'location_sheet.dart';
import 'market_controller.dart';

final _productProvider = FutureProvider.autoDispose.family(
  (ref, (int, MarketSort, MarketLocation?) key) => ref
      .watch(marketRepositoryProvider)
      .product(key.$1, sort: key.$2, from: key.$3),
);

String _qty(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

/// Every seller offering one product: distance, price, availability.
class MarketProductScreen extends ConsumerStatefulWidget {
  const MarketProductScreen({super.key, required this.id});

  final int id;

  @override
  ConsumerState<MarketProductScreen> createState() =>
      _MarketProductScreenState();
}

class _MarketProductScreenState extends ConsumerState<MarketProductScreen> {
  MarketSort _sort = MarketSort.nearest;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final from = ref.watch(marketLocationProvider);
    final sort = from == null && _sort == MarketSort.nearest
        ? MarketSort.price
        : _sort;
    final detail = ref.watch(_productProvider((widget.id, sort, from)));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.marketCompareSellers)),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (p) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (p.imageUrls.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: PhotoCarousel(urls: p.imageUrls),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              [p.animalType, p.category].whereType<String>().join(' · '),
              style: const TextStyle(fontSize: 12, color: DukaColors.muted),
            ),
            const SizedBox(height: 4),
            Text(
              p.displayName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (p.producer != null) ...[
              const SizedBox(height: 6),
              ProducerLine(producer: p.producer, large: true),
              if (p.producerDescription != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    p.producerDescription!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: DukaColors.muted,
                    ),
                  ),
                ),
            ],
            if (p.description != null) ...[
              const SizedBox(height: 8),
              Text(p.description!),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: const MarketLocationChip(),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final s in MarketSort.values)
                  ChoiceChip(
                    label: Text(switch (s) {
                      MarketSort.nearest => l10n.marketSortNearest,
                      MarketSort.price => l10n.marketSortPrice,
                      MarketSort.availability => l10n.marketSortAvailability,
                    }),
                    selected: sort == s,
                    onSelected: s == MarketSort.nearest && from == null
                        ? null
                        : (_) => setState(() => _sort = s),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (p.offers.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.marketNoSellers,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: DukaColors.muted),
                ),
              )
            else ...[
              MultiStoreMap(
                pins: [
                  for (final o in p.offers)
                    MapPin(
                      latitude: o.store.latitude,
                      longitude: o.store.longitude,
                      onTap: () => context.push('/market/stores/${o.store.id}'),
                    ),
                ],
                me: from == null ? null : LatLng(from.latitude, from.longitude),
              ),
              const SizedBox(height: 12),
              for (final o in p.offers) _OfferTile(offer: o),
            ],
            const SizedBox(height: 12),
            Text(
              l10n.cartTotalAtPickup,
              style: const TextStyle(fontSize: 12, color: DukaColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferTile extends ConsumerWidget {
  const _OfferTile({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final muted = !offer.isAvailable;

    return Card(
      child: Column(
        children: [
          ListTile(
            onTap: () => context.push('/market/stores/${offer.store.id}'),
            title: Text(
              offer.sellerName,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: muted ? DukaColors.muted : DukaColors.ink,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(offer.store.name),
                const SizedBox(height: 4),
                if (offer.distanceLabel != null)
                  DistancePill(label: offer.distanceLabel!)
                else
                  Text(
                    l10n.marketSetLocationForDistance,
                    style: const TextStyle(
                      fontSize: 11,
                      color: DukaColors.muted,
                    ),
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  offer.price != null ? formatTzs(offer.price!) : '—',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: muted ? DukaColors.muted : DukaColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  offer.isAvailable
                      ? l10n.marketAvailableQty(
                          '${_qty(offer.availableQuantity)} ${offer.unit}',
                        )
                      : l10n.marketOutOfStock,
                  style: TextStyle(
                    fontSize: 12,
                    color: offer.isAvailable ? Colors.green : DukaColors.rose,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (offer.isAvailable)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => addOfferToCart(context, ref, offer),
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: Text(l10n.cartAdd),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Front and back photos of the product; swipe or tap a dot to switch.
