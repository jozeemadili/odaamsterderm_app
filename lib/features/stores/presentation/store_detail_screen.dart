import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/format/currency.dart';
import '../../../l10n/l10n_extension.dart';
import 'store_controller.dart';

class StoreDetailScreen extends ConsumerWidget {
  const StoreDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final detailAsync = ref.watch(storeDetailProvider(id));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.storesTitle)),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text(l10n.dashboardLoadError('$e'),
                textAlign: TextAlign.center)),
        data: (detail) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(detail.store.name,
                style: Theme.of(context).textTheme.headlineSmall),
            if (detail.store.address != null || detail.store.phone != null) ...[
              const SizedBox(height: 4),
              Text(
                [detail.store.address, detail.store.phone]
                    .whereType<String>()
                    .join(' · '),
                style: const TextStyle(fontSize: 13, color: DukaColors.muted),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: l10n.stockValueCostLabel,
                    value: formatTzs(detail.store.stockValue),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    label: l10n.stockValueSellingLabel,
                    value: formatTzs(detail.store.sellingValue),
                    tone: DukaColors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _StatTile(
              label: l10n.expectedProfitLabel,
              value: formatTzs(detail.store.expectedProfit),
              tone: detail.store.expectedProfit >= 0
                  ? DukaColors.indigo
                  : DukaColors.rose,
            ),
            const SizedBox(height: 20),
            Text(l10n.storeDetailProductsTitle,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            if (detail.items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                    child: Text(l10n.noProductsInStore,
                        style: const TextStyle(
                            fontSize: 12, color: DukaColors.muted))),
              )
            else
              Card(
                child: Column(
                  children: [
                    for (final item in detail.items) ...[
                      ListTile(
                        onTap: () => context.push('/inventory/${item.id}'),
                        title: Text(item.name),
                        subtitle: Text(
                            '${item.quantityOnHand.toStringAsFixed(0)} ${item.unit ?? ''}'),
                        trailing: Text(
                          formatTzs(item.quantityOnHand * (item.unitCost ?? 0)),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (item != detail.items.last)
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, this.tone});

  final String label;
  final String value;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 11.5, color: DukaColors.muted)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: tone ?? DukaColors.ink)),
          ],
        ),
      ),
    );
  }
}
