// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get navDashboard => 'Dashibodi';

  @override
  String get navInventory => 'Bidhaa';

  @override
  String get navSell => 'Uza';

  @override
  String get navInvoices => 'Ankara';

  @override
  String get navMore => 'Zaidi';

  @override
  String get moreTitle => 'Zaidi';

  @override
  String get moreStockReceiptsTitle => 'Mapokezi ya bidhaa';

  @override
  String get moreStockReceiptsSubtitle =>
      'Rekodi mizigo iliyofika na uiongeze kwenye hisa';

  @override
  String get moreCustomersTitle => 'Wateja';

  @override
  String get moreCustomersSubtitle => 'Orodha, mauzo na historia ya ankara';

  @override
  String get moreSuppliersTitle => 'Wasambazaji';

  @override
  String get moreSuppliersSubtitle => 'Orodha na madeni yaliyobaki';

  @override
  String get moreExpensesTitle => 'Matumizi';

  @override
  String get moreExpensesSubtitle => 'Rekodi kodi, mishahara, huduma na zaidi';

  @override
  String get morePaymentsTitle => 'Malipo';

  @override
  String get morePaymentsSubtitle =>
      'Rekodi fedha taslimu zilizopokelewa, na uthibitisho wa malipo';

  @override
  String get moreSettingsTitle => 'Mipangilio ya duka';

  @override
  String get moreSettingsSubtitle =>
      'Wasifu wa biashara, wafanyakazi na hati za uthibitisho';

  @override
  String get shopSettingsTitle => 'Mipangilio ya duka';

  @override
  String get shopSettingsProfileTitle => 'Wasifu wa biashara';

  @override
  String get shopSettingsProfileSubtitle => 'Jina, mawasiliano, chapa';

  @override
  String get shopSettingsStaffTitle => 'Akaunti za wafanyakazi';

  @override
  String get shopSettingsStaffSubtitleOwner =>
      'Simamia nani anaweza kufikia duka hili';

  @override
  String get shopSettingsStaffSubtitleStaff => 'Kwa mmiliki tu';

  @override
  String get shopSettingsKycTitle => 'Hati za uthibitisho';

  @override
  String get shopSettingsKycSubtitle =>
      'Kitambulisho, leseni ya biashara, cheti cha TIN';

  @override
  String get shopSettingsLanguageTitle => 'Lugha';

  @override
  String get languagePickerTitle => 'Chagua lugha';

  @override
  String get languageEnglish => 'Kiingereza';

  @override
  String get languageKiswahili => 'Kiswahili';

  @override
  String get loginSubtitle => 'Ingia kwenye akaunti yako';

  @override
  String get loginGoogleNotConfigured =>
      'Kuingia kwa Google hakujawekwa kwa toleo hili bado.';

  @override
  String get loginGoogleNoIdToken => 'Google haikutoa ID token.';

  @override
  String get loginEmailLabel => 'Barua pepe';

  @override
  String get loginEmailValidator => 'Weka barua pepe yako';

  @override
  String get loginPasswordLabel => 'Nenosiri';

  @override
  String get loginPasswordValidator => 'Weka nenosiri lako';

  @override
  String get loginButton => 'Ingia';

  @override
  String get loginSigningIn => 'Inaingia…';

  @override
  String get loginContinueWithGoogle => 'Endelea na Google';

  @override
  String get loginRegisterPrompt =>
      'Unauza bidhaa za mifugo? Sajili biashara yako';

  @override
  String get registerTitle => 'Sajili biashara yako';

  @override
  String get registerBusinessNameLabel => 'Jina la biashara';

  @override
  String get registerOwnerNameLabel => 'Jina la mmiliki';

  @override
  String get registerPhoneLabel => 'Simu';

  @override
  String get registerRegionLabel => 'Mkoa';

  @override
  String get registerBusinessTypeLabel => 'Aina ya biashara';

  @override
  String get registerEmailLabel => 'Barua pepe';

  @override
  String get registerPasswordLabel => 'Nenosiri';

  @override
  String get registerRequiredValidator => 'Inahitajika';

  @override
  String get registerPasswordLengthValidator => 'Angalau herufi 8';

  @override
  String get registerButton => 'Fungua duka langu';

  @override
  String get registerWithGoogle => 'Jisajili na Google';

  @override
  String get registerOrDivider => 'au jisajili na barua pepe';

  @override
  String get selectBusinessType => 'Chagua aina ya biashara';

  @override
  String get selectRegion => 'Chagua mkoa';

  @override
  String dashboardLoadError(String error) {
    return 'Imeshindwa kupakia dashibodi.\n$error';
  }

  @override
  String get greetingMorning => 'Habari za asubuhi';

  @override
  String get greetingAfternoon => 'Habari za mchana';

  @override
  String get greetingEvening => 'Habari za jioni';

  @override
  String get greetingFallbackName => 'rafiki';

  @override
  String greetingMessage(String timeGreeting, String name) {
    return '$timeGreeting, $name';
  }

  @override
  String get periodWeek => 'Wiki';

  @override
  String get periodMonth => 'Mwezi';

  @override
  String get periodYear => 'Mwaka';

  @override
  String get periodLabelWeek => 'Siku 7 zilizopita';

  @override
  String get periodLabelMonth => 'Siku 30 zilizopita';

  @override
  String get periodLabelYear => 'Mwaka huu';

  @override
  String salesLabelPrefix(String period) {
    return 'MAUZO · $period';
  }

  @override
  String get expensesLabel => 'matumizi';

  @override
  String get legendSales => 'Mauzo';

  @override
  String get legendExpenses => 'Matumizi';

  @override
  String get noActivityYet => 'Bado hakuna shughuli';

  @override
  String get lowStockTitle => 'Hisa chache';

  @override
  String get expiringSoonTitle => 'Inakaribia kuisha muda';

  @override
  String get seeAll => 'Ona zote';

  @override
  String get statLowStock => 'Hisa chache';

  @override
  String get statExpiringSoon => 'Inakaribia kuisha muda';

  @override
  String get statUnverifiedPayments => 'Malipo yasiyothibitishwa';

  @override
  String get recentPayments => 'Malipo ya karibuni';

  @override
  String get noPaymentsRecorded => 'Bado hakuna malipo yaliyorekodiwa.';

  @override
  String get paymentStatusRecorded => 'Imerekodiwa';

  @override
  String get paymentStatusVerified => 'Imethibitishwa';

  @override
  String get paymentStatusFlagged => 'Imetiwa alama';

  @override
  String get profitLabel => 'Faida';

  @override
  String get unpaidTodayLabel => 'Deni la leo';

  @override
  String get unpaidTotalLabel => 'Jumla ya deni';

  @override
  String get stockValueCostLabel => 'Thamani ya hisa (gharama)';

  @override
  String get stockValueSellingLabel => 'Thamani ya hisa (mauzo)';

  @override
  String get expectedProfitLabel => 'Faida inayotarajiwa';

  @override
  String get totalStoresLabel => 'Maduka yote';

  @override
  String get storesTitle => 'Maduka';

  @override
  String get storeDetailProductsTitle => 'Bidhaa katika duka hili';

  @override
  String get noStoresYet => 'Bado hakuna maduka.';

  @override
  String get noProductsInStore => 'Bado hakuna bidhaa katika duka hili.';

  @override
  String get addStore => 'Ongeza duka';

  @override
  String get storeNameLabel => 'Jina la duka';

  @override
  String get storeAddressLabel => 'Anwani';

  @override
  String get storePhoneLabel => 'Simu';

  @override
  String get save => 'Hifadhi';

  @override
  String get moreProductPerformanceTitle => 'Ufanisi wa bidhaa';

  @override
  String get moreProductPerformanceSubtitle =>
      'Bidhaa zinazouzwa zaidi na zenye faida kubwa';

  @override
  String get todayCardTitle => 'Leo';

  @override
  String get storeEditTitle => 'Hariri duka';

  @override
  String get storeEmailLabel => 'Barua pepe (hiari)';

  @override
  String get storeCityLabel => 'Mji / wilaya';

  @override
  String get storeLocationTitle => 'Mahali duka lilipo';

  @override
  String get storeLocationHint =>
      'Gusa ramani au tumia mahali ulipo sasa kuweka alama kwenye mlango wa duka.';

  @override
  String get storeUseMyLocation => 'Tumia mahali nilipo sasa';

  @override
  String get storeLocationDenied =>
      'Mahali pamezimwa au ruhusa imekataliwa. Gusa ramani kuweka alama.';

  @override
  String get storeNoLocation =>
      'Hakuna mahali kwenye ramani bado — wateja hawawezi kupata duka hili.';

  @override
  String get storeOpenInMaps => 'Fungua kwenye Google Maps';

  @override
  String get storeOpeningHoursTitle => 'Saa za kufungua';

  @override
  String get storeClosed => 'Imefungwa';

  @override
  String get storePickupLabel => 'Maelekezo ya kuchukua mzigo kwa wateja';

  @override
  String get storeMarketplaceSwitch => 'Onyesha duka hili sokoni';

  @override
  String get storeMarketplaceSwitchHint =>
      'Zima ili kutumia duka hili kwa mauzo ya dukani pekee.';

  @override
  String get storeOnMarketplace => 'Liko sokoni';

  @override
  String get storeMarketplaceOff => 'Soko limezimwa';

  @override
  String get storeSuspended => 'Limesimamishwa na jukwaa';

  @override
  String get storeSetLocationBadge => 'Weka mahali kwenye ramani';

  @override
  String get storeSaved => 'Taarifa za duka zimehifadhiwa.';

  @override
  String get notSet => 'Haijawekwa';

  @override
  String get marketplaceTitle => 'Soko';

  @override
  String get marketplaceSubtitle =>
      'Wateja wanachoweza kuona na kuagiza mtandaoni';

  @override
  String get marketplaceFilterAll => 'Zote';

  @override
  String get marketplaceFilterListed => 'Zinaonekana';

  @override
  String get marketplaceFilterHidden => 'Zimefichwa';

  @override
  String get marketplaceFilterOutOfStock => 'Zimeisha';

  @override
  String get marketplaceEmpty => 'Hakuna bidhaa hapa.';

  @override
  String get marketplaceListedProducts => 'Bidhaa zilizo sokoni';

  @override
  String get marketplaceUnitsExposed => 'Idadi mtandaoni';

  @override
  String get marketplaceOutOfStockOnline => 'Zimeisha mtandaoni';

  @override
  String get marketplaceApprovalPending =>
      'Biashara yako inasubiri kuidhinishwa sokoni — bidhaa zitaonekana baada ya kuidhinishwa.';

  @override
  String get catalogTitle => 'Orodha ya bidhaa';

  @override
  String get catalogSubtitle =>
      'Bidhaa ambazo wateja hulinganisha kati ya wauzaji';

  @override
  String get catalogSearchHint => 'Tafuta kwenye orodha';

  @override
  String get catalogPropose => 'Pendekeza bidhaa';

  @override
  String get catalogProposals => 'Mapendekezo yako';

  @override
  String get catalogPending => 'Inasubiri kukaguliwa';

  @override
  String get catalogRejected => 'Imekataliwa';

  @override
  String get catalogNotFound => 'Haipo kwenye orodha? Ipendekeze ikaguliwe.';

  @override
  String get catalogProposed =>
      'Bidhaa imependekezwa. Itaonekana sokoni baada ya kuidhinishwa.';

  @override
  String get catalogNameLabel => 'Jina la bidhaa';

  @override
  String get catalogPackSizeLabel => 'Ukubwa wa kifurushi (mf. 25KG)';

  @override
  String get catalogUnitLabel => 'Kipimo cha kuuzia';

  @override
  String get catalogBrandLabel => 'Chapa (kama mzalishaji hayupo)';

  @override
  String get catalogAnimalLabel => 'Aina ya mnyama';

  @override
  String get catalogCategoryLabel => 'Kundi';

  @override
  String get catalogDescriptionLabel => 'Maelezo (hiari)';

  @override
  String get catalogSubmit => 'Tuma ikaguliwe';

  @override
  String get catalogPickTitle => 'Unganisha na bidhaa ya orodha';

  @override
  String get catalogNoMatches => 'Hakuna bidhaa inayolingana.';

  @override
  String get moreMarketplaceTitle => 'Soko';

  @override
  String get moreMarketplaceSubtitle => 'Bidhaa na idadi wanazoona wateja';

  @override
  String get moreCatalogTitle => 'Orodha ya bidhaa';

  @override
  String get moreCatalogSubtitle => 'Angalia bidhaa au pendekeza mpya';

  @override
  String marketplaceStockLine(String online, String stock) {
    return '$online mtandaoni · $stock stoo';
  }

  @override
  String get stockQuantityLabel => 'Idadi ya mzigo stoo';

  @override
  String get marketSearchHint => 'Tafuta chakula, chanjo, dawa…';

  @override
  String get marketSetLocation => 'Weka mahali ulipo';

  @override
  String get marketSetLocationHint =>
      'Weka mahali ulipo kuona maduka yaliyo karibu na umbali wake.';

  @override
  String get marketMyLocation => 'Mahali nilipo';

  @override
  String get marketAllAnimals => 'Wanyama wote';

  @override
  String get marketSortNearest => 'Karibu zaidi';

  @override
  String get marketSortPrice => 'Bei ya chini';

  @override
  String get marketSortAvailability => 'Zinazopatikana zaidi';

  @override
  String get marketInStockOnly => 'Zinazopatikana sasa tu';

  @override
  String get marketFrom => 'kuanzia';

  @override
  String get marketOutOfStock => 'Imeisha';

  @override
  String get marketAvailable => 'Inapatikana';

  @override
  String get marketNoProducts =>
      'Hakuna bidhaa zinazolingana. Jaribu kutafuta tena.';

  @override
  String get marketStoresNearYou => 'Maduka karibu nawe';

  @override
  String get marketStores => 'Maduka';

  @override
  String get marketCompareSellers => 'Linganisha wauzaji';

  @override
  String get marketDirections => 'Njia';

  @override
  String get marketCall => 'Piga simu';

  @override
  String get marketPickupPoint => 'Mahali pa kuchukua';

  @override
  String get marketProductsInStore => 'Bidhaa za duka hili';

  @override
  String get marketOrderingSoon =>
      'Kuagiza na kuchukua kunakuja hivi karibuni — kwa sasa piga simu au tembelea duka.';

  @override
  String get marketWhereAreYou => 'Uko wapi?';

  @override
  String get marketPickOnMap => 'Au gusa ramani kuchagua mahali';

  @override
  String get marketUseThisPoint => 'Tumia mahali hapa';

  @override
  String get marketSignIn => 'Ingia';

  @override
  String get marketBrowse => 'Tazama soko';

  @override
  String get marketNoSellers => 'Hakuna muuzaji anayeuza bidhaa hii kwa sasa.';

  @override
  String get customerSignupTitle => 'Fungua akaunti yako';

  @override
  String get customerSignupSubtitle =>
      'Linganisha bei na upate duka lililo karibu kwa chakula cha mifugo, dawa na vifaa.';

  @override
  String get customerNameLabel => 'Jina kamili';

  @override
  String get customerPhoneLabel => 'Simu';

  @override
  String get customerEmailLabel => 'Barua pepe';

  @override
  String get customerPasswordLabel => 'Nenosiri (angalau herufi 8)';

  @override
  String get customerCreateAccount => 'Fungua akaunti ya mteja';

  @override
  String get customerSellInstead =>
      'Unauza bidhaa za mifugo? Sajili biashara yako';

  @override
  String get accountTitle => 'Akaunti yangu';

  @override
  String get accountOrdersSoon => 'Oda zako zitaonekana hapa kuagiza kukianza.';

  @override
  String get accountDefaultLocation => 'Mahali pa kawaida';

  @override
  String get accountLogout => 'Toka';

  @override
  String get navMarket => 'Soko';

  @override
  String get navAccount => 'Akaunti';

  @override
  String marketNear(String place) {
    return 'Karibu na: $place';
  }

  @override
  String marketNearestDistance(String distance) {
    return 'Karibu $distance';
  }

  @override
  String marketAvailableQty(String qty) {
    return '$qty zinapatikana';
  }

  @override
  String marketSellersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'wauzaji $count',
      one: 'muuzaji 1',
    );
    return '$_temp0';
  }

  @override
  String get accountOrders => 'Oda';

  @override
  String get navCart => 'Kikapu';

  @override
  String get navOrders => 'Oda';

  @override
  String get cartTitle => 'Kikapu';

  @override
  String get cartEmpty => 'Kikapu chako ni tupu.';

  @override
  String get cartAdd => 'Weka kikapuni';

  @override
  String get cartAdded => 'Imewekwa kikapuni.';

  @override
  String get cartView => 'Ona kikapu';

  @override
  String get cartQuantity => 'Idadi';

  @override
  String get cartTotalAtPickup => 'Jumla ya kulipa unapochukua';

  @override
  String get cartPhone => 'Simu ya duka kukupigia';

  @override
  String get cartNote => 'Ujumbe kwa duka (hiari)';

  @override
  String get cartPlaceOrder => 'Weka oda ya kuchukua';

  @override
  String get cartFixProblems => 'Rekebisha bidhaa zilizowekwa alama kwanza.';

  @override
  String get cartSignInToOrder => 'Ingia kwa akaunti ya mteja ili kuagiza.';

  @override
  String get orderPlaced => 'Oda imewekwa. Tutakujulisha duka likiikubali.';

  @override
  String get ordersTitle => 'Oda zangu';

  @override
  String get ordersEmpty => 'Bado hakuna oda.';

  @override
  String get orderReference => 'Namba ya oda';

  @override
  String get orderCancel => 'Ghairi oda';

  @override
  String get orderCancelHint => 'Unaweza kughairi hadi duka lianze kuiandaa.';

  @override
  String get orderCancelReason => 'Sababu (hiari)';

  @override
  String get orderTotalPickup => 'Jumla (lipa unapochukua)';

  @override
  String get orderTimeline => 'Hatua';

  @override
  String get orderItems => 'Bidhaa';

  @override
  String get orderUpdates => 'Taarifa';

  @override
  String get sellerOrdersTitle => 'Oda za sokoni';

  @override
  String get sellerOrdersSubtitle => 'Kubali, andaa na kabidhi oda za wateja';

  @override
  String get sellerOrdersEmpty => 'Hakuna oda hapa.';

  @override
  String get ordersTabOpen => 'Zinazoendelea';

  @override
  String get ordersTabNew => 'Mpya';

  @override
  String get ordersTabReady => 'Tayari';

  @override
  String get ordersTabCompleted => 'Zimekamilika';

  @override
  String get ordersTabClosed => 'Zimefungwa';

  @override
  String get orderCustomer => 'Mteja';

  @override
  String get orderActionAccept => 'Kubali oda';

  @override
  String get orderActionPrepare => 'Anza kuandaa';

  @override
  String get orderActionReady => 'Weka tayari kuchukuliwa';

  @override
  String get orderActionComplete => 'Imechukuliwa — kamilisha';

  @override
  String get orderActionReject => 'Kataa';

  @override
  String get orderRejectReason => 'Sababu (itatumwa kwa mteja)';

  @override
  String get orderCompleteConfirm =>
      'Thibitisha mteja amechukua na kulipa? Mzigo utapunguzwa na mauzo yatarekodiwa.';

  @override
  String get dashboardNewOrders => 'Oda mpya';

  @override
  String get dashboardReadyOrders => 'Tayari kuchukuliwa';

  @override
  String get confirm => 'Thibitisha';

  @override
  String get cancel => 'Ghairi';

  @override
  String cartPickupAt(String store) {
    return 'Chukua $store';
  }

  @override
  String cartManyStores(int count) {
    return 'Bidhaa kutoka maduka $count zitakuwa oda $count — chukua kila moja dukani kwake.';
  }

  @override
  String orderReadyBanner(String reference) {
    return 'Iko tayari! Onyesha namba $reference kaunta na ulipe hapo.';
  }

  @override
  String get aiAskAi => 'Uliza AI';

  @override
  String get aiSearchHint =>
      'Eleza unachohitaji, mfano chakula cha vifaranga 200';

  @override
  String get aiPicksTitle => 'Mapendekezo ya AI';

  @override
  String get aiThinking => 'Inatafuta bidhaa zinazofaa kwenye stoo…';

  @override
  String get aiDisclaimer =>
      'Mapendekezo ya AI yanaweza kukosea — hakiki kila bidhaa kabla ya kununua. Bei, stoo na umbali ni vya sasa kutoka madukani.';

  @override
  String get aiSearchUnavailable =>
      'Uliza AI haipatikani sasa. Tunaonyesha matokeo ya kawaida.';

  @override
  String get aiSearchLimited =>
      'Uliza AI ina shughuli nyingi sasa. Tunaonyesha matokeo ya kawaida — jaribu tena baada ya dakika moja.';

  @override
  String get aiSearchRefused =>
      'Uliza AI haiwezi kusaidia ombi hilo. Eleza bidhaa ya mifugo unayohitaji.';

  @override
  String get aiSignInToAsk => 'Ingia ili kutumia Uliza AI.';

  @override
  String get aiClear => 'Futa';

  @override
  String get aiOrderButton => 'Tumia AI kuagiza';

  @override
  String get aiOrderBannerTitle => 'Hujui ununue nini?';

  @override
  String get aiOrderBannerBody =>
      'Iambie AI mifugo yako inahitaji nini, nayo itaandaa oda kutoka maduka yaliyo karibu nawe.';

  @override
  String get aiOrderTitle => 'Msaidizi wa oda wa AI';

  @override
  String get aiOrderSubtitle =>
      'Ieleze unachohitaji — Kiingereza au Kiswahili.';

  @override
  String get aiOrderIntro =>
      'Eleza unachohitaji nami nitaandaa kikapu kutoka maduka yaliyo karibu nawe. Utakihakiki, kisha uthibitishe oda kwenye kikapu chako.';

  @override
  String get aiOrderExample1 =>
      'Chakula cha vifaranga 200 vya nyama kwa wiki 2 za kwanza';

  @override
  String get aiOrderExample2 => 'Layers mash kwa kuku 500, bei nafuu zaidi';

  @override
  String get aiOrderExample3 => 'Nahitaji chakula cha samaki tilapia';

  @override
  String get aiOrderHint => 'mfano Nina vifaranga 200 vya wiki moja…';

  @override
  String get aiOrderSend => 'Tuma';

  @override
  String get aiOrderStartOver => 'Anza upya';

  @override
  String get aiOrderChecking => 'Inaangalia stoo…';

  @override
  String get aiOrderBasketTitle => 'Kikapu kilichopendekezwa';

  @override
  String aiOrderPickupStores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Maduka $count ya kuchukulia',
      one: 'Duka 1 la kuchukulia',
    );
    return '$_temp0';
  }

  @override
  String get aiOrderTotal => 'Jumla';

  @override
  String aiOrderAvailable(String quantity) {
    return '$quantity zinapatikana';
  }

  @override
  String get aiOrderRemove => 'Ondoa';

  @override
  String get aiOrderAddToCart => 'Weka kwenye kikapu na hakiki oda';

  @override
  String get aiOrderNothingOrdered =>
      'Hakuna kinachoagizwa hadi uthibitishe kwenye kikapu. Mapendekezo ya AI yanaweza kukosea — hakiki idadi kwanza.';

  @override
  String get aiOrderSignIn =>
      'Ingia kwa akaunti yako ya mteja ili kuagiza kwa msaidizi wa AI.';

  @override
  String get aiOrderNotCustomer =>
      'Ni akaunti za wateja pekee zinazoweza kuagiza sokoni. Akaunti za wauzaji na wafanyakazi haziwezi.';

  @override
  String get aiOrderBusy =>
      'Msaidizi ana shughuli nyingi sasa. Tafadhali jaribu tena baada ya dakika moja.';

  @override
  String get aiOrderUnavailable =>
      'Msaidizi hapatikani sasa. Bado unaweza kutafuta na kuweka bidhaa kwenye kikapu mwenyewe.';

  @override
  String get aiOrderRefused =>
      'Msaidizi hawezi kusaidia hilo. Mweleze bidhaa za mifugo unazohitaji.';

  @override
  String get aiOrderAdded =>
      'Kikapu cha AI kiko kwenye kikapu chako. Kihakiki na uthibitishe ili kuweka oda.';

  @override
  String aiOrderSomeFailed(String details) {
    return 'Baadhi ya bidhaa hazikuweza kuongezwa: $details';
  }

  @override
  String producerBy(String name) {
    return 'na $name';
  }

  @override
  String get catalogProducerLabel => 'Mzalishaji / kiwanda';

  @override
  String get catalogProducerNotListed => 'Hayupo kwenye orodha / haijulikani';

  @override
  String signInFailed(String details) {
    return 'Hitilafu imetokea kwenye simu hii: $details. Hakikisha una intaneti kisha jaribu tena.';
  }

  @override
  String get photoTake => 'Piga picha';

  @override
  String get photoChoose => 'Chagua kutoka kwenye picha';

  @override
  String get photoRemove => 'Ondoa picha';

  @override
  String get photoSaved => 'Picha imehifadhiwa. Wateja wanaiona sokoni.';

  @override
  String photoFailed(String details) {
    return 'Imeshindikana kutumia picha: $details';
  }

  @override
  String get photoHintAdd => 'Gusa kuongeza picha — wateja wanaiona sokoni';

  @override
  String get photoHintChange => 'Gusa kubadilisha au kuondoa picha';

  @override
  String get orderDistanceTitle => 'UMBALI HADI DUKANI';

  @override
  String get orderDistanceFinding => 'Inatafuta mahali ulipo…';

  @override
  String orderDistanceFromYou(String distance) {
    return '$distance kutoka ulipo sasa';
  }

  @override
  String orderDistanceEta(int minutes) {
    return 'Takriban dakika $minutes kwa gari au bodaboda';
  }

  @override
  String get orderDistanceAtStore =>
      'Umefika dukani — onyesha namba ya oda yako kaunta.';

  @override
  String get orderDistanceServiceOff =>
      'Washa GPS (mahali) kuona umbali wa duka.';

  @override
  String get orderDistanceNeedsPermission =>
      'Ruhusu mahali kuona umbali wa duka.';

  @override
  String get orderDistanceFailed => 'Imeshindikana kupata mahali ulipo sasa.';

  @override
  String get orderDistanceRetry => 'Washa mahali';

  @override
  String get orderDirections => 'Maelekezo';

  @override
  String get marketNearestShort => 'Karibu zaidi';

  @override
  String get marketSetLocationForDistance => 'Weka mahali ulipo kuona umbali';

  @override
  String get receiptOpen => 'Risiti';

  @override
  String get storeAll => 'Maduka yangu yote';

  @override
  String get posChooseStore => 'Unauza kutoka duka gani?';

  @override
  String get posChooseStoreHint =>
      'Mauzo yatatoka kwenye stoo ya duka hilo na kurekodiwa kwake.';

  @override
  String get staffStoreAccess => 'Ruhusa ya maduka';

  @override
  String get staffAllStores => 'Maduka yote (sasa na ya baadaye)';

  @override
  String get staffChooseStore =>
      'Chagua angalau duka moja, au washa Maduka yote.';
}
