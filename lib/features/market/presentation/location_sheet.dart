import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/store_map.dart';
import '../../../l10n/l10n_extension.dart';
import '../data/market_models.dart';
import 'market_controller.dart';

/// Lets the customer share their GPS position or pick a point on the map.
Future<void> showMarketLocationSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _LocationSheet(),
    );

class _LocationSheet extends ConsumerStatefulWidget {
  const _LocationSheet();

  @override
  ConsumerState<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends ConsumerState<_LocationSheet> {
  late LatLng? _point = () {
    final current = ref.read(marketLocationProvider);
    return current == null ? null : LatLng(current.latitude, current.longitude);
  }();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.marketWhereAreYou,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.marketPickOnMap,
            style: const TextStyle(fontSize: 13, color: DukaColors.muted),
          ),
          const SizedBox(height: 12),
          LocationPickerMap(
            value: _point,
            height: 320,
            onChanged: (p) => setState(() => _point = p),
            useMyLocationLabel: l10n.storeUseMyLocation,
            locationDeniedMessage: l10n.storeLocationDenied,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _point == null
                ? null
                : () async {
                    await ref
                        .read(marketLocationProvider.notifier)
                        .set(
                          MarketLocation(
                            latitude: _point!.latitude,
                            longitude: _point!.longitude,
                            label: l10n.marketMyLocation,
                          ),
                        );
                    if (context.mounted) Navigator.pop(context);
                  },
            child: Text(l10n.marketUseThisPoint),
          ),
        ],
      ),
    );
  }
}

/// Header chip showing the current search location; tap to change.
class MarketLocationChip extends ConsumerWidget {
  const MarketLocationChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final location = ref.watch(marketLocationProvider);

    return ActionChip(
      avatar: const Icon(Icons.location_on_outlined, size: 18),
      label: Text(
        location == null
            ? l10n.marketSetLocation
            : l10n.marketNear(location.label ?? l10n.marketMyLocation),
        overflow: TextOverflow.ellipsis,
      ),
      onPressed: () => showMarketLocationSheet(context),
    );
  }
}
