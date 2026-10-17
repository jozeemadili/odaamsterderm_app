import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../auth/data/auth_models.dart';

class MerchantSettingsRepository {
  MerchantSettingsRepository(this._client);

  final ApiClient _client;

  Future<DukaMerchant> get() async {
    final response = await _client.guard(() => _client.dio.get('/merchant'));
    return DukaMerchant.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }

  Future<DukaMerchant> update({
    String? businessName,
    String? ownerName,
    String? phone,
    int? businessTypeId,
    String? physicalAddress,
    int? regionId,
    String? city,
    String? brandColor,
  }) async {
    final response = await _client.guard(
      () => _client.dio.patch('/merchant', data: {
        if (businessName != null) 'business_name': businessName,
        if (ownerName != null) 'owner_name': ownerName,
        if (phone != null) 'phone': phone,
        'business_type_id': businessTypeId,
        'physical_address': physicalAddress,
        'region_id': regionId,
        'city': city,
        'brand_color': brandColor,
      }),
    );
    return DukaMerchant.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }

  Future<DukaMerchant> uploadLogo(File logo) async {
    final formData =
        FormData.fromMap({'logo': await MultipartFile.fromFile(logo.path)});
    final response = await _client
        .guard(() => _client.dio.post('/merchant/logo', data: formData));
    return DukaMerchant.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }
}
