import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n_extension.dart';
import '../../auth/presentation/auth_controller.dart';

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
          const _ProfileCard(),
          _MoreTile(
            icon: Icons.receipt_long,
            title: l10n.sellerOrdersTitle,
            subtitle: l10n.sellerOrdersSubtitle,
            onTap: () => context.push('/seller-orders'),
          ),
          _MoreTile(
            icon: Icons.egg_outlined,
            title: l10n.moreChicksTitle,
            subtitle: l10n.moreChicksSubtitle,
            onTap: () => context.push('/agent-chicks'),
          ),
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
            icon: Icons.swap_horiz,
            title: l10n.moreTransfersTitle,
            subtitle: l10n.moreTransfersSubtitle,
            onTap: () => context.push('/transfers'),
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

/// The signed-in person at the top of More: photo, name, role → Profile.
class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    if (user == null) return const SizedBox.shrink();
    final initials = user.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Material(
        color: DukaColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: DukaColors.line),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push('/profile'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: DukaColors.maroonTint,
                  foregroundImage: user.avatarUrl != null
                      ? CachedNetworkImageProvider(user.avatarUrl!)
                      : null,
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: DukaColors.indigo,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        [?user.roleLabel, user.email].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: DukaColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: DukaColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
