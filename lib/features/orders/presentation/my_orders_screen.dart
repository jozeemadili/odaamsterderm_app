import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../core/format/currency.dart';
import '../../../l10n/l10n_extension.dart';
import 'order_controller.dart';
import 'order_status_chip.dart';

/// A customer's orders, with recent order updates on top.
class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final orders = ref.watch(myOrdersProvider);
    final notifications = ref.watch(userNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ordersTitle),
        automaticallyImplyLeading: !embedded,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myOrdersProvider);
          ref.invalidate(userNotificationsProvider);
          await ref.read(orderRepositoryProvider).markNotificationsRead();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...notifications.maybeWhen(
              data: (n) => n.$2.where((x) => !x.read).isEmpty
                  ? const <Widget>[]
                  : [
                      Text(
                        l10n.orderUpdates,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      for (final x in n.$2.where((x) => !x.read).take(5))
                        Card(
                          color: DukaColors.gold.withValues(alpha: 0.08),
                          child: ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.notifications_active_outlined,
                            ),
                            title: Text(x.title),
                            subtitle: Text(x.message),
                            onTap: x.orderId == null
                                ? null
                                : () => context.push('/my-orders/${x.orderId}'),
                          ),
                        ),
                      const SizedBox(height: 12),
                    ],
              orElse: () => const <Widget>[],
            ),
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
                          l10n.ordersEmpty,
                          style: const TextStyle(color: DukaColors.muted),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        for (final o in list)
                          Card(
                            child: ListTile(
                              onTap: () => context.push('/my-orders/${o.id}'),
                              title: Text(
                                o.reference,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                [
                                  o.store?.name,
                                  if (o.createdAt != null)
                                    DateFormat.yMMMd().add_Hm().format(
                                      o.createdAt!.toLocal(),
                                    ),
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
