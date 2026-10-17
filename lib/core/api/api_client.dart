import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Base URL for the DukaFlow v1 API. Override per build with:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8001/api/v1
/// (10.0.2.2 is how the Android emulator reaches the host machine's
/// localhost; use your Mac's LAN IP for a physical device against a local
/// `php artisan serve`.)
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://dukaflow-production-lfgbd3.laravel.cloud/api/v1',
);

/// Thin wrapper around Dio: attaches the bearer token to every request,
/// and normalizes Laravel's error JSON into [ApiException].
class ApiClient {
  ApiClient(this._tokenStorage) : dio = Dio(BaseOptions(baseUrl: apiBaseUrl)) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.read();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          handler.next(options);
        },
        onError: (error, handler) => handler.next(error),
      ),
    );
  }

  final Dio dio;
  final TokenStorage _tokenStorage;

  /// Runs [request] and converts any Dio error into an [ApiException].
  Future<Response<dynamic>> guard(
      Future<Response<dynamic>> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  /// Exposed for call sites that need to inspect a [DioException]'s response
  /// body themselves (e.g. a 422 that isn't a plain validation error) before
  /// deciding whether to fall back to the normal [ApiException] conversion.
  ApiException toApiException(DioException e) => _toApiException(e);

  ApiException _toApiException(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      final rawErrors = data['errors'];
      Map<String, List<String>>? errors;
      if (rawErrors is Map) {
        errors = rawErrors.map(
          (key, value) => MapEntry(
              key as String, (value as List).map((v) => v.toString()).toList()),
        );
      }

      return ApiException(
        message: (data['message'] as String?) ??
            e.message ??
            'Something went wrong.',
        errors: errors,
        statusCode: e.response?.statusCode,
      );
    }

    return ApiException(
      message:
          e.message ?? 'Could not reach the server. Check your connection.',
      statusCode: e.response?.statusCode,
    );
  }
}
