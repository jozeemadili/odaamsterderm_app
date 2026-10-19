import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../features/market/data/market_models.dart';

/// A store in its seller's colours: logo (or initials), business name,
/// store name and distance — so customers recognise it at a glance.
class StoreBrandHeader extends StatelessWidget {
  const StoreBrandHeader({super.key, required this.store, this.large = false});

  final PublicStore store;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final brand = colorFromHex(store.brandColor) ?? DukaColors.indigo;
    final accent = colorFromHex(store.accentColor) ?? DukaColors.gold;
    final ink = colorFromHex(store.brandTextColor) ?? Colors.white;
    final seller = store.sellerName ?? store.name;
    final size = large ? 56.0 : 44.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: brand,
          padding: EdgeInsets.all(large ? 16 : 12),
          child: Row(
            children: [
              Container(
                width: size,
                height: size,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: store.sellerLogoUrl != null ? Colors.white : accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: store.sellerLogoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: store.sellerLogoUrl!,
                        fit: BoxFit.contain,
                      )
                    : Text(
                        seller
                            .substring(0, seller.length < 2 ? seller.length : 2)
                            .toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: accent.computeLuminance() > 0.45
                              ? DukaColors.ink
                              : Colors.white,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      seller,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ink,
                        fontWeight: FontWeight.w800,
                        fontSize: large ? 18 : 15,
                      ),
                    ),
                    Text(
                      store.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ink.withValues(alpha: .8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (store.distanceLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .92),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    store.distanceLabel!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: DukaColors.ink,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(height: 4, color: accent),
      ],
    );
  }
}
