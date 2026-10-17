// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navInventory => 'Inventory';

  @override
  String get navSell => 'Sell';

  @override
  String get navInvoices => 'Invoices';

  @override
  String get navMore => 'More';

  @override
  String get moreTitle => 'More';

  @override
  String get moreStockReceiptsTitle => 'Stock receipts';

  @override
  String get moreStockReceiptsSubtitle =>
      'Record deliveries and post them to stock';

  @override
  String get moreCustomersTitle => 'Customers';

  @override
  String get moreCustomersSubtitle => 'Directory, sales and invoice history';

  @override
  String get moreSuppliersTitle => 'Suppliers';

  @override
  String get moreSuppliersSubtitle => 'Directory and outstanding balances';

  @override
  String get moreExpensesTitle => 'Expenses';

  @override
  String get moreExpensesSubtitle => 'Log rent, payroll, utilities and more';

  @override
  String get morePaymentsTitle => 'Payments';

  @override
  String get morePaymentsSubtitle =>
      'Record cash received, with proof of payment';

  @override
  String get moreSettingsTitle => 'Shop settings';

  @override
  String get moreSettingsSubtitle =>
      'Business profile, staff and KYC documents';

  @override
  String get shopSettingsTitle => 'Shop settings';

  @override
  String get shopSettingsProfileTitle => 'Business profile';

  @override
  String get shopSettingsProfileSubtitle => 'Name, contact details, branding';

  @override
  String get shopSettingsStaffTitle => 'Staff accounts';

  @override
  String get shopSettingsStaffSubtitleOwner =>
      'Manage who can access this shop';

  @override
  String get shopSettingsStaffSubtitleStaff => 'Owner-only';

  @override
  String get shopSettingsKycTitle => 'KYC documents';

  @override
  String get shopSettingsKycSubtitle => 'ID, business license, TIN certificate';

  @override
  String get shopSettingsLanguageTitle => 'Language';

  @override
  String get languagePickerTitle => 'Choose language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageKiswahili => 'Kiswahili';

  @override
  String get loginSubtitle => 'Sign in to your shop';

  @override
  String get loginGoogleNotConfigured =>
      'Google sign-in is not configured for this build yet.';

  @override
  String get loginGoogleNoIdToken => 'Google did not return an ID token.';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginEmailValidator => 'Enter your email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordValidator => 'Enter your password';

  @override
  String get loginButton => 'Log in';

  @override
  String get loginSigningIn => 'Signing in…';

  @override
  String get loginContinueWithGoogle => 'Continue with Google';

  @override
  String get loginRegisterPrompt => 'Don\'t have a shop yet? Register';

  @override
  String get registerTitle => 'Register your business';

  @override
  String get registerBusinessNameLabel => 'Business name';

  @override
  String get registerOwnerNameLabel => 'Owner name';

  @override
  String get registerPhoneLabel => 'Phone';

  @override
  String get registerRegionLabel => 'Region';

  @override
  String get registerBusinessTypeLabel => 'Business type';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerRequiredValidator => 'Required';

  @override
  String get registerPasswordLengthValidator => 'At least 8 characters';

  @override
  String get registerButton => 'Create my shop';

  @override
  String get registerWithGoogle => 'Register with Google';

  @override
  String get registerOrDivider => 'or register with email';

  @override
  String get selectBusinessType => 'Select business type';

  @override
  String get selectRegion => 'Select region';

  @override
  String dashboardLoadError(String error) {
    return 'Could not load the dashboard.\n$error';
  }

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get greetingFallbackName => 'there';

  @override
  String greetingMessage(String timeGreeting, String name) {
    return '$timeGreeting, $name';
  }

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get periodYear => 'Year';

  @override
  String get periodLabelWeek => 'Last 7 days';

  @override
  String get periodLabelMonth => 'Last 30 days';

  @override
  String get periodLabelYear => 'This year';

  @override
  String salesLabelPrefix(String period) {
    return 'SALES · $period';
  }

  @override
  String get expensesLabel => 'expenses';

  @override
  String get legendSales => 'Sales';

  @override
  String get legendExpenses => 'Expenses';

  @override
  String get noActivityYet => 'No activity yet';

  @override
  String get lowStockTitle => 'Low stock';

  @override
  String get expiringSoonTitle => 'Expiring soon';

  @override
  String get seeAll => 'See all';

  @override
  String get statLowStock => 'Low stock';

  @override
  String get statExpiringSoon => 'Expiring soon';

  @override
  String get statUnverifiedPayments => 'Unverified payments';

  @override
  String get recentPayments => 'Recent payments';

  @override
  String get noPaymentsRecorded => 'No payments recorded yet.';

  @override
  String get paymentStatusRecorded => 'Recorded';

  @override
  String get paymentStatusVerified => 'Verified';

  @override
  String get paymentStatusFlagged => 'Flagged';

  @override
  String get profitLabel => 'Profit';

  @override
  String get unpaidTodayLabel => 'Unpaid today';

  @override
  String get unpaidTotalLabel => 'Total unpaid';

  @override
  String get stockValueCostLabel => 'Stock value (cost)';

  @override
  String get stockValueSellingLabel => 'Stock value (selling)';

  @override
  String get expectedProfitLabel => 'Expected profit';

  @override
  String get totalStoresLabel => 'Total stores';

  @override
  String get storesTitle => 'Stores';

  @override
  String get storeDetailProductsTitle => 'Products in this store';

  @override
  String get noStoresYet => 'No stores yet.';

  @override
  String get noProductsInStore => 'No products assigned to this store yet.';

  @override
  String get addStore => 'Add store';

  @override
  String get storeNameLabel => 'Store name';

  @override
  String get storeAddressLabel => 'Address';

  @override
  String get storePhoneLabel => 'Phone';

  @override
  String get save => 'Save';

  @override
  String get moreProductPerformanceTitle => 'Product performance';

  @override
  String get moreProductPerformanceSubtitle =>
      'Most sold and most profitable products';

  @override
  String get todayCardTitle => 'Today';
}
