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
  String get loginSubtitle => 'Sign in to your account';

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
  String get loginRegisterPrompt =>
      'Selling animal products? Register your business';

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

  @override
  String get storeEditTitle => 'Edit store';

  @override
  String get storeEmailLabel => 'Email (optional)';

  @override
  String get storeCityLabel => 'City / district';

  @override
  String get storeLocationTitle => 'Store location';

  @override
  String get storeLocationHint =>
      'Tap the map or use your current location to pin the store entrance.';

  @override
  String get storeUseMyLocation => 'Use my current location';

  @override
  String get storeLocationDenied =>
      'Location is off or permission was denied. Tap the map to place the pin.';

  @override
  String get storeNoLocation =>
      'No map location yet — customers can\'t find this store.';

  @override
  String get storeOpenInMaps => 'Open in Google Maps';

  @override
  String get storeOpeningHoursTitle => 'Opening hours';

  @override
  String get storeClosed => 'Closed';

  @override
  String get storePickupLabel => 'Pickup instructions for customers';

  @override
  String get storeMarketplaceSwitch => 'List this store on the marketplace';

  @override
  String get storeMarketplaceSwitchHint =>
      'Turn off to use this store for offline sales only.';

  @override
  String get storeOnMarketplace => 'On marketplace';

  @override
  String get storeMarketplaceOff => 'Marketplace off';

  @override
  String get storeSuspended => 'Suspended by the platform';

  @override
  String get storeSetLocationBadge => 'Set map location';

  @override
  String get storeSaved => 'Store details saved.';

  @override
  String get notSet => 'Not set';

  @override
  String get marketplaceTitle => 'Marketplace';

  @override
  String get marketplaceSubtitle => 'What customers can see and order online';

  @override
  String get marketplaceFilterAll => 'All';

  @override
  String get marketplaceFilterListed => 'Listed';

  @override
  String get marketplaceFilterHidden => 'Hidden';

  @override
  String get marketplaceFilterOutOfStock => 'Out of stock';

  @override
  String get marketplaceEmpty => 'No items here.';

  @override
  String get marketplaceListedProducts => 'Listed products';

  @override
  String get marketplaceUnitsExposed => 'Units online';

  @override
  String get marketplaceOutOfStockOnline => 'Out of stock online';

  @override
  String get marketplaceApprovalPending =>
      'Your business is awaiting marketplace approval — listings go live once approved.';

  @override
  String get catalogTitle => 'Product catalog';

  @override
  String get catalogSubtitle =>
      'Shared products customers compare across sellers';

  @override
  String get catalogSearchHint => 'Search the catalog';

  @override
  String get catalogPropose => 'Propose a product';

  @override
  String get catalogProposals => 'Your proposals';

  @override
  String get catalogPending => 'Waiting for review';

  @override
  String get catalogRejected => 'Rejected';

  @override
  String get catalogNotFound => 'Not in the catalog? Propose it for review.';

  @override
  String get catalogProposed =>
      'Product proposed. It goes live on the marketplace once approved.';

  @override
  String get catalogNameLabel => 'Product name';

  @override
  String get catalogPackSizeLabel => 'Pack size (e.g. 25KG)';

  @override
  String get catalogUnitLabel => 'Selling unit';

  @override
  String get catalogBrandLabel => 'Brand (if the producer is not listed)';

  @override
  String get catalogAnimalLabel => 'Animal type';

  @override
  String get catalogCategoryLabel => 'Category';

  @override
  String get catalogDescriptionLabel => 'Description (optional)';

  @override
  String get catalogSubmit => 'Submit for review';

  @override
  String get catalogPickTitle => 'Link to catalog product';

  @override
  String get catalogNoMatches => 'No catalog products match.';

  @override
  String get moreMarketplaceTitle => 'Marketplace';

  @override
  String get moreMarketplaceSubtitle =>
      'Visibility and quantities customers see';

  @override
  String get moreCatalogTitle => 'Product catalog';

  @override
  String get moreCatalogSubtitle =>
      'Browse shared products or propose new ones';

  @override
  String marketplaceStockLine(String online, String stock) {
    return '$online online · $stock in stock';
  }

  @override
  String get stockQuantityLabel => 'Stock quantity (units)';

  @override
  String get marketSearchHint => 'Search feeds, vaccines, medicines…';

  @override
  String get marketSetLocation => 'Set your location';

  @override
  String get marketSetLocationHint =>
      'Set your location to see the nearest stores and distances.';

  @override
  String get marketMyLocation => 'My location';

  @override
  String get marketAllAnimals => 'All animals';

  @override
  String get marketSortNearest => 'Nearest';

  @override
  String get marketSortPrice => 'Lowest price';

  @override
  String get marketSortAvailability => 'Most available';

  @override
  String get marketInStockOnly => 'Available now only';

  @override
  String get marketFrom => 'from';

  @override
  String get marketOutOfStock => 'Out of stock';

  @override
  String get marketAvailable => 'Available';

  @override
  String get marketNoProducts => 'No products match. Try another search.';

  @override
  String get marketStoresNearYou => 'Stores near you';

  @override
  String get marketStores => 'Stores';

  @override
  String get marketCompareSellers => 'Compare sellers';

  @override
  String get marketDirections => 'Directions';

  @override
  String get marketCall => 'Call';

  @override
  String get marketPickupPoint => 'Pickup point';

  @override
  String get marketProductsInStore => 'Products from this store';

  @override
  String get marketOrderingSoon =>
      'Ordering and pickup are coming soon — for now, call or visit the store.';

  @override
  String get marketWhereAreYou => 'Where are you?';

  @override
  String get marketPickOnMap => 'Or tap the map to choose a location';

  @override
  String get marketUseThisPoint => 'Use this point';

  @override
  String get marketSignIn => 'Sign in';

  @override
  String get marketBrowse => 'Browse the marketplace';

  @override
  String get marketNoSellers =>
      'No sellers are offering this product right now.';

  @override
  String get customerSignupTitle => 'Create your account';

  @override
  String get customerSignupSubtitle =>
      'Compare prices and find the nearest store for animal feeds, medicines and equipment.';

  @override
  String get customerNameLabel => 'Full name';

  @override
  String get customerPhoneLabel => 'Phone';

  @override
  String get customerEmailLabel => 'Email';

  @override
  String get customerPasswordLabel => 'Password (at least 8 characters)';

  @override
  String get customerCreateAccount => 'Create customer account';

  @override
  String get customerSellInstead =>
      'Selling animal products? Register your business';

  @override
  String get accountTitle => 'My account';

  @override
  String get accountOrdersSoon =>
      'Your orders will appear here once ordering launches.';

  @override
  String get accountDefaultLocation => 'Default location';

  @override
  String get accountLogout => 'Log out';

  @override
  String get navMarket => 'Market';

  @override
  String get navAccount => 'Account';

  @override
  String marketNear(String place) {
    return 'Near: $place';
  }

  @override
  String marketNearestDistance(String distance) {
    return 'Nearest $distance';
  }

  @override
  String marketAvailableQty(String qty) {
    return '$qty available';
  }

  @override
  String marketSellersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sellers',
      one: '1 seller',
    );
    return '$_temp0';
  }

  @override
  String get accountOrders => 'Orders';

  @override
  String get navCart => 'Cart';

  @override
  String get navOrders => 'Orders';

  @override
  String get cartTitle => 'Cart';

  @override
  String get cartEmpty => 'Your cart is empty.';

  @override
  String get cartAdd => 'Add to cart';

  @override
  String get cartAdded => 'Added to your cart.';

  @override
  String get cartView => 'View cart';

  @override
  String get cartQuantity => 'Quantity';

  @override
  String get cartTotalAtPickup => 'Total to pay at pickup';

  @override
  String get cartPhone => 'Phone for the store to reach you';

  @override
  String get cartNote => 'Note to the store (optional)';

  @override
  String get cartPlaceOrder => 'Place order for pickup';

  @override
  String get cartFixProblems => 'Fix the highlighted items first.';

  @override
  String get cartSignInToOrder => 'Sign in with a customer account to order.';

  @override
  String get orderPlaced =>
      'Order placed. We\'ll notify you when the store accepts it.';

  @override
  String get ordersTitle => 'My orders';

  @override
  String get ordersEmpty => 'No orders yet.';

  @override
  String get orderReference => 'Order reference';

  @override
  String get orderCancel => 'Cancel order';

  @override
  String get orderCancelHint =>
      'You can cancel until the store starts preparing it.';

  @override
  String get orderCancelReason => 'Reason (optional)';

  @override
  String get orderTotalPickup => 'Total (pay at pickup)';

  @override
  String get orderTimeline => 'Timeline';

  @override
  String get orderItems => 'Items';

  @override
  String get orderUpdates => 'Updates';

  @override
  String get sellerOrdersTitle => 'Marketplace orders';

  @override
  String get sellerOrdersSubtitle =>
      'Accept, prepare and hand over customer orders';

  @override
  String get sellerOrdersEmpty => 'No orders here.';

  @override
  String get ordersTabOpen => 'Open';

  @override
  String get ordersTabNew => 'New';

  @override
  String get ordersTabReady => 'Ready';

  @override
  String get ordersTabCompleted => 'Completed';

  @override
  String get ordersTabClosed => 'Closed';

  @override
  String get orderCustomer => 'Customer';

  @override
  String get orderActionAccept => 'Accept order';

  @override
  String get orderActionPrepare => 'Start preparing';

  @override
  String get orderActionReady => 'Mark ready for pickup';

  @override
  String get orderActionComplete => 'Collected — complete';

  @override
  String get orderActionReject => 'Reject';

  @override
  String get orderRejectReason => 'Reason (sent to the customer)';

  @override
  String get orderCompleteConfirm =>
      'Confirm the customer collected and paid? Stock will be deducted and the sale recorded.';

  @override
  String get dashboardNewOrders => 'New orders';

  @override
  String get dashboardReadyOrders => 'Ready for pickup';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String cartPickupAt(String store) {
    return 'Pickup at $store';
  }

  @override
  String cartManyStores(int count) {
    return 'Items from $count stores become $count orders — collect each at its store.';
  }

  @override
  String orderReadyBanner(String reference) {
    return 'Ready for pickup! Show reference $reference at the counter and pay there.';
  }

  @override
  String get aiAskAi => 'Ask AI';

  @override
  String get aiSearchHint =>
      'Describe what you need, e.g. feed for 200 broiler chicks';

  @override
  String get aiPicksTitle => 'AI picks for you';

  @override
  String get aiThinking => 'Finding the right products in live stock…';

  @override
  String get aiDisclaimer =>
      'AI suggestions can be wrong — check each product before you buy. Prices, stock and distances are live from the stores.';

  @override
  String get aiSearchUnavailable =>
      'Ask AI is not available right now. Showing normal search results instead.';

  @override
  String get aiSearchLimited =>
      'Ask AI is busy right now. Showing normal search results — please try again in a minute.';

  @override
  String get aiSearchRefused =>
      'Ask AI can\'t help with that request. Try describing the animal product you need.';

  @override
  String get aiSignInToAsk => 'Sign in to use Ask AI.';

  @override
  String get aiClear => 'Clear';

  @override
  String get aiOrderButton => 'Use AI to place order';

  @override
  String get aiOrderBannerTitle => 'Not sure what to buy?';

  @override
  String get aiOrderBannerBody =>
      'Tell our AI what your animals need and it builds the order from stores near you.';

  @override
  String get aiOrderTitle => 'AI order assistant';

  @override
  String get aiOrderSubtitle => 'Tell it what you need — English or Kiswahili.';

  @override
  String get aiOrderIntro =>
      'Describe what you need and I\'ll put together a basket from stores near you. You check it, then confirm the order in your cart.';

  @override
  String get aiOrderExample1 =>
      'Feed for 200 broiler chicks for the first 2 weeks';

  @override
  String get aiOrderExample2 => 'Layers mash for 500 hens, the cheapest';

  @override
  String get aiOrderExample3 => 'Nahitaji chakula cha samaki tilapia';

  @override
  String get aiOrderHint => 'e.g. I have 200 broiler chicks, 1 week old…';

  @override
  String get aiOrderSend => 'Send';

  @override
  String get aiOrderStartOver => 'Start over';

  @override
  String get aiOrderChecking => 'Checking live stock…';

  @override
  String get aiOrderBasketTitle => 'Proposed basket';

  @override
  String aiOrderPickupStores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pickup stores',
      one: '1 pickup store',
    );
    return '$_temp0';
  }

  @override
  String get aiOrderTotal => 'Total';

  @override
  String aiOrderAvailable(String quantity) {
    return '$quantity available';
  }

  @override
  String get aiOrderRemove => 'Remove';

  @override
  String get aiOrderAddToCart => 'Add to cart & review order';

  @override
  String get aiOrderNothingOrdered =>
      'Nothing is ordered until you confirm in your cart. AI suggestions can be wrong — check quantities first.';

  @override
  String get aiOrderSignIn =>
      'Sign in with your customer account to order with the AI assistant.';

  @override
  String get aiOrderNotCustomer =>
      'Only customer accounts can place marketplace orders. Seller and staff accounts cannot.';

  @override
  String get aiOrderBusy =>
      'The assistant is busy right now. Please try again in a minute.';

  @override
  String get aiOrderUnavailable =>
      'The assistant is not available right now. You can still search and add products to your cart yourself.';

  @override
  String get aiOrderRefused =>
      'The assistant can\'t help with that. Tell it which animal products you need.';

  @override
  String get aiOrderAdded =>
      'The AI basket is in your cart. Check it and confirm to place your order.';

  @override
  String aiOrderSomeFailed(String details) {
    return 'Some items could not be added: $details';
  }

  @override
  String producerBy(String name) {
    return 'by $name';
  }

  @override
  String get catalogProducerLabel => 'Producer / factory';

  @override
  String get catalogProducerNotListed => 'Not listed / unknown';

  @override
  String signInFailed(String details) {
    return 'Something went wrong on this phone: $details. Check your internet connection and try again.';
  }

  @override
  String get photoTake => 'Take a photo';

  @override
  String get photoChoose => 'Choose from gallery';

  @override
  String get photoRemove => 'Remove photo';

  @override
  String get photoSaved => 'Photo saved. Customers see it on the marketplace.';

  @override
  String photoFailed(String details) {
    return 'Could not use the photo: $details';
  }

  @override
  String get photoHintAdd =>
      'Tap to add a photo — customers see it on the marketplace';

  @override
  String get photoHintChange => 'Tap to change or remove the photo';

  @override
  String get orderDistanceTitle => 'DISTANCE TO THE STORE';

  @override
  String get orderDistanceFinding => 'Finding your location…';

  @override
  String orderDistanceFromYou(String distance) {
    return '$distance from you right now';
  }

  @override
  String orderDistanceEta(int minutes) {
    return 'About $minutes min by car or boda boda';
  }

  @override
  String get orderDistanceAtStore =>
      'You\'re at the store — show your order reference at the counter.';

  @override
  String get orderDistanceServiceOff =>
      'Turn on location (GPS) to see how far the store is.';

  @override
  String get orderDistanceNeedsPermission =>
      'Allow location access to see how far the store is.';

  @override
  String get orderDistanceFailed => 'Couldn\'t get your location right now.';

  @override
  String get orderDistanceRetry => 'Turn on location';

  @override
  String get orderDirections => 'Directions';

  @override
  String get marketNearestShort => 'Nearest';

  @override
  String get marketSetLocationForDistance =>
      'Set your location to see the distance';

  @override
  String get receiptOpen => 'Receipt';

  @override
  String get storeAll => 'All my stores';

  @override
  String get posChooseStore => 'Which store are you selling from?';

  @override
  String get posChooseStoreHint =>
      'The till sells that store\'s stock and records the sale under it.';

  @override
  String get staffStoreAccess => 'Store access';

  @override
  String get staffAllStores => 'All stores (now and future)';

  @override
  String get staffChooseStore =>
      'Choose at least one store, or turn on All stores.';
}
