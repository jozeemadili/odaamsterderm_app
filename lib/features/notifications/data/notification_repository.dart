import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import 'notification_models.dart';

class NotificationRepository {
  NotificationRepository(this._client);

  final ApiClient _client;

  Future<NotificationsFeed> feed() async {
    final response = await _client.guard(() => _client.dio.get('/notifications'));
    return NotificationsFeed.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DamageReport> reportDamage({
    required int inventoryItemId,
    required double quantity,
    String? description,
    File? photo,
  }) async {
    final formData = FormData.fromMap({
      'inventory_item_id': inventoryItemId,
      'quantity': quantity,
      if (description != null && description.isNotEmpty) 'description': description,
      if (photo != null) 'photo': await MultipartFile.fromFile(photo.path),
    });
    final response = await _client.guard(() => _client.dio.post('/damage-reports', data: formData));
    return DamageReport.fromJson((response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }
}
