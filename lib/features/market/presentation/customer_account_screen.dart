import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n_extension.dart';
import '../../auth/presentation/auth_controller.dart';
import 'location_sheet.dart';
import 'market_controller.dart';

/// A customer's profile, default location and (from Phase 3) orders.
class CustomerAccountScreen extends ConsumerWidget {
  const CustomerAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider).user;
    final location = ref.watch(marketLocationProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user?.name ?? ''),
              subtitle: Text(
                [user?.email, user?.phone].whereType<String>().join(' · '),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(l10n.accountDefaultLocation),
              subtitle: Text(
                location == null
                    ? l10n.marketSetLocation
                    : (location.label ?? l10n.marketMyLocation),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showMarketLocationSheet(context),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text(l10n.accountOrders),
              subtitle: Text(
                l10n.ordersTitle,
                style: const TextStyle(color: DukaColors.muted),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/my-orders'),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            label: Text(l10n.accountLogout),
          ),
        ],
      ),
    );
  }
}
