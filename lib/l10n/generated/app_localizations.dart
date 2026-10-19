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
  /// **'Sign in to your account'**
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
  /// **'Selling animal products? Register your business'**
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

  /// No description provided for @storeEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit store'**
  String get storeEditTitle;

  /// No description provided for @storeEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get storeEmailLabel;

  /// No description provided for @storeCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City / district'**
  String get storeCityLabel;

  /// No description provided for @storeLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Store location'**
  String get storeLocationTitle;

  /// No description provided for @storeLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the map or use your current location to pin the store entrance.'**
  String get storeLocationHint;

  /// No description provided for @storeUseMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get storeUseMyLocation;

  /// No description provided for @storeLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location is off or permission was denied. Tap the map to place the pin.'**
  String get storeLocationDenied;

  /// No description provided for @storeNoLocation.
  ///
  /// In en, this message translates to:
  /// **'No map location yet — customers can\'t find this store.'**
  String get storeNoLocation;

  /// No description provided for @storeOpenInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Google Maps'**
  String get storeOpenInMaps;

  /// No description provided for @storeOpeningHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Opening hours'**
  String get storeOpeningHoursTitle;

  /// No description provided for @storeClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get storeClosed;

  /// No description provided for @storePickupLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup instructions for customers'**
  String get storePickupLabel;

  /// No description provided for @storeMarketplaceSwitch.
  ///
  /// In en, this message translates to:
  /// **'List this store on the marketplace'**
  String get storeMarketplaceSwitch;

  /// No description provided for @storeMarketplaceSwitchHint.
  ///
  /// In en, this message translates to:
  /// **'Turn off to use this store for offline sales only.'**
  String get storeMarketplaceSwitchHint;

  /// No description provided for @storeOnMarketplace.
  ///
  /// In en, this message translates to:
  /// **'On marketplace'**
  String get storeOnMarketplace;

  /// No description provided for @storeMarketplaceOff.
  ///
  /// In en, this message translates to:
  /// **'Marketplace off'**
  String get storeMarketplaceOff;

  /// No description provided for @storeSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended by the platform'**
  String get storeSuspended;

  /// No description provided for @storeSetLocationBadge.
  ///
  /// In en, this message translates to:
  /// **'Set map location'**
  String get storeSetLocationBadge;

  /// No description provided for @storeSaved.
  ///
  /// In en, this message translates to:
  /// **'Store details saved.'**
  String get storeSaved;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @marketplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplaceTitle;

  /// No description provided for @marketplaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What customers can see and order online'**
  String get marketplaceSubtitle;

  /// No description provided for @marketplaceFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get marketplaceFilterAll;

  /// No description provided for @marketplaceFilterListed.
  ///
  /// In en, this message translates to:
  /// **'Listed'**
  String get marketplaceFilterListed;

  /// No description provided for @marketplaceFilterHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get marketplaceFilterHidden;

  /// No description provided for @marketplaceFilterOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get marketplaceFilterOutOfStock;

  /// No description provided for @marketplaceEmpty.
  ///
  /// In en, this message translates to:
  /// **'No items here.'**
  String get marketplaceEmpty;

  /// No description provided for @marketplaceListedProducts.
  ///
  /// In en, this message translates to:
  /// **'Listed products'**
  String get marketplaceListedProducts;

  /// No description provided for @marketplaceUnitsExposed.
  ///
  /// In en, this message translates to:
  /// **'Units online'**
  String get marketplaceUnitsExposed;

  /// No description provided for @marketplaceOutOfStockOnline.
  ///
  /// In en, this message translates to:
  /// **'Out of stock online'**
  String get marketplaceOutOfStockOnline;

  /// No description provided for @marketplaceApprovalPending.
  ///
  /// In en, this message translates to:
  /// **'Your business is awaiting marketplace approval — listings go live once approved.'**
  String get marketplaceApprovalPending;

  /// No description provided for @catalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Product catalog'**
  String get catalogTitle;

  /// No description provided for @catalogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shared products customers compare across sellers'**
  String get catalogSubtitle;

  /// No description provided for @catalogSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search the catalog'**
  String get catalogSearchHint;

  /// No description provided for @catalogPropose.
  ///
  /// In en, this message translates to:
  /// **'Propose a product'**
  String get catalogPropose;

  /// No description provided for @catalogProposals.
  ///
  /// In en, this message translates to:
  /// **'Your proposals'**
  String get catalogProposals;

  /// No description provided for @catalogPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for review'**
  String get catalogPending;

  /// No description provided for @catalogRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get catalogRejected;

  /// No description provided for @catalogNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not in the catalog? Propose it for review.'**
  String get catalogNotFound;

  /// No description provided for @catalogProposed.
  ///
  /// In en, this message translates to:
  /// **'Product proposed. It goes live on the marketplace once approved.'**
  String get catalogProposed;

  /// No description provided for @catalogNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get catalogNameLabel;

  /// No description provided for @catalogPackSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pack size (e.g. 25KG)'**
  String get catalogPackSizeLabel;

  /// No description provided for @catalogUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Selling unit'**
  String get catalogUnitLabel;

  /// No description provided for @catalogBrandLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand (if the producer is not listed)'**
  String get catalogBrandLabel;

  /// No description provided for @catalogAnimalLabel.
  ///
  /// In en, this message translates to:
  /// **'Animal type'**
  String get catalogAnimalLabel;

  /// No description provided for @catalogCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get catalogCategoryLabel;

  /// No description provided for @catalogDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get catalogDescriptionLabel;

  /// No description provided for @catalogSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get catalogSubmit;

  /// No description provided for @catalogPickTitle.
  ///
  /// In en, this message translates to:
  /// **'Link to catalog product'**
  String get catalogPickTitle;

  /// No description provided for @catalogNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No catalog products match.'**
  String get catalogNoMatches;

  /// No description provided for @moreMarketplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get moreMarketplaceTitle;

  /// No description provided for @moreMarketplaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visibility and quantities customers see'**
  String get moreMarketplaceSubtitle;

  /// No description provided for @moreCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Product catalog'**
  String get moreCatalogTitle;

  /// No description provided for @moreCatalogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse shared products or propose new ones'**
  String get moreCatalogSubtitle;

  /// No description provided for @marketplaceStockLine.
  ///
  /// In en, this message translates to:
  /// **'{online} online · {stock} in stock'**
  String marketplaceStockLine(String online, String stock);

  /// No description provided for @stockQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock quantity (units)'**
  String get stockQuantityLabel;

  /// No description provided for @marketSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search feeds, vaccines, medicines…'**
  String get marketSearchHint;

  /// No description provided for @marketSetLocation.
  ///
  /// In en, this message translates to:
  /// **'Set your location'**
  String get marketSetLocation;

  /// No description provided for @marketSetLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Set your location to see the nearest stores and distances.'**
  String get marketSetLocationHint;

  /// No description provided for @marketMyLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get marketMyLocation;

  /// No description provided for @marketAllAnimals.
  ///
  /// In en, this message translates to:
  /// **'All animals'**
  String get marketAllAnimals;

  /// No description provided for @marketSortNearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get marketSortNearest;

  /// No description provided for @marketSortPrice.
  ///
  /// In en, this message translates to:
  /// **'Lowest price'**
  String get marketSortPrice;

  /// No description provided for @marketSortAvailability.
  ///
  /// In en, this message translates to:
  /// **'Most available'**
  String get marketSortAvailability;

  /// No description provided for @marketInStockOnly.
  ///
  /// In en, this message translates to:
  /// **'Available now only'**
  String get marketInStockOnly;

  /// No description provided for @marketFrom.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get marketFrom;

  /// No description provided for @marketOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get marketOutOfStock;

  /// No description provided for @marketAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get marketAvailable;

  /// No description provided for @marketNoProducts.
  ///
  /// In en, this message translates to:
  /// **'No products match. Try another search.'**
  String get marketNoProducts;

  /// No description provided for @marketStoresNearYou.
  ///
  /// In en, this message translates to:
  /// **'Stores near you'**
  String get marketStoresNearYou;

  /// No description provided for @marketStores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get marketStores;

  /// No description provided for @marketCompareSellers.
  ///
  /// In en, this message translates to:
  /// **'Compare sellers'**
  String get marketCompareSellers;

  /// No description provided for @marketDirections.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get marketDirections;

  /// No description provided for @marketCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get marketCall;

  /// No description provided for @marketPickupPoint.
  ///
  /// In en, this message translates to:
  /// **'Pickup point'**
  String get marketPickupPoint;

  /// No description provided for @marketProductsInStore.
  ///
  /// In en, this message translates to:
  /// **'Products from this store'**
  String get marketProductsInStore;

  /// No description provided for @marketOrderingSoon.
  ///
  /// In en, this message translates to:
  /// **'Ordering and pickup are coming soon — for now, call or visit the store.'**
  String get marketOrderingSoon;

  /// No description provided for @marketWhereAreYou.
  ///
  /// In en, this message translates to:
  /// **'Where are you?'**
  String get marketWhereAreYou;

  /// No description provided for @marketPickOnMap.
  ///
  /// In en, this message translates to:
  /// **'Or tap the map to choose a location'**
  String get marketPickOnMap;

  /// No description provided for @marketUseThisPoint.
  ///
  /// In en, this message translates to:
  /// **'Use this point'**
  String get marketUseThisPoint;

  /// No description provided for @marketSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get marketSignIn;

  /// No description provided for @marketBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse the marketplace'**
  String get marketBrowse;

  /// No description provided for @marketNoSellers.
  ///
  /// In en, this message translates to:
  /// **'No sellers are offering this product right now.'**
  String get marketNoSellers;

  /// No description provided for @customerSignupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get customerSignupTitle;

  /// No description provided for @customerSignupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compare prices and find the nearest store for animal feeds, medicines and equipment.'**
  String get customerSignupSubtitle;

  /// No description provided for @customerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get customerNameLabel;

  /// No description provided for @customerPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get customerPhoneLabel;

  /// No description provided for @customerEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get customerEmailLabel;

  /// No description provided for @customerPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password (at least 8 characters)'**
  String get customerPasswordLabel;

  /// No description provided for @customerCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create customer account'**
  String get customerCreateAccount;

  /// No description provided for @customerSellInstead.
  ///
  /// In en, this message translates to:
  /// **'Selling animal products? Register your business'**
  String get customerSellInstead;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get accountTitle;

  /// No description provided for @accountOrdersSoon.
  ///
  /// In en, this message translates to:
  /// **'Your orders will appear here once ordering launches.'**
  String get accountOrdersSoon;

  /// No description provided for @accountDefaultLocation.
  ///
  /// In en, this message translates to:
  /// **'Default location'**
  String get accountDefaultLocation;

  /// No description provided for @accountLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get accountLogout;

  /// No description provided for @navMarket.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get navMarket;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @marketNear.
  ///
  /// In en, this message translates to:
  /// **'Near: {place}'**
  String marketNear(String place);

  /// No description provided for @marketNearestDistance.
  ///
  /// In en, this message translates to:
  /// **'Nearest {distance}'**
  String marketNearestDistance(String distance);

  /// No description provided for @marketAvailableQty.
  ///
  /// In en, this message translates to:
  /// **'{qty} available'**
  String marketAvailableQty(String qty);

  /// No description provided for @marketSellersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 seller} other{{count} sellers}}'**
  String marketSellersCount(int count);

  /// No description provided for @accountOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get accountOrders;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty.'**
  String get cartEmpty;

  /// No description provided for @cartAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get cartAdd;

  /// No description provided for @cartAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to your cart.'**
  String get cartAdded;

  /// No description provided for @cartView.
  ///
  /// In en, this message translates to:
  /// **'View cart'**
  String get cartView;

  /// No description provided for @cartQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get cartQuantity;

  /// No description provided for @cartTotalAtPickup.
  ///
  /// In en, this message translates to:
  /// **'Total to pay at pickup'**
  String get cartTotalAtPickup;

  /// No description provided for @cartPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone for the store to reach you'**
  String get cartPhone;

  /// No description provided for @cartNote.
  ///
  /// In en, this message translates to:
  /// **'Note to the store (optional)'**
  String get cartNote;

  /// No description provided for @cartPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order for pickup'**
  String get cartPlaceOrder;

  /// No description provided for @cartFixProblems.
  ///
  /// In en, this message translates to:
  /// **'Fix the highlighted items first.'**
  String get cartFixProblems;

  /// No description provided for @cartSignInToOrder.
  ///
  /// In en, this message translates to:
  /// **'Sign in with a customer account to order.'**
  String get cartSignInToOrder;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed. We\'ll notify you when the store accepts it.'**
  String get orderPlaced;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get ordersTitle;

  /// No description provided for @ordersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders yet.'**
  String get ordersEmpty;

  /// No description provided for @orderReference.
  ///
  /// In en, this message translates to:
  /// **'Order reference'**
  String get orderReference;

  /// No description provided for @orderCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get orderCancel;

  /// No description provided for @orderCancelHint.
  ///
  /// In en, this message translates to:
  /// **'You can cancel until the store starts preparing it.'**
  String get orderCancelHint;

  /// No description provided for @orderCancelReason.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get orderCancelReason;

  /// No description provided for @orderTotalPickup.
  ///
  /// In en, this message translates to:
  /// **'Total (pay at pickup)'**
  String get orderTotalPickup;

  /// No description provided for @orderTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get orderTimeline;

  /// No description provided for @orderItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get orderItems;

  /// No description provided for @orderUpdates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get orderUpdates;

  /// No description provided for @sellerOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Marketplace orders'**
  String get sellerOrdersTitle;

  /// No description provided for @sellerOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Accept, prepare and hand over customer orders'**
  String get sellerOrdersSubtitle;

  /// No description provided for @sellerOrdersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders here.'**
  String get sellerOrdersEmpty;

  /// No description provided for @ordersTabOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get ordersTabOpen;

  /// No description provided for @ordersTabNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get ordersTabNew;

  /// No description provided for @ordersTabReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ordersTabReady;

  /// No description provided for @ordersTabCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ordersTabCompleted;

  /// No description provided for @ordersTabClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get ordersTabClosed;

  /// No description provided for @orderCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get orderCustomer;

  /// No description provided for @orderActionAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept order'**
  String get orderActionAccept;

  /// No description provided for @orderActionPrepare.
  ///
  /// In en, this message translates to:
  /// **'Start preparing'**
  String get orderActionPrepare;

  /// No description provided for @orderActionReady.
  ///
  /// In en, this message translates to:
  /// **'Mark ready for pickup'**
  String get orderActionReady;

  /// No description provided for @orderActionComplete.
  ///
  /// In en, this message translates to:
  /// **'Collected — complete'**
  String get orderActionComplete;

  /// No description provided for @orderActionReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get orderActionReject;

  /// No description provided for @orderRejectReason.
  ///
  /// In en, this message translates to:
  /// **'Reason (sent to the customer)'**
  String get orderRejectReason;

  /// No description provided for @orderCompleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm the customer collected and paid? Stock will be deducted and the sale recorded.'**
  String get orderCompleteConfirm;

  /// No description provided for @dashboardNewOrders.
  ///
  /// In en, this message translates to:
  /// **'New orders'**
  String get dashboardNewOrders;

  /// No description provided for @dashboardReadyOrders.
  ///
  /// In en, this message translates to:
  /// **'Ready for pickup'**
  String get dashboardReadyOrders;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cartPickupAt.
  ///
  /// In en, this message translates to:
  /// **'Pickup at {store}'**
  String cartPickupAt(String store);

  /// No description provided for @cartManyStores.
  ///
  /// In en, this message translates to:
  /// **'Items from {count} stores become {count} orders — collect each at its store.'**
  String cartManyStores(int count);

  /// No description provided for @orderReadyBanner.
  ///
  /// In en, this message translates to:
  /// **'Ready for pickup! Show reference {reference} at the counter and pay there.'**
  String orderReadyBanner(String reference);

  /// No description provided for @aiAskAi.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get aiAskAi;

  /// No description provided for @aiSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what you need, e.g. feed for 200 broiler chicks'**
  String get aiSearchHint;

  /// No description provided for @aiPicksTitle.
  ///
  /// In en, this message translates to:
  /// **'AI picks for you'**
  String get aiPicksTitle;

  /// No description provided for @aiThinking.
  ///
  /// In en, this message translates to:
  /// **'Finding the right products in live stock…'**
  String get aiThinking;

  /// No description provided for @aiDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'AI suggestions can be wrong — check each product before you buy. Prices, stock and distances are live from the stores.'**
  String get aiDisclaimer;

  /// No description provided for @aiSearchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Ask AI is not available right now. Showing normal search results instead.'**
  String get aiSearchUnavailable;

  /// No description provided for @aiSearchLimited.
  ///
  /// In en, this message translates to:
  /// **'Ask AI is busy right now. Showing normal search results — please try again in a minute.'**
  String get aiSearchLimited;

  /// No description provided for @aiSearchRefused.
  ///
  /// In en, this message translates to:
  /// **'Ask AI can\'t help with that request. Try describing the animal product you need.'**
  String get aiSearchRefused;

  /// No description provided for @aiSignInToAsk.
  ///
  /// In en, this message translates to:
  /// **'Sign in to use Ask AI.'**
  String get aiSignInToAsk;

  /// No description provided for @aiClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get aiClear;

  /// No description provided for @aiOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Use AI to place order'**
  String get aiOrderButton;

  /// No description provided for @aiOrderBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Not sure what to buy?'**
  String get aiOrderBannerTitle;

  /// No description provided for @aiOrderBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Tell our AI what your animals need and it builds the order from stores near you.'**
  String get aiOrderBannerBody;

  /// No description provided for @aiOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'AI order assistant'**
  String get aiOrderTitle;

  /// No description provided for @aiOrderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell it what you need — English or Kiswahili.'**
  String get aiOrderSubtitle;

  /// No description provided for @aiOrderIntro.
  ///
  /// In en, this message translates to:
  /// **'Describe what you need and I\'ll put together a basket from stores near you. You check it, then confirm the order in your cart.'**
  String get aiOrderIntro;

  /// No description provided for @aiOrderExample1.
  ///
  /// In en, this message translates to:
  /// **'Feed for 200 broiler chicks for the first 2 weeks'**
  String get aiOrderExample1;

  /// No description provided for @aiOrderExample2.
  ///
  /// In en, this message translates to:
  /// **'Layers mash for 500 hens, the cheapest'**
  String get aiOrderExample2;

  /// No description provided for @aiOrderExample3.
  ///
  /// In en, this message translates to:
  /// **'Nahitaji chakula cha samaki tilapia'**
  String get aiOrderExample3;

  /// No description provided for @aiOrderHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. I have 200 broiler chicks, 1 week old…'**
  String get aiOrderHint;

  /// No description provided for @aiOrderSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get aiOrderSend;

  /// No description provided for @aiOrderStartOver.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get aiOrderStartOver;

  /// No description provided for @aiOrderChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking live stock…'**
  String get aiOrderChecking;

  /// No description provided for @aiOrderBasketTitle.
  ///
  /// In en, this message translates to:
  /// **'Proposed basket'**
  String get aiOrderBasketTitle;

  /// No description provided for @aiOrderPickupStores.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pickup store} other{{count} pickup stores}}'**
  String aiOrderPickupStores(int count);

  /// No description provided for @aiOrderTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get aiOrderTotal;

  /// No description provided for @aiOrderAvailable.
  ///
  /// In en, this message translates to:
  /// **'{quantity} available'**
  String aiOrderAvailable(String quantity);

  /// No description provided for @aiOrderRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get aiOrderRemove;

  /// No description provided for @aiOrderAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart & review order'**
  String get aiOrderAddToCart;

  /// No description provided for @aiOrderNothingOrdered.
  ///
  /// In en, this message translates to:
  /// **'Nothing is ordered until you confirm in your cart. AI suggestions can be wrong — check quantities first.'**
  String get aiOrderNothingOrdered;

  /// No description provided for @aiOrderSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your customer account to order with the AI assistant.'**
  String get aiOrderSignIn;

  /// No description provided for @aiOrderNotCustomer.
  ///
  /// In en, this message translates to:
  /// **'Only customer accounts can place marketplace orders. Seller and staff accounts cannot.'**
  String get aiOrderNotCustomer;

  /// No description provided for @aiOrderBusy.
  ///
  /// In en, this message translates to:
  /// **'The assistant is busy right now. Please try again in a minute.'**
  String get aiOrderBusy;

  /// No description provided for @aiOrderUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The assistant is not available right now. You can still search and add products to your cart yourself.'**
  String get aiOrderUnavailable;

  /// No description provided for @aiOrderRefused.
  ///
  /// In en, this message translates to:
  /// **'The assistant can\'t help with that. Tell it which animal products you need.'**
  String get aiOrderRefused;

  /// No description provided for @aiOrderAdded.
  ///
  /// In en, this message translates to:
  /// **'The AI basket is in your cart. Check it and confirm to place your order.'**
  String get aiOrderAdded;

  /// No description provided for @aiOrderSomeFailed.
  ///
  /// In en, this message translates to:
  /// **'Some items could not be added: {details}'**
  String aiOrderSomeFailed(String details);

  /// No description provided for @producerBy.
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String producerBy(String name);

  /// No description provided for @catalogProducerLabel.
  ///
  /// In en, this message translates to:
  /// **'Producer / factory'**
  String get catalogProducerLabel;

  /// No description provided for @catalogProducerNotListed.
  ///
  /// In en, this message translates to:
  /// **'Not listed / unknown'**
  String get catalogProducerNotListed;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on this phone: {details}. Check your internet connection and try again.'**
  String signInFailed(String details);

  /// No description provided for @photoTake.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get photoTake;

  /// No description provided for @photoChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get photoChoose;

  /// No description provided for @photoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get photoRemove;

  /// No description provided for @photoSaved.
  ///
  /// In en, this message translates to:
  /// **'Photo saved. Customers see it on the marketplace.'**
  String get photoSaved;

  /// No description provided for @photoFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not use the photo: {details}'**
  String photoFailed(String details);

  /// No description provided for @photoHintAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap to add a photo — customers see it on the marketplace'**
  String get photoHintAdd;

  /// No description provided for @photoHintChange.
  ///
  /// In en, this message translates to:
  /// **'Tap to change or remove the photo'**
  String get photoHintChange;

  /// No description provided for @orderDistanceTitle.
  ///
  /// In en, this message translates to:
  /// **'DISTANCE TO THE STORE'**
  String get orderDistanceTitle;

  /// No description provided for @orderDistanceFinding.
  ///
  /// In en, this message translates to:
  /// **'Finding your location…'**
  String get orderDistanceFinding;

  /// No description provided for @orderDistanceFromYou.
  ///
  /// In en, this message translates to:
  /// **'{distance} from you right now'**
  String orderDistanceFromYou(String distance);

  /// No description provided for @orderDistanceEta.
  ///
  /// In en, this message translates to:
  /// **'About {minutes} min by car or boda boda'**
  String orderDistanceEta(int minutes);

  /// No description provided for @orderDistanceAtStore.
  ///
  /// In en, this message translates to:
  /// **'You\'re at the store — show your order reference at the counter.'**
  String get orderDistanceAtStore;

  /// No description provided for @orderDistanceServiceOff.
  ///
  /// In en, this message translates to:
  /// **'Turn on location (GPS) to see how far the store is.'**
  String get orderDistanceServiceOff;

  /// No description provided for @orderDistanceNeedsPermission.
  ///
  /// In en, this message translates to:
  /// **'Allow location access to see how far the store is.'**
  String get orderDistanceNeedsPermission;

  /// No description provided for @orderDistanceFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get your location right now.'**
  String get orderDistanceFailed;

  /// No description provided for @orderDistanceRetry.
  ///
  /// In en, this message translates to:
  /// **'Turn on location'**
  String get orderDistanceRetry;

  /// No description provided for @orderDirections.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get orderDirections;

  /// No description provided for @marketNearestShort.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get marketNearestShort;

  /// No description provided for @marketSetLocationForDistance.
  ///
  /// In en, this message translates to:
  /// **'Set your location to see the distance'**
  String get marketSetLocationForDistance;

  /// No description provided for @receiptOpen.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receiptOpen;

  /// No description provided for @storeAll.
  ///
  /// In en, this message translates to:
  /// **'All my stores'**
  String get storeAll;

  /// No description provided for @posChooseStore.
  ///
  /// In en, this message translates to:
  /// **'Which store are you selling from?'**
  String get posChooseStore;

  /// No description provided for @posChooseStoreHint.
  ///
  /// In en, this message translates to:
  /// **'The till sells that store\'s stock and records the sale under it.'**
  String get posChooseStoreHint;

  /// No description provided for @staffStoreAccess.
  ///
  /// In en, this message translates to:
  /// **'Store access'**
  String get staffStoreAccess;

  /// No description provided for @staffAllStores.
  ///
  /// In en, this message translates to:
  /// **'All stores (now and future)'**
  String get staffAllStores;

  /// No description provided for @staffChooseStore.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one store, or turn on All stores.'**
  String get staffChooseStore;

  /// No description provided for @moreTransfersTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock transfers'**
  String get moreTransfersTitle;

  /// No description provided for @moreTransfersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send stock between your stores and receive it'**
  String get moreTransfersSubtitle;
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
