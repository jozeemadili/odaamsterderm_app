import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import 'kyc_document_models.dart';

class KycDocumentRepository {
  KycDocumentRepository(this._client);

  final ApiClient _client;

  Future<List<KycDocument>> list() async {
    final response =
        await _client.guard(() => _client.dio.get('/kyc-documents'));
    final data = (response.data as Map<String, dynamic>)['data'] as List;
    return data
        .map((e) => KycDocument.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<KycDocument> upload(
      {required String documentType, required File file}) async {
    final formData = FormData.fromMap({
      'document_type': documentType,
      'file': await MultipartFile.fromFile(file.path),
    });
    final response = await _client
        .guard(() => _client.dio.post('/kyc-documents', data: formData));
    return KycDocument.fromJson((response.data as Map<String, dynamic>)['data']
        as Map<String, dynamic>);
  }
}
