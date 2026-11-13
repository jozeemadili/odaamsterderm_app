import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n_extension.dart';
import '../../ai/presentation/ai_order_screen.dart';
import '../../orders/presentation/cart_badge.dart';
import '../../orders/presentation/cart_screen.dart';
import '../../orders/presentation/my_orders_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import 'market_home_screen.dart';

/// The selected bottom-nav tab, so other screens can send the customer
/// back to the shop (0) after checkout.
final customerTabProvider = StateProvider<int>((ref) => 0);

/// Bottom-nav shell for marketplace customers.
class CustomerShell extends ConsumerWidget {
  const CustomerShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final index = ref.watch(customerTabProvider);
    void select(int i) => ref.read(customerTabProvider.notifier).state = i;

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [
          const MarketHomeScreen(),
          const AiOrderScreen(),
          CartScreen(embedded: true, onShopMore: () => select(0)),
          const MyOrdersScreen(embedded: true),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: DukaColors.line)),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: select,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.storefront_outlined),
              selectedIcon: const Icon(Icons.storefront),
              label: l10n.navMarket,
            ),
            NavigationDestination(
              icon: const Icon(Icons.auto_awesome_outlined),
              selectedIcon: const Icon(Icons.auto_awesome),
              label: l10n.navAssistant,
            ),
            NavigationDestination(
              icon: const CartBadgeIcon(),
              selectedIcon: const CartBadgeIcon(icon: Icons.shopping_cart),
              label: l10n.navCart,
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long),
              label: l10n.navOrders,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: l10n.navAccount,
            ),
          ],
        ),
      ),
    );
  }
}
