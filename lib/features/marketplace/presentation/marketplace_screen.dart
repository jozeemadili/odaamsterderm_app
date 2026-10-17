import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/format/currency.dart';
import '../../../l10n/l10n_extension.dart';
import '../../inventory/data/inventory_models.dart';
import '../../inventory/presentation/inventory_controller.dart';

/// Filter → items, one page of up to 100 (sellers rarely list more).
final marketplaceItemsProvider = FutureProvider.autoDispose
    .family<List<InventoryItem>, String?>((ref, filter) async {
      final page = await ref
          .watch(inventoryRepositoryProvider)
          .list(marketplace: filter, perPage: 100);
      return page.items;
    });

/// Seller view of what customers see: online quantity vs physical stock.
class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  String? _filter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = ref.watch(marketplaceItemsProvider(_filter));
    final filters = <String?, String>{
      null: l10n.marketplaceFilterAll,
      'listed': l10n.marketplaceFilterListed,
      'hidden': l10n.marketplaceFilterHidden,
      'out_of_stock': l10n.marketplaceFilterOutOfStock,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.marketplaceTitle)),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(marketplaceItemsProvider(_filter).future),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.marketplaceSubtitle,
              style: const TextStyle(fontSize: 13, color: DukaColors.muted),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final entry in filters.entries)
                  ChoiceChip(
                    label: Text(entry.value),
                    selected: _filter == entry.key,
                    onSelected: (_) => setState(() => _filter = entry.key),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            items.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('$e'),
              data: (list) => list.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          l10n.marketplaceEmpty,
                          style: const TextStyle(color: DukaColors.muted),
                        ),
                      ),
                    )
                  : Card(
                      child: Column(
                        children: [
                          for (final item in list) ...[
                            _MarketplaceTile(item: item),
                            if (item != list.last)
                              const Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                              ),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketplaceTile extends ConsumerWidget {
  const _MarketplaceTile({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = item.marketplace;
    final color = !m.isVisible
        ? DukaColors.muted
        : m.status == 'active'
        ? Colors.green
        : m.status == 'out_of_stock'
        ? DukaColors.rose
        : DukaColors.muted;

    return ListTile(
      onTap: () async {
        await context.push('/inventory/${item.id}');
        ref.invalidate(marketplaceItemsProvider);
      },
      title: Text(item.name),
      subtitle: Text(
        [
          context.l10n.marketplaceStockLine(
            _qty(m.quantity),
            '${_qty(item.quantityOnHand)} ${item.unit ?? ''}'.trim(),
          ),
          if (item.branch != null) item.branch!.name,
          if (m.blockers != null && m.blockers!.isNotEmpty) m.blockers!.first,
        ].join('\n'),
      ),
      isThreeLine: true,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            item.unitPrice != null ? formatTzs(item.unitPrice!) : '—',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            m.isVisible ? m.statusLabel : context.l10n.marketplaceFilterHidden,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String _qty(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
