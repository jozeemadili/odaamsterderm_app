import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/format/currency.dart';
import '../../../l10n/l10n_extension.dart';
import 'order_controller.dart';
import 'order_status_chip.dart';

/// A seller's marketplace order inbox.
class SellerOrdersScreen extends ConsumerStatefulWidget {
  const SellerOrdersScreen({super.key, this.initialStatus = 'open'});

  final String initialStatus;

  @override
  ConsumerState<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends ConsumerState<SellerOrdersScreen> {
  late String _status = widget.initialStatus;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final orders = ref.watch(sellerOrdersProvider(_status));
    final tabs = {
      'open': l10n.ordersTabOpen,
      'pending': l10n.ordersTabNew,
      'ready_for_pickup': l10n.ordersTabReady,
      'completed': l10n.ordersTabCompleted,
      'closed': l10n.ordersTabClosed,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sellerOrdersTitle)),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(sellerOrdersProvider(_status).future),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in tabs.entries)
                  ChoiceChip(
                    label: Text(t.value),
                    selected: _status == t.key,
                    onSelected: (_) => setState(() => _status = t.key),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            orders.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('$e'),
              data: (list) => list.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          l10n.sellerOrdersEmpty,
                          style: const TextStyle(color: DukaColors.muted),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        for (final o in list)
                          Card(
                            child: ListTile(
                              onTap: () async {
                                await context.push('/seller-orders/${o.id}');
                                ref.invalidate(sellerOrdersProvider);
                              },
                              title: Text(
                                o.reference,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                [
                                  o.customerName,
                                  o.store?.name,
                                  '${o.itemsCount}×',
                                ].whereType<String>().join(' · '),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatTzs(o.total),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  OrderStatusChip(
                                    status: o.status,
                                    label: o.statusLabel,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
