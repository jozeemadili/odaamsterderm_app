import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/catalog/presentation/catalog_screen.dart';
import '../features/customers/data/customer_models.dart';
import '../features/customers/presentation/customer_detail_screen.dart';
import '../features/customers/presentation/customer_form_screen.dart';
import '../features/customers/presentation/customer_list_screen.dart';
import '../features/expenses/presentation/expense_form_screen.dart';
import '../features/expenses/presentation/expense_list_screen.dart';
import '../features/inventory/data/inventory_models.dart';
import '../features/inventory/presentation/barcode_labels_screen.dart';
import '../features/inventory/presentation/barcode_scanner_screen.dart';
import '../features/inventory/presentation/inventory_list_screen.dart';
import '../features/inventory/presentation/product_detail_screen.dart';
import '../features/inventory/presentation/product_form_screen.dart';
import '../features/invoices/presentation/invoice_detail_screen.dart';
import '../features/invoices/presentation/invoice_form_screen.dart';
import '../features/invoices/presentation/invoice_list_screen.dart';
import '../features/marketplace/presentation/marketplace_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/notifications/presentation/report_damage_screen.dart';
import '../features/payments/presentation/payment_form_screen.dart';
import '../features/payments/presentation/payment_list_screen.dart';
import '../features/pos/presentation/checkout_screen.dart';
import '../features/reports/presentation/product_performance_screen.dart';
import '../features/reports/presentation/today_sales_screen.dart';
import '../features/settings/presentation/kyc_documents_screen.dart';
import '../features/settings/presentation/merchant_profile_screen.dart';
import '../features/settings/presentation/shop_settings_screen.dart';
import '../features/settings/presentation/staff_form_screen.dart';
import '../features/settings/presentation/staff_list_screen.dart';
import '../features/stock_receipts/presentation/stock_receipt_detail_screen.dart';
import '../features/stock_receipts/presentation/stock_receipt_form_screen.dart';
import '../features/stock_receipts/presentation/stock_receipt_list_screen.dart';
import '../features/stores/data/store_models.dart';
import '../features/stores/presentation/store_detail_screen.dart';
import '../features/stores/presentation/store_form_screen.dart';
import '../features/stores/presentation/store_list_screen.dart';
import '../features/suppliers/data/supplier_models.dart';
import '../features/suppliers/presentation/supplier_detail_screen.dart';
import '../features/suppliers/presentation/supplier_form_screen.dart';
import '../features/suppliers/presentation/supplier_list_screen.dart';
import 'home_shell.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

/// Bridges Riverpod's [authControllerProvider] to go_router's
/// [Listenable]-based `refreshListenable`, so navigation re-evaluates
/// whenever auth state changes (login, logout, session restore).
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (previous, next) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loc = state.matchedLocation;
      final onAuthScreens = loc == '/login' || loc == '/register';

      switch (auth.status) {
        case AuthStatus.unknown:
          return null; // still restoring the session — stay on splash
        case AuthStatus.authenticating:
          return null;
        case AuthStatus.unauthenticated:
          return onAuthScreens ? null : '/login';
        case AuthStatus.authenticated:
          return (loc == '/' || onAuthScreens) ? '/dashboard' : null;
      }
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const HomeShell(),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryListScreen(),
      ),
      GoRoute(
        path: '/inventory/scan',
        builder: (context, state) => const BarcodeScannerScreen(),
      ),
      GoRoute(
        path: '/inventory/scan-for-form',
        builder: (context, state) =>
            const BarcodeScannerScreen(returnCode: true),
      ),
      GoRoute(
        path: '/inventory/barcode-labels',
        builder: (context, state) => const BarcodeLabelsScreen(),
      ),
      GoRoute(
        path: '/inventory/new',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ProductFormScreen(
            prefillBarcode: extra?['barcode'] as String?,
            duplicateFrom: extra?['duplicateFrom'] as InventoryItem?,
          );
        },
      ),
      GoRoute(
        path: '/inventory/:id',
        builder: (context, state) =>
            ProductDetailScreen(id: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/inventory/:id/edit',
        builder: (context, state) =>
            ProductFormScreen(existing: state.extra as InventoryItem?),
      ),
      GoRoute(
        path: '/pos/scan',
        builder: (context, state) => const BarcodeScannerScreen(forCart: true),
      ),
      GoRoute(
        path: '/pos/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/invoices',
        builder: (context, state) => const InvoiceListScreen(),
      ),
      GoRoute(
        path: '/invoices/new',
        builder: (context, state) => const InvoiceFormScreen(),
      ),
      GoRoute(
        path: '/invoices/:id',
        builder: (context, state) =>
            InvoiceDetailScreen(id: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/customers',
        builder: (context, state) => const CustomerListScreen(),
      ),
      GoRoute(
        path: '/customers/new',
        builder: (context, state) => const CustomerFormScreen(),
      ),
      GoRoute(
        path: '/customers/:id',
        builder: (context, state) =>
            CustomerDetailScreen(id: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/customers/:id/edit',
        builder: (context, state) =>
            CustomerFormScreen(existing: state.extra as Customer?),
      ),
      GoRoute(
        path: '/suppliers',
        builder: (context, state) => const SupplierListScreen(),
      ),
      GoRoute(
        path: '/suppliers/new',
        builder: (context, state) => const SupplierFormScreen(),
      ),
      GoRoute(
        path: '/suppliers/:id',
        builder: (context, state) =>
            SupplierDetailScreen(id: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/suppliers/:id/edit',
        builder: (context, state) =>
            SupplierFormScreen(existing: state.extra as Supplier?),
      ),
      GoRoute(
        path: '/stock-receipts',
        builder: (context, state) => const StockReceiptListScreen(),
      ),
      GoRoute(
        path: '/stock-receipts/new',
        builder: (context, state) => const StockReceiptFormScreen(),
      ),
      GoRoute(
        path: '/stock-receipts/:id',
        builder: (context, state) => StockReceiptDetailScreen(
          id: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/expenses',
        builder: (context, state) => const ExpenseListScreen(),
      ),
      GoRoute(
        path: '/expenses/new',
        builder: (context, state) => const ExpenseFormScreen(),
      ),
      GoRoute(
        path: '/payments',
        builder: (context, state) => const PaymentListScreen(),
      ),
      GoRoute(
        path: '/payments/new',
        builder: (context, state) => const PaymentFormScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const ShopSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/profile',
        builder: (context, state) => const MerchantProfileScreen(),
      ),
      GoRoute(
        path: '/settings/staff',
        builder: (context, state) => const StaffListScreen(),
      ),
      GoRoute(
        path: '/settings/staff/new',
        builder: (context, state) => const StaffFormScreen(),
      ),
      GoRoute(
        path: '/settings/kyc',
        builder: (context, state) => const KycDocumentsScreen(),
      ),
      GoRoute(
        path: '/stores',
        builder: (context, state) => const StoreListScreen(),
      ),
      GoRoute(
        path: '/stores/:id',
        builder: (context, state) =>
            StoreDetailScreen(id: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/stores/:id/edit',
        builder: (context, state) =>
            StoreFormScreen(store: state.extra! as Store),
      ),
      GoRoute(
        path: '/marketplace',
        builder: (context, state) => const MarketplaceScreen(),
      ),
      GoRoute(
        path: '/catalog',
        builder: (context, state) => CatalogScreen(
          openProposeForm:
              (state.extra as Map<String, dynamic>?)?['propose'] == true,
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/notifications/report-damage',
        builder: (context, state) => const ReportDamageScreen(),
      ),
      GoRoute(
        path: '/reports/sales/today',
        builder: (context, state) => const TodaySalesScreen(),
      ),
      GoRoute(
        path: '/reports/product-performance',
        builder: (context, state) => const ProductPerformanceScreen(),
      ),
    ],
  );
});
