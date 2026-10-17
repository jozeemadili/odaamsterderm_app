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
  String get loginSubtitle => 'Ingia kwenye duka lako';

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
  String get loginRegisterPrompt => 'Huna duka bado? Jisajili';

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
  String get catalogBrandLabel => 'Chapa (hiari)';

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
}
