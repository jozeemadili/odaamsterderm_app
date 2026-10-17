import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw'),
  ];

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get navInventory;

  /// No description provided for @navSell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get navSell;

  /// No description provided for @navInvoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get navInvoices;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @moreTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTitle;

  /// No description provided for @moreStockReceiptsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock receipts'**
  String get moreStockReceiptsTitle;

  /// No description provided for @moreStockReceiptsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record deliveries and post them to stock'**
  String get moreStockReceiptsSubtitle;

  /// No description provided for @moreCustomersTitle.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get moreCustomersTitle;

  /// No description provided for @moreCustomersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Directory, sales and invoice history'**
  String get moreCustomersSubtitle;

  /// No description provided for @moreSuppliersTitle.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get moreSuppliersTitle;

  /// No description provided for @moreSuppliersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Directory and outstanding balances'**
  String get moreSuppliersSubtitle;

  /// No description provided for @moreExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get moreExpensesTitle;

  /// No description provided for @moreExpensesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log rent, payroll, utilities and more'**
  String get moreExpensesSubtitle;

  /// No description provided for @morePaymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get morePaymentsTitle;

  /// No description provided for @morePaymentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record cash received, with proof of payment'**
  String get morePaymentsSubtitle;

  /// No description provided for @moreSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop settings'**
  String get moreSettingsTitle;

  /// No description provided for @moreSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Business profile, staff and KYC documents'**
  String get moreSettingsSubtitle;

  /// No description provided for @shopSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop settings'**
  String get shopSettingsTitle;

  /// No description provided for @shopSettingsProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Business profile'**
  String get shopSettingsProfileTitle;

  /// No description provided for @shopSettingsProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name, contact details, branding'**
  String get shopSettingsProfileSubtitle;

  /// No description provided for @shopSettingsStaffTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff accounts'**
  String get shopSettingsStaffTitle;

  /// No description provided for @shopSettingsStaffSubtitleOwner.
  ///
  /// In en, this message translates to:
  /// **'Manage who can access this shop'**
  String get shopSettingsStaffSubtitleOwner;

  /// No description provided for @shopSettingsStaffSubtitleStaff.
  ///
  /// In en, this message translates to:
  /// **'Owner-only'**
  String get shopSettingsStaffSubtitleStaff;

  /// No description provided for @shopSettingsKycTitle.
  ///
  /// In en, this message translates to:
  /// **'KYC documents'**
  String get shopSettingsKycTitle;

  /// No description provided for @shopSettingsKycSubtitle.
  ///
  /// In en, this message translates to:
  /// **'ID, business license, TIN certificate'**
  String get shopSettingsKycSubtitle;

  /// No description provided for @shopSettingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get shopSettingsLanguageTitle;

  /// No description provided for @languagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get languagePickerTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageKiswahili.
  ///
  /// In en, this message translates to:
  /// **'Kiswahili'**
  String get languageKiswahili;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your shop'**
  String get loginSubtitle;

  /// No description provided for @loginGoogleNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is not configured for this build yet.'**
  String get loginGoogleNotConfigured;

  /// No description provided for @loginGoogleNoIdToken.
  ///
  /// In en, this message translates to:
  /// **'Google did not return an ID token.'**
  String get loginGoogleNoIdToken;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailValidator.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get loginEmailValidator;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordValidator.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordValidator;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginButton;

  /// No description provided for @loginSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get loginSigningIn;

  /// No description provided for @loginContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginContinueWithGoogle;

  /// No description provided for @loginRegisterPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have a shop yet? Register'**
  String get loginRegisterPrompt;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register your business'**
  String get registerTitle;

  /// No description provided for @registerBusinessNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get registerBusinessNameLabel;

  /// No description provided for @registerOwnerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner name'**
  String get registerOwnerNameLabel;

  /// No description provided for @registerPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get registerPhoneLabel;

  /// No description provided for @registerRegionLabel.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get registerRegionLabel;

  /// No description provided for @registerBusinessTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Business type'**
  String get registerBusinessTypeLabel;

  /// No description provided for @registerEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmailLabel;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPasswordLabel;

  /// No description provided for @registerRequiredValidator.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get registerRequiredValidator;

  /// No description provided for @registerPasswordLengthValidator.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get registerPasswordLengthValidator;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create my shop'**
  String get registerButton;

  /// No description provided for @registerWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Register with Google'**
  String get registerWithGoogle;

  /// No description provided for @registerOrDivider.
  ///
  /// In en, this message translates to:
  /// **'or register with email'**
  String get registerOrDivider;

  /// No description provided for @selectBusinessType.
  ///
  /// In en, this message translates to:
  /// **'Select business type'**
  String get selectBusinessType;

  /// No description provided for @selectRegion.
  ///
  /// In en, this message translates to:
  /// **'Select region'**
  String get selectRegion;

  /// No description provided for @dashboardLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the dashboard.\n{error}'**
  String dashboardLoadError(String error);

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @greetingFallbackName.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get greetingFallbackName;

  /// No description provided for @greetingMessage.
  ///
  /// In en, this message translates to:
  /// **'{timeGreeting}, {name}'**
  String greetingMessage(String timeGreeting, String name);

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get periodMonth;

  /// No description provided for @periodYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get periodYear;

  /// No description provided for @periodLabelWeek.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get periodLabelWeek;

  /// No description provided for @periodLabelMonth.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get periodLabelMonth;

  /// No description provided for @periodLabelYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get periodLabelYear;

  /// No description provided for @salesLabelPrefix.
  ///
  /// In en, this message translates to:
  /// **'SALES · {period}'**
  String salesLabelPrefix(String period);

  /// No description provided for @expensesLabel.
  ///
  /// In en, this message translates to:
  /// **'expenses'**
  String get expensesLabel;

  /// No description provided for @legendSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get legendSales;

  /// No description provided for @legendExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get legendExpenses;

  /// No description provided for @noActivityYet.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get noActivityYet;

  /// No description provided for @lowStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get lowStockTitle;

  /// No description provided for @expiringSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get expiringSoonTitle;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @statLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get statLowStock;

  /// No description provided for @statExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get statExpiringSoon;

  /// No description provided for @statUnverifiedPayments.
  ///
  /// In en, this message translates to:
  /// **'Unverified payments'**
  String get statUnverifiedPayments;

  /// No description provided for @recentPayments.
  ///
  /// In en, this message translates to:
  /// **'Recent payments'**
  String get recentPayments;

  /// No description provided for @noPaymentsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No payments recorded yet.'**
  String get noPaymentsRecorded;

  /// No description provided for @paymentStatusRecorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get paymentStatusRecorded;

  /// No description provided for @paymentStatusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get paymentStatusVerified;

  /// No description provided for @paymentStatusFlagged.
  ///
  /// In en, this message translates to:
  /// **'Flagged'**
  String get paymentStatusFlagged;

  /// No description provided for @profitLabel.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get profitLabel;

  /// No description provided for @unpaidTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Unpaid today'**
  String get unpaidTodayLabel;

  /// No description provided for @unpaidTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total unpaid'**
  String get unpaidTotalLabel;

  /// No description provided for @stockValueCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock value (cost)'**
  String get stockValueCostLabel;

  /// No description provided for @stockValueSellingLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock value (selling)'**
  String get stockValueSellingLabel;

  /// No description provided for @expectedProfitLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected profit'**
  String get expectedProfitLabel;

  /// No description provided for @totalStoresLabel.
  ///
  /// In en, this message translates to:
  /// **'Total stores'**
  String get totalStoresLabel;

  /// No description provided for @storesTitle.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get storesTitle;

  /// No description provided for @storeDetailProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Products in this store'**
  String get storeDetailProductsTitle;

  /// No description provided for @noStoresYet.
  ///
  /// In en, this message translates to:
  /// **'No stores yet.'**
  String get noStoresYet;

  /// No description provided for @noProductsInStore.
  ///
  /// In en, this message translates to:
  /// **'No products assigned to this store yet.'**
  String get noProductsInStore;

  /// No description provided for @addStore.
  ///
  /// In en, this message translates to:
  /// **'Add store'**
  String get addStore;

  /// No description provided for @storeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Store name'**
  String get storeNameLabel;

  /// No description provided for @storeAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get storeAddressLabel;

  /// No description provided for @storePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get storePhoneLabel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @moreProductPerformanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Product performance'**
  String get moreProductPerformanceTitle;

  /// No description provided for @moreProductPerformanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Most sold and most profitable products'**
  String get moreProductPerformanceSubtitle;

  /// No description provided for @todayCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayCardTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
