/// Reference-data option for the registration screen's "Business type"
/// dropdown — sourced from the backend so Super Admin can add/retire
/// options without an app release.
class BusinessTypeOption {
  BusinessTypeOption({required this.id, required this.name});

  factory BusinessTypeOption.fromJson(Map<String, dynamic> json) =>
      BusinessTypeOption(id: json['id'] as int, name: json['name'] as String);

  final int id;
  final String name;
}

/// Reference-data option for the registration screen's "Region" dropdown.
class RegionOption {
  RegionOption({required this.id, required this.name, this.code});

  factory RegionOption.fromJson(Map<String, dynamic> json) => RegionOption(
    id: json['id'] as int,
    name: json['name'] as String,
    code: json['code'] as String?,
  );

  final int id;
  final String name;
  final String? code;
}

class DukaUser {
  DukaUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.userType,
    this.role,
    this.roleLabel,
    this.merchantId,
    this.latitude,
    this.longitude,
    this.locationLabel,
  });

  factory DukaUser.fromJson(Map<String, dynamic> json) => DukaUser(
    id: json['id'] as int,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String?,
    userType: json['user_type'] as String,
    role: json['role'] as String?,
    roleLabel: json['role_label'] as String?,
    merchantId: json['merchant_id'] as int?,
    latitude: ((json['location'] as Map<String, dynamic>?)?['latitude'] as num?)
        ?.toDouble(),
    longitude:
        ((json['location'] as Map<String, dynamic>?)?['longitude'] as num?)
            ?.toDouble(),
    locationLabel:
        (json['location'] as Map<String, dynamic>?)?['label'] as String?,
  );

  final int id;
  final String name;
  final String email;
  final String? phone;
  final String userType;
  final String? role;
  final String? roleLabel;
  final int? merchantId;

  /// A marketplace customer's saved location (customers only).
  final double? latitude;
  final double? longitude;
  final String? locationLabel;

  /// Marketplace buyer (farmer, livestock keeper, retailer) — not a seller.
  bool get isCustomer => userType == 'customer';
}

class DukaMerchant {
  DukaMerchant({
    required this.id,
    required this.businessName,
    this.ownerName,
    this.phone,
    this.email,
    this.businessType,
    this.businessTypeId,
    this.physicalAddress,
    this.region,
    this.regionId,
    this.city,
    required this.kycStatus,
    required this.status,
    required this.brandColor,
    this.brandAccentColor = '#C9972E',
    this.brandTextColor = '#FFFFFF',
    this.brandAccentTextColor = '#01162F',
    this.logoUrl,
  });

  factory DukaMerchant.fromJson(Map<String, dynamic> json) => DukaMerchant(
    id: json['id'] as int,
    businessName: json['business_name'] as String,
    ownerName: json['owner_name'] as String?,
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    businessType: json['business_type'] as String?,
    businessTypeId: json['business_type_id'] as int?,
    physicalAddress: json['physical_address'] as String?,
    region: json['region'] as String?,
    regionId: json['region_id'] as int?,
    city: json['city'] as String?,
    kycStatus: json['kyc_status'] as String,
    status: json['status'] as String,
    brandColor: json['brand_color'] as String,
    brandAccentColor: json['brand_accent_color'] as String? ?? '#C9972E',
    brandTextColor: json['brand_text_color'] as String? ?? '#FFFFFF',
    brandAccentTextColor:
        json['brand_accent_text_color'] as String? ?? '#01162F',
    logoUrl: json['logo_url'] as String?,
  );

  final int id;
  final String businessName;
  final String? ownerName;
  final String? phone;
  final String? email;
  final String? businessType;
  final int? businessTypeId;
  final String? physicalAddress;
  final String? region;
  final int? regionId;
  final String? city;
  final String kycStatus;
  final String status;
  final String brandColor;

  /// Second brand colour (highlights, totals, floating button).
  final String brandAccentColor;

  /// Readable text on [brandColor] / [brandAccentColor] (worked out by the server).
  final String brandTextColor;
  final String brandAccentTextColor;
  final String? logoUrl;
}

/// Result of a successful login/register/Google sign-in.
class AuthSession {
  AuthSession({required this.token, required this.user, this.merchant});

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    token: json['token'] as String,
    user: DukaUser.fromJson(json['user'] as Map<String, dynamic>),
    merchant: json['merchant'] != null
        ? DukaMerchant.fromJson(json['merchant'] as Map<String, dynamic>)
        : null,
  );

  final String token;
  final DukaUser user;
  final DukaMerchant? merchant;
}

/// Returned by POST /auth/google when the Google account has no Odaamsterderm Hub
/// user yet — the app should show the registration form pre-filled with
/// these, then submit them via AuthRepository.register(googleId: ...).
class GoogleRegistrationRequired {
  GoogleRegistrationRequired({required this.googleId, this.email, this.name});

  factory GoogleRegistrationRequired.fromJson(Map<String, dynamic> json) =>
      GoogleRegistrationRequired(
        googleId: json['google_id'] as String,
        email: json['email'] as String?,
        name: json['name'] as String?,
      );

  final String googleId;
  final String? email;
  final String? name;
}
