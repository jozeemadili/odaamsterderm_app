import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/l10n_extension.dart';

/// A simple hub for sections that don't warrant their own bottom-nav slot:
/// Phase 5's stock receipts/customers/suppliers, and Phase 6's expenses,
/// payments and shop settings.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.moreTitle)),
      body: ListView(
        children: [
          _MoreTile(
            icon: Icons.travel_explore,
            title: l10n.marketBrowse,
            subtitle: l10n.marketCompareSellers,
            onTap: () => context.push('/market'),
          ),
          _MoreTile(
            icon: Icons.storefront,
            title: l10n.moreMarketplaceTitle,
            subtitle: l10n.moreMarketplaceSubtitle,
            onTap: () => context.push('/marketplace'),
          ),
          _MoreTile(
            icon: Icons.menu_book_outlined,
            title: l10n.moreCatalogTitle,
            subtitle: l10n.moreCatalogSubtitle,
            onTap: () => context.push('/catalog'),
          ),
          _MoreTile(
            icon: Icons.local_shipping_outlined,
            title: l10n.moreStockReceiptsTitle,
            subtitle: l10n.moreStockReceiptsSubtitle,
            onTap: () => context.push('/stock-receipts'),
          ),
          _MoreTile(
            icon: Icons.people_outline,
            title: l10n.moreCustomersTitle,
            subtitle: l10n.moreCustomersSubtitle,
            onTap: () => context.push('/customers'),
          ),
          _MoreTile(
            icon: Icons.storefront_outlined,
            title: l10n.moreSuppliersTitle,
            subtitle: l10n.moreSuppliersSubtitle,
            onTap: () => context.push('/suppliers'),
          ),
          _MoreTile(
            icon: Icons.receipt_outlined,
            title: l10n.moreExpensesTitle,
            subtitle: l10n.moreExpensesSubtitle,
            onTap: () => context.push('/expenses'),
          ),
          _MoreTile(
            icon: Icons.payments_outlined,
            title: l10n.morePaymentsTitle,
            subtitle: l10n.morePaymentsSubtitle,
            onTap: () => context.push('/payments'),
          ),
          _MoreTile(
            icon: Icons.leaderboard_outlined,
            title: l10n.moreProductPerformanceTitle,
            subtitle: l10n.moreProductPerformanceSubtitle,
            onTap: () => context.push('/reports/product-performance'),
          ),
          _MoreTile(
            icon: Icons.settings_outlined,
            title: l10n.moreSettingsTitle,
            subtitle: l10n.moreSettingsSubtitle,
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
